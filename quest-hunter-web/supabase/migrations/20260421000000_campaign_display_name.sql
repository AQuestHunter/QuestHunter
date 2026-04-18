-- Optional human-readable label for grouped project UI (alongside campaign_slug).

alter table public.quests
  add column if not exists campaign_display_name text;

comment on column public.quests.campaign_display_name is
  'Human-readable project name for admin/profile grouping; optional; slug remains campaign_slug.';

-- Extend finale history RPC so Profile can group/show project names.
drop function if exists public.get_player_finale_branch_history(integer);

create function public.get_player_finale_branch_history(p_limit int default 12)
returns table (
  quest_slug text,
  quest_title text,
  branch text,
  completed_at timestamptz,
  campaign_slug text,
  campaign_display_name text
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
         q.campaign_slug,
         q.campaign_display_name
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
