-- Quest Hunter — admin gebruiker zetten (app_metadata.role = 'admin')
-- Voer uit in Supabase: SQL Editor (service role / postgres context).
-- Daarna: gebruiker uitloggen en opnieuw inloggen zodat de JWT vernieuwt.

-- -----------------------------------------------------------------------------
-- Optie A — op e-mailadres (pas het adres aan)
-- -----------------------------------------------------------------------------
UPDATE auth.users
SET raw_app_meta_data =
  COalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'admin')
WHERE email = lower('aquesthunter@outlook.com');

-- -----------------------------------------------------------------------------
-- Optie B — op user id (UUID uit Authentication → Users)
-- -----------------------------------------------------------------------------
-- UPDATE auth.users
-- SET raw_app_meta_data =
--   coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'admin')
-- WHERE id = '00000000-0000-0000-0000-000000000000'::uuid;

-- -----------------------------------------------------------------------------
-- Controleren (optioneel)
-- -----------------------------------------------------------------------------
-- SELECT id, email, raw_app_meta_data
-- FROM auth.users
-- WHERE email = lower('jouw@email.com');

-- Admin rol weer verwijderen (optioneel):
-- UPDATE auth.users
-- SET raw_app_meta_data = raw_app_meta_data - 'role'
-- WHERE email = lower('jouw@email.com');
