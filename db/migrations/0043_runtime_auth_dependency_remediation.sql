-- 0043: keep the duta_app runtime on the app.user_id identity bridge.
--
-- Supabase JWT roles resolve identity through auth.uid(). The server-side
-- duta_app role instead sets app.user_id inside a transaction. Do not grant
-- duta_app access to the provider-owned auth schema: remove it from legacy
-- JWT-only policies and make the organization trigger use the runtime bridge.
BEGIN;

CREATE OR REPLACE FUNCTION public.enforce_organization_member_role_change()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF TG_OP='UPDATE' AND (
    NEW.organization_id IS DISTINCT FROM OLD.organization_id
    OR NEW.user_id IS DISTINCT FROM OLD.user_id
  ) THEN
    RAISE EXCEPTION 'organization membership identity is immutable';
  END IF;

  IF TG_OP='UPDATE'
    AND NEW.user_id=public.current_app_user_id()
    AND NEW.role IS DISTINCT FROM OLD.role
  THEN
    RAISE EXCEPTION 'members cannot change their own role';
  END IF;

  IF NEW.role IN ('OWNER','ADMIN')
    AND NOT public.current_app_has_org_role(
      NEW.organization_id,
      ARRAY['OWNER']::public.organization_role[]
    )
  THEN
    IF TG_OP='INSERT'
      AND NEW.role='OWNER'
      AND NOT EXISTS (
        SELECT 1
        FROM public.organization_members member
        WHERE member.organization_id=NEW.organization_id
      )
    THEN
      RETURN NEW;
    END IF;
    RAISE EXCEPTION 'only an existing owner can grant privileged organization roles';
  END IF;

  IF TG_OP='UPDATE'
    AND OLD.role='OWNER'
    AND NEW.role IS DISTINCT FROM 'OWNER'
  THEN
    RAISE EXCEPTION 'owner transfer requires a dedicated audited workflow';
  END IF;

  RETURN NEW;
END
$$;

ALTER FUNCTION public.enforce_organization_member_role_change() OWNER TO postgres;
REVOKE ALL ON FUNCTION public.enforce_organization_member_role_change() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enforce_organization_member_role_change() TO duta_app;

-- These legacy policies use Supabase JWT identity and remain available only
-- to the provider's anon/authenticated roles. duta_app has dedicated policies
-- backed by current_app_user_id().
ALTER POLICY communities_public ON public.communities TO anon, authenticated;
ALTER POLICY jobs_public ON public.jobs TO anon, authenticated;
ALTER POLICY products_public ON public.products TO anon, authenticated;
ALTER POLICY sellers_public_read ON public.sellers TO anon, authenticated;

COMMIT;
