-- LOCAL/DISPOSABLE DATABASE ONLY. Run after 0042.
\set ON_ERROR_STOP on
DO $$
DECLARE policy_count integer;
BEGIN
  SELECT count(*) INTO policy_count FROM pg_policies
  WHERE schemaname='public' AND policyname IN (
    'jobs_runtime_owner','jobs_runtime_moderator','products_runtime_owner',
    'products_runtime_moderator','communities_runtime_owner',
    'organizations_runtime_owner_update','notifications_runtime_owner'
  );
  IF policy_count <> 7 THEN RAISE EXCEPTION '0042 runtime policy contract mismatch: %', policy_count; END IF;
END
$$;
\echo 0042_VERIFY=PASS