-- LOCAL TEST ONLY. Synthetic minimum pre-state for governed migration 0039.
-- It is not a historical replay, a production snapshot, or a hosted-database script.
\set ON_ERROR_STOP on

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'duta_app') THEN
    CREATE ROLE duta_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'duta_system') THEN
    CREATE ROLE duta_system LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
END
$$;

CREATE TYPE public.user_role AS ENUM ('USER', 'ORG_ADMIN', 'SUPER_ADMIN');
CREATE TYPE public.trust_level AS ENUM ('OFFICIAL_VERIFIED', 'USER_GENERATED');

CREATE TABLE public.users (
  id uuid PRIMARY KEY,
  role public.user_role NOT NULL,
  suspended_at timestamptz
);

CREATE TABLE public.official_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  institution text NOT NULL,
  channel text NOT NULL,
  url text NOT NULL,
  category text NOT NULL,
  priority text NOT NULL,
  trust_level public.trust_level NOT NULL DEFAULT 'OFFICIAL_VERIFIED',
  last_checked timestamptz NOT NULL,
  checksum text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX sources_url_uq ON public.official_sources (url);
CREATE INDEX source_institution_idx ON public.official_sources (institution);

CREATE FUNCTION public.current_app_user_id()
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT NULLIF(current_setting('app.user_id', true), '')::uuid
$$;
CREATE FUNCTION public.current_app_has_role(allowed public.user_role[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE id = public.current_app_user_id() AND suspended_at IS NULL AND role = ANY(allowed))
$$;
REVOKE ALL ON FUNCTION public.current_app_user_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.current_app_has_role(public.user_role[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_app_user_id() TO duta_app;
GRANT EXECUTE ON FUNCTION public.current_app_has_role(public.user_role[]) TO duta_app;

REVOKE ALL ON TABLE public.official_sources FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.official_sources TO duta_app;
ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;
CREATE POLICY official_sources_public ON public.official_sources
  FOR SELECT TO anon, authenticated, duta_app USING (active = true);
CREATE POLICY official_sources_admin_all ON public.official_sources
  FOR ALL TO duta_app
  USING (public.current_app_has_role(ARRAY['ORG_ADMIN', 'SUPER_ADMIN']::public.user_role[]))
  WITH CHECK (public.current_app_has_role(ARRAY['ORG_ADMIN', 'SUPER_ADMIN']::public.user_role[]));

INSERT INTO public.users (id, role) VALUES
  ('00000000-0000-4000-8000-000000000001', 'ORG_ADMIN');
INSERT INTO public.official_sources (
  id, institution, channel, url, category, priority, trust_level, last_checked, checksum, active
) VALUES (
  '00000000-0000-4000-8000-000000000101', 'Synthetic Mission', 'website',
  'https://source.example.invalid/legacy', 'general', 'P0', 'OFFICIAL_VERIFIED',
  '2026-01-01T00:00:00Z', 'synthetic-checksum', true
);

COMMIT;
