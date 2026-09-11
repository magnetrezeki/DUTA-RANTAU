-- Day 8J: provenance-first official job discovery. No scraper or candidate workflow is introduced.
DO $$ BEGIN CREATE TYPE public.external_job_source_type AS ENUM ('OFFICIAL','DIRECT_EMPLOYER','LICENSED_APS'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.external_job_source_status AS ENUM ('active','stale','unknown','closed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS public.external_job_listings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  external_job_id text NOT NULL,
  source_type public.external_job_source_type NOT NULL,
  source_name text NOT NULL,
  source_url text NOT NULL,
  destination_country text NOT NULL,
  job_title text NOT NULL,
  sector text,
  employer_name text,
  p3mi_name text,
  location text,
  vacancy_count integer,
  education_requirement text,
  published_at timestamptz,
  expires_at timestamptz,
  source_status public.external_job_source_status NOT NULL DEFAULT 'unknown',
  fetched_at timestamptz,
  last_checked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(source_type,external_job_id)
);
CREATE INDEX IF NOT EXISTS external_jobs_malaysia_active_idx ON public.external_job_listings(destination_country,source_status,last_checked_at);
--> statement-breakpoint

CREATE OR REPLACE FUNCTION public.enforce_official_job_source_safety()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.source_type='OFFICIAL' THEN
    IF NEW.source_name<>'SISKOP2MI / KP2MI' OR NEW.destination_country<>'MALAYSIA' THEN RAISE EXCEPTION 'official source identity and Malaysia destination are required'; END IF;
    IF NEW.source_url !~ '^https://siskop2mi\\.bp2mi\\.go\\.id/lowongan/(detail/[0-9]+|list)$' THEN RAISE EXCEPTION 'official source URL is not approved'; END IF;
  END IF;
  IF NEW.source_status='active' AND (NEW.last_checked_at IS NULL OR NEW.last_checked_at<=now()-interval '7 days') THEN RAISE EXCEPTION 'active external job requires current source check'; END IF;
  IF NEW.expires_at IS NOT NULL AND NEW.expires_at<=now() THEN NEW.source_status:='stale'; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS external_job_source_safety_enforcement ON public.external_job_listings;
CREATE TRIGGER external_job_source_safety_enforcement BEFORE INSERT OR UPDATE ON public.external_job_listings FOR EACH ROW EXECUTE FUNCTION public.enforce_official_job_source_safety();
--> statement-breakpoint

ALTER TABLE public.external_job_listings ENABLE ROW LEVEL SECURITY;
CREATE POLICY external_jobs_public_malaysia_read ON public.external_job_listings
FOR SELECT TO anon,authenticated
USING (source_type='OFFICIAL' AND source_name='SISKOP2MI / KP2MI' AND destination_country='MALAYSIA' AND source_status='active' AND last_checked_at>now()-interval '7 days' AND (expires_at IS NULL OR expires_at>now()));
GRANT SELECT ON public.external_job_listings TO duta_app;
