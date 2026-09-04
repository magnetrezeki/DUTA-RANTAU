-- Phase 4 runtime identity bridge
--
-- Application identity is supplied through transaction-local:
--   app.user_id
--
-- SECURITY:
--   SECURITY DEFINER
--   fixed search_path
--   UUID validation
--   users lookup
--   suspended users rejected
--
-- These functions do NOT trust a client supplied role.

BEGIN;

CREATE OR REPLACE FUNCTION public.current_app_user_id()
RETURNS uuid
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  raw_value text;
  parsed uuid;
BEGIN
  raw_value := current_setting('app.user_id', true);

  IF raw_value IS NULL
     OR btrim(raw_value) = ''
  THEN
    RETURN NULL;
  END IF;

  BEGIN
    parsed := raw_value::uuid;
  EXCEPTION
    WHEN invalid_text_representation THEN
      RETURN NULL;
  END;

  RETURN parsed;
END
$$;

CREATE OR REPLACE FUNCTION public.current_app_has_role(
  allowed public.user_role[]
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u.id = public.current_app_user_id()
      AND u.suspended_at IS NULL
      AND u.role = ANY(allowed)
  )
$$;

CREATE OR REPLACE FUNCTION public.current_app_has_org_role(
  org_id uuid,
  allowed public.organization_role[]
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.organization_members om
    WHERE om.organization_id = org_id
      AND om.user_id = public.current_app_user_id()
      AND om.role = ANY(allowed)
      AND om.member_status = 'ACTIVE'
  )
$$;

REVOKE ALL ON FUNCTION public.current_app_user_id() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.current_app_has_role(public.user_role[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.current_app_has_org_role(uuid, public.organization_role[]) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.current_app_user_id() TO duta_app;
GRANT EXECUTE ON FUNCTION public.current_app_has_role(public.user_role[]) TO duta_app;
GRANT EXECUTE ON FUNCTION public.current_app_has_org_role(uuid, public.organization_role[]) TO duta_app;

GRANT EXECUTE ON FUNCTION public.current_app_user_id() TO duta_system;
GRANT EXECUTE ON FUNCTION public.current_app_has_role(public.user_role[]) TO duta_system;
GRANT EXECUTE ON FUNCTION public.current_app_has_org_role(uuid, public.organization_role[]) TO duta_system;

COMMIT;
