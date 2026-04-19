-- Player UI: list campaign_slug values that currently have at least one playable (windowed) quest.
-- Used to let operators pick which story arc to play when several projects are live at once.

create or replace function public.list_active_player_campaigns()
returns table (
  campaign_slug text,
  display_name text
)
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  return query
  select
    q.campaign_slug,
    coalesce(
      nullif(max(nullif(trim(q.campaign_display_name), '')), ''),
      q.campaign_slug
    )::text as display_name
  from public.quests q
  where q.is_published = true
    and coalesce(q.archived, false) = false
    and q.starts_at is not null
    and q.starts_at <= now()
    and (q.ends_at is null or q.ends_at > now())
  group by q.campaign_slug
  order by q.campaign_slug;
end;
$$;

grant execute on function public.list_active_player_campaigns() to authenticated;
