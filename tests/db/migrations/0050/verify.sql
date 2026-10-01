\set ON_ERROR_STOP on

DO $$
BEGIN
  IF to_regtype('public.eligibility_type') IS NULL THEN
    RAISE EXCEPTION '0050 verification failed: eligibility_type missing';
  END IF;

  IF to_regtype('public.eligibility_status') IS NULL THEN
    RAISE EXCEPTION '0050 verification failed: eligibility_status missing';
  END IF;

  IF to_regtype('public.eligibility_decision_source') IS NULL THEN
    RAISE EXCEPTION '0050 verification failed: eligibility_decision_source missing';
  END IF;

  IF to_regclass('public.entity_eligibilities') IS NULL THEN
    RAISE EXCEPTION '0050 verification failed: entity_eligibilities missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname='public'
      AND tablename='entity_eligibilities'
      AND indexname='entity_eligibility_status_idx'
  ) THEN
    RAISE EXCEPTION '0050 verification failed: entity eligibility index missing';
  END IF;

  IF to_regprocedure('public.enforce_job_posting_safety()') IS NULL THEN
    RAISE EXCEPTION '0050 verification failed: job safety function missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgrelid='public.jobs'::regclass
      AND tgname='enforce_job_posting_safety'
      AND NOT tgisinternal
  ) THEN
    RAISE EXCEPTION '0050 verification failed: job safety trigger missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_owner'
  ) THEN
    RAISE EXCEPTION '0050 verification failed: jobs_runtime_owner missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_moderator'
  ) THEN
    RAISE EXCEPTION '0050 verification failed: jobs_runtime_moderator missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public'
      AND tablename='jobs'
      AND policyname='jobs_runtime_moderator_read'
  ) THEN
    RAISE EXCEPTION '0050 verification failed: jobs_runtime_moderator_read missing';
  END IF;
END
$$;

SELECT '0050_VERIFY=PASS';