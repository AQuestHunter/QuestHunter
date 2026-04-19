-- Qualify user_quest_progress.state in UPDATE so SQL does not confuse the column
-- with PL/pgSQL variables named `state` (ERROR: column reference "state" is ambiguous).

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
