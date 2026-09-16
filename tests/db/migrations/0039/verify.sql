-- LOCAL TEST ONLY. Structural post-state verification for 0039.
\set ON_ERROR_STOP on

DO $$
DECLARE
  purpose_values text[];
  currentness_values text[];
BEGIN
  SELECT array_agg(enumlabel ORDER BY enumsortorder) INTO purpose_values
  FROM pg_enum WHERE enumtypid = 'public.source_purpose'::regtype;
  IF purpose_values <> ARRAY['NEWS', 'CONSULAR_SERVICE', 'CONTACT'] THEN
    RAISE EXCEPTION 'source_purpose enum mismatch';
  END IF;

  SELECT array_agg(enumlabel ORDER BY enumsortorder) INTO currentness_values
  FROM pg_enum WHERE enumtypid = 'public.official_source_currentness'::regtype;
  IF currentness_values <> ARRAY['UNKNOWN', 'CURRENT', 'STALE', 'REVIEW_REQUIRED'] THEN
    RAISE EXCEPTION 'official_source_currentness enum mismatch';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='official_sources' AND column_name='source_purpose' AND is_nullable='YES') THEN
    RAISE EXCEPTION 'nullable official_sources.source_purpose is missing';
  END IF;
  IF (SELECT source_purpose FROM public.official_sources WHERE id='00000000-0000-4000-8000-000000000101') IS NOT NULL THEN
    RAISE EXCEPTION 'legacy source was classified';
  END IF;
  IF to_regclass('public.official_source_governance') IS NULL OR to_regclass('public.official_source_evidence') IS NULL THEN
    RAISE EXCEPTION 'governance tables are missing';
  END IF;
  IF EXISTS (SELECT 1 FROM public.official_source_governance) OR EXISTS (SELECT 1 FROM public.official_source_evidence) THEN
    RAISE EXCEPTION 'migration created governance or evidence data';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='official_source_governance_pkey') THEN
    RAISE EXCEPTION 'governance source primary key missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='official_source_evidence_source_url_uq') THEN
    RAISE EXCEPTION 'evidence uniqueness missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE oid='public.official_source_governance'::regclass AND relrowsecurity)
    OR NOT EXISTS (SELECT 1 FROM pg_class WHERE oid='public.official_source_evidence'::regclass AND relrowsecurity) THEN
    RAISE EXCEPTION 'restricted tables require RLS';
  END IF;
END
$$;
