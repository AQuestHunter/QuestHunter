-- Draft substring policy: titles and campaign_display_name cannot contain "draft" (any case).
-- Use this in the SQL editor if migrations have not run yet or you need to inspect/fix manually.

-- List quest titles that still contain "draft"
select id, slug, title
from public.quests
where lower(title) like '%draft%';

-- List project display names that still contain "draft"
select id, slug, campaign_display_name
from public.quests
where campaign_display_name is not null
  and lower(campaign_display_name) like '%draft%';

-- Fix data (same logic as migration 20260427120000): strip "draft" case-insensitively, collapse spaces.
-- Run the SELECTs above first; then uncomment and run if needed.

/*
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
*/
