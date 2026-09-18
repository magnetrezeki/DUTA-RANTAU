-- LOCAL TEST ONLY. Synthetic provider-style ACL prestate for migration 0040.
\set ON_ERROR_STOP on

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN BYPASSRLS; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_app') THEN CREATE ROLE duta_app NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_system') THEN CREATE ROLE duta_system NOLOGIN; END IF;
END
$$;

CREATE TABLE public.official_sources (
  id uuid PRIMARY KEY,
  institution text NOT NULL,
  channel text NOT NULL,
  url text NOT NULL,
  category text NOT NULL,
  priority text NOT NULL,
  trust_level text NOT NULL,
  last_checked timestamptz,
  checksum text,
  active boolean NOT NULL DEFAULT true,
  source_purpose text
);

REVOKE ALL PRIVILEGES ON TABLE public.official_sources FROM anon, authenticated, service_role, duta_app, duta_system;
GRANT SELECT, DELETE ON TABLE public.official_sources TO duta_app;
GRANT INSERT (institution, channel, url, category, priority, trust_level, last_checked, checksum, active)
  ON TABLE public.official_sources TO duta_app;
GRANT UPDATE (active, priority, trust_level) ON TABLE public.official_sources TO duta_app;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO anon, authenticated, service_role;

CREATE TABLE public.official_source_governance (source_id uuid PRIMARY KEY);
CREATE TABLE public.official_source_evidence (id uuid PRIMARY KEY, source_id uuid NOT NULL);
ALTER TABLE public.official_source_governance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_source_evidence ENABLE ROW LEVEL SECURITY;
