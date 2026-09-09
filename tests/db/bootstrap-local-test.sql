-- LOCAL TEST ONLY. NOT FOR PRODUCTION. DO NOT APPLY TO HOSTED SUPABASE.
-- Run solely against a disposable local database.
-- This file intentionally creates only the minimum surface required by the six
-- APP_DATABASE_URL-blocked source and AI-router tests.
\set ON_ERROR_STOP on

BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'duta_app') THEN
    CREATE ROLE duta_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  ELSE
    ALTER ROLE duta_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_class relation
    JOIN pg_namespace namespace ON namespace.oid = relation.relnamespace
    JOIN pg_roles role ON role.oid = relation.relowner
    WHERE namespace.nspname = 'public'
      AND relation.relkind IN ('r', 'p')
      AND role.rolname = 'duta_app'
  ) THEN
    RAISE EXCEPTION 'duta_app already owns public tables; use a fresh isolated local test database';
  END IF;
END
$$;

DO $$
BEGIN
  CREATE TYPE public.trust_level AS ENUM ('OFFICIAL_VERIFIED', 'OFFICIAL_UNVERIFIED', 'COMMUNITY');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

CREATE TABLE IF NOT EXISTS public.official_sources (
  id uuid PRIMARY KEY,
  institution text NOT NULL,
  channel text NOT NULL,
  url text NOT NULL UNIQUE,
  category text NOT NULL,
  priority text NOT NULL,
  trust_level public.trust_level NOT NULL,
  last_checked timestamptz NOT NULL,
  checksum text NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS official_sources_institution_idx
  ON public.official_sources (institution);

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO duta_app;
REVOKE ALL ON TABLE public.official_sources FROM PUBLIC;
REVOKE ALL ON TABLE public.official_sources FROM duta_app;
GRANT SELECT ON TABLE public.official_sources TO duta_app;

ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS official_sources_active_select ON public.official_sources;
CREATE POLICY official_sources_active_select
  ON public.official_sources
  FOR SELECT
  TO duta_app
  USING (active = true);

COMMIT;
