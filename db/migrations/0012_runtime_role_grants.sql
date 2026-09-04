-- Phase 4 runtime least-privilege grants
BEGIN;

GRANT USAGE ON SCHEMA public TO duta_app;
GRANT SELECT ON TABLE public.official_sources TO duta_app;

COMMIT;
