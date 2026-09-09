-- STAGING SECURITY TEST ONLY. Apply after 001_security_schema.sql.
-- Ordinary authenticated users receive no membership INSERT, UPDATE, or DELETE policy.
BEGIN;
-- Reject pre-existing policies, including ALL policies with unrelated names.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename IN
    ('profiles','organizations','organization_members','jobs','audit_logs')) THEN
    RAISE EXCEPTION 'Unexpected policies: inspect before applying security fixture';
  END IF;
END $$;
REVOKE ALL ON public.profiles, public.organizations, public.organization_members,
  public.jobs, public.audit_logs FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.profiles, public.organizations, public.organization_members,
  public.jobs TO authenticated;
-- Immutable IDs, ownership, organisation linkage and publication state.
GRANT UPDATE (display_name, private_note, updated_at) ON public.profiles TO authenticated;
GRANT UPDATE (name, updated_at) ON public.organizations TO authenticated;
GRANT UPDATE (title, employer, updated_at) ON public.jobs TO authenticated;
GRANT INSERT (id, actor_id, organization_id, action, entity_type, entity_id)
  ON public.audit_logs TO authenticated;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS security_profiles_self_select ON public.profiles;
CREATE POLICY security_profiles_self_select ON public.profiles
  FOR SELECT TO authenticated USING (id = auth.uid());
DROP POLICY IF EXISTS security_profiles_self_update ON public.profiles;
CREATE POLICY security_profiles_self_update ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS security_members_self_select ON public.organization_members;
CREATE POLICY security_members_self_select ON public.organization_members
  FOR SELECT TO authenticated USING (user_id = auth.uid());

DROP POLICY IF EXISTS security_organizations_member_select ON public.organizations;
CREATE POLICY security_organizations_member_select ON public.organizations
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.organization_members member
      WHERE member.organization_id = organizations.id AND member.user_id = auth.uid())
  );
DROP POLICY IF EXISTS security_organizations_owner_update ON public.organizations;
CREATE POLICY security_organizations_owner_update ON public.organizations
  FOR UPDATE TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS security_jobs_member_select ON public.jobs;
CREATE POLICY security_jobs_member_select ON public.jobs
  FOR SELECT TO authenticated USING (
    owner_id = auth.uid() OR EXISTS (SELECT 1 FROM public.organization_members member
      WHERE member.organization_id = jobs.organization_id AND member.user_id = auth.uid())
  );
DROP POLICY IF EXISTS security_jobs_owner_update ON public.jobs;
CREATE POLICY security_jobs_owner_update ON public.jobs
  FOR UPDATE TO authenticated
  USING (owner_id = auth.uid() AND EXISTS (SELECT 1 FROM public.organization_members member
    WHERE member.organization_id = jobs.organization_id AND member.user_id = auth.uid()))
  WITH CHECK (owner_id = auth.uid() AND EXISTS (SELECT 1 FROM public.organization_members member
    WHERE member.organization_id = jobs.organization_id AND member.user_id = auth.uid()));

DROP POLICY IF EXISTS security_audit_actor_insert ON public.audit_logs;
CREATE POLICY security_audit_actor_insert ON public.audit_logs
  FOR INSERT TO authenticated
  WITH CHECK (actor_id = auth.uid()
    AND action = 'synthetic.job_note' AND entity_type = 'job'
    AND organization_id IS NOT NULL AND entity_id IS NOT NULL
    AND EXISTS (SELECT 1 FROM public.jobs job
      WHERE job.id = audit_logs.entity_id AND job.owner_id = auth.uid()
        AND job.organization_id = audit_logs.organization_id)
    AND EXISTS (SELECT 1 FROM public.organization_members member
      WHERE member.organization_id = audit_logs.organization_id AND member.user_id = auth.uid()));

-- No authenticated INSERT/UPDATE/DELETE policies exist for organization_members.
-- No authenticated DELETE policy exists for profiles, organizations, jobs, or audit_logs.
COMMIT;
