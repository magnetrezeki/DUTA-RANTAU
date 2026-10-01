\set ON_ERROR_STOP on

DO $$
DECLARE
  rejected_count integer;
BEGIN
  SELECT count(*)
    INTO rejected_count
  FROM pg_enum e
  JOIN pg_type t ON t.oid=e.enumtypid
  JOIN pg_namespace n ON n.oid=t.typnamespace
  WHERE n.nspname='public'
    AND t.typname='record_status'
    AND e.enumlabel='REJECTED';

  IF rejected_count <> 1 THEN
    RAISE EXCEPTION '0051 verification failed: expected exactly one REJECTED enum value';
  END IF;
END
$$;

SELECT '0051_VERIFY=PASS';