-- LOCAL/DISPOSABLE DATABASE ONLY. Minimal post-0043 state needed by 0044.
\set ON_ERROR_STOP on

CREATE EXTENSION IF NOT EXISTS pgcrypto;
DO $$ BEGIN CREATE ROLE duta_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS; EXCEPTION WHEN duplicate_object THEN NULL; END $$;
CREATE TYPE public.trust_level AS ENUM ('OFFICIAL_VERIFIED','INSTITUTION_VERIFIED','DUTA_VERIFIED','COMMUNITY_VERIFIED','USER_GENERATED');
CREATE TYPE public.source_purpose AS ENUM ('NEWS','CONSULAR_SERVICE','CONTACT');
CREATE TYPE public.official_source_currentness AS ENUM ('UNKNOWN','CURRENT','STALE','REVIEW_REQUIRED');

CREATE TABLE public.users (id uuid PRIMARY KEY DEFAULT gen_random_uuid());
CREATE TABLE public.official_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), institution text NOT NULL,
  channel text NOT NULL, url text NOT NULL UNIQUE, category text NOT NULL,
  priority text NOT NULL, trust_level public.trust_level NOT NULL DEFAULT 'OFFICIAL_VERIFIED',
  last_checked timestamptz NOT NULL, checksum text, active boolean NOT NULL DEFAULT true,
  source_purpose public.source_purpose, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.official_source_governance (
  source_id uuid PRIMARY KEY REFERENCES public.official_sources(id) ON DELETE RESTRICT,
  identity_verified boolean NOT NULL DEFAULT false,
  official_source_verified boolean NOT NULL DEFAULT false,
  currentness public.official_source_currentness NOT NULL DEFAULT 'UNKNOWN',
  verified_at timestamptz, verified_by uuid REFERENCES public.users(id) ON DELETE RESTRICT,
  production_approved boolean NOT NULL DEFAULT false,
  approved_at timestamptz, approved_by uuid REFERENCES public.users(id) ON DELETE RESTRICT,
  next_review_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_source_governance ENABLE ROW LEVEL SECURITY;
GRANT USAGE ON SCHEMA public TO duta_app;
GRANT SELECT ON public.official_sources TO duta_app;
REVOKE ALL ON public.official_source_governance FROM PUBLIC, duta_app;
CREATE POLICY official_sources_public ON public.official_sources
  FOR SELECT TO duta_app USING (active=true);
