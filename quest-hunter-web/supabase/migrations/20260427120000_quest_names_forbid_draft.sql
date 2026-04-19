-- Quest title and project display name must not contain "draft" (case-insensitive).
--
-- Inspect violations (run anytime):
--   select id, slug, title from public.quests where lower(title) like '%draft%';
--   select id, slug, campaign_display_name from public.quests
--     where campaign_display_name is not null and lower(campaign_display_name) like '%draft%';

-- Normalize existing rows before CHECK constraints (otherwise ADD CONSTRAINT fails with 23514).
update public.quests
set title = coalesce(
        nullif(
          trim(regexp_replace(regexp_replace(title, 'draft', '', 'gi'), '\s+', ' ', 'g')),
          ''
        ),
        'Untitled dossier'
      ),
    updated_at = now()
where lower(title) like '%draft%';

update public.quests
set campaign_display_name = nullif(
      trim(regexp_replace(regexp_replace(campaign_display_name, 'draft', '', 'gi'), '\s+', ' ', 'g')),
      ''
    ),
    updated_at = now()
where campaign_display_name is not null
  and lower(campaign_display_name) like '%draft%';

alter table public.quests
  drop constraint if exists quests_title_forbids_draft_substring;

alter table public.quests
  add constraint quests_title_forbids_draft_substring
  check (lower(title) not like '%draft%');

alter table public.quests
  drop constraint if exists quests_campaign_display_name_forbids_draft_substring;

alter table public.quests
  add constraint quests_campaign_display_name_forbids_draft_substring
  check (
    campaign_display_name is null
    or lower(campaign_display_name) not like '%draft%'
  );

comment on constraint quests_title_forbids_draft_substring on public.quests is
  'Title must not contain the substring draft (any case).';

comment on constraint quests_campaign_display_name_forbids_draft_substring on public.quests is
  'Project display name must not contain the substring draft (any case).';
