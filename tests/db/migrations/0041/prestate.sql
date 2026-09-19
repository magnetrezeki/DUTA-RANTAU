-- LOCAL TEST ONLY. Synthetic prestate reproducing the observed 0041 defect.
--
-- This is the state the governed chain (0000..0040) actually produces: the two
-- duta_app audit policies exist and permit the row, but duta_app holds no
-- INSERT privilege on public.audit_logs, so the privilege check rejects the
-- statement before RLS is ever evaluated. The policies are therefore inert.
\set ON_ERROR_STOP on

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN BYPASSRLS; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_app') THEN CREATE ROLE duta_app NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='duta_system') THEN CREATE ROLE duta_system NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='user_role') THEN
    CREATE TYPE public.user_role AS ENUM ('USER','ORG_ADMIN','SUPER_ADMIN');
  END IF;
END
$$;

-- Identity helpers (0011 / 0037 shape, reduced to what the audit policies call).
CREATE OR REPLACE FUNCTION public.current_app_user_id() RETURNS uuid
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.user_id', true), '')::uuid
$$;

CREATE OR REPLACE FUNCTION public.current_app_has_role(roles public.user_role[]) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT COALESCE(NULLIF(current_setting('app.user_role', true), '')::public.user_role = ANY(roles), false)
$$;

CREATE TABLE public.users (
  id uuid PRIMARY KEY,
  email text NOT NULL,
  name text,
  role public.user_role NOT NULL DEFAULT 'USER'
);

CREATE TABLE public.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid,
  organization_id uuid,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id text,
  metadata jsonb,
  ip_hash text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- The two governed duta_app policies, exactly as 0008/0009/0020 author them.
CREATE POLICY audit_user_insert ON public.audit_logs FOR INSERT TO duta_app
  WITH CHECK (
    actor_id = public.current_app_user_id()
    AND action = ANY (ARRAY[
      'profile_update','source_change','organization.create','organization.application_submitted',
      'organization.reviewed','publication.create_draft','secretary.create_draft',
      'meeting.audio_transcribed','member.phone_verified','member.location_verified',
      'member.location_manual_review','member.selfie_uploaded','member.reviewed',
      'content_admin_create','content_admin_update','content_admin_delete','account_deletion'
    ])
  );

CREATE POLICY audit_logs_content_admin ON public.audit_logs FOR INSERT TO duta_app
  WITH CHECK (
    actor_id = public.current_app_user_id()
    AND public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role,'SUPER_ADMIN'::public.user_role])
  );

CREATE POLICY audit_system_insert ON public.audit_logs FOR INSERT TO duta_system
  WITH CHECK (current_setting('app.system_operation', true) <> '');

-- 0038 section F grants duta_system only. This is the defect: duta_app is absent.
GRANT INSERT ON TABLE public.audit_logs TO duta_system;

-- Fixture actors.
INSERT INTO public.users(id,email,name,role) VALUES
  ('10000000-0000-4000-8000-0000000000a1','a@fixture.test','Actor A','USER'),
  ('10000000-0000-4000-8000-0000000000b2','b@fixture.test','Actor B','USER');
