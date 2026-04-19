-- Web Push: store per-device subscriptions (VAPID) and dedupe “new project live” sends per campaign.

create table if not exists public.push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  endpoint text not null,
  p256dh text not null,
  auth text not null,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, endpoint)
);

create index if not exists push_subscriptions_user_id_idx on public.push_subscriptions (user_id);

comment on table public.push_subscriptions is
  'Browser Push API subscriptions for PWA alerts; rows removed when unsubscribe or invalid endpoint (410).';

alter table public.push_subscriptions enable row level security;

create policy "push_subscriptions_select_own"
  on public.push_subscriptions for select
  to authenticated
  using (user_id = auth.uid());

create policy "push_subscriptions_insert_own"
  on public.push_subscriptions for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "push_subscriptions_update_own"
  on public.push_subscriptions for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "push_subscriptions_delete_own"
  on public.push_subscriptions for delete
  to authenticated
  using (user_id = auth.uid());

-- One row per campaign_slug after we’ve broadcast “project is live” (non-default campaigns only).
create table if not exists public.project_push_notifications_sent (
  campaign_slug text primary key,
  notified_at timestamptz not null default now(),
  title text,
  body text
);

comment on table public.project_push_notifications_sent is
  'Dedup for GitHub cron project-live pushes; written only by service role / backend jobs.';

alter table public.project_push_notifications_sent enable row level security;

-- No policies: only service_role (bypasses RLS) and Postgres owner access.
