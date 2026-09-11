-- LOCAL TEST ONLY. Canonical prerequisite subset for 0035 validation.
-- public.users is created by 0000_next_marrow.sql; its primary key is UUID.
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid()
);

-- Exact 0011 identity-function contract required by 0035's INSERT policy.
CREATE OR REPLACE FUNCTION public.current_app_user_id()
RETURNS uuid LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE raw_value text; parsed uuid;
BEGIN
  raw_value := current_setting('app.user_id', true);
  IF raw_value IS NULL OR btrim(raw_value) = '' THEN RETURN NULL; END IF;
  BEGIN parsed := raw_value::uuid; EXCEPTION WHEN invalid_text_representation THEN RETURN NULL; END;
  RETURN parsed;
END $$;

-- Local stand-ins for the standard Supabase database roles named by 0035.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
END $$;
