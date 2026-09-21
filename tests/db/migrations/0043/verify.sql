\set ON_ERROR_STOP on

DO $$
DECLARE
  trigger_definition text;
BEGIN
  IF has_schema_privilege('duta_app', 'auth', 'USAGE') THEN
    RAISE EXCEPTION '0043 must not grant duta_app usage on auth schema';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee='duta_app' AND table_schema='auth'
  ) THEN
    RAISE EXCEPTION '0043 granted duta_app access to auth tables';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_proc function
    WHERE function.oid='public.current_app_has_org_role(uuid,public.organization_role[])'::regprocedure
      AND function.prosecdef
      AND (
        function.proconfig @> ARRAY['search_path=""']::text[]
        OR function.proconfig @> ARRAY['search_path=']::text[]
      )
      AND pg_get_userbyid(function.proowner)='postgres'
  ) THEN
    RAISE EXCEPTION 'runtime organization helper security contract mismatch';
  END IF;

  SELECT pg_get_functiondef('public.enforce_organization_member_role_change()'::regprocedure)
    INTO trigger_definition;
  IF trigger_definition ~ 'auth\.uid\s*\(' OR trigger_definition !~ 'public\.current_app_user_id\s*\(' THEN
    RAISE EXCEPTION 'organization trigger still depends on auth.uid()';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND policyname IN ('communities_public','jobs_public','products_public','sellers_public_read')
      AND 'duta_app'=ANY(roles)
  ) THEN
    RAISE EXCEPTION 'legacy JWT policy still targets duta_app';
  END IF;
END
$$;

\echo 0043_VERIFY=PASS
