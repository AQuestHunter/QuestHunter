-- Player lives: wrong puzzle answers cost one life; one life regenerates every 5 minutes up to max (5).

alter table public.profiles
  add column if not exists lives integer not null default 5,
  add column if not exists next_life_at timestamptz;

comment on column public.profiles.lives is 'Puzzle-attempt budget; decremented on wrong answer; regens every 5 min when below 5';
comment on column public.profiles.next_life_at is 'When the next life arrives (when lives < 5); null when full';

alter table public.profiles
  drop constraint if exists profiles_lives_nonnegative;

alter table public.profiles
  add constraint profiles_lives_range check (lives >= 0 and lives <= 5);

create or replace function public.refresh_profile_lives(p_uid uuid)
returns table (out_lives integer, out_next_at timestamptz)
language plpgsql
security definer
set search_path = public
as $$
declare
  max_l constant int := 5;
  regen constant interval := interval '5 minutes';
  l int;
  n timestamptz;
begin
  select p.lives, p.next_life_at
    into l, n
    from public.profiles p
   where p.id = p_uid
   for update;

  if not found then
    return;
  end if;

  if l is null then
    l := max_l;
  end if;

  while l < max_l and n is not null and n <= now() loop
    l := l + 1;
    if l >= max_l then
      n := null;
    else
      n := n + regen;
    end if;
  end loop;

  update public.profiles
     set lives = l,
         next_life_at = n,
         updated_at = now()
   where id = p_uid;

  return query select l, n;
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
             select jsonb_agg(e - 'answer' - 'xp')
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
    'ui', coalesce(b -> 'ui', '{}'::jsonb),
    'lives', coalesce(lv, 0),
    'livesMax', 5,
    'nextLifeAt', to_jsonb(nx)
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
  elem jsonb;
  expected text;
  norm_attempt text := public.normalize_answer(p_attempt);
  xp_piece int;
  is_single boolean := false;
  is_fatal boolean := false;
  already_attempted boolean := false;
  cur_lives int;
  cur_next timestamptz;
  life_after int;
  next_after timestamptz;
  max_l constant int := 5;
  regen constant interval := interval '5 minutes';
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

  select u.step, u.completed_at, u.failed_at
    into prog_step, done_at, failed_at
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

  expected := public.normalize_answer(elem ->> 'answer');

  insert into public.answer_attempts (user_id, quest_id, puzzle_key, is_correct)
  values (uid, p_quest_id, p_puzzle_id, norm_attempt is not distinct from expected);

  if norm_attempt is distinct from expected then
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
        'lives', life_after,
        'next_life_at', to_jsonb(next_after)
      );
    end if;

    return jsonb_build_object(
      'ok', true,
      'correct', false,
      'fatal', false,
      'lives', life_after,
      'next_life_at', to_jsonb(next_after)
    );
  end if;

  xp_piece := coalesce(nullif(elem ->> 'xp', '')::int, 25);

  update public.user_quest_progress
     set step = step + 1,
         updated_at = now(),
         state = state || jsonb_build_object(elem ->> 'id', true)
   where user_id = uid
     and quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_piece);

  select p.lives, p.next_life_at into life_after, next_after from public.profiles p where p.id = uid;

  return jsonb_build_object(
    'ok', true,
    'correct', true,
    'fatal', false,
    'lives', life_after,
    'next_life_at', to_jsonb(next_after)
  );
end;
$$;
