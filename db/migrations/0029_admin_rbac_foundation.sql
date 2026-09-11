-- Day 8I-A: additive platform-role storage. No user receives a new role here.
-- Existing organisation membership roles remain entity-scoped and unchanged.
DO $$ BEGIN CREATE TYPE public.platform_role AS ENUM ('super_admin','compliance_admin','verification_reviewer','moderation_admin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS public.user_platform_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role public.platform_role NOT NULL,
  assigned_by uuid REFERENCES public.users(id),
  assigned_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  reason text
);
CREATE UNIQUE INDEX IF NOT EXISTS user_platform_role_active_uq ON public.user_platform_roles(user_id,role) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS user_platform_role_active_idx ON public.user_platform_roles(user_id,revoked_at);
--> statement-breakpoint

ALTER TABLE public.user_platform_roles ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.user_platform_roles FROM anon, authenticated;
GRANT SELECT ON public.user_platform_roles TO authenticated;
-- A user may inspect only their own current assignment; write access remains
-- unavailable until an explicitly audited, server-authorized assignment flow exists.
CREATE POLICY user_platform_roles_self_read ON public.user_platform_roles
FOR SELECT TO authenticated USING (user_id=auth.uid() AND revoked_at IS NULL);

-- Platform role checks are explicit and do not derive from entity membership.
CREATE OR REPLACE FUNCTION public.has_platform_role(required_role public.platform_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_platform_roles upr
    WHERE upr.user_id=auth.uid() AND upr.role=required_role AND upr.revoked_at IS NULL
  )
$$;
REVOKE ALL ON FUNCTION public.has_platform_role(public.platform_role) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_platform_role(public.platform_role) TO authenticated;
--> statement-breakpoint

-- Replace broad legacy reviewer access. Entity owners retain only verification
-- summaries; raw evidence requires an explicit verification reviewer assignment.
DROP POLICY IF EXISTS user_verification_self_read ON public.user_verifications;
CREATE POLICY user_verification_self_read ON public.user_verifications
FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_platform_role('verification_reviewer'));
DROP POLICY IF EXISTS entity_verification_summary_read ON public.entity_verifications;
CREATE POLICY entity_verification_summary_read ON public.entity_verifications
FOR SELECT TO authenticated USING (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_platform_role('verification_reviewer'));
DROP POLICY IF EXISTS verification_evidence_privileged_read ON public.verification_evidence;
CREATE POLICY verification_evidence_privileged_read ON public.verification_evidence
FOR SELECT TO authenticated USING (public.has_platform_role('verification_reviewer'));
DROP POLICY IF EXISTS entity_eligibility_owner_read ON public.entity_eligibilities;
CREATE POLICY entity_eligibility_owner_read ON public.entity_eligibilities
FOR SELECT TO authenticated USING (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_platform_role('compliance_admin'));
--> statement-breakpoint

-- Platform moderation and administration do not become entity ownership.
DROP POLICY IF EXISTS entities_public_read ON public.entities;
CREATE POLICY entities_public_read ON public.entities
FOR SELECT TO anon,authenticated USING (record_status='ACTIVE' OR owner_user_id=auth.uid() OR public.has_platform_role('moderation_admin'));
DROP POLICY IF EXISTS entities_owner_update ON public.entities;
CREATE POLICY entities_owner_update ON public.entities
FOR UPDATE TO authenticated
USING (owner_user_id=auth.uid())
WITH CHECK (owner_user_id=auth.uid() AND legal_status_verified IS NULL);
DROP POLICY IF EXISTS presence_self_read ON public.user_presence_checks;
CREATE POLICY presence_self_read ON public.user_presence_checks
FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_platform_role('verification_reviewer'));
DROP POLICY IF EXISTS responsible_read ON public.entity_responsible_persons;
CREATE POLICY responsible_read ON public.entity_responsible_persons
FOR SELECT TO authenticated USING (user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_platform_role('verification_reviewer'));
DROP POLICY IF EXISTS responsible_owner_manage ON public.entity_responsible_persons;
CREATE POLICY responsible_owner_manage ON public.entity_responsible_persons
FOR ALL TO authenticated
USING (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()))
WITH CHECK (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()));
DROP POLICY IF EXISTS organizations_manage ON public.organizations;
CREATE POLICY organizations_manage ON public.organizations
FOR UPDATE TO authenticated
USING (public.has_org_role(id,ARRAY['OWNER','ADMIN']::public.organization_role[]))
WITH CHECK (public.has_org_role(id,ARRAY['OWNER','ADMIN']::public.organization_role[]));
DROP POLICY IF EXISTS communities_owner_manage ON public.communities;
CREATE POLICY communities_owner_manage ON public.communities
FOR UPDATE TO authenticated
USING (owner_id=auth.uid()) WITH CHECK (owner_id=auth.uid());
--> statement-breakpoint

-- Members cannot promote themselves. Only an existing owner may grant or alter
-- OWNER/ADMIN; transfer remains a separate, audited workflow and is not added here.
CREATE OR REPLACE FUNCTION public.enforce_organization_member_role_change()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='UPDATE' AND (NEW.organization_id IS DISTINCT FROM OLD.organization_id OR NEW.user_id IS DISTINCT FROM OLD.user_id) THEN
    RAISE EXCEPTION 'organization membership identity is immutable';
  END IF;
  IF TG_OP='UPDATE' AND NEW.user_id=auth.uid() AND NEW.role IS DISTINCT FROM OLD.role THEN
    RAISE EXCEPTION 'members cannot change their own role';
  END IF;
  IF NEW.role IN ('OWNER','ADMIN') AND NOT public.has_org_role(NEW.organization_id,ARRAY['OWNER']::public.organization_role[]) THEN
    IF TG_OP='INSERT' AND NEW.role='OWNER' AND NOT EXISTS(SELECT 1 FROM public.organization_members m WHERE m.organization_id=NEW.organization_id) THEN
      RETURN NEW;
    END IF;
    RAISE EXCEPTION 'only an existing owner can grant privileged organization roles';
  END IF;
  IF TG_OP='UPDATE' AND OLD.role='OWNER' AND NEW.role IS DISTINCT FROM 'OWNER' THEN
    RAISE EXCEPTION 'owner transfer requires a dedicated audited workflow';
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS organization_member_role_change ON public.organization_members;
CREATE TRIGGER organization_member_role_change
BEFORE INSERT OR UPDATE ON public.organization_members
FOR EACH ROW EXECUTE FUNCTION public.enforce_organization_member_role_change();
