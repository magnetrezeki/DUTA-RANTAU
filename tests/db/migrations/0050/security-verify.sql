\set ON_ERROR_STOP on

DO $$
DECLARE
  public_roles name[];
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_class
    WHERE oid='public.entity_eligibilities'::regclass
      AND relrowsecurity
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: entity_eligibilities RLS disabled';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname='public'
      AND tablename='entity_eligibilities'
      AND policyname='entity_eligibility_owner_read'
      AND cmd='SELECT'
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: eligibility owner-read policy missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public'
      AND p.proname='enforce_job_posting_safety'
      AND p.prosecdef
      AND EXISTS (
        SELECT 1
        FROM unnest(COALESCE(p.proconfig, ARRAY[]::text[])) cfg
        WHERE cfg IN ('search_path=', 'search_path=""')
      )
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: safety function SECURITY DEFINER/search_path contract missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgrelid='public.jobs'::regclass
      AND tgname='enforce_job_posting_safety'
      AND NOT tgisinternal
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: safety trigger missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_owner'
      AND cmd='ALL'
      AND roles=ARRAY['duta_app']::name[]
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: runtime owner policy contract incorrect';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_moderator'
      AND cmd='UPDATE'
      AND roles=ARRAY['duta_app']::name[]
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: runtime moderator policy contract incorrect';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_moderator_read'
      AND cmd='SELECT'
      AND roles=ARRAY['duta_app']::name[]
  ) THEN
    RAISE EXCEPTION '0050 security verification failed: moderator-read policy contract incorrect';
  END IF;

  SELECT roles
    INTO public_roles
  FROM pg_policies
  WHERE schemaname='public'
    AND tablename='jobs'
    AND policyname='jobs_public';

  IF public_roles IS NULL
     OR NOT (public_roles @> ARRAY['anon','authenticated']::name[])
     OR NOT (ARRAY['anon','authenticated']::name[] @> public_roles) THEN
    RAISE EXCEPTION '0050 security verification failed: jobs_public roles incorrect';
  END IF;

  IF NOT has_table_privilege('duta_app','public.entity_eligibilities','SELECT') THEN
    RAISE EXCEPTION '0050 security verification failed: duta_app eligibility SELECT missing';
  END IF;

  IF NOT has_table_privilege('duta_app','public.jobs','SELECT')
     OR NOT has_table_privilege('duta_app','public.jobs','INSERT')
     OR NOT has_table_privilege('duta_app','public.jobs','UPDATE') THEN
    RAISE EXCEPTION '0050 security verification failed: duta_app jobs grants incomplete';
  END IF;
END
$$;

SELECT '0050_SECURITY_VERIFY=PASS';