-- Quest Hunter — core schema + RLS
-- Run in Supabase SQL Editor or via supabase db push after linking the project.

create extension if not exists "pgcrypto";

-- Profiles (1:1 with auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  hunter_name text unique,
  xp integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_hunter_name_idx on public.profiles (hunter_name);

-- Quests (admin-managed)
create table if not exists public.quests (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  body jsonb not null default '{}'::jsonb,
  starts_at timestamptz,
  ends_at timestamptz,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Progress per user + quest
create table if not exists public.user_quest_progress (
  user_id uuid not null references public.profiles (id) on delete cascade,
  quest_id uuid not null references public.quests (id) on delete cascade,
  branch text check (branch in ('CONTROL', 'OBSERVE', 'INFLUENCE')),
  step integer not null default 0,
  state jsonb not null default '{}'::jsonb,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, quest_id)
);

create index if not exists user_quest_progress_quest_idx on public.user_quest_progress (quest_id);

-- Raw attempts for analytics
create table if not exists public.answer_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  quest_id uuid references public.quests (id) on delete set null,
  puzzle_key text,
  is_correct boolean not null,
  created_at timestamptz not null default now()
);

create index if not exists answer_attempts_quest_idx on public.answer_attempts (quest_id);

-- New auth users get a profile row
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.quests enable row level security;
alter table public.user_quest_progress enable row level security;
alter table public.answer_attempts enable row level security;

-- Profiles
create policy "profiles_select_authenticated"
  on public.profiles for select
  to authenticated
  using (true);

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Quests: players see only the published window; admins see everything
create policy "quests_select_player"
  on public.quests for select
  to authenticated
  using (
    is_published = true
    and starts_at is not null
    and starts_at <= now()
    and (ends_at is null or ends_at > now())
  );

create policy "quests_select_admin"
  on public.quests for select
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "quests_write_admin"
  on public.quests for insert
  to authenticated
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "quests_update_admin"
  on public.quests for update
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "quests_delete_admin"
  on public.quests for delete
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Progress: own rows only
create policy "user_quest_progress_select_own"
  on public.user_quest_progress for select
  to authenticated
  using (user_id = auth.uid());

create policy "user_quest_progress_insert_own"
  on public.user_quest_progress for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "user_quest_progress_update_own"
  on public.user_quest_progress for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "user_quest_progress_delete_own"
  on public.user_quest_progress for delete
  to authenticated
  using (user_id = auth.uid());

-- Attempts
create policy "answer_attempts_insert_own"
  on public.answer_attempts for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "answer_attempts_select_own"
  on public.answer_attempts for select
  to authenticated
  using (user_id = auth.uid());

create policy "answer_attempts_select_admin"
  on public.answer_attempts for select
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Optional seed quest (comment out if you prefer to add via Admin UI later)
-- insert into public.quests (slug, title, body, starts_at, ends_at, is_published)
-- values (
--   'signal-01',
--   'PROJECT ORACLE // Signal 01',
--   '{}'::jsonb,
--   now() - interval '1 hour',
--   null,
--   true
-- );
