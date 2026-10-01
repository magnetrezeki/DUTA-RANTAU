\set ON_ERROR_STOP on

DO $$
BEGIN
  IF to_regclass('public.users') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: public.users missing';
  END IF;

  IF to_regclass('public.entities') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: public.entities missing';
  END IF;

  IF to_regclass('public.jobs') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: public.jobs missing';
  END IF;

  IF to_regtype('public.user_role') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: public.user_role missing';
  END IF;

  IF to_regprocedure('public.has_system_role(public.user_role[])') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: has_system_role missing';
  END IF;

  IF to_regprocedure('auth.uid()') IS NULL THEN
    RAISE EXCEPTION '0050 prestate failed: auth.uid missing';
  END IF;

  IF to_regclass('public.entity_eligibilities') IS NOT NULL
     OR to_regtype('public.eligibility_type') IS NOT NULL
     OR to_regtype('public.eligibility_status') IS NOT NULL
     OR to_regtype('public.eligibility_decision_source') IS NOT NULL THEN
    RAISE EXCEPTION '0050 prestate failed: eligibility foundation unexpectedly present';
  END IF;

  IF to_regprocedure('public.enforce_job_posting_safety()') IS NOT NULL THEN
    RAISE EXCEPTION '0050 prestate failed: job safety function unexpectedly present';
  END IF;
END
$$;