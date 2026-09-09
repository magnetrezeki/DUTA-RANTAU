-- Verification for the minimal isolated local-test bootstrap. This script fails
-- fast when the required role, RLS, grants, or deterministic seed is absent.
\set ON_ERROR_STOP on

DO $$
DECLARE
  app_role pg_roles%ROWTYPE;
  policy_count integer;
BEGIN
  IF to_regclass('public.official_sources') IS NULL THEN
    RAISE EXCEPTION 'public.official_sources is missing';
  END IF;

  SELECT * INTO app_role FROM pg_roles WHERE rolname = 'duta_app';
  IF NOT FOUND OR NOT app_role.rolcanlogin OR app_role.rolsuper OR app_role.rolbypassrls
    OR app_role.rolcreaterole OR app_role.rolcreatedb OR app_role.rolreplication THEN
    RAISE EXCEPTION 'duta_app does not satisfy restricted runtime-role requirements';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_class relation
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public'
      AND relation.relkind IN ('r', 'p')
      AND relation.relowner = app_role.oid
  ) THEN
    RAISE EXCEPTION 'duta_app must not own public tables';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_class relation
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    WHERE namespace.nspname = 'public'
      AND relation.relname = 'official_sources'
      AND relation.relrowsecurity
  ) THEN
    RAISE EXCEPTION 'official_sources must have RLS enabled';
  END IF;

  SELECT count(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename = 'official_sources';
  IF policy_count <> 1 OR NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'official_sources'
      AND policyname = 'official_sources_active_select'
      AND cmd = 'SELECT'
      AND roles = ARRAY['duta_app']::name[]
  ) THEN
    RAISE EXCEPTION 'official_sources must have exactly the required duta_app SELECT policy';
  END IF;

  IF NOT has_table_privilege('duta_app', 'public.official_sources', 'SELECT')
    OR has_table_privilege('duta_app', 'public.official_sources', 'INSERT')
    OR has_table_privilege('duta_app', 'public.official_sources', 'UPDATE')
    OR has_table_privilege('duta_app', 'public.official_sources', 'DELETE')
    OR has_table_privilege('duta_app', 'public.official_sources', 'TRUNCATE')
    OR has_table_privilege('duta_app', 'public.official_sources', 'REFERENCES')
    OR has_table_privilege('duta_app', 'public.official_sources', 'TRIGGER') THEN
    RAISE EXCEPTION 'duta_app table grants are not restricted to SELECT';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.official_sources
    WHERE id = '00000000-0000-4000-8000-000000000101'
      AND institution = 'KJRI Penang'
      AND priority = 'P0'
      AND trust_level = 'OFFICIAL_VERIFIED'
      AND last_checked = '2026-08-16T00:00:00Z'
      AND active
  ) OR NOT EXISTS (
    SELECT 1 FROM public.official_sources
    WHERE id = '00000000-0000-4000-8000-000000000102' AND NOT active
  ) THEN
    RAISE EXCEPTION 'deterministic synthetic seed is incomplete';
  END IF;
END
$$;

BEGIN;
SET LOCAL ROLE duta_app;

DO $$
DECLARE
  visible_active integer;
  visible_inactive integer;
BEGIN
  IF current_user <> 'duta_app' THEN
    RAISE EXCEPTION 'verification did not assume duta_app';
  END IF;

  SELECT count(*) INTO visible_active FROM public.official_sources WHERE active;
  SELECT count(*) INTO visible_inactive FROM public.official_sources WHERE NOT active;
  IF visible_active <> 1 OR visible_inactive <> 0 THEN
    RAISE EXCEPTION 'duta_app SELECT behavior does not enforce active-only RLS';
  END IF;
END
$$;

ROLLBACK;
