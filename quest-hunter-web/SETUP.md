# Quest Hunter — Supabase & Netlify setup

Follow in order.

## 1. Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. **Project Settings → API**: copy **Project URL** and **anon public** key.

## 2. Environment (local)

In `quest-hunter-web/`:

1. Copy `.env.example` to `.env`.
2. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
3. Optional — branching campaigns: set **`VITE_QUEST_CAMPAIGN_SLUG`** (e.g. `project-oracle`) so the Quests page resolves the **next dossier** from finale paths instead of only picking the newest published quest. Omit or leave empty for legacy behaviour (**default** = global latest playable quest).

Optional check:

```bash
npm run verify
```

## 3. Database migrations

In **Supabase → SQL Editor**, run these files **in order** (full contents, each run separately or as one script):

1. `supabase/migrations/20260418120000_initial.sql`
2. `supabase/migrations/20260418200000_quest_rpc_and_security.sql`
3. `supabase/migrations/20260419000000_quest_archive_retention.sql`
4. `supabase/migrations/20260420000000_campaign_branching.sql`

The third adds **`quests.archived`**, tightens RPCs, and **`run_quest_archive_sweep_admin`** for the Admin “Archive sweep” button. The fourth adds **`campaign_slug`**, **`sequence_idx`**, branch **next-quest** pointers, **`get_player_resolved_quest_summary`**, and **`get_player_finale_branch_history`**.

## 4. Auth

1. **Authentication → Providers**: enable **Email** (adjust “Confirm email” for testing if you want instant sign-up).
2. Sign up once in the app, then open **Authentication → Users**, select your user, and under **App metadata** set raw JSON:

```json
{ "role": "admin" }
```

3. Sign out and sign in again so the JWT includes `role`.

## 5. First quest

1. Run the app: `npm run dev`.
2. **Profile**: set a **hunter name**.
3. **Admin → Quests**: create a quest with **start ≤ now**, optional **end**, **published** checked, at least one puzzle + finale text.
4. **Quests** page should load the dossier; **Admin → Analytics** fills after attempts.

## 6. Archive retention

- When **`ends_at` + 1 day** has passed, use **Admin → Archive sweep** (or schedule the SQL function `run_quest_archive_sweep()` yourself).
- Quests are marked **`archived = true`**; players already cannot play past `ends_at`; this step is for admin hygiene.
- Optional: enable **`pg_cron`** in Supabase (if available on your plan) and schedule:

```sql
SELECT cron.schedule(
  'quest_hunter_archive_sweep',
  '30 * * * *',
  $$SELECT public.run_quest_archive_sweep();$$
);
```

Adjust the cron expression as needed. If `cron` is unavailable, rely on the Admin button or an external scheduler calling the same function via service role.

## 7. Netlify

The repository has a root `netlify.toml` (next to `quest-hunter-web/`) that sets `command` to build inside `quest-hunter-web` and `publish` to `quest-hunter-web/dist`. You usually **do not** set a separate “Base directory” in the Netlify UI, and you should **not** set a conflicting custom publish path (e.g. `dist` at repo root) or the site can 404.

1. Connect the GitHub repo and use the default “Build from main” (or your branch).
2. **Site settings → Build & deploy → Build settings**: if you previously set a custom build command or publish directory, **clear** them so `netlify.toml` is used, or match: command `cd quest-hunter-web && npm ci && npm run build`, publish `quest-hunter-web/dist`.
3. **Environment variables**: add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (same as local). Redeploy after changes.

SPA redirects are defined in `netlify.toml`.

## Draft story content (PROJECT ORACLE)

Run these SQL snippets **in order** in the SQL Editor (each uses `ON CONFLICT (slug)` upsert):

1. `supabase/snippets/draft_project_oracle_quests.sql` — Quest **1** + **3A/B/C** (hoofdstuk-teaser + jouw uitgewerkte Quest 3).
2. `supabase/snippets/draft_project_oracle_story_arc.sql` — Quest **2, 4, 6, 8** (×3 paden), **9** (lineair), **10** (finale).
3. `supabase/snippets/draft_project_oracle_q5_q7.sql` — Quest **5** en **7** (×3 paden).

Alle rijen hebben `is_published = false`. Zet in **Admin → Quests** **starts_at / ends** en **Published** wanneer je live gaat.

**Bedoelde volgorde verhaal** (per speler-pad moet je het juiste quest-bestand publiceren):  
`01` → `02[a|b|c]` → `03[a|b|c]` → `04…` → `05…` → `06…` → `07…` → `08…` → `09` → `10`.  
Vertakking zit in de **finale-keuze** (CONTROL / OBSERVE / INFLUENCE); welk `oracle-0Xy-*` je publiceert koppel je handmatig aan je campagne.

Na import: zet in **Admin → Quests** per rij **Campaign slug** (`project-oracle`), **Sequence**, en **Next quest after CONTROL/OBSERVE/INFLUENCE** zodat spelers automatisch het juiste hoofdstuk zien (plus `VITE_QUEST_CAMPAIGN_SLUG` in `.env` / Netlify).

**Content QA (playtest):** at least one full run per draft quest — exact answer strings, all **English** in-quest copy (snippets), then finale → next dossier as wired in Admin.

**Slugs** (prefix `oracle-`):  
`01-lek`, `02a/b/c-*`, `03a/b/c-*`, `04a/b/c-*`, `05a/b/c-*`, `06a/b/c-*`, `07a/b/c-*`, `08a/b/c-*`, `09-lab`, `10-finale`.

## 8. Verify Netlify env (after deploy)

Open **`https://YOUR_SITE.netlify.app/env-check`** on the deployed site. It reports whether `VITE_*` variables were embedded at build time (without printing secrets) and pings Supabase Auth health. If anything shows placeholder text or “missing”, fix variables in Netlify and **redeploy with cache clear**.
