-- Day 8I: additive event safety and paid-event eligibility foundation.
-- Existing events remain readable and are not mass-updated, unpublished, or deleted.
DO $$ BEGIN CREATE TYPE public.event_risk_tier AS ENUM ('LOW','REVIEW','PROHIBITED'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.event_compliance_review_status AS ENUM ('not_required','pending','approved','rejected','not_applicable'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint

ALTER TABLE public.events ADD COLUMN IF NOT EXISTS organizer_entity_id uuid REFERENCES public.entities(id);
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS price_myr numeric(10,2);
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS event_category text;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS risk_tier public.event_risk_tier;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS compliance_review_status public.event_compliance_review_status;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS published_at timestamptz;
CREATE INDEX IF NOT EXISTS events_organizer_entity_idx ON public.events(organizer_entity_id,status);
--> statement-breakpoint

-- Paid state and event risk are derived here; clients cannot submit a boolean,
-- eligibility, risk, or review claim that overrides this policy.
CREATE OR REPLACE FUNCTION public.enforce_event_safety()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  organizer_type public.entity_type;
  organizer_active boolean;
  organization_entity uuid;
  paid_event_current boolean;
BEGIN
  IF NEW.price_myr IS NOT NULL AND NEW.price_myr < 0 THEN RAISE EXCEPTION 'event price cannot be negative'; END IF;

  -- Existing rows retain their nullable legacy linkage until an edit supplies one.
  IF NEW.organizer_entity_id IS NULL THEN
    IF TG_OP='INSERT' THEN RAISE EXCEPTION 'event organizer entity is required'; END IF;
    RETURN NEW;
  END IF;

  SELECT entity_type,record_status='ACTIVE' INTO organizer_type,organizer_active FROM public.entities WHERE id=NEW.organizer_entity_id;
  IF organizer_type IS NULL OR NOT organizer_active THEN RAISE EXCEPTION 'event organizer must be an active entity'; END IF;
  IF organizer_type NOT IN ('organisation','community') THEN RAISE EXCEPTION 'event hosting is not supported for this entity type'; END IF;

  IF NEW.organization_id IS NOT NULL THEN
    SELECT entity_id INTO organization_entity FROM public.organizations WHERE id=NEW.organization_id;
    IF organization_entity IS NULL OR organization_entity IS DISTINCT FROM NEW.organizer_entity_id THEN RAISE EXCEPTION 'event organization must match organizer entity'; END IF;
  ELSIF organizer_type='organisation' THEN
    RAISE EXCEPTION 'organisation event requires its organization linkage';
  END IF;

  NEW.risk_tier:=CASE lower(trim(COALESCE(NEW.event_category,'')))
    WHEN 'community_gathering' THEN 'LOW'::public.event_risk_tier
    WHEN 'education_session' THEN 'LOW'::public.event_risk_tier
    WHEN 'networking' THEN 'LOW'::public.event_risk_tier
    WHEN 'cultural_event' THEN 'LOW'::public.event_risk_tier
    WHEN 'internal_meeting' THEN 'LOW'::public.event_risk_tier
    WHEN 'food_and_beverage' THEN 'REVIEW'::public.event_risk_tier
    WHEN 'large_gathering' THEN 'REVIEW'::public.event_risk_tier
    ELSE 'PROHIBITED'::public.event_risk_tier
  END;
  NEW.compliance_review_status:=CASE NEW.risk_tier
    WHEN 'LOW' THEN 'not_required'::public.event_compliance_review_status
    WHEN 'REVIEW' THEN 'pending'::public.event_compliance_review_status
    ELSE 'not_applicable'::public.event_compliance_review_status
  END;
  IF NEW.risk_tier='PROHIBITED' THEN RAISE EXCEPTION 'event category is prohibited or unknown'; END IF;
  IF NEW.risk_tier='REVIEW' THEN RAISE EXCEPTION 'event category requires manual review'; END IF;

  IF COALESCE(NEW.price_myr,0)>0 THEN
    IF organizer_type='community' THEN RAISE EXCEPTION 'community paid events are not allowed'; END IF;
    SELECT EXISTS(SELECT 1 FROM public.entity_eligibilities ee WHERE ee.entity_id=NEW.organizer_entity_id AND ee.eligibility_type='paid_event' AND ee.status='approved' AND (ee.expires_at IS NULL OR ee.expires_at>now())) INTO paid_event_current;
    IF NOT paid_event_current THEN RAISE EXCEPTION 'paid event requires current paid_event eligibility'; END IF;
  END IF;
  IF NEW.status='ACTIVE' AND NEW.published_at IS NULL THEN NEW.published_at:=now(); END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS events_safety_enforcement ON public.events;
CREATE TRIGGER events_safety_enforcement BEFORE INSERT OR UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.enforce_event_safety();
--> statement-breakpoint

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS events_org_manage ON public.events;
DROP POLICY IF EXISTS events_entity_manage ON public.events;
CREATE POLICY events_entity_manage ON public.events
FOR ALL TO authenticated
USING (organizer_entity_id IS NOT NULL AND EXISTS(
  SELECT 1 FROM public.entities e WHERE e.id=events.organizer_entity_id AND e.record_status='ACTIVE' AND (
    (e.entity_type='organisation' AND EXISTS(SELECT 1 FROM public.organizations o WHERE o.entity_id=e.id AND public.has_org_role(o.id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[])))
    OR (e.entity_type='community' AND EXISTS(SELECT 1 FROM public.communities c WHERE c.entity_id=e.id AND c.owner_id=auth.uid()))
  )
))
WITH CHECK (organizer_entity_id IS NOT NULL AND EXISTS(
  SELECT 1 FROM public.entities e WHERE e.id=events.organizer_entity_id AND e.record_status='ACTIVE' AND (
    (e.entity_type='organisation' AND EXISTS(SELECT 1 FROM public.organizations o WHERE o.entity_id=e.id AND public.has_org_role(o.id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[])))
    OR (e.entity_type='community' AND EXISTS(SELECT 1 FROM public.communities c WHERE c.entity_id=e.id AND c.owner_id=auth.uid()))
  )
));
