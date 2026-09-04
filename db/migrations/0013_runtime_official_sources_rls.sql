-- Phase 4: allow restricted runtime app role to read active official sources
BEGIN;

DROP POLICY IF EXISTS official_sources_public ON public.official_sources;

CREATE POLICY official_sources_public
ON public.official_sources
AS PERMISSIVE
FOR SELECT
TO anon, authenticated, duta_app
USING (active = true);

COMMIT;
