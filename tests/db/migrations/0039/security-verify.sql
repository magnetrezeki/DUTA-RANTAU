-- LOCAL TEST ONLY. Security behavior verification for 0039.
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.assert_denied(statement_text text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN
    EXECUTE statement_text;
    RAISE EXCEPTION 'expected denial: %', label;
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END
$$;

CREATE OR REPLACE FUNCTION pg_temp.assert_check_rejected(statement_text text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN
    EXECUTE statement_text;
    RAISE EXCEPTION 'expected check rejection: %', label;
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
END
$$;

BEGIN;
UPDATE public.official_sources SET source_purpose='NEWS'
WHERE id='00000000-0000-4000-8000-000000000101';
SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id', '00000000-0000-4000-8000-000000000001', true);

UPDATE public.official_sources SET priority='P1'
WHERE id='00000000-0000-4000-8000-000000000101';

SELECT pg_temp.assert_denied(
  $$UPDATE public.official_sources SET source_purpose='CONTACT' WHERE id='00000000-0000-4000-8000-000000000101'$$,
  'duta_app cannot set source purpose'
);
SELECT pg_temp.assert_denied(
  $$UPDATE public.official_sources SET source_purpose=NULL WHERE id='00000000-0000-4000-8000-000000000101'$$,
  'duta_app cannot clear source purpose'
);
SELECT pg_temp.assert_denied(
  $$INSERT INTO public.official_sources (institution,channel,url,category,priority,trust_level,last_checked,active,source_purpose) VALUES ('Synthetic','website','https://source.example.invalid/new','general','P0','OFFICIAL_VERIFIED',now(),true,'NEWS')$$,
  'duta_app cannot insert classified source'
);
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance', 'duta_app cannot read governance');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_governance (source_id) VALUES ('00000000-0000-4000-8000-000000000101')$$, 'duta_app cannot insert governance');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence', 'duta_app cannot read evidence');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at) VALUES ('00000000-0000-4000-8000-000000000101','https://evidence.example.invalid/one','PRIMARY_OFFICIAL_SOURCE',now())$$, 'duta_app cannot insert evidence');

RESET ROLE;

SELECT pg_temp.assert_check_rejected(
  $$INSERT INTO public.official_source_governance (source_id, production_approved) VALUES ('00000000-0000-4000-8000-000000000101',true)$$,
  'approval requires verification'
);
SELECT pg_temp.assert_check_rejected(
  $$INSERT INTO public.official_source_governance (source_id, official_source_verified) VALUES ('00000000-0000-4000-8000-000000000101',true)$$,
  'verification requires identity and metadata'
);

ROLLBACK;
