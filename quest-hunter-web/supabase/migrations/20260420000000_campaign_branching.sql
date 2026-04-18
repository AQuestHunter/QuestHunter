-- Campaign ordering + branch → next quest pointers for narrative sequencing.
-- Legacy behaviour: campaign_slug = 'default' keeps global "latest windowed quest" (pickLatest).

alter table public.quests
  add column if not exists campaign_slug text not null default 'default';

alter table public.quests
  add column if not exists sequence_idx integer not null default 1;

alter table public.quests
  add column if not exists next_control_id uuid references public.quests (id) on delete set null;

alter table public.quests
  add column if not exists next_observe_id uuid references public.quests (id) on delete set null;

alter table public.quests
  add column if not exists next_influence_id uuid references public.quests (id) on delete set null;

create index if not exists quests_campaign_sequence_idx on public.quests (campaign_slug, sequence_idx);

comment on column public.quests.campaign_slug is 'groups quests into a story arc; default = legacy global latest';
comment on column public.quests.sequence_idx is 'ordering within campaign_slug (1 = entry chapter)';
comment on column public.quests.next_control_id is 'next quest after finale CONTROL';
comment on column public.quests.next_observe_id is 'next quest after finale OBSERVE';
comment on column public.quests.next_influence_id is 'next quest after finale INFLUENCE';

-- Resolved dossier for player: campaign-aware next quest, or legacy latest when campaign is default.
create or replace function public.get_player_resolved_quest_summary(p_campaign text default 'default')
returns table (
  id uuid,
  slug text,
  title text,
  starts_at timestamptz,
  ends_at timestamptz,
  resolve_status text
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  uid uuid := auth.uid();
  camp text := trim(coalesce(p_campaign, 'default'));
  inprog_id uuid;
  last_rec record;
  next_id uuid;
  pq public.quests%rowtype;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  -- Legacy / non-branching: same as pickLatest over all playable quests.
  if camp = '' or lower(camp) = 'default' then
    select * into pq
      from public.quests q
     where q.is_published = true
       and coalesce(q.archived, false) = false
       and q.starts_at is not null
       and q.starts_at <= now()
       and (q.ends_at is null or q.ends_at > now())
     order by q.starts_at desc
     limit 1;

    if pq.id is null then
      return query
      select null::uuid,
             null::text,
             null::text,
             null::timestamptz,
             null::timestamptz,
             'none'::text;
    else
      return query
      select pq.id, pq.slug, pq.title, pq.starts_at, pq.ends_at, 'active'::text;
    end if;
    return;
  end if;

  -- In-progress (not completed): lowest sequence_idx first.
  select q.id into inprog_id
    from public.user_quest_progress u
    join public.quests q on q.id = u.quest_id
   where u.user_id = uid
     and q.campaign_slug = camp
     and u.completed_at is null
   order by q.sequence_idx asc nulls last, q.starts_at desc
   limit 1;

  if inprog_id is not null then
    select * into pq from public.quests where id = inprog_id;
    if pq.id is not null
       and pq.is_published = true
       and coalesce(pq.archived, false) = false
       and pq.starts_at is not null
       and pq.starts_at <= now()
       and (pq.ends_at is null or pq.ends_at > now())
    then
      return query select pq.id, pq.slug, pq.title, pq.starts_at, pq.ends_at, 'active'::text;
      return;
    end if;
    -- Window closed while incomplete: fall through (player may continue via next entry rules).
  end if;

  select q.id,
         q.slug,
         q.title,
         q.starts_at,
         q.ends_at,
         q.sequence_idx,
         q.next_control_id,
         q.next_observe_id,
         q.next_influence_id,
         u.branch as finale_branch
    into last_rec
    from public.user_quest_progress u
    join public.quests q on q.id = u.quest_id
   where u.user_id = uid
     and q.campaign_slug = camp
     and u.completed_at is not null
   order by q.sequence_idx desc nulls last, u.completed_at desc nulls last
   limit 1;

  if found then
    next_id := case trim(upper(coalesce(last_rec.finale_branch, '')))
      when 'CONTROL' then last_rec.next_control_id
      when 'OBSERVE' then last_rec.next_observe_id
      when 'INFLUENCE' then last_rec.next_influence_id
      else null
    end;

    if next_id is not null then
      select * into pq from public.quests where id = next_id and campaign_slug = camp;
      if pq.id is null then
        next_id := null;
      elsif pq.is_published = true
            and coalesce(pq.archived, false) = false
            and pq.starts_at is not null
            and pq.starts_at <= now()
            and (pq.ends_at is null or pq.ends_at > now())
      then
        return query select pq.id, pq.slug, pq.title, pq.starts_at, pq.ends_at, 'active'::text;
        return;
      else
        return query select null::uuid,
                     null::text,
                     null::text,
                     null::timestamptz,
                     null::timestamptz,
                     'waiting_next'::text;
        return;
      end if;
    end if;

    return query select null::uuid,
                 null::text,
                 null::text,
                 null::timestamptz,
                 null::timestamptz,
                 'campaign_complete'::text;
    return;
  end if;

  -- First playable chapter in campaign.
  select * into pq
    from public.quests q
   where q.campaign_slug = camp
     and q.is_published = true
     and coalesce(q.archived, false) = false
     and q.starts_at is not null
     and q.starts_at <= now()
     and (q.ends_at is null or q.ends_at > now())
   order by q.sequence_idx asc nulls last, q.starts_at asc
   limit 1;

  if pq.id is not null then
    return query select pq.id, pq.slug, pq.title, pq.starts_at, pq.ends_at, 'active'::text;
    return;
  end if;

  return query select null::uuid,
               null::text,
               null::text,
               null::timestamptz,
               null::timestamptz,
               'none'::text;
end;
$$;

grant execute on function public.get_player_resolved_quest_summary(text) to authenticated;

-- Profile / operator record: recent finale choices with quest labels (no direct SELECT on quests.body).
create or replace function public.get_player_finale_branch_history(p_limit int default 12)
returns table (
  quest_slug text,
  quest_title text,
  branch text,
  completed_at timestamptz,
  campaign_slug text
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  uid uuid := auth.uid();
  lim int := greatest(1, least(coalesce(p_limit, 12), 50));
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  return query
  select q.slug,
         q.title,
         coalesce(u.branch::text, '—'),
         u.completed_at,
         q.campaign_slug
    from public.user_quest_progress u
    join public.quests q on q.id = u.quest_id
   where u.user_id = uid
     and u.completed_at is not null
     and u.branch is not null
   order by u.completed_at desc
   limit lim;
end;
$$;

grant execute on function public.get_player_finale_branch_history(integer) to authenticated;
