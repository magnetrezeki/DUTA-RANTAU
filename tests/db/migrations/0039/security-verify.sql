-- LOCAL TEST ONLY. Behavioral security verification for 0039.
-- Owner setup below is not application authorization or a reviewer workflow.
\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION pg_temp.assert_true(condition boolean, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF condition IS DISTINCT FROM true THEN RAISE EXCEPTION 'assertion failed: %', label; END IF; END $$;
CREATE OR REPLACE FUNCTION pg_temp.assert_denied(statement_text text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN EXECUTE statement_text; RAISE EXCEPTION 'expected permission denial: %', label;
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END $$;
CREATE OR REPLACE FUNCTION pg_temp.assert_check_rejected(statement_text text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  BEGIN EXECUTE statement_text; RAISE EXCEPTION 'expected check violation: %', label;
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END $$;

BEGIN;

-- Owner-only synthetic setup used as targets for the negative cases.
UPDATE public.official_sources SET source_purpose='NEWS' WHERE id='00000000-0000-4000-8000-000000000101';
INSERT INTO public.official_sources (id,institution,channel,url,category,priority,trust_level,last_checked,active) VALUES
  ('00000000-0000-4000-8000-000000000102','Synthetic restricted','website','https://source.example.invalid/restricted','general','P0','OFFICIAL_VERIFIED',now(),true),
  ('00000000-0000-4000-8000-000000000201','Synthetic invalid one','website','https://source.example.invalid/invalid-one','general','P0','OFFICIAL_VERIFIED',now(),true),
  ('00000000-0000-4000-8000-000000000202','Synthetic invalid two','website','https://source.example.invalid/invalid-two','general','P0','OFFICIAL_VERIFIED',now(),true),
  ('00000000-0000-4000-8000-000000000203','Synthetic invalid three','website','https://source.example.invalid/invalid-three','general','P0','OFFICIAL_VERIFIED',now(),true),
  ('00000000-0000-4000-8000-000000000204','Synthetic invalid four','website','https://source.example.invalid/invalid-four','general','P0','OFFICIAL_VERIFIED',now(),true);
INSERT INTO public.official_source_governance (source_id,identity_verified,official_source_verified,verified_at,verified_by)
VALUES ('00000000-0000-4000-8000-000000000102',true,true,now(),'00000000-0000-4000-8000-000000000001');
INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at)
VALUES ('00000000-0000-4000-8000-000000000102','https://evidence.example.invalid/restricted','PRIMARY_OFFICIAL_SOURCE',now());

SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id','00000000-0000-4000-8000-000000000001',true);
SELECT pg_temp.assert_true(EXISTS (SELECT 1 FROM public.official_sources WHERE id='00000000-0000-4000-8000-000000000101' AND active), 'duta_app reads active source');
UPDATE public.official_sources SET priority='P1' WHERE id='00000000-0000-4000-8000-000000000101';
SELECT pg_temp.assert_true((SELECT priority='P1' FROM public.official_sources WHERE id='00000000-0000-4000-8000-000000000101'), 'duta_app updates priority');
INSERT INTO public.official_sources (institution,channel,url,category,priority,trust_level,last_checked,active)
VALUES ('Synthetic legacy insert','website','https://source.example.invalid/legacy-insert','general','P0','OFFICIAL_VERIFIED',now(),true);
SELECT pg_temp.assert_true((SELECT source_purpose IS NULL FROM public.official_sources WHERE url='https://source.example.invalid/legacy-insert'), 'legacy insert remains unclassified');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_sources (institution,channel,url,category,priority,trust_level,last_checked,active,source_purpose) VALUES ('Synthetic','website','https://source.example.invalid/denied-insert','general','P0','OFFICIAL_VERIFIED',now(),true,'NEWS')$$, 'duta_app purpose insert');
SELECT pg_temp.assert_denied($$UPDATE public.official_sources SET source_purpose='CONTACT' WHERE url='https://source.example.invalid/legacy-insert'$$, 'duta_app purpose update');
SELECT pg_temp.assert_denied($$UPDATE public.official_sources SET source_purpose='CONTACT' WHERE id='00000000-0000-4000-8000-000000000101'$$, 'duta_app purpose change');
SELECT pg_temp.assert_denied($$UPDATE public.official_sources SET source_purpose=NULL WHERE id='00000000-0000-4000-8000-000000000101'$$, 'duta_app purpose clear');

SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','duta_app governance select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_governance (source_id) VALUES ('00000000-0000-4000-8000-000000000101')$$,'duta_app governance insert');
SELECT pg_temp.assert_denied($$UPDATE public.official_source_governance SET currentness='STALE' WHERE source_id='00000000-0000-4000-8000-000000000102'$$,'duta_app governance update');
SELECT pg_temp.assert_denied($$DELETE FROM public.official_source_governance WHERE source_id='00000000-0000-4000-8000-000000000102'$$,'duta_app governance delete');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','duta_app evidence select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at) VALUES ('00000000-0000-4000-8000-000000000101','https://evidence.example.invalid/denied','PRIMARY_OFFICIAL_SOURCE',now())$$,'duta_app evidence insert');
SELECT pg_temp.assert_denied($$UPDATE public.official_source_evidence SET evidence_type='OTHER' WHERE source_id='00000000-0000-4000-8000-000000000102'$$,'duta_app evidence update');
SELECT pg_temp.assert_denied($$DELETE FROM public.official_source_evidence WHERE source_id='00000000-0000-4000-8000-000000000102'$$,'duta_app evidence delete');

