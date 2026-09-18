-- LOCAL TEST ONLY. Negative authorization verification for migration 0040.
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.assert_denied(statement_text text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN
    EXECUTE statement_text;
    RAISE EXCEPTION 'expected permission denial: %', label;
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END
$$;

BEGIN;
SET LOCAL ROLE anon;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','anon governance select');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','anon evidence select');
RESET ROLE;
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','authenticated governance select');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','authenticated evidence select');
RESET ROLE;
SET LOCAL ROLE duta_app;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','duta_app governance select');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','duta_app evidence select');
RESET ROLE;
SET LOCAL ROLE duta_system;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','duta_system governance select');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','duta_system evidence select');
ROLLBACK;
