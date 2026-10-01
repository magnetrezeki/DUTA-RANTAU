-- DUTA RANTAU Production forward reconciliation.
-- Restore the canonical record_status value introduced by migration 0042
-- but missing from Production.
-- No table, policy, role, grant, RLS, or data-row changes.

DO $$
BEGIN
  IF to_regtype('public.record_status') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.record_status is missing';
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
    RAISE EXCEPTION 'precondition failed: REJECTED already exists in public.record_status';
  END IF;
END
$$;

ALTER TYPE public.record_status
ADD VALUE 'REJECTED' AFTER 'ACTIVE';