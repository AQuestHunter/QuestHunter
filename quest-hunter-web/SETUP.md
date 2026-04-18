# Quest Hunter — Supabase & Netlify setup

Follow in order.

## 1. Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. **Project Settings → API**: copy **Project URL** and **anon public** key.

## 2. Environment (local)

In `quest-hunter-web/`:

1. Copy `.env.example` to `.env`.
2. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.

Optional check:

```bash
npm run verify
```

## 3. Database migrations

In **Supabase → SQL Editor**, run these files **in order** (full contents, each run separately or as one script):

1. `supabase/migrations/20260418120000_initial.sql`
2. `supabase/migrations/20260418200000_quest_rpc_and_security.sql`
3. `supabase/migrations/20260419000000_quest_archive_retention.sql`

The third adds **`quests.archived`**, tightens RPCs, and **`run_quest_archive_sweep_admin`** for the Admin “Archive sweep” button.

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

## 8. Verify Netlify env (after deploy)

Open **`https://YOUR_SITE.netlify.app/env-check`** on the deployed site. It reports whether `VITE_*` variables were embedded at build time (without printing secrets) and pings Supabase Auth health. If anything shows placeholder text or “missing”, fix variables in Netlify and **redeploy with cache clear**.
