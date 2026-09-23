-- LOCAL/DISPOSABLE DATABASE ONLY. Negative authorization checks for 0044.
\set ON_ERROR_STOP on

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_app' AND rolbypassrls) THEN
    RAISE EXCEPTION 'duta_app must remain NOBYPASSRLS';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_sources'
      AND policyname='official_sources_public' AND cmd='SELECT' AND 'duta_app'=ANY(roles)
  ) THEN RAISE EXCEPTION 'active-source read policy is missing for duta_app'; END IF;
  IF has_table_privilege('duta_app','public.official_source_governance','SELECT')
    OR has_table_privilege('duta_app','public.official_source_governance','INSERT')
    OR has_table_privilege('duta_app','public.official_source_governance','UPDATE')
    OR has_table_privilege('duta_app','public.official_source_governance','DELETE') THEN
    RAISE EXCEPTION 'duta_app must not access source governance rows';
  END IF;
END
$$;
