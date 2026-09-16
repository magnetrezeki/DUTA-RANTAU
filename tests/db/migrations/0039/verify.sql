-- LOCAL TEST ONLY. Catalog-level structural verification for 0039.
\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(condition boolean, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF condition IS DISTINCT FROM true THEN RAISE EXCEPTION 'assertion failed: %', label; END IF;
END
$$;

CREATE OR REPLACE FUNCTION pg_temp.assert_fk(source_table regclass, source_column text, target_table regclass, target_column text, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  PERFORM 1 FROM pg_constraint c
  JOIN pg_attribute source_attribute ON source_attribute.attrelid=c.conrelid AND source_attribute.attnum=c.conkey[1]
  JOIN pg_attribute target_attribute ON target_attribute.attrelid=c.confrelid AND target_attribute.attnum=c.confkey[1]
  WHERE c.contype='f' AND c.conrelid=source_table AND source_attribute.attname=source_column
    AND c.confrelid=target_table AND target_attribute.attname=target_column
    AND cardinality(c.conkey)=1 AND cardinality(c.confkey)=1
    AND c.confdeltype='r' AND c.confupdtype='a';
  IF NOT FOUND THEN RAISE EXCEPTION 'foreign key mismatch: %', label; END IF;
END
$$;

CREATE OR REPLACE FUNCTION pg_temp.assert_column(
  table_name regclass,
  column_name text,
  expected_type regtype,
  expected_not_null boolean,
  expected_default text,
  label text
)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  actual_type oid;
  actual_not_null boolean;
  default_expression text;
  normalized_default text;
BEGIN
  SELECT attribute_row.atttypid, attribute_row.attnotnull, pg_get_expr(default_row.adbin, default_row.adrelid)
    INTO actual_type, actual_not_null, default_expression
  FROM pg_attribute attribute_row
  LEFT JOIN pg_attrdef default_row ON default_row.adrelid=attribute_row.attrelid AND default_row.adnum=attribute_row.attnum
  WHERE attribute_row.attrelid=table_name AND attribute_row.attname=column_name AND attribute_row.attnum>0 AND NOT attribute_row.attisdropped;
  IF NOT FOUND OR actual_type<>expected_type OR actual_not_null IS DISTINCT FROM expected_not_null THEN
    RAISE EXCEPTION 'column type/nullability mismatch: %', label;
  END IF;
  normalized_default := regexp_replace(lower(coalesce(default_expression,'')), '[[:space:]()]', '', 'g');
  IF (expected_default='NONE' AND default_expression IS NOT NULL)
    OR (expected_default='FALSE' AND normalized_default !~ '^false(::boolean)?$')
    OR (expected_default='UNKNOWN' AND normalized_default !~ '^''unknown''::(public[.])?official_source_currentness$')
    OR (expected_default='NOW' AND normalized_default !~ '^(now|current_timestamp)$')
    OR (expected_default='GEN_RANDOM_UUID' AND normalized_default !~ '^gen_random_uuid$') THEN
    RAISE EXCEPTION 'column default mismatch: %', label;
  END IF;
END
$$;

DO $$
DECLARE
  purpose_values text[];
  currentness_values text[];
  governance_columns text[];
  evidence_columns text[];
  governance_id uuid := '00000000-0000-4000-8000-000000000201';
  evidence_id uuid := '00000000-0000-4000-8000-000000000202';
BEGIN
  SELECT array_agg(enumlabel ORDER BY enumsortorder) INTO purpose_values FROM pg_enum WHERE enumtypid='public.source_purpose'::regtype;
  PERFORM pg_temp.assert_true(purpose_values=ARRAY['NEWS','CONSULAR_SERVICE','CONTACT'], 'source_purpose values');
  SELECT array_agg(enumlabel ORDER BY enumsortorder) INTO currentness_values FROM pg_enum WHERE enumtypid='public.official_source_currentness'::regtype;
  PERFORM pg_temp.assert_true(currentness_values=ARRAY['UNKNOWN','CURRENT','STALE','REVIEW_REQUIRED'], 'currentness values');

  PERFORM pg_temp.assert_true(EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attname='source_purpose' AND atttypid='public.source_purpose'::regtype AND NOT attnotnull AND NOT attisdropped), 'nullable source_purpose type');
  PERFORM pg_temp.assert_column('public.official_sources'::regclass,'source_purpose','public.source_purpose'::regtype,false,'NONE','source_purpose');
  PERFORM pg_temp.assert_true(EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attname='last_checked' AND NOT attisdropped) AND NOT EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attname='last_checked_at' AND NOT attisdropped), 'last_checked canonical');
  PERFORM pg_temp.assert_true((SELECT source_purpose IS NULL FROM public.official_sources WHERE id='00000000-0000-4000-8000-000000000101'), 'legacy unclassified');

  SELECT array_agg(attname ORDER BY attnum) INTO governance_columns FROM pg_attribute WHERE attrelid='public.official_source_governance'::regclass AND attnum>0 AND NOT attisdropped;
  PERFORM pg_temp.assert_true(governance_columns=ARRAY['source_id','identity_verified','official_source_verified','currentness','verified_at','verified_by','production_approved','approved_at','approved_by','next_review_at','created_at','updated_at'], 'governance columns');
  PERFORM pg_temp.assert_true((SELECT array_agg(a.attname ORDER BY a.attnum) FROM pg_index i JOIN pg_attribute a ON a.attrelid=i.indrelid AND a.attnum=ANY(i.indkey) WHERE i.indrelid='public.official_source_governance'::regclass AND i.indisprimary)=ARRAY['source_id'], 'governance primary key');
  PERFORM pg_temp.assert_fk('public.official_source_governance'::regclass,'source_id','public.official_sources'::regclass,'id','governance source');
  PERFORM pg_temp.assert_fk('public.official_source_governance'::regclass,'verified_by','public.users'::regclass,'id','governance verifier');
  PERFORM pg_temp.assert_fk('public.official_source_governance'::regclass,'approved_by','public.users'::regclass,'id','governance approver');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'source_id','uuid'::regtype,true,'NONE','governance source_id');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'identity_verified','boolean'::regtype,true,'FALSE','governance identity_verified');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'official_source_verified','boolean'::regtype,true,'FALSE','governance official_source_verified');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'currentness','public.official_source_currentness'::regtype,true,'UNKNOWN','governance currentness');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'verified_at','timestamp with time zone'::regtype,false,'NONE','governance verified_at');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'verified_by','uuid'::regtype,false,'NONE','governance verified_by');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'production_approved','boolean'::regtype,true,'FALSE','governance production_approved');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'approved_at','timestamp with time zone'::regtype,false,'NONE','governance approved_at');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'approved_by','uuid'::regtype,false,'NONE','governance approved_by');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'next_review_at','timestamp with time zone'::regtype,false,'NONE','governance next_review_at');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'created_at','timestamp with time zone'::regtype,true,'NOW','governance created_at');
  PERFORM pg_temp.assert_column('public.official_source_governance'::regclass,'updated_at','timestamp with time zone'::regtype,true,'NOW','governance updated_at');
  PERFORM pg_temp.assert_true(EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_source_governance'::regclass AND attname='identity_verified' AND atttypid='boolean'::regtype AND attnotnull) AND EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_source_governance'::regclass AND attname='official_source_verified' AND atttypid='boolean'::regtype AND attnotnull) AND EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_source_governance'::regclass AND attname='production_approved' AND atttypid='boolean'::regtype AND attnotnull) AND EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.official_source_governance'::regclass AND attname='currentness' AND atttypid='public.official_source_currentness'::regtype AND attnotnull), 'governance required types');
  PERFORM pg_temp.assert_true(
    (SELECT regexp_replace(lower(pg_get_constraintdef(oid)), '[[:space:]()]', '', 'g') FROM pg_constraint WHERE conrelid='public.official_source_governance'::regclass AND conname='official_source_governance_verification_metadata_ck')
      = 'checkofficial_source_verifiedandidentity_verifiedandverified_atisnotnullandverified_byisnotnullornotofficial_source_verifiedandverified_atisnullandverified_byisnull'
    AND
    (SELECT regexp_replace(lower(pg_get_constraintdef(oid)), '[[:space:]()]', '', 'g') FROM pg_constraint WHERE conrelid='public.official_source_governance'::regclass AND conname='official_source_governance_approval_metadata_ck')
      = 'checkproduction_approvedandidentity_verifiedandofficial_source_verifiedandapproved_atisnotnullandapproved_byisnotnullornotproduction_approvedandapproved_atisnullandapproved_byisnull',
    'complete governance checks'
  );

  SELECT array_agg(attname ORDER BY attnum) INTO evidence_columns FROM pg_attribute WHERE attrelid='public.official_source_evidence'::regclass AND attnum>0 AND NOT attisdropped;
  PERFORM pg_temp.assert_true(evidence_columns=ARRAY['id','source_id','evidence_url','evidence_type','checked_at','reviewed_by','created_at','updated_at'], 'evidence columns');
  PERFORM pg_temp.assert_true((SELECT array_agg(a.attname ORDER BY a.attnum) FROM pg_index i JOIN pg_attribute a ON a.attrelid=i.indrelid AND a.attnum=ANY(i.indkey) WHERE i.indrelid='public.official_source_evidence'::regclass AND i.indisprimary)=ARRAY['id'], 'evidence primary key');
  PERFORM pg_temp.assert_fk('public.official_source_evidence'::regclass,'source_id','public.official_sources'::regclass,'id','evidence source');
  PERFORM pg_temp.assert_fk('public.official_source_evidence'::regclass,'reviewed_by','public.users'::regclass,'id','evidence reviewer');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'id','uuid'::regtype,true,'GEN_RANDOM_UUID','evidence id');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'source_id','uuid'::regtype,true,'NONE','evidence source_id');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'evidence_url','text'::regtype,true,'NONE','evidence url');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'evidence_type','text'::regtype,true,'NONE','evidence type');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'checked_at','timestamp with time zone'::regtype,true,'NONE','evidence checked_at');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'reviewed_by','uuid'::regtype,false,'NONE','evidence reviewed_by');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'created_at','timestamp with time zone'::regtype,true,'NOW','evidence created_at');
  PERFORM pg_temp.assert_column('public.official_source_evidence'::regclass,'updated_at','timestamp with time zone'::regtype,true,'NOW','evidence updated_at');
  PERFORM pg_temp.assert_true(EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.official_source_evidence'::regclass AND contype='u' AND pg_get_constraintdef(oid)='UNIQUE (source_id, evidence_url)'), 'evidence uniqueness');

  PERFORM pg_temp.assert_true((SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class WHERE oid='public.official_source_governance'::regclass) AND (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class WHERE oid='public.official_source_evidence'::regclass), 'RLS no FORCE');
  PERFORM pg_temp.assert_true(NOT EXISTS (SELECT 1 FROM pg_policy WHERE polrelid IN ('public.official_source_governance'::regclass,'public.official_source_evidence'::regclass)), 'restricted policies absent');
  PERFORM pg_temp.assert_true(NOT EXISTS (SELECT 1 FROM pg_roles r CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER']) p WHERE r.rolname IN ('duta_app','duta_system','anon','authenticated') AND (has_table_privilege(r.oid,'public.official_source_governance',p) OR has_table_privilege(r.oid,'public.official_source_evidence',p))), 'restricted application grants absent');
  PERFORM pg_temp.assert_true(NOT has_table_privilege('duta_app','public.official_sources','INSERT') AND NOT has_table_privilege('duta_app','public.official_sources','UPDATE') AND has_table_privilege('duta_app','public.official_sources','SELECT') AND has_table_privilege('duta_app','public.official_sources','DELETE'), 'source table privileges');
  PERFORM pg_temp.assert_true((SELECT array_agg(attname ORDER BY attnum) FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attnum>0 AND NOT attisdropped AND has_column_privilege('duta_app','public.official_sources',attname,'INSERT'))=ARRAY['institution','channel','url','category','priority','trust_level','last_checked','checksum','active'] AND (SELECT array_agg(attname ORDER BY attnum) FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attnum>0 AND NOT attisdropped AND has_column_privilege('duta_app','public.official_sources',attname,'UPDATE'))=ARRAY['priority','trust_level','active'], 'source column privileges');
  PERFORM pg_temp.assert_true(NOT EXISTS (SELECT 1 FROM public.official_source_governance) AND NOT EXISTS (SELECT 1 FROM public.official_source_evidence), 'no automatic rows');

  INSERT INTO public.official_sources (id,institution,channel,url,category,priority,trust_level,last_checked,active) VALUES (governance_id,'Synthetic governance','website','https://source.example.invalid/governance','general','P0','OFFICIAL_VERIFIED',now(),true);
  INSERT INTO public.official_source_governance (source_id) VALUES (governance_id);
  PERFORM pg_temp.assert_true((SELECT NOT identity_verified AND NOT official_source_verified AND currentness='UNKNOWN'::public.official_source_currentness AND verified_at IS NULL AND verified_by IS NULL AND NOT production_approved AND approved_at IS NULL AND approved_by IS NULL AND next_review_at IS NULL FROM public.official_source_governance WHERE source_id=governance_id), 'governance defaults');
  INSERT INTO public.official_sources (id,institution,channel,url,category,priority,trust_level,last_checked,active) VALUES (evidence_id,'Synthetic evidence','website','https://source.example.invalid/evidence','general','P0','OFFICIAL_VERIFIED',now(),true);
  INSERT INTO public.official_source_evidence (source_id,evidence_url,evidence_type,checked_at) VALUES (evidence_id,'https://evidence.example.invalid/without-governance','PRIMARY_OFFICIAL_SOURCE',now());
  PERFORM pg_temp.assert_true(NOT EXISTS (SELECT 1 FROM public.official_source_governance WHERE source_id=evidence_id), 'evidence without governance');
END
$$;

ROLLBACK;