RESET ROLE;
SET LOCAL ROLE anon;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','anon governance select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_governance (source_id) VALUES ('00000000-0000-4000-8000-000000000101')$$,'anon governance insert');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','anon evidence select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at) VALUES ('00000000-0000-4000-8000-000000000101','https://evidence.example.invalid/anon','PRIMARY_OFFICIAL_SOURCE',now())$$,'anon evidence insert');
RESET ROLE;
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','authenticated governance select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_governance (source_id) VALUES ('00000000-0000-4000-8000-000000000101')$$,'authenticated governance insert');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','authenticated evidence select');
SELECT pg_temp.assert_denied($$INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at) VALUES ('00000000-0000-4000-8000-000000000101','https://evidence.example.invalid/authenticated','PRIMARY_OFFICIAL_SOURCE',now())$$,'authenticated evidence insert');
RESET ROLE;
SET LOCAL ROLE duta_system;
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_governance','duta_system governance select');
SELECT pg_temp.assert_denied('SELECT * FROM public.official_source_evidence','duta_system evidence select');

RESET ROLE;
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,official_source_verified,verified_at,verified_by) VALUES ('00000000-0000-4000-8000-000000000201',true,now(),'00000000-0000-4000-8000-000000000001')$$,'verification requires identity');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,identity_verified,official_source_verified,verified_by) VALUES ('00000000-0000-4000-8000-000000000202',true,true,'00000000-0000-4000-8000-000000000001')$$,'verification requires timestamp');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,identity_verified,official_source_verified,verified_at) VALUES ('00000000-0000-4000-8000-000000000203',true,true,now())$$,'verification requires reviewer');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,verified_at) VALUES ('00000000-0000-4000-8000-000000000204',now())$$,'false verification metadata');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,production_approved) VALUES ('00000000-0000-4000-8000-000000000201',true)$$,'approval requires verification');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,identity_verified,official_source_verified,verified_at,verified_by,production_approved,approved_by) VALUES ('00000000-0000-4000-8000-000000000202',true,true,now(),'00000000-0000-4000-8000-000000000001',true,'00000000-0000-4000-8000-000000000001')$$,'approval requires timestamp');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,identity_verified,official_source_verified,verified_at,verified_by,production_approved,approved_at) VALUES ('00000000-0000-4000-8000-000000000203',true,true,now(),'00000000-0000-4000-8000-000000000001',true,now())$$,'approval requires reviewer');
SELECT pg_temp.assert_check_rejected($$INSERT INTO public.official_source_governance (source_id,approved_at) VALUES ('00000000-0000-4000-8000-000000000204',now())$$,'false approval metadata');

ROLLBACK;
