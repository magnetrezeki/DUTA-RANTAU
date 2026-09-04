-- Phase 4 runtime database roles
--
-- SECURITY MODEL
-- duta_app:
--   application runtime connection
-- duta_system:
--   privileged system-operation runtime connection
--
-- IMPORTANT:
--   1. Neither role may own application tables.
--   2. Neither role may bypass RLS.
--   3. No broad GRANT over every public table.
--   4. Passwords are intentionally NOT stored here.
--   5. Roles must be provisioned with credentials outside this migration.
--
-- This migration intentionally does NOT grant table privileges yet.
-- Least-privilege grants are added only after runtime call-sites have
-- been audited.

BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_roles
    WHERE rolname = 'duta_app'
  ) THEN
    CREATE ROLE duta_app
      LOGIN
      NOSUPERUSER
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      NOBYPASSRLS;
  ELSE
    ALTER ROLE duta_app
      NOSUPERUSER
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      NOBYPASSRLS;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_roles
    WHERE rolname = 'duta_system'
  ) THEN
    CREATE ROLE duta_system
      LOGIN
      NOSUPERUSER
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      NOBYPASSRLS;
  ELSE
    ALTER ROLE duta_system
      NOSUPERUSER
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      NOBYPASSRLS;
  END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO duta_app;
GRANT USAGE ON SCHEMA public TO duta_system;

-- Explicitly remove accidental broad privileges that may have been
-- installed by an earlier unsafe version of this migration.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format(
      'REVOKE ALL PRIVILEGES ON TABLE public.%I FROM duta_app',
      r.tablename
    );

    EXECUTE format(
      'REVOKE ALL PRIVILEGES ON TABLE public.%I FROM duta_system',
      r.tablename
    );
  END LOOP;
END
$$;

DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT sequence_name
    FROM information_schema.sequences
    WHERE sequence_schema = 'public'
  LOOP
    EXECUTE format(
      'REVOKE ALL PRIVILEGES ON SEQUENCE public.%I FROM duta_app',
      r.sequence_name
    );

    EXECUTE format(
      'REVOKE ALL PRIVILEGES ON SEQUENCE public.%I FROM duta_system',
      r.sequence_name
    );
  END LOOP;
END
$$;

COMMIT;
