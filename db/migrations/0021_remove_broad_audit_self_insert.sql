BEGIN;

DROP POLICY IF EXISTS audit_logs_self_insert
ON public.audit_logs;

COMMIT;
