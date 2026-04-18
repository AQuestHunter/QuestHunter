-- Admin: wipe all player progress + answer attempts for every quest in a campaign (replay / "republish" reset).

create or replace function public.reset_campaign_quest_progress_admin(p_campaign_slug text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_campaign text := trim(coalesce(p_campaign_slug, ''));
  n_prog int := 0;
  n_attempts int := 0;
begin
  if (auth.jwt() -> 'app_metadata' ->> 'role') is distinct from 'admin' then
    return jsonb_build_object('ok', false, 'error', 'forbidden');
  end if;

  if v_campaign = '' then
    return jsonb_build_object('ok', false, 'error', 'invalid_campaign');
  end if;

  delete from public.user_quest_progress
   where quest_id in (
     select q.id from public.quests q where q.campaign_slug = v_campaign
   );

  get diagnostics n_prog = row_count;

  delete from public.answer_attempts
   where quest_id in (
     select q.id from public.quests q where q.campaign_slug = v_campaign
   );

  get diagnostics n_attempts = row_count;

  return jsonb_build_object(
    'ok', true,
    'campaign_slug', v_campaign,
    'deleted_progress_rows', n_prog,
    'deleted_attempt_rows', n_attempts
  );
end;
$$;

grant execute on function public.reset_campaign_quest_progress_admin(text) to authenticated;
