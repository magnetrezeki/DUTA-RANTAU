-- DUTA RANTAU Production forward reconciliation.
-- Restore only the missing eligibility structure required by job-posting safety
-- and the proven missing jobs runtime security contract.
-- No data backfill. No unrelated capability/security reconciliation.

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.entities') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.entities is missing';
  END IF;

  IF to_regclass('public.users') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.users is missing';
  END IF;

  IF to_regclass('public.jobs') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.jobs is missing';
  END IF;

  IF to_regtype('public.user_role') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.user_role is missing';
  END IF;

  IF to_regprocedure('public.has_system_role(public.user_role[])') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.has_system_role(user_role[]) is missing';
  END IF;

  IF to_regprocedure('auth.uid()') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: auth.uid() is missing';
  END IF;

  IF to_regclass('public.entity_eligibilities') IS NOT NULL
     OR to_regtype('public.eligibility_type') IS NOT NULL
     OR to_regtype('public.eligibility_status') IS NOT NULL
     OR to_regtype('public.eligibility_decision_source') IS NOT NULL THEN
    RAISE EXCEPTION 'precondition failed: eligibility foundation is not in expected missing state';
  END IF;

  IF to_regprocedure('public.enforce_job_posting_safety()') IS NOT NULL THEN
    RAISE EXCEPTION 'precondition failed: enforce_job_posting_safety already exists';
  END IF;
END
$$;

CREATE TYPE public.eligibility_type AS ENUM (
  'commercial',
  'employer',
  'paid_event',
  'regulated_service',
  'payment_connect'
);

CREATE TYPE public.eligibility_status AS ENUM (
  'not_started',
  'pending',
  'approved',
  'rejected',
  'expired',
  'suspended'
);

CREATE TYPE public.eligibility_decision_source AS ENUM (
  'manual_review',
  'system_rule',
  'regulatory_check',
  'admin_review',
  'legacy_migration'
);

CREATE TABLE public.entity_eligibilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id uuid NOT NULL REFERENCES public.entities(id) ON DELETE CASCADE,
  eligibility_type public.eligibility_type NOT NULL,
  status public.eligibility_status NOT NULL DEFAULT 'not_started',
  decision_source public.eligibility_decision_source NOT NULL,
  approved_at timestamptz,
  recheck_at timestamptz,
  expires_at timestamptz,
  reviewed_by uuid REFERENCES public.users(id),
  decision_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(entity_id, eligibility_type)
);

CREATE INDEX entity_eligibility_status_idx
  ON public.entity_eligibilities(entity_id, status);

ALTER TABLE public.entity_eligibilities ENABLE ROW LEVEL SECURITY;

CREATE POLICY entity_eligibility_owner_read
ON public.entity_eligibilities
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.entities e
    WHERE e.id=entity_id
      AND e.owner_user_id=auth.uid()
  )
  OR public.has_system_role(
    ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]
  )
);

GRANT SELECT ON public.entity_eligibilities TO duta_app;

CREATE OR REPLACE FUNCTION public.enforce_job_posting_safety()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $$
DECLARE
  employer_type public.entity_type;
  employer_status public.record_status;
  employer_name text;
  eligibility_current boolean;
BEGIN
  IF NEW.employer_entity_id IS NULL THEN
    RAISE EXCEPTION 'job employer entity is required';
  END IF;

  SELECT entity_type, record_status, display_name
  INTO employer_type, employer_status, employer_name
  FROM public.entities
  WHERE id=NEW.employer_entity_id;

  IF employer_type NOT IN ('business','organisation') THEN
    RAISE EXCEPTION 'job posting is not supported for this entity type';
  END IF;

  IF NEW.posting_kind IS DISTINCT FROM 'direct_employer' THEN
    RAISE EXCEPTION 'candidate placement and agency posting are not supported';
  END IF;

  SELECT EXISTS(
    SELECT 1
    FROM public.entity_eligibilities ee
    WHERE ee.entity_id=NEW.employer_entity_id
      AND ee.eligibility_type='employer'
      AND ee.status='approved'
      AND (ee.expires_at IS NULL OR ee.expires_at>now())
  )
  INTO eligibility_current;

  IF NEW.status='ACTIVE'
     AND (employer_status<>'ACTIVE' OR NOT eligibility_current) THEN
    RAISE EXCEPTION 'job publication requires active eligible employer';
  END IF;

  NEW.employer:=employer_name;

  NEW.employer_eligibility_snapshot:=
    CASE
      WHEN eligibility_current THEN 'approved'
      ELSE 'pending'
    END;

  IF NEW.status='ACTIVE'
     AND NEW.published_at IS NULL THEN
    NEW.published_at:=now();
  END IF;

  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS enforce_job_posting_safety
ON public.jobs;

CREATE TRIGGER enforce_job_posting_safety
BEFORE INSERT OR UPDATE
ON public.jobs
FOR EACH ROW
EXECUTE FUNCTION public.enforce_job_posting_safety();

DROP POLICY IF EXISTS jobs_runtime_owner
ON public.jobs;

CREATE POLICY jobs_runtime_owner
ON public.jobs
FOR ALL
TO duta_app
USING (
  owner_id=public.current_app_user_id()
)
WITH CHECK (
  owner_id=public.current_app_user_id()
  AND status IN (
    'DRAFT',
    'PENDING',
    'REJECTED',
    'ARCHIVED'
  )
);

DROP POLICY IF EXISTS jobs_runtime_moderator
ON public.jobs;

CREATE POLICY jobs_runtime_moderator
ON public.jobs
FOR UPDATE
TO duta_app
USING (
  public.current_app_has_role(
    ARRAY['MODERATOR']::public.user_role[]
  )
)
WITH CHECK (
  public.current_app_has_role(
    ARRAY['MODERATOR']::public.user_role[]
  )
);

DROP POLICY IF EXISTS jobs_runtime_moderator_read
ON public.jobs;

CREATE POLICY jobs_runtime_moderator_read
ON public.jobs
FOR SELECT
TO duta_app
USING (
  public.current_app_has_role(
    ARRAY['MODERATOR']::public.user_role[]
  )
);

ALTER POLICY jobs_public
ON public.jobs
TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE
ON public.jobs
TO duta_app;

COMMIT;