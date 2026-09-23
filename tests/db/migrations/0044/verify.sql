-- LOCAL/DISPOSABLE DATABASE ONLY. Run after 0044.
\set ON_ERROR_STOP on

DO $$
DECLARE
  registry_count integer;
  mission_count integer;
  function_count integer;
  consular_count integer;
BEGIN
  SELECT count(*) INTO registry_count FROM public.official_sources
    WHERE checksum='p5c-0044-founder-approved-registry-v1' AND active;
  IF registry_count <> 27 THEN RAISE EXCEPTION '0044 registry count mismatch: %', registry_count; END IF;

  SELECT count(DISTINCT institution) INTO mission_count FROM public.official_sources
    WHERE checksum='p5c-0044-founder-approved-registry-v1'
      AND institution IN ('KBRI Kuala Lumpur','KJRI Johor Bahru','KJRI Penang','KJRI Kota Kinabalu','KJRI Kuching','KRI Tawau');
  IF mission_count <> 6 THEN RAISE EXCEPTION '0044 mission coverage mismatch'; END IF;

  SELECT count(*) INTO function_count FROM public.official_sources
    WHERE checksum='p5c-0044-founder-approved-registry-v1' AND institution LIKE 'Atase%';
  IF function_count <> 5 THEN RAISE EXCEPTION '0044 function coverage mismatch'; END IF;

  SELECT count(*) INTO consular_count FROM public.official_sources
    WHERE checksum='p5c-0044-founder-approved-registry-v1' AND priority='P0'
      AND source_purpose='CONSULAR_SERVICE' AND channel='WEBSITE';
  IF consular_count <> 6 THEN RAISE EXCEPTION '0044 consular retrieval population mismatch'; END IF;

  IF EXISTS (
    SELECT 1 FROM public.official_source_governance governance
    JOIN public.official_sources source ON source.id=governance.source_id
    WHERE source.checksum='p5c-0044-founder-approved-registry-v1'
      AND (governance.identity_verified OR governance.official_source_verified
        OR governance.production_approved OR governance.currentness<>'UNKNOWN'
        OR governance.verified_at IS NOT NULL OR governance.verified_by IS NOT NULL
        OR governance.approved_at IS NOT NULL OR governance.approved_by IS NOT NULL)
  ) THEN RAISE EXCEPTION '0044 manufactured unsupported governance claims'; END IF;
END
$$;

BEGIN;
SET LOCAL ROLE duta_app;
DO $$
DECLARE visible_count integer;
BEGIN
  SELECT count(*) INTO visible_count FROM public.official_sources
    WHERE checksum='p5c-0044-founder-approved-registry-v1';
  IF visible_count <> 27 THEN RAISE EXCEPTION 'duta_app cannot read all active 0044 sources: %', visible_count; END IF;
END
$$;
ROLLBACK;
