-- LOCAL/DISPOSABLE DATABASE ONLY. Negative authorization checks for 0042.
\set ON_ERROR_STOP on
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_app' AND rolbypassrls) THEN
    RAISE EXCEPTION 'duta_app must remain NOBYPASSRLS';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE oid='public.current_app_can_add_community_membership(uuid,uuid,text)'::regprocedure
      AND prosecdef
  ) THEN RAISE EXCEPTION 'membership authorization helper must be SECURITY DEFINER'; END IF;
END
$$;
\echo 0042_SECURITY_VERIFY=PASS