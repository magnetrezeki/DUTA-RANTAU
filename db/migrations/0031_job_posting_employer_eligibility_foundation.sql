-- Day 8J: additive direct-employer job posting foundation. Discovery remains free.
-- This migration creates no candidate profiles, placement workflow, agency model, or payment flow.
ALTER TABLE public.jobs ADD COLUMN IF NOT EXISTS employer_entity_id uuid REFERENCES public.entities(id);
ALTER TABLE public.jobs ADD COLUMN IF NOT EXISTS posting_kind text;
ALTER TABLE public.jobs ADD COLUMN IF NOT EXISTS employer_eligibility_snapshot text;
ALTER TABLE public.jobs ADD COLUMN IF NOT EXISTS published_at timestamptz;
CREATE INDEX IF NOT EXISTS jobs_employer_entity_idx ON public.jobs(employer_entity_id,status);
--> statement-breakpoint

CREATE OR REPLACE FUNCTION public.enforce_job_posting_safety()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  employer_type public.entity_type;
  employer_active boolean;
  employer_name text;
  eligibility_current boolean;
BEGIN
  -- Legacy listings keep their owner-only shape until a new employer entity is supplied.
  IF NEW.employer_entity_id IS NULL THEN
    IF TG_OP='INSERT' THEN RAISE EXCEPTION 'job employer entity is required'; END IF;
    RETURN NEW;
  END IF;
  SELECT entity_type,record_status='ACTIVE',display_name INTO employer_type,employer_active,employer_name FROM public.entities WHERE id=NEW.employer_entity_id;
  IF employer_type IS NULL OR NOT employer_active THEN RAISE EXCEPTION 'job employer must be an active entity'; END IF;
  IF employer_type NOT IN ('business','organisation') THEN RAISE EXCEPTION 'job posting is not supported for this entity type'; END IF;
  IF NEW.posting_kind IS DISTINCT FROM 'direct_employer' THEN RAISE EXCEPTION 'candidate placement and agency posting are not supported'; END IF;
  SELECT EXISTS(SELECT 1 FROM public.entity_eligibilities ee WHERE ee.entity_id=NEW.employer_entity_id AND ee.eligibility_type='employer' AND ee.status='approved' AND (ee.expires_at IS NULL OR ee.expires_at>now())) INTO eligibility_current;
  IF NOT eligibility_current THEN RAISE EXCEPTION 'job posting requires current employer eligibility'; END IF;
  NEW.employer:=employer_name;
  NEW.employer_eligibility_snapshot:='approved';
  IF NEW.status='ACTIVE' AND NEW.published_at IS NULL THEN NEW.published_at:=now(); END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS jobs_posting_safety_enforcement ON public.jobs;
CREATE TRIGGER jobs_posting_safety_enforcement BEFORE INSERT OR UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.enforce_job_posting_safety();
--> statement-breakpoint

ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS jobs_admin_all ON public.jobs;
DROP POLICY IF EXISTS jobs_employer_entity_write ON public.jobs;
CREATE POLICY jobs_employer_entity_write ON public.jobs
FOR ALL TO duta_app
USING (employer_entity_id IS NOT NULL AND EXISTS(
  SELECT 1 FROM public.entities e WHERE e.id=jobs.employer_entity_id AND e.record_status='ACTIVE' AND (
    e.owner_user_id=public.current_app_user_id()
    OR (e.entity_type='organisation' AND EXISTS(SELECT 1 FROM public.organizations o WHERE o.entity_id=e.id AND public.current_app_has_org_role(o.id,ARRAY['OWNER','ADMIN']::public.organization_role[])))
  )
))
WITH CHECK (employer_entity_id IS NOT NULL AND EXISTS(
  SELECT 1 FROM public.entities e WHERE e.id=jobs.employer_entity_id AND e.record_status='ACTIVE' AND (
    e.owner_user_id=public.current_app_user_id()
    OR (e.entity_type='organisation' AND EXISTS(SELECT 1 FROM public.organizations o WHERE o.entity_id=e.id AND public.current_app_has_org_role(o.id,ARRAY['OWNER','ADMIN']::public.organization_role[])))
  )
));
GRANT SELECT, INSERT, UPDATE, DELETE ON public.jobs TO duta_app;
