-- Day 8G: additive community access and organisation membership application foundation.
-- This migration creates no memberships and does not change eligibility, verification, legal status, or consumer subscriptions.

DO $$ BEGIN
  CREATE TYPE public.community_access_scope AS ENUM ('malaysia_present_only','pre_arrival_allowed','global');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN
  CREATE TYPE public.membership_geography AS ENUM ('malaysia_present_only','malaysia_and_indonesia','global');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN
  CREATE TYPE public.organization_membership_application_status AS ENUM ('pending','approved','rejected','withdrawn','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN
  CREATE TYPE public.organization_membership_application_source AS ENUM ('direct_application','invite','referral','event','admin_added','legacy');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint

ALTER TABLE public.communities ADD COLUMN IF NOT EXISTS community_access_scope public.community_access_scope;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS membership_geography public.membership_geography;
--> statement-breakpoint

CREATE TABLE IF NOT EXISTS public.organization_membership_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  membership_type text NOT NULL DEFAULT 'standard',
  status public.organization_membership_application_status NOT NULL DEFAULT 'pending',
  source public.organization_membership_application_source NOT NULL DEFAULT 'direct_application',
  application_answers jsonb NOT NULL DEFAULT '{}'::jsonb,
  access_country_code text,
  submitted_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES public.users(id),
  decision_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS org_membership_application_org_status_idx ON public.organization_membership_applications(organization_id,status);
CREATE INDEX IF NOT EXISTS org_membership_application_user_status_idx ON public.organization_membership_applications(user_id,status);
CREATE UNIQUE INDEX IF NOT EXISTS org_membership_application_pending_uq ON public.organization_membership_applications(organization_id,user_id) WHERE status='pending';
--> statement-breakpoint

CREATE OR REPLACE FUNCTION public.enforce_organization_membership_application_transition()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.organization_id IS DISTINCT FROM OLD.organization_id
    OR NEW.user_id IS DISTINCT FROM OLD.user_id
    OR NEW.membership_type IS DISTINCT FROM OLD.membership_type
    OR NEW.source IS DISTINCT FROM OLD.source
    OR NEW.application_answers IS DISTINCT FROM OLD.application_answers
    OR NEW.access_country_code IS DISTINCT FROM OLD.access_country_code
    OR NEW.submitted_at IS DISTINCT FROM OLD.submitted_at THEN
    RAISE EXCEPTION 'membership application submission data is immutable';
  END IF;
  IF OLD.status <> 'pending' OR NEW.status NOT IN ('approved','rejected','withdrawn') THEN
    RAISE EXCEPTION 'invalid membership application status transition';
  END IF;
  IF NEW.status='withdrawn' AND (NEW.reviewed_at IS NOT NULL OR NEW.reviewed_by IS NOT NULL OR NEW.decision_reason IS NOT NULL) THEN
    RAISE EXCEPTION 'withdrawn application cannot contain review data';
  END IF;
  IF NEW.status IN ('approved','rejected') AND (NEW.reviewed_at IS NULL OR NEW.reviewed_by IS NULL) THEN
    RAISE EXCEPTION 'reviewed application requires reviewer and review time';
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS organization_membership_application_transition ON public.organization_membership_applications;
CREATE TRIGGER organization_membership_application_transition
BEFORE UPDATE ON public.organization_membership_applications
FOR EACH ROW EXECUTE FUNCTION public.enforce_organization_membership_application_transition();
--> statement-breakpoint

ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_membership_applications ENABLE ROW LEVEL SECURITY;

-- Null scope preserves existing community behaviour and never evicts a current member.
DROP POLICY IF EXISTS community_member_join_with_access_scope ON public.community_members;
CREATE POLICY community_member_join_with_access_scope ON public.community_members
FOR INSERT TO authenticated
WITH CHECK (
  user_id=auth.uid() AND EXISTS (
    SELECT 1 FROM public.communities c
    WHERE c.id=community_id
      AND c.record_status='ACTIVE'
      AND (
        c.community_access_scope IS NULL
        OR c.community_access_scope IN ('pre_arrival_allowed','global')
        OR (c.community_access_scope='malaysia_present_only' AND EXISTS (
          SELECT 1 FROM public.user_presence_checks p
          WHERE p.user_id=auth.uid() AND p.country_code='MY' AND p.status='verified'
            AND (p.expires_at IS NULL OR p.expires_at>now())
        ))
      )
  )
);

-- Applicants can only submit a pending application for themselves. An organisation
-- must be backed by an organisation entity; community and business entities fail closed.
CREATE POLICY org_membership_application_submit ON public.organization_membership_applications
FOR INSERT TO authenticated
WITH CHECK (
  user_id=auth.uid()
  AND status='pending'
  AND reviewed_at IS NULL AND reviewed_by IS NULL AND decision_reason IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.organization_members m
    WHERE m.organization_id=organization_membership_applications.organization_id
      AND m.user_id=auth.uid() AND m.member_status='ACTIVE'
  )
  AND EXISTS (
    SELECT 1
    FROM public.organizations o
    JOIN public.entities e ON e.id=o.entity_id
    WHERE o.id=organization_membership_applications.organization_id
      AND e.entity_type='organisation'
      AND (
        o.membership_geography IS NULL OR o.membership_geography='global'
        OR (o.membership_geography='malaysia_present_only' AND EXISTS (
          SELECT 1 FROM public.user_presence_checks p
          WHERE p.user_id=auth.uid() AND p.country_code='MY' AND p.status='verified'
            AND (p.expires_at IS NULL OR p.expires_at>now())
        ))
        OR (o.membership_geography='malaysia_and_indonesia' AND (
          EXISTS (SELECT 1 FROM public.user_presence_checks p WHERE p.user_id=auth.uid() AND p.country_code='MY' AND p.status='verified' AND (p.expires_at IS NULL OR p.expires_at>now()))
          OR access_country_code='ID'
        ))
      )
  )
);

CREATE POLICY org_membership_application_scoped_read ON public.organization_membership_applications
FOR SELECT TO authenticated
USING (
  user_id=auth.uid()
  OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])
);

-- A withdrawal cannot change reviewer or decision data and only applies while pending.
CREATE POLICY org_membership_application_withdraw ON public.organization_membership_applications
FOR UPDATE TO authenticated
USING (user_id=auth.uid() AND status='pending')
WITH CHECK (
  user_id=auth.uid() AND status='withdrawn'
  AND reviewed_at IS NULL AND reviewed_by IS NULL AND decision_reason IS NULL
);

-- Reviewer must be an owner or admin of the same organisation and cannot self-review.
CREATE POLICY org_membership_application_review ON public.organization_membership_applications
FOR UPDATE TO authenticated
USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]))
WITH CHECK (
  public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])
  AND user_id<>auth.uid()
  AND status IN ('approved','rejected')
  AND reviewed_by=auth.uid() AND reviewed_at IS NOT NULL
);

GRANT SELECT, INSERT, UPDATE ON public.community_members TO duta_app;
GRANT SELECT, INSERT, UPDATE ON public.organization_membership_applications TO duta_app;