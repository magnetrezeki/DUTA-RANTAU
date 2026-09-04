-- Supabase Phase 4 hardening companion.
-- Apply after db/supabase-phase4-content.sql and membership RLS setup.
BEGIN;

DROP POLICY IF EXISTS organizations_admin_delete ON public.organizations;
DROP POLICY IF EXISTS organizations_admin_insert ON public.organizations;
DROP POLICY IF EXISTS organizations_manage ON public.organizations;

CREATE POLICY organizations_admin_insert ON public.organizations FOR INSERT TO authenticated WITH CHECK(
  public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]) AND
  status='PENDING' AND
  verification='USER_GENERATED' AND
  application_status='PENDING_REVIEW' AND
  (applicant_id IS NULL OR applicant_id=auth.uid())
);

CREATE POLICY organizations_manage ON public.organizations FOR UPDATE TO authenticated
USING(
  public.has_org_role(id,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR
  public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])
)
WITH CHECK(
  (
    public.has_org_role(id,ARRAY['OWNER','ADMIN']::public.organization_role[]) AND
    (status<>'ACTIVE' OR application_status='APPROVED')
  ) OR
  (
    public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]) AND
    (
      status='ARCHIVED' OR
      (status='PENDING' AND application_status IN ('PENDING_REVIEW','REJECTED') AND verification='USER_GENERATED') OR
      (status='ACTIVE' AND application_status='APPROVED' AND reviewed_by IS NOT NULL)
    )
  )
);

CREATE OR REPLACE FUNCTION public.protect_organization_archival_supabase() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]) OR public.has_org_role(NEW.id,ARRAY['OWNER','ADMIN']::public.organization_role[]) THEN
    IF NEW.status <> 'ARCHIVED' AND (NEW.status='ACTIVE' OR NEW.verification='DUTA_VERIFIED') AND (NEW.application_status<>'APPROVED' OR NEW.reviewed_by IS NULL) THEN
      RAISE EXCEPTION 'organization approval workflow required' USING ERRCODE='42501';
    END IF;
    RETURN NEW;
  END IF;
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'authenticated identity required' USING ERRCODE='42501'; END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS protect_organization_archival_supabase_trigger ON public.organizations;
CREATE TRIGGER protect_organization_archival_supabase_trigger BEFORE INSERT OR UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION public.protect_organization_archival_supabase();

COMMIT;
