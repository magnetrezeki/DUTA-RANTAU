-- LOCAL TEST ONLY. Structural verification for migration 0041.
-- Run after the migration; asserts the grant is present, narrow, and that
-- nothing else about the table moved.
\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(condition boolean, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF condition IS DISTINCT FROM true THEN RAISE EXCEPTION 'assertion failed: %', label; END IF;
END
$$;

SELECT pg_temp.assert_true(
  has_table_privilege('duta_app','public.audit_logs','INSERT'),
  'duta_app holds audit_logs INSERT'
);

-- The grant must be exactly INSERT. No read, mutate, or destroy privilege.
SELECT pg_temp.assert_true(
  NOT has_table_privilege('duta_app','public.audit_logs','SELECT')
  AND NOT has_table_privilege('duta_app','public.audit_logs','UPDATE')
  AND NOT has_table_privilege('duta_app','public.audit_logs','DELETE')
  AND NOT has_table_privilege('duta_app','public.audit_logs','TRUNCATE')
  AND NOT has_table_privilege('duta_app','public.audit_logs','REFERENCES')
  AND NOT has_table_privilege('duta_app','public.audit_logs','TRIGGER'),
  'duta_app holds no other audit_logs privilege'
);

-- Column-scoped grants must not be used to widen or narrow the table grant.
SELECT pg_temp.assert_true(
  NOT EXISTS (
    SELECT 1 FROM pg_attribute
    WHERE attrelid='public.audit_logs'::regclass AND attnum>0 AND NOT attisdropped AND attacl IS NOT NULL
  ),
  'no column-level ACL entries on audit_logs'
);

SELECT pg_temp.assert_true(
  EXISTS (
    SELECT 1 FROM pg_policy
    WHERE polrelid='public.audit_logs'::regclass
      AND polname IN ('audit_user_insert','audit_logs_content_admin')
      AND polcmd='a' AND 'duta_app'::regrole = ANY(polroles)
  ),
  'duta_app insert policies still present'
);

SELECT pg_temp.assert_true(
  (SELECT count(*) FROM pg_policy WHERE polrelid='public.audit_logs'::regclass)=3,
  'policy count unchanged'
);

SELECT pg_temp.assert_true(
  (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class WHERE oid='public.audit_logs'::regclass),
  'RLS enabled and still not forced, as 0038 requires'
);

SELECT pg_temp.assert_true(
  NOT (SELECT rolsuper OR rolbypassrls FROM pg_roles WHERE rolname='duta_app'),
  'duta_app remains NOSUPERUSER and NOBYPASSRLS'
);

SELECT pg_temp.assert_true(
  (SELECT count(*) FROM public.audit_logs)=0,
  'no data mutation'
);

ROLLBACK;
