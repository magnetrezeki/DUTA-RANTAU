-- LOCAL TEST ONLY. Negative authorization verification for migration 0041.
--
-- After this migration the deciding layer for every duta_app audit write must
-- be RLS, never the privilege check. A missing or mismatched actor must be
-- rejected by the policy, and the denial must leave no row behind. Outside the
-- FOR INSERT grant, duta_app must still be stopped at the privilege layer.
--
-- The helpers below set an explicit flag instead of raising from inside the
-- protected block, so an ALLOWED statement can never be mistaken for a denial.
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.assert_denied(statement_text text, layer text, label text)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  denied boolean := false;
  detail text := '';
BEGIN
  BEGIN
    EXECUTE statement_text;
  EXCEPTION WHEN OTHERS THEN
    denied := true;
    detail := SQLERRM;
  END;
  IF NOT denied THEN
    RAISE EXCEPTION 'expected a denial, but the statement was ALLOWED: %', label;
  END IF;
  IF layer = 'RLS' AND detail NOT LIKE '%row-level security%' THEN
    RAISE EXCEPTION 'wrong denial layer for % (expected RLS): %', label, detail;
  END IF;
  IF layer = 'PRIVILEGE' AND detail NOT LIKE '%permission denied%' THEN
    RAISE EXCEPTION 'wrong denial layer for % (expected privilege): %', label, detail;
  END IF;
END
$$;

-- Reads and destructive writes stay blocked at the privilege layer.
BEGIN;
SET LOCAL ROLE duta_app;
SELECT pg_temp.assert_denied('SELECT * FROM public.audit_logs', 'PRIVILEGE', 'duta_app audit select');
SELECT pg_temp.assert_denied('DELETE FROM public.audit_logs', 'PRIVILEGE', 'duta_app audit delete');
SELECT pg_temp.assert_denied('UPDATE public.audit_logs SET action = ''x''', 'PRIVILEGE', 'duta_app audit update');
SELECT pg_temp.assert_denied('TRUNCATE public.audit_logs', 'PRIVILEGE', 'duta_app audit truncate');
ROLLBACK;

-- Missing identity: the grant is no longer the blocker, the policy is.
BEGIN;
SET LOCAL ROLE duta_app;
SELECT pg_temp.assert_denied(
  'INSERT INTO public.audit_logs(actor_id,action,entity_type) VALUES (''10000000-0000-4000-8000-0000000000a1'',''profile_update'',''user'')',
  'RLS', 'missing app.user_id');
ROLLBACK;

-- Mismatched actor: a row cannot be attributed to somebody else.
BEGIN;
SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id', '10000000-0000-4000-8000-0000000000a1', true);
SELECT pg_temp.assert_denied(
  'INSERT INTO public.audit_logs(actor_id,action,entity_type) VALUES (''10000000-0000-4000-8000-0000000000b2'',''profile_update'',''user'')',
  'RLS', 'forged audit actor');
ROLLBACK;

-- Action outside the governed allowlist.
BEGIN;
SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id', '10000000-0000-4000-8000-0000000000a1', true);
SELECT pg_temp.assert_denied(
  'INSERT INTO public.audit_logs(actor_id,action,entity_type) VALUES (''10000000-0000-4000-8000-0000000000a1'',''attacker.action'',''user'')',
  'RLS', 'non-allowlisted action');
ROLLBACK;

-- A matching actor and a governed action is the one path the grant opens.
BEGIN;
SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id', '10000000-0000-4000-8000-0000000000a1', true);
INSERT INTO public.audit_logs(actor_id,action,entity_type)
  VALUES ('10000000-0000-4000-8000-0000000000a1','profile_update','user');
ROLLBACK;

-- Every denied write above left the table untouched.
DO $$
BEGIN
  IF (SELECT count(*) FROM public.audit_logs) <> 0 THEN
    RAISE EXCEPTION 'denied writes changed the table';
  END IF;
END
$$;
