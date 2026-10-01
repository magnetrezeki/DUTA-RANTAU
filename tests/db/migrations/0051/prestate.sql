\set ON_ERROR_STOP on

DO $$
BEGIN
  IF to_regtype('public.record_status') IS NULL THEN
    RAISE EXCEPTION '0051 prestate failed: record_status missing';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid=e.enumtypid
    JOIN pg_namespace n ON n.oid=t.typnamespace
    WHERE n.nspname='public'
      AND t.typname='record_status'
      AND e.enumlabel='REJECTED'
  ) THEN
    RAISE EXCEPTION '0051 prestate failed: REJECTED already present';
  END IF;
END
$$;