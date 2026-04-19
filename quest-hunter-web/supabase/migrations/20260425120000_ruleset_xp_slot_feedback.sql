-- Ruleset alignment: progressive hint XP (−5% / −10% / −20% per tier vs base),
-- wrong-answer stacking (−2% per wrong attempt on this puzzle),
-- clean-solve bonus (+5% when no hints and no wrong attempts),
-- optional near-miss copy per puzzle (wrongFeedback),
-- preFinale payload + ack RPC for structured slot screen,
-- finale XP path multipliers + hiddenAxes tally in progress.state.

create or replace function public.quest_xp_hint_factor(p_hints_used int)
returns numeric
language plpgsql
immutable
as $$
declare
  i int;
  p numeric := 1;
  tier_factor numeric;
begin
  if p_hints_used is null or p_hints_used <= 0 then
    return 1::numeric;
  end if;
  for i in 1..p_hints_used loop
    tier_factor := case i
      when 1 then 0.95::numeric
      when 2 then 0.90::numeric
      when 3 then 0.80::numeric
      else 0.80::numeric
    end;
    p := p * tier_factor;
  end loop;
  return p;
end;
$$;

create or replace function public.get_player_quest_payload(p_quest_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb := '[]'::jsonb;
  lv int;
  nx timestamptz;
begin
  if uid is null then
    return jsonb_build_object('error', 'auth');
  end if;

  select out_lives, out_next_at into lv, nx from public.refresh_profile_lives(uid);

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('error', 'not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('error', 'not_available');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('error', 'not_available');
  end if;

  b := q.body;

  select coalesce(
           (
             select jsonb_agg(
                      (e - 'answer' - 'xp' - 'hint' - 'hints' - 'wrongFeedback')
                      || jsonb_build_object(
                           'hintCount',
                           case
                             when e ? 'hints'
                               and jsonb_typeof(e -> 'hints') = 'array'
                               and jsonb_array_length(coalesce(e -> 'hints', '[]'::jsonb)) > 0
                               then jsonb_array_length(e -> 'hints')
                             when coalesce(trim(e ->> 'hint'), '') <> '' then 1
                             else 0
                           end
                         )
                    )
               from (
                      select jsonb_array_elements(coalesce(b -> 'puzzles', '[]'::jsonb)) as e
                    ) as elems
           ),
           '[]'::jsonb
         )
    into puzzles;

  return jsonb_build_object(
    'intro', coalesce(b ->> 'intro', ''),
    'puzzles', puzzles,
    'finalePrompt', coalesce(b ->> 'finalePrompt', ''),
    'preFinale', case when b ? 'preFinale' then b -> 'preFinale' else null end,
    'ui', coalesce(b -> 'ui', '{}'::jsonb),
    'lives', coalesce(lv, 0),
    'livesMax', 5,
    'nextLifeAt', to_jsonb(nx)
  );
end;
$$;

create or replace function public.peek_revealed_puzzle_hints(p_quest_id uuid, p_puzzle_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb;
  puzzle_count int;
  prog_step int;
  done_at timestamptz;
  failed_at timestamptz;
  state jsonb;
  elem jsonb;
  hints_arr jsonb := '[]'::jsonb;
  max_hints int := 0;
  used int := 0;
  i int;
  acc jsonb := '[]'::jsonb;
  xp_base int;
  xp_proj int;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  insert into public.user_quest_progress (user_id, quest_id, step, state, started_at)
  values (uid, p_quest_id, 0, '{}'::jsonb, now())
  on conflict (user_id, quest_id) do nothing;

  select u.step, u.completed_at, u.failed_at, coalesce(u.state, '{}'::jsonb)
    into prog_step, done_at, failed_at, state
    from public.user_quest_progress u
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
  end if;

  if failed_at is not null then
    return jsonb_build_object('ok', false, 'error', 'quest_failed');
  end if;

  prog_step := coalesce(prog_step, 0);

  b := q.body;
  puzzles := coalesce(b -> 'puzzles', '[]'::jsonb);
  puzzle_count := jsonb_array_length(puzzles);

  if puzzle_count = 0 then
    return jsonb_build_object('ok', false, 'error', 'no_puzzles');
  end if;

  if prog_step >= puzzle_count then
    return jsonb_build_object('ok', false, 'error', 'finale_next');
  end if;

  elem := puzzles -> prog_step;

  if (elem ->> 'id') is distinct from p_puzzle_id then
    return jsonb_build_object('ok', false, 'error', 'wrong_puzzle');
  end if;

  if elem ? 'hints'
     and jsonb_typeof(elem -> 'hints') = 'array'
     and jsonb_array_length(coalesce(elem -> 'hints', '[]'::jsonb)) > 0 then
    hints_arr := elem -> 'hints';
  elsif coalesce(trim(elem ->> 'hint'), '') <> '' then
    hints_arr := jsonb_build_array(trim(elem ->> 'hint'));
  else
    hints_arr := '[]'::jsonb;
  end if;

  max_hints := jsonb_array_length(hints_arr);

  used := coalesce(nullif(trim(state -> 'hintsUsed' ->> p_puzzle_id), '')::int, 0);
  if used < 0 then used := 0; end if;
  if used > max_hints then used := max_hints; end if;

  if max_hints = 0 then
    return jsonb_build_object(
      'ok', true,
      'hints', '[]'::jsonb,
      'tier', 0,
      'total', 0,
      'baseXp', coalesce(nullif(elem ->> 'xp', '')::int, 25),
      'projectedXp', coalesce(nullif(elem ->> 'xp', '')::int, 25),
      'hintTierPercents', '[5,10,20]'::jsonb
    );
  end if;

  i := 0;
  while i < used loop
    acc := acc || jsonb_build_array(hints_arr -> i);
    i := i + 1;
  end loop;

  xp_base := coalesce(nullif(elem ->> 'xp', '')::int, 25);
  xp_proj := greatest(1, floor(xp_base * public.quest_xp_hint_factor(used)));

  return jsonb_build_object(
    'ok', true,
    'hints', acc,
    'tier', used,
    'total', max_hints,
    'baseXp', xp_base,
    'projectedXp', xp_proj,
    'hintTierPercents', '[5,10,20]'::jsonb
  );
end;
$$;

create or replace function public.reveal_puzzle_hint(p_quest_id uuid, p_puzzle_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb;
  puzzle_count int;
  prog_step int;
  done_at timestamptz;
  failed_at timestamptz;
  state jsonb;
  elem jsonb;
  hints_arr jsonb := '[]'::jsonb;
  max_hints int := 0;
  used int := 0;
  new_used int;
  hint_text text;
  xp_base int;
  xp_proj int;
  hints_used_obj jsonb;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  insert into public.user_quest_progress (user_id, quest_id, step, state, started_at)
  values (uid, p_quest_id, 0, '{}'::jsonb, now())
  on conflict (user_id, quest_id) do nothing;

  select u.step, u.completed_at, u.failed_at, coalesce(u.state, '{}'::jsonb)
    into prog_step, done_at, failed_at, state
    from public.user_quest_progress u
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
  end if;

  if failed_at is not null then
    return jsonb_build_object('ok', false, 'error', 'quest_failed');
  end if;

  prog_step := coalesce(prog_step, 0);

  b := q.body;
  puzzles := coalesce(b -> 'puzzles', '[]'::jsonb);
  puzzle_count := jsonb_array_length(puzzles);

  if puzzle_count = 0 then
    return jsonb_build_object('ok', false, 'error', 'no_puzzles');
  end if;

  if prog_step >= puzzle_count then
    return jsonb_build_object('ok', false, 'error', 'finale_next');
  end if;

  elem := puzzles -> prog_step;

  if (elem ->> 'id') is distinct from p_puzzle_id then
    return jsonb_build_object('ok', false, 'error', 'wrong_puzzle');
  end if;

  if elem ? 'hints'
     and jsonb_typeof(elem -> 'hints') = 'array'
     and jsonb_array_length(coalesce(elem -> 'hints', '[]'::jsonb)) > 0 then
    hints_arr := elem -> 'hints';
  elsif coalesce(trim(elem ->> 'hint'), '') <> '' then
    hints_arr := jsonb_build_array(trim(elem ->> 'hint'));
  else
    hints_arr := '[]'::jsonb;
  end if;

  max_hints := jsonb_array_length(hints_arr);

  if max_hints = 0 then
    return jsonb_build_object('ok', false, 'error', 'no_hints');
  end if;

  used := coalesce(nullif(trim(state -> 'hintsUsed' ->> p_puzzle_id), '')::int, 0);
  if used < 0 then used := 0; end if;

  if used >= max_hints then
    return jsonb_build_object('ok', false, 'error', 'all_hints_revealed');
  end if;

  new_used := used + 1;
  hint_text := hints_arr ->> (new_used - 1);

  hints_used_obj := coalesce(state -> 'hintsUsed', '{}'::jsonb)
    || jsonb_build_object(p_puzzle_id, new_used);

  update public.user_quest_progress u
     set state = jsonb_set(u.state, '{hintsUsed}', hints_used_obj, true),
         updated_at = now()
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  xp_base := coalesce(nullif(elem ->> 'xp', '')::int, 25);
  xp_proj := greatest(1, floor(xp_base * public.quest_xp_hint_factor(new_used)));

  return jsonb_build_object(
    'ok', true,
    'hint', hint_text,
    'tier', new_used,
    'total', max_hints,
    'baseXp', xp_base,
    'projectedXp', xp_proj,
    'hintTierPercents', '[5,10,20]'::jsonb
  );
end;
$$;

create or replace function public.submit_puzzle_answer(
  p_quest_id uuid,
  p_puzzle_id text,
  p_attempt text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb;
  puzzle_count int;
  prog_step int;
  done_at timestamptz;
  failed_at timestamptz;
  state jsonb;
  elem jsonb;
  expected text;
  norm_attempt text := public.normalize_answer(p_attempt);
  xp_piece int;
  xp_base int;
  hints_used int := 0;
  wrong_prev int := 0;
  wrong_new int := 0;
  hint_factor numeric;
  wrong_factor numeric;
  near_text text;
  is_single boolean := false;
  is_fatal boolean := false;
  already_attempted boolean := false;
  cur_lives int;
  cur_next timestamptz;
  life_after int;
  next_after timestamptz;
  max_l constant int := 5;
  regen constant interval := interval '5 minutes';
  hints_used_clean jsonb;
  wrong_used_clean jsonb;
  clean_bonus boolean := false;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  select out_lives, out_next_at into cur_lives, cur_next from public.refresh_profile_lives(uid);

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  insert into public.user_quest_progress (user_id, quest_id, step, state, started_at)
  values (uid, p_quest_id, 0, '{}'::jsonb, now())
  on conflict (user_id, quest_id) do nothing;

  select u.step, u.completed_at, u.failed_at, coalesce(u.state, '{}'::jsonb)
    into prog_step, done_at, failed_at, state
    from public.user_quest_progress u
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
  end if;

  if failed_at is not null then
    return jsonb_build_object('ok', false, 'error', 'quest_failed');
  end if;

  prog_step := coalesce(prog_step, 0);

  b := q.body;
  puzzles := coalesce(b -> 'puzzles', '[]'::jsonb);
  puzzle_count := jsonb_array_length(puzzles);

  if puzzle_count = 0 then
    return jsonb_build_object('ok', false, 'error', 'no_puzzles');
  end if;

  if prog_step >= puzzle_count then
    return jsonb_build_object('ok', false, 'error', 'finale_next');
  end if;

  elem := puzzles -> prog_step;

  if (elem ->> 'id') is distinct from p_puzzle_id then
    insert into public.answer_attempts (user_id, quest_id, puzzle_key, is_correct)
    values (uid, p_quest_id, p_puzzle_id, false);

    return jsonb_build_object(
      'ok', false,
      'correct', false,
      'error', 'wrong_order',
      'lives', cur_lives,
      'next_life_at', to_jsonb(cur_next)
    );
  end if;

  is_single := coalesce((elem ->> 'singleAttempt')::boolean, false);
  is_fatal := coalesce((elem ->> 'fatalWrong')::boolean, false);

  if is_single then
    select exists(
      select 1
        from public.answer_attempts a
       where a.user_id = uid
         and a.quest_id = p_quest_id
         and a.puzzle_key is not distinct from p_puzzle_id
    ) into already_attempted;

    if already_attempted then
      return jsonb_build_object(
        'ok', false,
        'error', 'puzzle_locked',
        'lives', cur_lives,
        'next_life_at', to_jsonb(cur_next)
      );
    end if;
  end if;

  if cur_lives < 1 then
    return jsonb_build_object(
      'ok', false,
      'error', 'no_lives',
      'lives', 0,
      'next_life_at', to_jsonb(cur_next)
    );
  end if;

  hints_used := coalesce(nullif(trim(state -> 'hintsUsed' ->> p_puzzle_id), '')::int, 0);
  if hints_used < 0 then hints_used := 0; end if;

  wrong_prev := coalesce(nullif(trim(state -> 'wrongAttempts' ->> p_puzzle_id), '')::int, 0);
  if wrong_prev < 0 then wrong_prev := 0; end if;

  expected := public.normalize_answer(elem ->> 'answer');

  insert into public.answer_attempts (user_id, quest_id, puzzle_key, is_correct)
  values (uid, p_quest_id, p_puzzle_id, norm_attempt is not distinct from expected);

  near_text := coalesce(
    nullif(trim(elem ->> 'wrongFeedback'), ''),
    'That does not verify yet — recheck the mechanism before resubmitting.'
  );

  if norm_attempt is distinct from expected then
    wrong_new := wrong_prev + 1;
    update public.user_quest_progress u
       set state = jsonb_set(
             coalesce(u.state, '{}'::jsonb),
             '{wrongAttempts}',
             coalesce(u.state -> 'wrongAttempts', '{}'::jsonb)
               || jsonb_build_object(p_puzzle_id, wrong_new),
             true
           ),
           updated_at = now()
     where u.user_id = uid
       and u.quest_id = p_quest_id;

    update public.profiles as p
       set lives = p.lives - 1,
           next_life_at = case
             when p.lives - 1 <= 0 then coalesce(p.next_life_at, now() + regen)
             when p.next_life_at is not null then p.next_life_at
             else now() + regen
           end,
           updated_at = now()
     where p.id = uid
       and p.lives > 0
    returning p.lives, p.next_life_at into life_after, next_after;

    if is_fatal then
      update public.user_quest_progress
         set failed_at = now(),
             failed_puzzle_key = p_puzzle_id,
             updated_at = now()
       where user_id = uid
         and quest_id = p_quest_id;

      return jsonb_build_object(
        'ok', true,
        'correct', false,
        'fatal', true,
        'nearMiss', near_text,
        'wrongStrikes', wrong_new,
        'lives', life_after,
        'next_life_at', to_jsonb(next_after)
      );
    end if;

    return jsonb_build_object(
      'ok', true,
      'correct', false,
      'fatal', false,
      'nearMiss', near_text,
      'wrongStrikes', wrong_new,
      'lives', life_after,
      'next_life_at', to_jsonb(next_after)
    );
  end if;

  xp_base := coalesce(nullif(elem ->> 'xp', '')::int, 25);
  hint_factor := public.quest_xp_hint_factor(hints_used);
  wrong_factor := power(0.98::numeric, wrong_prev::numeric);
  xp_piece := greatest(1, floor(xp_base * hint_factor * wrong_factor));

  if hints_used = 0 and wrong_prev = 0 then
    clean_bonus := true;
    xp_piece := greatest(1, floor(xp_piece * 1.05::numeric));
  else
    clean_bonus := false;
  end if;

  hints_used_clean := coalesce(state -> 'hintsUsed', '{}'::jsonb) - p_puzzle_id;
  wrong_used_clean := coalesce(state -> 'wrongAttempts', '{}'::jsonb) - p_puzzle_id;

  update public.user_quest_progress u
     set step = u.step + 1,
         updated_at = now(),
         state =
           jsonb_set(
             jsonb_set(
               coalesce(u.state, '{}'::jsonb),
               '{hintsUsed}',
               hints_used_clean,
               true
             ),
             '{wrongAttempts}',
             wrong_used_clean,
             true
           )
           || jsonb_build_object(elem ->> 'id', true)
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_piece);

  select p.lives, p.next_life_at into life_after, next_after from public.profiles p where p.id = uid;

  return jsonb_build_object(
    'ok', true,
    'correct', true,
    'fatal', false,
    'lives', life_after,
    'next_life_at', to_jsonb(next_after),
    'xpAwarded', xp_piece,
    'xpBase', xp_base,
    'hintsUsed', hints_used,
    'wrongStrikes', wrong_prev,
    'cleanSolveBonus', clean_bonus
  );
end;
$$;

create or replace function public.ack_quest_pre_finale(p_quest_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzle_count int;
  prog_step int;
  done_at timestamptz;
  failed_at timestamptz;
  st jsonb;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  b := q.body;
  if not (b ? 'preFinale') then
    return jsonb_build_object('ok', false, 'error', 'no_pre_finale');
  end if;

  puzzle_count := jsonb_array_length(coalesce(b -> 'puzzles', '[]'::jsonb));

  select u.step, u.completed_at, u.failed_at, coalesce(u.state, '{}'::jsonb)
    into prog_step, done_at, failed_at, st
    from public.user_quest_progress u
   where u.user_id = uid
     and u.quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
  end if;

  if failed_at is not null then
    return jsonb_build_object('ok', false, 'error', 'quest_failed');
  end if;

  prog_step := coalesce(prog_step, 0);

  if prog_step < puzzle_count then
    return jsonb_build_object('ok', false, 'error', 'puzzles_incomplete');
  end if;

  update public.user_quest_progress
     set state = coalesce(state, '{}'::jsonb) || jsonb_build_object('preFinaleAck', true),
         updated_at = now()
   where user_id = uid
     and quest_id = p_quest_id;

  return jsonb_build_object('ok', true);
end;
$$;

create or replace function public.submit_finale_choice(p_quest_id uuid, p_choice text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb;
  puzzle_count int;
  prog_step int;
  done_at timestamptz;
  chosen text := upper(trim(coalesce(p_choice, '')));
  xp_finale_base int;
  xp_finale int;
  mult numeric;
  state_in jsonb;
  axes jsonb;
  v int;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  if chosen not in ('CONTROL', 'OBSERVE', 'INFLUENCE') then
    return jsonb_build_object('ok', false, 'error', 'bad_branch');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
  end if;

  if coalesce(q.archived, false) then
    return jsonb_build_object('ok', false, 'error', 'archived');
  end if;

  if not (
    q.is_published
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  ) then
    return jsonb_build_object('ok', false, 'error', 'quest_closed');
  end if;

  insert into public.user_quest_progress (user_id, quest_id, step, state, started_at)
  values (uid, p_quest_id, 0, '{}'::jsonb, now())
  on conflict (user_id, quest_id) do nothing;

  select step, completed_at, coalesce(state, '{}'::jsonb)
    into prog_step, done_at, state_in
    from public.user_quest_progress
   where user_id = uid
     and quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
  end if;

  b := q.body;
  puzzles := coalesce(b -> 'puzzles', '[]'::jsonb);
  puzzle_count := jsonb_array_length(puzzles);

  if prog_step < puzzle_count then
    return jsonb_build_object('ok', false, 'error', 'puzzles_incomplete');
  end if;

  xp_finale_base := coalesce(nullif(b ->> 'xpFinale', '')::int, 75);

  mult := case chosen
    when 'OBSERVE' then 0.94::numeric
    when 'INFLUENCE' then 1.00::numeric
    when 'CONTROL' then 1.06::numeric
  end;

  xp_finale := greatest(1, floor(xp_finale_base * mult));

  axes := coalesce(state_in -> 'hiddenAxes', '{}'::jsonb);
  v := coalesce((axes ->> chosen)::int, 0) + 1;
  axes := axes || jsonb_build_object(chosen, to_jsonb(v));

  update public.user_quest_progress
     set branch = chosen,
         completed_at = now(),
         updated_at = now(),
         state = coalesce(state, '{}'::jsonb)
                 || jsonb_build_object(
                      'hiddenAxes', axes,
                      'lastBranch', to_jsonb(chosen)
                    )
   where user_id = uid
     and quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_finale);

  return jsonb_build_object(
    'ok', true,
    'branch', chosen,
    'xpAwarded', xp_finale,
    'xpFinaleBase', xp_finale_base,
    'finaleMultiplier', mult,
    'hiddenAxes', axes
  );
end;
$$;

grant execute on function public.ack_quest_pre_finale(uuid) to authenticated;
grant execute on function public.quest_xp_hint_factor(int) to authenticated;
