-- LOCAL/DISPOSABLE DATABASE ONLY. Negative authorization checks for 0043.
\set ON_ERROR_STOP on
DO $$
BEGIN
  IF has_schema_privilege('duta_app', 'auth', 'USAGE') THEN
    RAISE EXCEPTION '0043 must not grant duta_app usage on auth schema';
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.role_table_grants WHERE grantee='duta_app' AND table_schema='auth') THEN
    RAISE EXCEPTION '0043 must not grant duta_app access to auth tables';
  END IF;
END
$$;
\echo 0043_SECURITY_VERIFY=PASS