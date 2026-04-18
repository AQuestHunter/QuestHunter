-- Single-attempt + fatal-wrong support for choice puzzles.
-- Adds failure fields to user_quest_progress and enforces server-side lockouts.

alter table public.user_quest_progress
  add column if not exists failed_at timestamptz,
  add column if not exists failed_puzzle_key text;

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

    return jsonb_build_object('ok', false, 'correct', false, 'error', 'wrong_order');
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
      return jsonb_build_object('ok', false, 'error', 'puzzle_locked');
    end if;
  end if;

  expected := public.normalize_answer(elem ->> 'answer');

  insert into public.answer_attempts (user_id, quest_id, puzzle_key, is_correct)
  values (uid, p_quest_id, p_puzzle_id, norm_attempt is not distinct from expected);

  if norm_attempt is distinct from expected then
    if is_fatal then
      update public.user_quest_progress
         set failed_at = now(),
             failed_puzzle_key = p_puzzle_id,
             updated_at = now()
       where user_id = uid
         and quest_id = p_quest_id;

      return jsonb_build_object('ok', true, 'correct', false, 'fatal', true);
    end if;

    return jsonb_build_object('ok', true, 'correct', false, 'fatal', false);
  end if;

  xp_piece := coalesce(nullif(elem ->> 'xp', '')::int, 25);

  update public.user_quest_progress
     set step = step + 1,
         updated_at = now(),
         state = state || jsonb_build_object(elem ->> 'id', true)
   where user_id = uid
     and quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_piece);

  return jsonb_build_object('ok', true, 'correct', true, 'fatal', false);
end;
$$;

