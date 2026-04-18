-- Secure quest play path: players no longer SELECT quests.body (answers leak).
-- RPCs run as SECURITY DEFINER and strip answers server-side.

-- Progress timing for analytics
alter table public.user_quest_progress
  add column if not exists started_at timestamptz default now();

update public.user_quest_progress
set started_at = coalesce(started_at, updated_at)
where started_at is null;

drop policy if exists "quests_select_player" on public.quests;

create or replace function public.normalize_answer(input text)
returns text
language sql
immutable
as $$
  select upper(
    trim(
      both from regexp_replace(coalesce(input, ''), '\s+', ' ', 'g')
    )
  )
$$;

create or replace function public.award_profile_xp(p_user uuid, p_delta int)
returns void
language sql
security definer
set search_path = public
as $$
  update public.profiles
    set xp = xp + greatest(p_delta, 0),
        updated_at = now()
  where id = p_user;
$$;

create or replace function public.list_active_quest_summaries()
returns table (
  id uuid,
  slug text,
  title text,
  starts_at timestamptz,
  ends_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  return query
  select q.id,
         q.slug,
         q.title,
         q.starts_at,
         q.ends_at
    from public.quests q
   where q.is_published = true
     and q.starts_at is not null
     and q.starts_at <= now()
     and (q.ends_at is null or q.ends_at > now())
   order by q.starts_at desc;
end;
$$;

create or replace function public.get_player_quest_payload(p_quest_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  q public.quests%rowtype;
  b jsonb;
  puzzles jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then
    return jsonb_build_object('error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('error', 'not_found');
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
    'finalePrompt', coalesce(b ->> 'finalePrompt', '')
  );
end;
$$;

create or replace function public.ensure_quest_progress(p_quest_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  insert into public.user_quest_progress (user_id, quest_id, step, state, started_at)
  values (uid, p_quest_id, 0, '{}'::jsonb, now())
  on conflict (user_id, quest_id) do nothing;
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
  elem jsonb;
  expected text;
  norm_attempt text := public.normalize_answer(p_attempt);
  xp_piece int;
begin
  if uid is null then
    return jsonb_build_object('ok', false, 'error', 'auth');
  end if;

  select * into q from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest_not_found');
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

  select step, completed_at
    into prog_step, done_at
    from public.user_quest_progress
   where user_id = uid
     and quest_id = p_quest_id;

  if done_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_completed');
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

  expected := public.normalize_answer(elem ->> 'answer');

  insert into public.answer_attempts (user_id, quest_id, puzzle_key, is_correct)
  values (uid, p_quest_id, p_puzzle_id, norm_attempt is not distinct from expected);

  if norm_attempt is distinct from expected then
    return jsonb_build_object('ok', true, 'correct', false);
  end if;

  xp_piece := coalesce(nullif(elem ->> 'xp', '')::int, 25);

  update public.user_quest_progress
     set step = step + 1,
         updated_at = now(),
         state = state || jsonb_build_object(elem ->> 'id', true)
   where user_id = uid
     and quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_piece);

  return jsonb_build_object('ok', true, 'correct', true);
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
  xp_finale int;
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

  select step, completed_at
    into prog_step, done_at
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

  xp_finale := coalesce(nullif(b ->> 'xpFinale', '')::int, 75);

  update public.user_quest_progress
     set branch = chosen,
         completed_at = now(),
         updated_at = now()
   where user_id = uid
     and quest_id = p_quest_id;

  perform public.award_profile_xp(uid, xp_finale);

  return jsonb_build_object('ok', true, 'branch', chosen);
end;
$$;

grant execute on function public.list_active_quest_summaries() to authenticated;
grant execute on function public.get_player_quest_payload(uuid) to authenticated;
grant execute on function public.ensure_quest_progress(uuid) to authenticated;
grant execute on function public.submit_puzzle_answer(uuid, text, text) to authenticated;
grant execute on function public.submit_finale_choice(uuid, text) to authenticated;
