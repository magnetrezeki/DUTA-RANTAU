BEGIN;

-- Runtime privileges.
GRANT USAGE ON SCHEMA public TO duta_app;

GRANT SELECT, INSERT, UPDATE
ON TABLE public.organizations
TO duta_app;

GRANT INSERT
ON TABLE public.audit_logs
TO duta_app;

-- Replace legacy/runtime organization policies by name.
DROP POLICY IF EXISTS organizations_admin_insert ON public.organizations;
DROP POLICY IF EXISTS organizations_admin_update ON public.organizations;
DROP POLICY IF EXISTS organizations_admin_archive ON public.organizations;

-- Runtime SELECT for duta_app.
DROP POLICY IF EXISTS organizations_runtime_select ON public.organizations;

CREATE POLICY organizations_runtime_select
ON public.organizations
AS PERMISSIVE
FOR SELECT
TO duta_app
USING (
  public.current_app_has_role(
    ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]
  )
);

-- Runtime INSERT.
CREATE POLICY organizations_admin_insert
ON public.organizations
AS PERMISSIVE
FOR INSERT
TO duta_app
WITH CHECK (
  public.current_app_has_role(
    ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]
  )
  AND status = 'PENDING'::public.record_status
  AND verification = 'USER_GENERATED'::public.trust_level
);

-- One UPDATE policy only.
CREATE POLICY organizations_admin_update
ON public.organizations
AS PERMISSIVE
FOR UPDATE
TO duta_app
USING (
  public.current_app_has_role(
    ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]
  )
)
WITH CHECK (
  public.current_app_has_role(
    ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]
  )
  AND (
    status <> 'ACTIVE'::public.record_status
    OR verification = 'DUTA_VERIFIED'::public.trust_level
  )
);

-- No direct DELETE.
REVOKE DELETE ON public.organizations FROM duta_app;

-- Protect activation and archived records.
CREATE OR REPLACE FUNCTION public.protect_organization_archival()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status = 'ACTIVE'::public.record_status
     AND OLD.status <> 'ACTIVE'::public.record_status
     AND NEW.verification <> 'DUTA_VERIFIED'::public.trust_level
  THEN
    RAISE EXCEPTION 'Organization must be DUTA_VERIFIED before activation';
  END IF;

  IF OLD.status = 'ARCHIVED'::public.record_status
     AND NEW.status <> 'ARCHIVED'::public.record_status
  THEN
    RAISE EXCEPTION 'Archived organization cannot be reactivated';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_organization_archival
ON public.organizations;

CREATE TRIGGER protect_organization_archival
BEFORE UPDATE ON public.organizations
FOR EACH ROW
EXECUTE FUNCTION public.protect_organization_archival();

-- Audit writes must identify the actual transaction actor.
DROP POLICY IF EXISTS audit_logs_content_admin ON public.audit_logs;

CREATE POLICY audit_logs_content_admin
ON public.audit_logs
AS PERMISSIVE
FOR INSERT
TO duta_app
WITH CHECK (
  actor_id = public.current_app_user_id()
  AND public.current_app_has_role(
    ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]
  )
);

COMMIT;



-- Archival invariant: status='ARCHIVED' is terminal.
