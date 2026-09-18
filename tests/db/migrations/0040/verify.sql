-- LOCAL TEST ONLY. Structural/default-ACL verification for migration 0040.
\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(condition boolean, label text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF condition IS DISTINCT FROM true THEN RAISE EXCEPTION 'assertion failed: %', label; END IF;
END
$$;

SELECT pg_temp.assert_true(
  NOT EXISTS (
    SELECT 1 FROM pg_roles r
    CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER']) p
    WHERE r.rolname IN ('anon','authenticated')
      AND (has_table_privilege(r.oid,'public.official_source_governance',p)
        OR has_table_privilege(r.oid,'public.official_source_evidence',p))
  ),
  'current sensitive table grants removed'
);

SELECT pg_temp.assert_true(
  has_table_privilege('service_role','public.official_source_governance','SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
  AND has_table_privilege('service_role','public.official_source_evidence','SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'),
  'service_role provider grants preserved'
);

SELECT pg_temp.assert_true(
  NOT EXISTS (
    SELECT 1 FROM pg_roles r
    CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER']) p
    WHERE r.rolname IN ('duta_app','duta_system')
      AND (has_table_privilege(r.oid,'public.official_source_governance',p)
        OR has_table_privilege(r.oid,'public.official_source_evidence',p))
  ),
  'restricted runtime roles remain ungranted'
);

CREATE TABLE public._0040_future_acl_probe (id integer);
SELECT pg_temp.assert_true(
  NOT has_table_privilege('anon','public._0040_future_acl_probe','SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
  AND NOT has_table_privilege('authenticated','public._0040_future_acl_probe','SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'),
  'future postgres public table excludes public API roles'
);
SELECT pg_temp.assert_true(
  has_table_privilege('service_role','public._0040_future_acl_probe','SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'),
  'future postgres public table preserves service_role'
);

SELECT pg_temp.assert_true(
  (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class WHERE oid='public.official_source_governance'::regclass)
  AND (SELECT relrowsecurity AND NOT relforcerowsecurity FROM pg_class WHERE oid='public.official_source_evidence'::regclass)
  AND NOT EXISTS (SELECT 1 FROM pg_policy WHERE polrelid IN ('public.official_source_governance'::regclass,'public.official_source_evidence'::regclass)),
  'RLS and zero-policy state unchanged'
);

SELECT pg_temp.assert_true(
  has_table_privilege('duta_app','public.official_sources','SELECT,DELETE')
  AND NOT has_table_privilege('duta_app','public.official_sources','INSERT')
  AND NOT has_table_privilege('duta_app','public.official_sources','UPDATE')
  AND (SELECT array_agg(attname::text ORDER BY attnum) FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attnum>0 AND NOT attisdropped AND has_column_privilege('duta_app','public.official_sources',attname,'INSERT'))
    = ARRAY['institution','channel','url','category','priority','trust_level','last_checked','checksum','active']::text[]
  AND (SELECT array_agg(attname::text ORDER BY attnum) FROM pg_attribute WHERE attrelid='public.official_sources'::regclass AND attnum>0 AND NOT attisdropped AND has_column_privilege('duta_app','public.official_sources',attname,'UPDATE'))
    = ARRAY['priority','trust_level','active']::text[],
  'official_sources duta_app privileges unchanged'
);

SELECT pg_temp.assert_true(
  (SELECT count(*) FROM public.official_sources)=0
  AND (SELECT count(*) FROM public.official_source_governance)=0
  AND (SELECT count(*) FROM public.official_source_evidence)=0,
  'no data mutation'
);

ROLLBACK;
