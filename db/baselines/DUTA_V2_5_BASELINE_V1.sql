-- DUTA_V2_5_BASELINE_V1
-- Canonical schema-only pre-0039 provisioning contract. No historical journal, no application data.
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN BYPASSRLS;
CREATE ROLE duta_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE duta_system LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
--
-- PostgreSQL database dump
--

\restrict 6hQeiF5GN4EGpvRNpsrqjJgg38Wd8HTbQ9KPTeBsv8KiebAi0vBRJAWsXlEwWqm

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: community_access_scope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.community_access_scope AS ENUM (
    'malaysia_present_only',
    'pre_arrival_allowed',
    'global'
);


--
-- Name: eligibility_decision_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.eligibility_decision_source AS ENUM (
    'manual_review',
    'system_rule',
    'regulatory_check',
    'admin_review',
    'legacy_migration'
);


--
-- Name: eligibility_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.eligibility_status AS ENUM (
    'not_started',
    'pending',
    'approved',
    'rejected',
    'expired',
    'suspended'
);


--
-- Name: eligibility_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.eligibility_type AS ENUM (
    'commercial',
    'employer',
    'paid_event',
    'regulated_service',
    'payment_connect'
);


--
-- Name: entity_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entity_type AS ENUM (
    'business',
    'community',
    'organisation'
);


--
-- Name: event_compliance_review_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.event_compliance_review_status AS ENUM (
    'not_required',
    'pending',
    'approved',
    'rejected',
    'not_applicable'
);


--
-- Name: event_risk_tier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.event_risk_tier AS ENUM (
    'LOW',
    'REVIEW',
    'PROHIBITED'
);


--
-- Name: external_job_source_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.external_job_source_status AS ENUM (
    'active',
    'stale',
    'unknown',
    'closed'
);


--
-- Name: external_job_source_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.external_job_source_type AS ENUM (
    'OFFICIAL',
    'DIRECT_EMPLOYER',
    'LICENSED_APS'
);


--
-- Name: legal_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.legal_status AS ENUM (
    'registered',
    'registered_under_other_law',
    'foreign_registered',
    'registration_pending',
    'registration_not_verified',
    'informal_group',
    'unknown'
);


--
-- Name: marketplace_compliance_review_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.marketplace_compliance_review_status AS ENUM (
    'not_required',
    'pending',
    'approved',
    'rejected',
    'not_applicable'
);


--
-- Name: marketplace_risk_tier; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.marketplace_risk_tier AS ENUM (
    'GREEN',
    'YELLOW',
    'RED'
);


--
-- Name: membership_geography; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.membership_geography AS ENUM (
    'malaysia_present_only',
    'malaysia_and_indonesia',
    'global'
);


--
-- Name: moderation_case_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.moderation_case_status AS ENUM (
    'NORMAL',
    'LIMITED',
    'UNDER_REVIEW',
    'SUSPENDED',
    'BANNED',
    'REGULATORY_HOLD',
    'CLOSED'
);


--
-- Name: moderation_scope; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.moderation_scope AS ENUM (
    'CONTENT_ONLY',
    'MARKETPLACE',
    'EVENTS',
    'JOBS',
    'COMMUNITY_POSTING',
    'ENTITY_ACTIVITY',
    'ACCOUNT'
);


--
-- Name: moderation_severity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.moderation_severity AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


--
-- Name: organization_membership_application_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.organization_membership_application_source AS ENUM (
    'direct_application',
    'invite',
    'referral',
    'event',
    'admin_added',
    'legacy'
);


--
-- Name: organization_membership_application_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.organization_membership_application_status AS ENUM (
    'pending',
    'approved',
    'rejected',
    'withdrawn',
    'cancelled'
);


--
-- Name: organization_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.organization_role AS ENUM (
    'OWNER',
    'ADMIN',
    'SECRETARY',
    'TREASURER',
    'STAFF',
    'MEMBER'
);


--
-- Name: platform_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.platform_role AS ENUM (
    'super_admin',
    'compliance_admin',
    'verification_reviewer',
    'moderation_admin'
);


--
-- Name: presence_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.presence_method AS ENUM (
    'malaysian_phone',
    'device_location',
    'manual_review',
    'provider_assertion'
);


--
-- Name: presence_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.presence_status AS ENUM (
    'pending',
    'verified',
    'failed',
    'expired',
    'revoked'
);


--
-- Name: record_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.record_status AS ENUM (
    'DRAFT',
    'PENDING',
    'ACTIVE',
    'SUSPENDED',
    'ARCHIVED'
);


--
-- Name: responsible_person_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.responsible_person_status AS ENUM (
    'pending',
    'active',
    'inactive',
    'revoked'
);


--
-- Name: trust_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.trust_level AS ENUM (
    'OFFICIAL_VERIFIED',
    'INSTITUTION_VERIFIED',
    'DUTA_VERIFIED',
    'COMMUNITY_VERIFIED',
    'USER_GENERATED'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'USER',
    'MEMBER',
    'VERIFIED_MEMBER',
    'SELLER',
    'ORG_ADMIN',
    'ORG_STAFF',
    'MODERATOR',
    'EDITOR',
    'SUPER_ADMIN'
);


--
-- Name: verification_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verification_source AS ENUM (
    'user_submitted',
    'manual_review',
    'official_registry',
    'provider_assertion',
    'system_check',
    'admin_review'
);


--
-- Name: verification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verification_status AS ENUM (
    'not_started',
    'pending',
    'verified',
    'rejected',
    'expired',
    'revoked',
    'suspended'
);


--
-- Name: verification_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verification_type AS ENUM (
    'phone',
    'identity',
    'liveness',
    'malaysia_presence',
    'entity_registration',
    'representative_authority',
    'licence',
    'official_source'
);


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$ SELECT coalesce(nullif(current_setting('request.jwt.claims',true),'')::jsonb,'{}'::jsonb) $$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$ SELECT nullif(current_setting('request.jwt.claim.role',true),'') $$;


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$ SELECT nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;


--
-- Name: consume_ai_usage(uuid, integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.consume_ai_usage(p_user uuid, p_units integer, p_limit integer, p_request_id text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
  quota_period_start timestamptz := date_trunc('day', now() AT TIME ZONE 'UTC') AT TIME ZONE 'UTC';
  actor_id uuid;
  request_inserted boolean;
BEGIN
  actor_id := public.current_app_user_id();
  IF actor_id IS NULL OR p_user IS NULL OR p_user IS DISTINCT FROM actor_id THEN
    RAISE EXCEPTION 'verified application identity is required';
  END IF;

  -- 30 is the current server-owned fair-use ceiling passed by the runtime.
  -- Lower limits remain valid; callers cannot raise the ceiling above 30.
  IF p_units IS NULL OR p_limit IS NULL OR p_units <= 0 OR p_limit <= 0
     OR p_units > p_limit OR p_limit > 30 THEN
    RAISE EXCEPTION 'invalid ai quota';
  END IF;

  IF p_request_id IS NULL OR length(btrim(p_request_id)) NOT BETWEEN 1 AND 128 THEN
    RAISE EXCEPTION 'valid ai quota request identifier is required';
  END IF;

  INSERT INTO public.ai_usage_requests(user_id, period_start, request_id, units)
  VALUES (actor_id, quota_period_start, p_request_id, p_units)
  ON CONFLICT (user_id, period_start, request_id) DO NOTHING
  RETURNING true INTO request_inserted;

  IF NOT COALESCE(request_inserted, false) THEN
    RETURN true;
  END IF;

  INSERT INTO public.ai_usage_buckets(user_id, period_start, usage_units, request_count)
  VALUES (actor_id, quota_period_start, p_units, 1)
  ON CONFLICT (user_id, period_start) DO UPDATE
  SET usage_units = public.ai_usage_buckets.usage_units + excluded.usage_units,
      request_count = public.ai_usage_buckets.request_count + 1,
      updated_at = now()
  WHERE public.ai_usage_buckets.usage_units + excluded.usage_units <= p_limit;

  IF FOUND THEN
    RETURN true;
  END IF;

  DELETE FROM public.ai_usage_requests
  WHERE user_id = actor_id
    AND period_start = quota_period_start
    AND request_id = p_request_id;
  RETURN false;
END
$$;


--
-- Name: current_app_has_org_role(uuid, public.organization_role[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_app_has_org_role(org_id uuid, allowed public.organization_role[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
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


--
-- Name: current_app_has_role(public.user_role[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_app_has_role(allowed public.user_role[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u.id = public.current_app_user_id()
      AND u.suspended_at IS NULL
      AND u.role = ANY(allowed)
  )
$$;


--
-- Name: current_app_user_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_app_user_id() RETURNS uuid
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO ''
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


--
-- Name: delete_current_app_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_current_app_user() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
  target_id uuid;
  deleted_count integer;
BEGIN
  target_id := public.current_app_user_id();

  IF target_id IS NULL THEN
    RAISE EXCEPTION 'Application identity is required';
  END IF;

  DELETE FROM public.users
  WHERE id = target_id;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  RETURN deleted_count = 1;
END;
$$;


--
-- Name: enforce_event_safety(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_event_safety() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: enforce_job_posting_safety(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_job_posting_safety() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: enforce_marketplace_product_compliance(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_marketplace_product_compliance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  seller_entity uuid;
  seller_entity_type public.entity_type;
  eligibility_current boolean;
BEGIN
  SELECT s.entity_id,e.entity_type
    INTO seller_entity,seller_entity_type
    FROM public.sellers s LEFT JOIN public.entities e ON e.id=s.entity_id
   WHERE s.id=NEW.seller_id;
  IF seller_entity IS NULL OR NEW.seller_entity_id IS DISTINCT FROM seller_entity THEN
    RAISE EXCEPTION 'seller entity linkage is required';
  END IF;
  IF seller_entity_type NOT IN ('business','organisation') THEN
    RAISE EXCEPTION 'community marketplace selling is not allowed';
  END IF;

  NEW.risk_tier := CASE lower(trim(NEW.category))
    WHEN 'ordinary_goods' THEN 'GREEN'::public.marketplace_risk_tier
    WHEN 'food_and_beverage' THEN 'YELLOW'::public.marketplace_risk_tier
    WHEN 'regulated_service' THEN 'RED'::public.marketplace_risk_tier
    WHEN 'employment' THEN 'RED'::public.marketplace_risk_tier
    WHEN 'paid_event' THEN 'RED'::public.marketplace_risk_tier
    WHEN 'investment' THEN 'RED'::public.marketplace_risk_tier
    ELSE 'RED'::public.marketplace_risk_tier
  END;
  NEW.compliance_review_status := CASE NEW.risk_tier
    WHEN 'GREEN' THEN 'not_required'::public.marketplace_compliance_review_status
    WHEN 'YELLOW' THEN 'pending'::public.marketplace_compliance_review_status
    ELSE 'not_applicable'::public.marketplace_compliance_review_status
  END;
  SELECT EXISTS (
    SELECT 1 FROM public.entity_eligibilities ee
     WHERE ee.entity_id=seller_entity AND ee.eligibility_type='commercial'
       AND ee.status='approved' AND (ee.expires_at IS NULL OR ee.expires_at>now())
  ) INTO eligibility_current;
  NEW.commercial_eligibility_snapshot := CASE WHEN eligibility_current THEN 'approved' ELSE 'not_approved' END;

  IF NEW.status='ACTIVE' AND (NEW.risk_tier<>'GREEN' OR NOT eligibility_current) THEN
    RAISE EXCEPTION 'marketplace publication requires current commercial eligibility and a GREEN category';
  END IF;
  IF NEW.status='ACTIVE' AND NEW.published_at IS NULL THEN NEW.published_at:=now(); END IF;
  RETURN NEW;
END $$;


--
-- Name: enforce_official_job_source_safety(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_official_job_source_safety() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF NEW.source_type='OFFICIAL' THEN
    IF NEW.source_name<>'SISKOP2MI / KP2MI' OR NEW.destination_country<>'MALAYSIA' THEN RAISE EXCEPTION 'official source identity and Malaysia destination are required'; END IF;
    IF NEW.source_url !~ '^https://siskop2mi\\.bp2mi\\.go\\.id/lowongan/(detail/[0-9]+|list)$' THEN RAISE EXCEPTION 'official source URL is not approved'; END IF;
  END IF;
  IF NEW.source_status='active' AND (NEW.last_checked_at IS NULL OR NEW.last_checked_at<=now()-interval '7 days') THEN RAISE EXCEPTION 'active external job requires current source check'; END IF;
  IF NEW.expires_at IS NOT NULL AND NEW.expires_at<=now() THEN NEW.source_status:='stale'; END IF;
  RETURN NEW;
END $_$;


--
-- Name: enforce_organization_member_role_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_organization_member_role_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: enforce_organization_membership_application_transition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enforce_organization_membership_application_transition() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: has_org_role(uuid, public.organization_role[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.organization_members m WHERE m.organization_id=org_id AND m.user_id=auth.uid() AND m.role=ANY(allowed) AND m.member_status='ACTIVE')
$$;


--
-- Name: has_platform_role(public.platform_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_platform_role(required_role public.platform_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_platform_roles upr
    WHERE upr.user_id=auth.uid() AND upr.role=required_role AND upr.revoked_at IS NULL
  )
$$;


--
-- Name: has_system_role(public.user_role[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_system_role(allowed public.user_role[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = ANY(allowed) AND u.suspended_at IS NULL)
$$;


--
-- Name: protect_moderation_fields(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_moderation_fields() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
DECLARE oldj jsonb:=CASE WHEN TG_OP='UPDATE' THEN to_jsonb(OLD) ELSE '{}'::jsonb END;newj jsonb:=to_jsonb(NEW);allowed boolean:=false;
BEGIN
 IF session_user IN ('duta_rantau','duta_system') THEN RETURN NEW; END IF;
 IF public.current_app_user_id() IS NULL THEN RAISE EXCEPTION 'authenticated identity required' USING ERRCODE='42501'; END IF;
 IF TG_TABLE_NAME='contents' THEN allowed:=public.current_app_has_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]); ELSIF TG_TABLE_NAME='publication_projects' THEN allowed:=public.current_app_has_org_role((newj->>'organization_id')::uuid,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR public.current_app_has_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]); ELSE allowed:=public.current_app_has_role(ARRAY['ORG_ADMIN','MODERATOR','SUPER_ADMIN']::public.user_role[]); END IF;
 IF allowed THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' THEN
  IF COALESCE(newj->>'status','') NOT IN ('DRAFT','PENDING') OR COALESCE(newj->>'trust_level',newj->>'verification','USER_GENERATED')<>'USER_GENERATED' THEN RAISE EXCEPTION 'moderation fields are protected' USING ERRCODE='42501'; END IF;
 ELSE
  IF newj->>'status' IS DISTINCT FROM oldj->>'status' OR newj->>'trust_level' IS DISTINCT FROM oldj->>'trust_level' OR newj->>'verification' IS DISTINCT FROM oldj->>'verification' OR newj->>'active' IS DISTINCT FROM oldj->>'active' OR newj->>'approved_by' IS DISTINCT FROM oldj->>'approved_by' OR newj->>'published_at' IS DISTINCT FROM oldj->>'published_at' THEN RAISE EXCEPTION 'moderation fields are protected' USING ERRCODE='42501'; END IF;
 END IF;
 RETURN NEW;
END $$;


--
-- Name: protect_organization_archival(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_organization_archival() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    intent text,
    messages jsonb NOT NULL,
    source_ids uuid[],
    confidence text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_telemetry_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_telemetry_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_ref uuid,
    intent text NOT NULL,
    risk text NOT NULL,
    sensitivity text NOT NULL,
    model_class text NOT NULL,
    provider text,
    model text,
    source_requirement text NOT NULL,
    source_tier text,
    quota_outcome text NOT NULL,
    weighted_units integer NOT NULL,
    input_tokens integer NOT NULL,
    output_tokens integer NOT NULL,
    estimated_cost numeric(14,8) DEFAULT 0 NOT NULL,
    latency_ms integer DEFAULT 0 NOT NULL,
    success boolean NOT NULL,
    error_code text,
    fallback_used boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    correlation_id text
);


--
-- Name: ai_usage_buckets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_usage_buckets (
    user_id uuid NOT NULL,
    period_start timestamp with time zone NOT NULL,
    usage_units integer DEFAULT 0 NOT NULL,
    request_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_usage_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_usage_requests (
    user_id uuid NOT NULL,
    period_start timestamp with time zone NOT NULL,
    request_id text NOT NULL,
    units integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_usage_requests_request_id_check CHECK (((length(btrim(request_id)) >= 1) AND (length(btrim(request_id)) <= 128))),
    CONSTRAINT ai_usage_requests_units_check CHECK ((units > 0))
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    actor_id uuid,
    organization_id uuid,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text,
    metadata jsonb,
    ip_hash text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: communities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.communities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid,
    name text NOT NULL,
    description text,
    category text NOT NULL,
    state text,
    city text,
    visibility text DEFAULT 'PUBLIC'::text NOT NULL,
    trust_level public.trust_level DEFAULT 'USER_GENERATED'::public.trust_level NOT NULL,
    status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    entity_id uuid,
    community_access_scope public.community_access_scope
);


--
-- Name: community_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.community_members (
    community_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text DEFAULT 'MEMBER'::text NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    author_id uuid,
    title text NOT NULL,
    slug text NOT NULL,
    body text NOT NULL,
    type text NOT NULL,
    category text,
    state text,
    city text,
    trust_level public.trust_level DEFAULT 'USER_GENERATED'::public.trust_level NOT NULL,
    source_id uuid,
    status public.record_status DEFAULT 'DRAFT'::public.record_status NOT NULL,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type public.entity_type NOT NULL,
    display_name text NOT NULL,
    slug text NOT NULL,
    owner_user_id uuid,
    record_status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    legal_status public.legal_status DEFAULT 'unknown'::public.legal_status NOT NULL,
    legal_status_claim public.legal_status,
    legal_status_verified public.legal_status,
    registration_authority text,
    registration_type text,
    registration_number text,
    jurisdiction text,
    operating_country text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT entities_legal_verified_requires_claim CHECK (((legal_status_verified IS NULL) OR (legal_status_claim IS NOT NULL)))
);


--
-- Name: entity_eligibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_eligibilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_id uuid NOT NULL,
    eligibility_type public.eligibility_type NOT NULL,
    status public.eligibility_status DEFAULT 'not_started'::public.eligibility_status NOT NULL,
    decision_source public.eligibility_decision_source NOT NULL,
    approved_at timestamp with time zone,
    recheck_at timestamp with time zone,
    expires_at timestamp with time zone,
    reviewed_by uuid,
    decision_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: entity_responsible_persons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_responsible_persons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    status public.responsible_person_status DEFAULT 'pending'::public.responsible_person_status NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    appointed_at timestamp with time zone,
    ended_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: entity_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_id uuid NOT NULL,
    verification_type public.verification_type NOT NULL,
    status public.verification_status DEFAULT 'not_started'::public.verification_status NOT NULL,
    source public.verification_source NOT NULL,
    checked_at timestamp with time zone,
    recheck_at timestamp with time zone,
    expires_at timestamp with time zone,
    reviewed_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid,
    title text NOT NULL,
    description text,
    location text,
    starts_at timestamp with time zone NOT NULL,
    capacity integer,
    registration_enabled boolean DEFAULT true,
    status public.record_status DEFAULT 'DRAFT'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    organizer_entity_id uuid,
    price_myr numeric(10,2),
    event_category text,
    risk_tier public.event_risk_tier,
    compliance_review_status public.event_compliance_review_status,
    published_at timestamp with time zone
);


--
-- Name: external_job_listings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_job_listings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    external_job_id text NOT NULL,
    source_type public.external_job_source_type NOT NULL,
    source_name text NOT NULL,
    source_url text NOT NULL,
    destination_country text NOT NULL,
    job_title text NOT NULL,
    sector text,
    employer_name text,
    p3mi_name text,
    location text,
    vacancy_count integer,
    education_requirement text,
    published_at timestamp with time zone,
    expires_at timestamp with time zone,
    source_status public.external_job_source_status DEFAULT 'unknown'::public.external_job_source_status NOT NULL,
    fetched_at timestamp with time zone,
    last_checked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid,
    title text NOT NULL,
    employer text NOT NULL,
    description text NOT NULL,
    state text,
    city text,
    salary_text text,
    employment_type text NOT NULL,
    requirements text,
    language text,
    application_method text,
    trust_level public.trust_level DEFAULT 'USER_GENERATED'::public.trust_level NOT NULL,
    expires_at timestamp with time zone,
    status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    employer_entity_id uuid,
    posting_kind text,
    employer_eligibility_snapshot text,
    published_at timestamp with time zone
);


--
-- Name: meeting_transcripts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.meeting_transcripts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    meeting_id uuid NOT NULL,
    created_by uuid NOT NULL,
    language text DEFAULT 'id'::text NOT NULL,
    transcript text NOT NULL,
    summary text NOT NULL,
    action_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    consent_confirmed boolean DEFAULT false NOT NULL,
    audio_deleted_at timestamp with time zone NOT NULL,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    plan text NOT NULL,
    status text NOT NULL,
    price_myr numeric(10,2),
    start_date timestamp with time zone,
    renewal_date timestamp with time zone,
    cancelled_at timestamp with time zone,
    eastel_bonus_status text DEFAULT 'NOT_CLAIMED'::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: moderation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    case_id uuid NOT NULL,
    actor_user_id uuid NOT NULL,
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    scope public.moderation_scope NOT NULL,
    old_status public.moderation_case_status,
    new_status public.moderation_case_status NOT NULL,
    reason text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: moderation_case_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_case_reports (
    case_id uuid NOT NULL,
    report_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: moderation_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_cases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    status public.moderation_case_status DEFAULT 'UNDER_REVIEW'::public.moderation_case_status NOT NULL,
    severity public.moderation_severity DEFAULT 'LOW'::public.moderation_severity NOT NULL,
    assigned_reviewer_id uuid,
    decision text,
    decision_reason text,
    decided_at timestamp with time zone,
    reviewed_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: moderation_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_evidence (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    case_id uuid NOT NULL,
    submitted_by uuid,
    storage_key text,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type text NOT NULL,
    priority text NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: official_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.official_contacts (
    id text NOT NULL,
    office_id text NOT NULL,
    label text NOT NULL,
    display_number text NOT NULL,
    e164 text NOT NULL,
    channel text NOT NULL,
    purpose text NOT NULL,
    warning text,
    whatsapp_confirmed boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true NOT NULL,
    last_checked timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: official_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.official_evidence (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    office_id text,
    institution text NOT NULL,
    evidence_type text NOT NULL,
    file_path text NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    effective_date timestamp with time zone,
    verification_status text DEFAULT 'SUPPLIED_OFFICIAL_SCREENSHOT'::text NOT NULL,
    extracted_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: official_offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.official_offices (
    id text NOT NULL,
    institution text NOT NULL,
    city text NOT NULL,
    region text NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    official_url text NOT NULL,
    source_channel text NOT NULL,
    last_checked timestamp with time zone NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: official_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.official_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    institution text NOT NULL,
    channel text NOT NULL,
    url text NOT NULL,
    category text NOT NULL,
    priority text NOT NULL,
    trust_level public.trust_level DEFAULT 'OFFICIAL_VERIFIED'::public.trust_level NOT NULL,
    last_checked timestamp with time zone NOT NULL,
    checksum text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_attendance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    event_id uuid,
    meeting_id uuid,
    user_id uuid NOT NULL,
    status text NOT NULL,
    checked_in_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_branches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    state text,
    city text,
    contact text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    author_id uuid NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    storage_key text,
    content text,
    status public.record_status DEFAULT 'DRAFT'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_finances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_finances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    type text NOT NULL,
    amount numeric(14,2) NOT NULL,
    description text NOT NULL,
    transaction_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_letters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_letters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    number text,
    direction text NOT NULL,
    title text NOT NULL,
    content text,
    approval_status text DEFAULT 'DRAFT'::text NOT NULL,
    approved_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_meetings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    title text NOT NULL,
    agenda text,
    minutes text,
    starts_at timestamp with time zone NOT NULL,
    location text,
    status public.record_status DEFAULT 'DRAFT'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_members (
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.organization_role DEFAULT 'MEMBER'::public.organization_role NOT NULL,
    member_status text DEFAULT 'ACTIVE'::text NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_membership_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_membership_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    membership_type text DEFAULT 'standard'::text NOT NULL,
    status public.organization_membership_application_status DEFAULT 'pending'::public.organization_membership_application_status NOT NULL,
    source public.organization_membership_application_source DEFAULT 'direct_application'::public.organization_membership_application_source NOT NULL,
    application_answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    access_country_code text,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL,
    reviewed_at timestamp with time zone,
    reviewed_by uuid,
    decision_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subscription_id uuid NOT NULL,
    provider text NOT NULL,
    provider_reference text,
    amount_myr numeric(10,2) NOT NULL,
    status text NOT NULL,
    invoice_number text,
    failure_code text,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    role public.organization_role NOT NULL,
    permission text NOT NULL
);


--
-- Name: organization_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    plan text DEFAULT 'FREE'::text NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    price_myr numeric(10,2) DEFAULT '0'::numeric NOT NULL,
    provider text,
    provider_reference text,
    start_date timestamp with time zone DEFAULT now() NOT NULL,
    renewal_date timestamp with time zone,
    cancelled_at timestamp with time zone,
    grace_ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organization_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    assignee_id uuid,
    created_by uuid NOT NULL,
    title text NOT NULL,
    description text,
    due_at timestamp with time zone,
    status text DEFAULT 'OPEN'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    description text,
    state text,
    city text,
    logo_url text,
    contact text,
    verification public.trust_level DEFAULT 'USER_GENERATED'::public.trust_level NOT NULL,
    status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    entity_id uuid,
    membership_geography public.membership_geography
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    membership_id uuid NOT NULL,
    provider text NOT NULL,
    provider_reference text,
    amount_myr numeric(10,2) NOT NULL,
    status text NOT NULL,
    invoice_number text,
    failure_code text,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    seller_id uuid NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    category text NOT NULL,
    price_myr numeric(12,2),
    images jsonb DEFAULT '[]'::jsonb,
    state text,
    city text,
    status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    seller_entity_id uuid,
    risk_tier public.marketplace_risk_tier,
    commercial_eligibility_snapshot text,
    compliance_review_status public.marketplace_compliance_review_status,
    published_at timestamp with time zone
);


--
-- Name: publication_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publication_projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    created_by uuid NOT NULL,
    approved_by uuid,
    type text NOT NULL,
    title text NOT NULL,
    prompt text,
    content jsonb NOT NULL,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: publication_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publication_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid,
    name text NOT NULL,
    type text NOT NULL,
    category text NOT NULL,
    schema jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reporter_id uuid,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    category text NOT NULL,
    details text,
    status text DEFAULT 'OPEN'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: sellers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sellers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    organization_id uuid,
    name text NOT NULL,
    description text,
    trust_level public.trust_level DEFAULT 'USER_GENERATED'::public.trust_level NOT NULL,
    status public.record_status DEFAULT 'PENDING'::public.record_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    entity_id uuid
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_platform_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_platform_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.platform_role NOT NULL,
    assigned_by uuid,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    reason text
);


--
-- Name: user_presence_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_presence_checks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    country_code text NOT NULL,
    status public.presence_status DEFAULT 'pending'::public.presence_status NOT NULL,
    method public.presence_method NOT NULL,
    checked_at timestamp with time zone,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    verification_type public.verification_type NOT NULL,
    status public.verification_status DEFAULT 'not_started'::public.verification_status NOT NULL,
    source public.verification_source NOT NULL,
    checked_at timestamp with time zone,
    recheck_at timestamp with time zone,
    expires_at timestamp with time zone,
    reviewed_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text,
    name text NOT NULL,
    phone text,
    avatar_url text,
    city text,
    state text,
    hometown text,
    profession text,
    interests text[],
    role public.user_role DEFAULT 'USER'::public.user_role NOT NULL,
    email_verified_at timestamp with time zone,
    profile_visibility text DEFAULT 'PRIVATE'::text NOT NULL,
    location_visibility text DEFAULT 'PRIVATE'::text NOT NULL,
    suspended_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: verification_evidence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verification_evidence (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_verification_id uuid,
    entity_verification_id uuid,
    provider_reference text,
    document_metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    review_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT verification_evidence_subject CHECK (((user_verification_id IS NULL) <> (entity_verification_id IS NULL)))
);


--
-- Name: ai_conversations ai_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_conversations
    ADD CONSTRAINT ai_conversations_pkey PRIMARY KEY (id);


--
-- Name: ai_telemetry_events ai_telemetry_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_telemetry_events
    ADD CONSTRAINT ai_telemetry_events_pkey PRIMARY KEY (id);


--
-- Name: ai_usage_buckets ai_usage_buckets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_buckets
    ADD CONSTRAINT ai_usage_buckets_pkey PRIMARY KEY (user_id, period_start);


--
-- Name: ai_usage_requests ai_usage_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_requests
    ADD CONSTRAINT ai_usage_requests_pkey PRIMARY KEY (user_id, period_start, request_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: communities communities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_pkey PRIMARY KEY (id);


--
-- Name: contents contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entity_eligibilities entity_eligibilities_entity_id_eligibility_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_eligibilities
    ADD CONSTRAINT entity_eligibilities_entity_id_eligibility_type_key UNIQUE (entity_id, eligibility_type);


--
-- Name: entity_eligibilities entity_eligibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_eligibilities
    ADD CONSTRAINT entity_eligibilities_pkey PRIMARY KEY (id);


--
-- Name: entity_responsible_persons entity_responsible_persons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_responsible_persons
    ADD CONSTRAINT entity_responsible_persons_pkey PRIMARY KEY (id);


--
-- Name: entity_verifications entity_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_verifications
    ADD CONSTRAINT entity_verifications_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_job_listings external_job_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_job_listings
    ADD CONSTRAINT external_job_listings_pkey PRIMARY KEY (id);


--
-- Name: external_job_listings external_job_listings_source_type_external_job_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_job_listings
    ADD CONSTRAINT external_job_listings_source_type_external_job_id_key UNIQUE (source_type, external_job_id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: meeting_transcripts meeting_transcripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_transcripts
    ADD CONSTRAINT meeting_transcripts_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- Name: moderation_case_reports moderation_case_reports_case_id_report_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_case_reports
    ADD CONSTRAINT moderation_case_reports_case_id_report_id_key UNIQUE (case_id, report_id);


--
-- Name: moderation_cases moderation_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_cases
    ADD CONSTRAINT moderation_cases_pkey PRIMARY KEY (id);


--
-- Name: moderation_evidence moderation_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_evidence
    ADD CONSTRAINT moderation_evidence_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: official_contacts official_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_contacts
    ADD CONSTRAINT official_contacts_pkey PRIMARY KEY (id);


--
-- Name: official_evidence official_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_evidence
    ADD CONSTRAINT official_evidence_pkey PRIMARY KEY (id);


--
-- Name: official_offices official_offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_offices
    ADD CONSTRAINT official_offices_pkey PRIMARY KEY (id);


--
-- Name: official_sources official_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_sources
    ADD CONSTRAINT official_sources_pkey PRIMARY KEY (id);


--
-- Name: organization_attendance organization_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_attendance
    ADD CONSTRAINT organization_attendance_pkey PRIMARY KEY (id);


--
-- Name: organization_branches organization_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_branches
    ADD CONSTRAINT organization_branches_pkey PRIMARY KEY (id);


--
-- Name: organization_documents organization_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_documents
    ADD CONSTRAINT organization_documents_pkey PRIMARY KEY (id);


--
-- Name: organization_finances organization_finances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_finances
    ADD CONSTRAINT organization_finances_pkey PRIMARY KEY (id);


--
-- Name: organization_letters organization_letters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_letters
    ADD CONSTRAINT organization_letters_pkey PRIMARY KEY (id);


--
-- Name: organization_meetings organization_meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_meetings
    ADD CONSTRAINT organization_meetings_pkey PRIMARY KEY (id);


--
-- Name: organization_membership_applications organization_membership_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_membership_applications
    ADD CONSTRAINT organization_membership_applications_pkey PRIMARY KEY (id);


--
-- Name: organization_payments organization_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_payments
    ADD CONSTRAINT organization_payments_pkey PRIMARY KEY (id);


--
-- Name: organization_permissions organization_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_permissions
    ADD CONSTRAINT organization_permissions_pkey PRIMARY KEY (id);


--
-- Name: organization_subscriptions organization_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions
    ADD CONSTRAINT organization_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: organization_tasks organization_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_tasks
    ADD CONSTRAINT organization_tasks_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: publication_projects publication_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_projects
    ADD CONSTRAINT publication_projects_pkey PRIMARY KEY (id);


--
-- Name: publication_templates publication_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_templates
    ADD CONSTRAINT publication_templates_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: user_platform_roles user_platform_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_platform_roles
    ADD CONSTRAINT user_platform_roles_pkey PRIMARY KEY (id);


--
-- Name: user_presence_checks user_presence_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_presence_checks
    ADD CONSTRAINT user_presence_checks_pkey PRIMARY KEY (id);


--
-- Name: user_verifications user_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verification_evidence verification_evidence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verification_evidence
    ADD CONSTRAINT verification_evidence_pkey PRIMARY KEY (id);


--
-- Name: ai_telemetry_events_correlation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ai_telemetry_events_correlation_idx ON public.ai_telemetry_events USING btree (correlation_id) WHERE (correlation_id IS NOT NULL);


--
-- Name: ai_telemetry_events_user_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_telemetry_events_user_created_idx ON public.ai_telemetry_events USING btree (user_ref, created_at);


--
-- Name: ai_usage_buckets_period_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ai_usage_buckets_period_idx ON public.ai_usage_buckets USING btree (period_start);


--
-- Name: audit_actor_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_actor_idx ON public.audit_logs USING btree (actor_id, created_at);


--
-- Name: communities_entity_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX communities_entity_uq ON public.communities USING btree (entity_id) WHERE (entity_id IS NOT NULL);


--
-- Name: community_location_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX community_location_idx ON public.communities USING btree (state, city, category);


--
-- Name: community_member_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX community_member_uq ON public.community_members USING btree (community_id, user_id);


--
-- Name: content_slug_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX content_slug_uq ON public.contents USING btree (slug);


--
-- Name: entities_legal_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_legal_status_idx ON public.entities USING btree (legal_status);


--
-- Name: entities_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_owner_idx ON public.entities USING btree (owner_user_id);


--
-- Name: entities_slug_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX entities_slug_uq ON public.entities USING btree (slug);


--
-- Name: entities_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_type_idx ON public.entities USING btree (entity_type);


--
-- Name: entity_eligibility_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entity_eligibility_status_idx ON public.entity_eligibilities USING btree (entity_id, status);


--
-- Name: entity_verification_subject_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entity_verification_subject_idx ON public.entity_verifications USING btree (entity_id, verification_type, status);


--
-- Name: events_organizer_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_organizer_entity_idx ON public.events USING btree (organizer_entity_id, status);


--
-- Name: external_jobs_malaysia_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX external_jobs_malaysia_active_idx ON public.external_job_listings USING btree (destination_country, source_status, last_checked_at);


--
-- Name: finance_org_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX finance_org_idx ON public.organization_finances USING btree (organization_id, transaction_at);


--
-- Name: jobs_employer_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_employer_entity_idx ON public.jobs USING btree (employer_entity_id, status);


--
-- Name: jobs_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_search_idx ON public.jobs USING btree (state, city, employment_type);


--
-- Name: meeting_transcript_meeting_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX meeting_transcript_meeting_uq ON public.meeting_transcripts USING btree (meeting_id);


--
-- Name: moderation_action_case_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX moderation_action_case_idx ON public.moderation_actions USING btree (case_id, created_at);


--
-- Name: moderation_case_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX moderation_case_target_idx ON public.moderation_cases USING btree (target_type, target_id, status);


--
-- Name: notification_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notification_user_idx ON public.notifications USING btree (user_id, read_at);


--
-- Name: official_contact_office_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX official_contact_office_idx ON public.official_contacts USING btree (office_id, active);


--
-- Name: official_evidence_office_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX official_evidence_office_idx ON public.official_evidence USING btree (office_id, evidence_type);


--
-- Name: official_evidence_path_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX official_evidence_path_uq ON public.official_evidence USING btree (file_path);


--
-- Name: org_attendance_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_attendance_uq ON public.organization_attendance USING btree (organization_id, event_id, meeting_id, user_id);


--
-- Name: org_branch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_branch_idx ON public.organization_branches USING btree (organization_id, active);


--
-- Name: org_document_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_document_idx ON public.organization_documents USING btree (organization_id, type);


--
-- Name: org_letter_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_letter_idx ON public.organization_letters USING btree (organization_id, direction);


--
-- Name: org_member_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_member_uq ON public.organization_members USING btree (organization_id, user_id);


--
-- Name: org_membership_application_org_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_membership_application_org_status_idx ON public.organization_membership_applications USING btree (organization_id, status);


--
-- Name: org_membership_application_pending_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_membership_application_pending_uq ON public.organization_membership_applications USING btree (organization_id, user_id) WHERE (status = 'pending'::public.organization_membership_application_status);


--
-- Name: org_membership_application_user_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_membership_application_user_status_idx ON public.organization_membership_applications USING btree (user_id, status);


--
-- Name: org_payment_provider_ref_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_payment_provider_ref_uq ON public.organization_payments USING btree (provider, provider_reference);


--
-- Name: org_permission_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_permission_uq ON public.organization_permissions USING btree (organization_id, role, permission);


--
-- Name: org_subscription_org_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX org_subscription_org_uq ON public.organization_subscriptions USING btree (organization_id);


--
-- Name: org_task_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX org_task_idx ON public.organization_tasks USING btree (organization_id, status);


--
-- Name: organizations_entity_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organizations_entity_uq ON public.organizations USING btree (entity_id) WHERE (entity_id IS NOT NULL);


--
-- Name: payment_provider_ref_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX payment_provider_ref_uq ON public.payments USING btree (provider, provider_reference);


--
-- Name: presence_expiry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presence_expiry_idx ON public.user_presence_checks USING btree (expires_at);


--
-- Name: presence_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presence_user_idx ON public.user_presence_checks USING btree (user_id, status);


--
-- Name: products_seller_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_seller_entity_idx ON public.products USING btree (seller_entity_id, status);


--
-- Name: publication_project_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publication_project_idx ON public.publication_projects USING btree (organization_id, status, type);


--
-- Name: publication_template_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX publication_template_idx ON public.publication_templates USING btree (organization_id, type, active);


--
-- Name: responsible_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX responsible_entity_idx ON public.entity_responsible_persons USING btree (entity_id, status);


--
-- Name: responsible_primary_active_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX responsible_primary_active_uq ON public.entity_responsible_persons USING btree (entity_id) WHERE ((is_primary = true) AND (status = 'active'::public.responsible_person_status));


--
-- Name: responsible_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX responsible_user_idx ON public.entity_responsible_persons USING btree (user_id, status);


--
-- Name: session_token_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX session_token_uq ON public.sessions USING btree (token_hash);


--
-- Name: session_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_user_idx ON public.sessions USING btree (user_id);


--
-- Name: source_institution_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_institution_idx ON public.official_sources USING btree (institution);


--
-- Name: sources_url_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sources_url_uq ON public.official_sources USING btree (url);


--
-- Name: user_platform_role_active_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_platform_role_active_idx ON public.user_platform_roles USING btree (user_id, revoked_at);


--
-- Name: user_platform_role_active_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_platform_role_active_uq ON public.user_platform_roles USING btree (user_id, role) WHERE (revoked_at IS NULL);


--
-- Name: user_verification_subject_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_verification_subject_idx ON public.user_verifications USING btree (user_id, verification_type, status);


--
-- Name: users_email_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_uq ON public.users USING btree (email);


--
-- Name: users_location_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_location_idx ON public.users USING btree (state, city);


--
-- Name: verification_evidence_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX verification_evidence_entity_idx ON public.verification_evidence USING btree (entity_verification_id);


--
-- Name: verification_evidence_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX verification_evidence_user_idx ON public.verification_evidence USING btree (user_verification_id);


--
-- Name: events events_safety_enforcement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER events_safety_enforcement BEFORE INSERT OR UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.enforce_event_safety();


--
-- Name: external_job_listings external_job_source_safety_enforcement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER external_job_source_safety_enforcement BEFORE INSERT OR UPDATE ON public.external_job_listings FOR EACH ROW EXECUTE FUNCTION public.enforce_official_job_source_safety();


--
-- Name: jobs jobs_posting_safety_enforcement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER jobs_posting_safety_enforcement BEFORE INSERT OR UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.enforce_job_posting_safety();


--
-- Name: organization_members organization_member_role_change; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER organization_member_role_change BEFORE INSERT OR UPDATE ON public.organization_members FOR EACH ROW EXECUTE FUNCTION public.enforce_organization_member_role_change();


--
-- Name: organization_membership_applications organization_membership_application_transition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER organization_membership_application_transition BEFORE UPDATE ON public.organization_membership_applications FOR EACH ROW EXECUTE FUNCTION public.enforce_organization_membership_application_transition();


--
-- Name: products products_marketplace_compliance; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER products_marketplace_compliance BEFORE INSERT OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.enforce_marketplace_product_compliance();


--
-- Name: organizations protect_organization_archival; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER protect_organization_archival BEFORE UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION public.protect_organization_archival();


--
-- Name: ai_conversations ai_conversations_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_conversations
    ADD CONSTRAINT ai_conversations_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: ai_telemetry_events ai_telemetry_events_user_ref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_telemetry_events
    ADD CONSTRAINT ai_telemetry_events_user_ref_fkey FOREIGN KEY (user_ref) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: ai_usage_buckets ai_usage_buckets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_buckets
    ADD CONSTRAINT ai_usage_buckets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_usage_requests ai_usage_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_usage_requests
    ADD CONSTRAINT ai_usage_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_actor_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_id_users_id_fk FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: communities communities_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id);


--
-- Name: communities communities_owner_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communities
    ADD CONSTRAINT communities_owner_id_users_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: community_members community_members_community_id_communities_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_community_id_communities_id_fk FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE;


--
-- Name: community_members community_members_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.community_members
    ADD CONSTRAINT community_members_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: contents contents_author_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_author_id_users_id_fk FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: contents contents_source_id_official_sources_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contents
    ADD CONSTRAINT contents_source_id_official_sources_id_fk FOREIGN KEY (source_id) REFERENCES public.official_sources(id);


--
-- Name: entities entities_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.users(id);


--
-- Name: entity_eligibilities entity_eligibilities_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_eligibilities
    ADD CONSTRAINT entity_eligibilities_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- Name: entity_eligibilities entity_eligibilities_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_eligibilities
    ADD CONSTRAINT entity_eligibilities_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: entity_responsible_persons entity_responsible_persons_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_responsible_persons
    ADD CONSTRAINT entity_responsible_persons_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- Name: entity_responsible_persons entity_responsible_persons_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_responsible_persons
    ADD CONSTRAINT entity_responsible_persons_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: entity_verifications entity_verifications_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_verifications
    ADD CONSTRAINT entity_verifications_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id) ON DELETE CASCADE;


--
-- Name: entity_verifications entity_verifications_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_verifications
    ADD CONSTRAINT entity_verifications_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: events events_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: events events_organizer_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_organizer_entity_id_fkey FOREIGN KEY (organizer_entity_id) REFERENCES public.entities(id);


--
-- Name: jobs jobs_employer_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_employer_entity_id_fkey FOREIGN KEY (employer_entity_id) REFERENCES public.entities(id);


--
-- Name: jobs jobs_owner_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_owner_id_users_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: meeting_transcripts meeting_transcripts_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_transcripts
    ADD CONSTRAINT meeting_transcripts_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: meeting_transcripts meeting_transcripts_meeting_id_organization_meetings_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_transcripts
    ADD CONSTRAINT meeting_transcripts_meeting_id_organization_meetings_id_fk FOREIGN KEY (meeting_id) REFERENCES public.organization_meetings(id) ON DELETE CASCADE;


--
-- Name: meeting_transcripts meeting_transcripts_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.meeting_transcripts
    ADD CONSTRAINT meeting_transcripts_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: moderation_actions moderation_actions_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id);


--
-- Name: moderation_actions moderation_actions_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.moderation_cases(id) ON DELETE RESTRICT;


--
-- Name: moderation_case_reports moderation_case_reports_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_case_reports
    ADD CONSTRAINT moderation_case_reports_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.moderation_cases(id) ON DELETE CASCADE;


--
-- Name: moderation_case_reports moderation_case_reports_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_case_reports
    ADD CONSTRAINT moderation_case_reports_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE RESTRICT;


--
-- Name: moderation_cases moderation_cases_assigned_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_cases
    ADD CONSTRAINT moderation_cases_assigned_reviewer_id_fkey FOREIGN KEY (assigned_reviewer_id) REFERENCES public.users(id);


--
-- Name: moderation_cases moderation_cases_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_cases
    ADD CONSTRAINT moderation_cases_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: moderation_evidence moderation_evidence_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_evidence
    ADD CONSTRAINT moderation_evidence_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.moderation_cases(id) ON DELETE CASCADE;


--
-- Name: moderation_evidence moderation_evidence_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_evidence
    ADD CONSTRAINT moderation_evidence_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES public.users(id);


--
-- Name: notifications notifications_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: official_contacts official_contacts_office_id_official_offices_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_contacts
    ADD CONSTRAINT official_contacts_office_id_official_offices_id_fk FOREIGN KEY (office_id) REFERENCES public.official_offices(id) ON DELETE CASCADE;


--
-- Name: official_evidence official_evidence_office_id_official_offices_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.official_evidence
    ADD CONSTRAINT official_evidence_office_id_official_offices_id_fk FOREIGN KEY (office_id) REFERENCES public.official_offices(id) ON DELETE SET NULL;


--
-- Name: organization_attendance organization_attendance_event_id_events_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_attendance
    ADD CONSTRAINT organization_attendance_event_id_events_id_fk FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: organization_attendance organization_attendance_meeting_id_organization_meetings_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_attendance
    ADD CONSTRAINT organization_attendance_meeting_id_organization_meetings_id_fk FOREIGN KEY (meeting_id) REFERENCES public.organization_meetings(id) ON DELETE CASCADE;


--
-- Name: organization_attendance organization_attendance_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_attendance
    ADD CONSTRAINT organization_attendance_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_attendance organization_attendance_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_attendance
    ADD CONSTRAINT organization_attendance_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organization_branches organization_branches_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_branches
    ADD CONSTRAINT organization_branches_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_documents organization_documents_author_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_documents
    ADD CONSTRAINT organization_documents_author_id_users_id_fk FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: organization_documents organization_documents_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_documents
    ADD CONSTRAINT organization_documents_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_finances organization_finances_actor_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_finances
    ADD CONSTRAINT organization_finances_actor_id_users_id_fk FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: organization_finances organization_finances_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_finances
    ADD CONSTRAINT organization_finances_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_letters organization_letters_approved_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_letters
    ADD CONSTRAINT organization_letters_approved_by_users_id_fk FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: organization_letters organization_letters_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_letters
    ADD CONSTRAINT organization_letters_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_meetings organization_meetings_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_meetings
    ADD CONSTRAINT organization_meetings_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organization_membership_applications organization_membership_applications_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_membership_applications
    ADD CONSTRAINT organization_membership_applications_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_membership_applications organization_membership_applications_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_membership_applications
    ADD CONSTRAINT organization_membership_applications_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: organization_membership_applications organization_membership_applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_membership_applications
    ADD CONSTRAINT organization_membership_applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: organization_payments organization_payments_subscription_id_organization_subscription; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_payments
    ADD CONSTRAINT organization_payments_subscription_id_organization_subscription FOREIGN KEY (subscription_id) REFERENCES public.organization_subscriptions(id) ON DELETE CASCADE;


--
-- Name: organization_permissions organization_permissions_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_permissions
    ADD CONSTRAINT organization_permissions_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_subscriptions organization_subscriptions_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_subscriptions
    ADD CONSTRAINT organization_subscriptions_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_tasks organization_tasks_assignee_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_tasks
    ADD CONSTRAINT organization_tasks_assignee_id_users_id_fk FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: organization_tasks organization_tasks_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_tasks
    ADD CONSTRAINT organization_tasks_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organization_tasks organization_tasks_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_tasks
    ADD CONSTRAINT organization_tasks_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organizations organizations_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id);


--
-- Name: payments payments_membership_id_memberships_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_membership_id_memberships_id_fk FOREIGN KEY (membership_id) REFERENCES public.memberships(id) ON DELETE CASCADE;


--
-- Name: products products_seller_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_seller_entity_id_fkey FOREIGN KEY (seller_entity_id) REFERENCES public.entities(id);


--
-- Name: products products_seller_id_sellers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_seller_id_sellers_id_fk FOREIGN KEY (seller_id) REFERENCES public.sellers(id) ON DELETE CASCADE;


--
-- Name: publication_projects publication_projects_approved_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_projects
    ADD CONSTRAINT publication_projects_approved_by_users_id_fk FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: publication_projects publication_projects_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_projects
    ADD CONSTRAINT publication_projects_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: publication_projects publication_projects_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_projects
    ADD CONSTRAINT publication_projects_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: publication_templates publication_templates_created_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_templates
    ADD CONSTRAINT publication_templates_created_by_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: publication_templates publication_templates_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publication_templates
    ADD CONSTRAINT publication_templates_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: reports reports_reporter_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reporter_id_users_id_fk FOREIGN KEY (reporter_id) REFERENCES public.users(id);


--
-- Name: sellers sellers_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES public.entities(id);


--
-- Name: sellers sellers_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sellers sellers_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sessions sessions_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_platform_roles user_platform_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_platform_roles
    ADD CONSTRAINT user_platform_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: user_platform_roles user_platform_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_platform_roles
    ADD CONSTRAINT user_platform_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_presence_checks user_presence_checks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_presence_checks
    ADD CONSTRAINT user_presence_checks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_verifications user_verifications_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: user_verifications user_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: verification_evidence verification_evidence_entity_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verification_evidence
    ADD CONSTRAINT verification_evidence_entity_verification_id_fkey FOREIGN KEY (entity_verification_id) REFERENCES public.entity_verifications(id) ON DELETE CASCADE;


--
-- Name: verification_evidence verification_evidence_user_verification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verification_evidence
    ADD CONSTRAINT verification_evidence_user_verification_id_fkey FOREIGN KEY (user_verification_id) REFERENCES public.user_verifications(id) ON DELETE CASCADE;


--
-- Name: ai_conversations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_telemetry_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_telemetry_events ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_telemetry_events ai_telemetry_insert_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_telemetry_insert_self ON public.ai_telemetry_events FOR INSERT TO duta_app WITH CHECK ((user_ref = public.current_app_user_id()));


--
-- Name: ai_usage_buckets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_usage_buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_usage_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ai_usage_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: ai_usage_buckets ai_usage_self_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY ai_usage_self_only ON public.ai_usage_buckets FOR SELECT TO duta_app USING ((user_id = public.current_app_user_id()));


--
-- Name: audit_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs audit_logs_content_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_logs_content_admin ON public.audit_logs FOR INSERT TO duta_app WITH CHECK (((actor_id = public.current_app_user_id()) AND public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role])));


--
-- Name: audit_logs audit_system_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_system_insert ON public.audit_logs FOR INSERT TO duta_system WITH CHECK ((current_setting('app.system_operation'::text, true) <> ''::text));


--
-- Name: audit_logs audit_user_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_user_insert ON public.audit_logs FOR INSERT TO duta_app WITH CHECK (((actor_id = public.current_app_user_id()) AND (action = ANY (ARRAY['profile_update'::text, 'source_change'::text, 'organization.create'::text, 'organization.application_submitted'::text, 'organization.reviewed'::text, 'publication.create_draft'::text, 'secretary.create_draft'::text, 'meeting.audio_transcribed'::text, 'member.phone_verified'::text, 'member.location_verified'::text, 'member.location_manual_review'::text, 'member.selfie_uploaded'::text, 'member.reviewed'::text, 'content_admin_create'::text, 'content_admin_update'::text, 'content_admin_delete'::text, 'account_deletion'::text]))));


--
-- Name: communities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

--
-- Name: communities communities_admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY communities_admin_all ON public.communities TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role])) WITH CHECK (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]));


--
-- Name: communities communities_owner_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY communities_owner_manage ON public.communities FOR UPDATE TO authenticated USING ((owner_id = auth.uid())) WITH CHECK ((owner_id = auth.uid()));


--
-- Name: communities communities_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY communities_public ON public.communities FOR SELECT TO anon, authenticated, duta_app USING ((((visibility = 'PUBLIC'::text) AND (status = 'ACTIVE'::public.record_status)) OR (owner_id = auth.uid()) OR public.has_system_role(ARRAY['MODERATOR'::public.user_role, 'SUPER_ADMIN'::public.user_role])));


--
-- Name: community_members community_member_join_with_access_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY community_member_join_with_access_scope ON public.community_members FOR INSERT TO authenticated WITH CHECK (((user_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.communities c
  WHERE ((c.id = community_members.community_id) AND (c.status = 'ACTIVE'::public.record_status) AND ((c.community_access_scope IS NULL) OR (c.community_access_scope = ANY (ARRAY['pre_arrival_allowed'::public.community_access_scope, 'global'::public.community_access_scope])) OR ((c.community_access_scope = 'malaysia_present_only'::public.community_access_scope) AND (EXISTS ( SELECT 1
           FROM public.user_presence_checks p
          WHERE ((p.user_id = auth.uid()) AND (p.country_code = 'MY'::text) AND (p.status = 'verified'::public.presence_status) AND ((p.expires_at IS NULL) OR (p.expires_at > now()))))))))))));


--
-- Name: community_members; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;

--
-- Name: contents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;

--
-- Name: entities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;

--
-- Name: entities entities_marketplace_actor_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entities_marketplace_actor_read ON public.entities FOR SELECT TO duta_app USING (((owner_user_id = public.current_app_user_id()) OR (EXISTS ( SELECT 1
   FROM public.organizations o
  WHERE ((o.entity_id = entities.id) AND public.current_app_has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]))))));


--
-- Name: entities entities_owner_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entities_owner_insert ON public.entities FOR INSERT TO authenticated WITH CHECK (((owner_user_id = auth.uid()) AND (legal_status_verified IS NULL)));


--
-- Name: entities entities_owner_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entities_owner_update ON public.entities FOR UPDATE TO authenticated USING ((owner_user_id = auth.uid())) WITH CHECK (((owner_user_id = auth.uid()) AND (legal_status_verified IS NULL)));


--
-- Name: entities entities_public_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entities_public_read ON public.entities FOR SELECT TO anon, authenticated USING (((record_status = 'ACTIVE'::public.record_status) OR (owner_user_id = auth.uid()) OR public.has_platform_role('moderation_admin'::public.platform_role)));


--
-- Name: entity_eligibilities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entity_eligibilities ENABLE ROW LEVEL SECURITY;

--
-- Name: entity_eligibilities entity_eligibility_marketplace_actor_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entity_eligibility_marketplace_actor_read ON public.entity_eligibilities FOR SELECT TO duta_app USING (((EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_eligibilities.entity_id) AND (e.owner_user_id = public.current_app_user_id())))) OR (EXISTS ( SELECT 1
   FROM public.organizations o
  WHERE ((o.entity_id = o.entity_id) AND public.current_app_has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]))))));


--
-- Name: entity_eligibilities entity_eligibility_owner_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entity_eligibility_owner_read ON public.entity_eligibilities FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_eligibilities.entity_id) AND (e.owner_user_id = auth.uid())))) OR public.has_platform_role('compliance_admin'::public.platform_role)));


--
-- Name: entity_responsible_persons; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entity_responsible_persons ENABLE ROW LEVEL SECURITY;

--
-- Name: entity_verifications entity_verification_summary_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY entity_verification_summary_read ON public.entity_verifications FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_verifications.entity_id) AND (e.owner_user_id = auth.uid())))) OR public.has_platform_role('verification_reviewer'::public.platform_role)));


--
-- Name: entity_verifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entity_verifications ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

--
-- Name: events events_entity_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY events_entity_manage ON public.events TO authenticated USING (((organizer_entity_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = events.organizer_entity_id) AND (e.record_status = 'ACTIVE'::public.record_status) AND (((e.entity_type = 'organisation'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.organizations o
          WHERE ((o.entity_id = e.id) AND public.has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role]))))) OR ((e.entity_type = 'community'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.communities c
          WHERE ((c.entity_id = e.id) AND (c.owner_id = auth.uid()))))))))))) WITH CHECK (((organizer_entity_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = events.organizer_entity_id) AND (e.record_status = 'ACTIVE'::public.record_status) AND (((e.entity_type = 'organisation'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.organizations o
          WHERE ((o.entity_id = e.id) AND public.has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role]))))) OR ((e.entity_type = 'community'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.communities c
          WHERE ((c.entity_id = e.id) AND (c.owner_id = auth.uid())))))))))));


--
-- Name: external_job_listings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.external_job_listings ENABLE ROW LEVEL SECURITY;

--
-- Name: external_job_listings external_jobs_public_malaysia_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY external_jobs_public_malaysia_read ON public.external_job_listings FOR SELECT TO anon, authenticated USING (((source_type = 'OFFICIAL'::public.external_job_source_type) AND (source_name = 'SISKOP2MI / KP2MI'::text) AND (destination_country = 'MALAYSIA'::text) AND (source_status = 'active'::public.external_job_source_status) AND (last_checked_at > (now() - '7 days'::interval)) AND ((expires_at IS NULL) OR (expires_at > now()))));


--
-- Name: jobs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

--
-- Name: jobs jobs_employer_entity_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY jobs_employer_entity_write ON public.jobs TO duta_app USING (((employer_entity_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = jobs.employer_entity_id) AND (e.record_status = 'ACTIVE'::public.record_status) AND ((e.owner_user_id = public.current_app_user_id()) OR ((e.entity_type = 'organisation'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.organizations o
          WHERE ((o.entity_id = e.id) AND public.current_app_has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]))))))))))) WITH CHECK (((employer_entity_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = jobs.employer_entity_id) AND (e.record_status = 'ACTIVE'::public.record_status) AND ((e.owner_user_id = public.current_app_user_id()) OR ((e.entity_type = 'organisation'::public.entity_type) AND (EXISTS ( SELECT 1
           FROM public.organizations o
          WHERE ((o.entity_id = e.id) AND public.current_app_has_org_role(o.id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role])))))))))));


--
-- Name: jobs jobs_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY jobs_public ON public.jobs FOR SELECT TO anon, authenticated, duta_app USING (((status = 'ACTIVE'::public.record_status) OR (owner_id = auth.uid())));


--
-- Name: meeting_transcripts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.meeting_transcripts ENABLE ROW LEVEL SECURITY;

--
-- Name: meeting_transcripts meeting_transcripts_runtime; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY meeting_transcripts_runtime ON public.meeting_transcripts TO duta_app USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role])) WITH CHECK (((created_by = public.current_app_user_id()) AND (consent_confirmed = true) AND public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role])));


--
-- Name: memberships; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.moderation_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_actions moderation_actions_admin_append; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY moderation_actions_admin_append ON public.moderation_actions FOR INSERT TO duta_app WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL)))));


--
-- Name: moderation_actions moderation_actions_admin_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY moderation_actions_admin_read ON public.moderation_actions FOR SELECT TO duta_app USING ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL)))));


--
-- Name: moderation_case_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.moderation_case_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_case_reports moderation_case_reports_admin_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY moderation_case_reports_admin_only ON public.moderation_case_reports TO duta_app USING ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL)))));


--
-- Name: moderation_cases; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.moderation_cases ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_cases moderation_cases_admin_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY moderation_cases_admin_only ON public.moderation_cases TO duta_app USING ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL)))));


--
-- Name: moderation_evidence; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.moderation_evidence ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_evidence moderation_evidence_admin_only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY moderation_evidence_admin_only ON public.moderation_evidence TO duta_app USING ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_platform_roles r
  WHERE ((r.user_id = public.current_app_user_id()) AND (r.role = 'moderation_admin'::public.platform_role) AND (r.revoked_at IS NULL)))));


--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: official_contacts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.official_contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: official_evidence; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.official_evidence ENABLE ROW LEVEL SECURITY;

--
-- Name: official_offices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.official_offices ENABLE ROW LEVEL SECURITY;

--
-- Name: official_sources; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;

--
-- Name: official_sources official_sources_admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY official_sources_admin_all ON public.official_sources TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role])) WITH CHECK (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]));


--
-- Name: official_sources official_sources_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY official_sources_public ON public.official_sources FOR SELECT TO anon, authenticated, duta_app USING ((active = true));


--
-- Name: organization_membership_applications org_membership_application_review; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY org_membership_application_review ON public.organization_membership_applications FOR UPDATE TO authenticated USING (public.has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role])) WITH CHECK ((public.has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]) AND (user_id <> auth.uid()) AND (status = ANY (ARRAY['approved'::public.organization_membership_application_status, 'rejected'::public.organization_membership_application_status])) AND (reviewed_by = auth.uid()) AND (reviewed_at IS NOT NULL)));


--
-- Name: organization_membership_applications org_membership_application_scoped_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY org_membership_application_scoped_read ON public.organization_membership_applications FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR public.has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role])));


--
-- Name: organization_membership_applications org_membership_application_submit; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY org_membership_application_submit ON public.organization_membership_applications FOR INSERT TO authenticated WITH CHECK (((user_id = auth.uid()) AND (status = 'pending'::public.organization_membership_application_status) AND (reviewed_at IS NULL) AND (reviewed_by IS NULL) AND (decision_reason IS NULL) AND (NOT (EXISTS ( SELECT 1
   FROM public.organization_members m
  WHERE ((m.organization_id = organization_membership_applications.organization_id) AND (m.user_id = auth.uid()) AND (m.member_status = 'ACTIVE'::text))))) AND (EXISTS ( SELECT 1
   FROM (public.organizations o
     JOIN public.entities e ON ((e.id = o.entity_id)))
  WHERE ((o.id = organization_membership_applications.organization_id) AND (e.entity_type = 'organisation'::public.entity_type) AND ((o.membership_geography IS NULL) OR (o.membership_geography = 'global'::public.membership_geography) OR ((o.membership_geography = 'malaysia_present_only'::public.membership_geography) AND (EXISTS ( SELECT 1
           FROM public.user_presence_checks p
          WHERE ((p.user_id = auth.uid()) AND (p.country_code = 'MY'::text) AND (p.status = 'verified'::public.presence_status) AND ((p.expires_at IS NULL) OR (p.expires_at > now())))))) OR ((o.membership_geography = 'malaysia_and_indonesia'::public.membership_geography) AND ((EXISTS ( SELECT 1
           FROM public.user_presence_checks p
          WHERE ((p.user_id = auth.uid()) AND (p.country_code = 'MY'::text) AND (p.status = 'verified'::public.presence_status) AND ((p.expires_at IS NULL) OR (p.expires_at > now()))))) OR (organization_membership_applications.access_country_code = 'ID'::text)))))))));


--
-- Name: organization_membership_applications org_membership_application_withdraw; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY org_membership_application_withdraw ON public.organization_membership_applications FOR UPDATE TO authenticated USING (((user_id = auth.uid()) AND (status = 'pending'::public.organization_membership_application_status))) WITH CHECK (((user_id = auth.uid()) AND (status = 'withdrawn'::public.organization_membership_application_status) AND (reviewed_at IS NULL) AND (reviewed_by IS NULL) AND (decision_reason IS NULL)));


--
-- Name: organization_attendance; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_attendance ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_branches; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_branches ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_documents organization_documents_runtime; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organization_documents_runtime ON public.organization_documents TO duta_app USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role])) WITH CHECK (public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role]));


--
-- Name: organization_finances; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_finances ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_letters; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_letters ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_meetings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_meetings ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_members; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_members organization_members_marketplace_authority_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organization_members_marketplace_authority_read ON public.organization_members FOR SELECT TO duta_app USING ((user_id = public.current_app_user_id()));


--
-- Name: organization_members organization_members_runtime_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organization_members_runtime_read ON public.organization_members FOR SELECT TO duta_app USING (true);


--
-- Name: organization_membership_applications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_membership_applications ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_payments ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_permissions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_subscriptions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_subscriptions ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_subscriptions organization_subscriptions_runtime_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organization_subscriptions_runtime_read ON public.organization_subscriptions FOR SELECT TO duta_app USING (true);


--
-- Name: organization_tasks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organization_tasks ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations organizations_admin_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_admin_delete ON public.organizations FOR DELETE TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]));


--
-- Name: organizations organizations_admin_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_admin_insert ON public.organizations FOR INSERT TO duta_app WITH CHECK ((public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]) AND (status = 'PENDING'::public.record_status) AND (verification = 'USER_GENERATED'::public.trust_level)));


--
-- Name: organizations organizations_admin_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_admin_update ON public.organizations FOR UPDATE TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role])) WITH CHECK ((public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]) AND ((status <> 'ACTIVE'::public.record_status) OR (verification = 'DUTA_VERIFIED'::public.trust_level))));


--
-- Name: organizations organizations_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_manage ON public.organizations FOR UPDATE TO authenticated USING (public.has_org_role(id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role])) WITH CHECK (public.has_org_role(id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]));


--
-- Name: organizations organizations_runtime_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_runtime_read ON public.organizations FOR SELECT TO duta_app USING ((status = 'ACTIVE'::public.record_status));


--
-- Name: organizations organizations_runtime_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY organizations_runtime_select ON public.organizations FOR SELECT TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]));


--
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: user_presence_checks presence_self_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY presence_self_read ON public.user_presence_checks FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR public.has_platform_role('verification_reviewer'::public.platform_role)));


--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- Name: products products_marketplace_entity_write; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY products_marketplace_entity_write ON public.products TO duta_app USING ((EXISTS ( SELECT 1
   FROM (public.sellers s
     JOIN public.entities e ON ((e.id = s.entity_id)))
  WHERE ((s.id = products.seller_id) AND (s.entity_id = products.seller_entity_id) AND ((e.owner_user_id = public.current_app_user_id()) OR ((s.organization_id IS NOT NULL) AND public.current_app_has_org_role(s.organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]))))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM (public.sellers s
     JOIN public.entities e ON ((e.id = s.entity_id)))
  WHERE ((s.id = products.seller_id) AND (s.entity_id = products.seller_entity_id) AND ((e.owner_user_id = public.current_app_user_id()) OR ((s.organization_id IS NOT NULL) AND public.current_app_has_org_role(s.organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role])))))));


--
-- Name: products products_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY products_public ON public.products FOR SELECT TO anon, authenticated, duta_app USING (((status = 'ACTIVE'::public.record_status) OR (EXISTS ( SELECT 1
   FROM public.sellers s
  WHERE ((s.id = products.seller_id) AND (s.user_id = auth.uid()))))));


--
-- Name: publication_projects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.publication_projects ENABLE ROW LEVEL SECURITY;

--
-- Name: publication_projects publication_projects_runtime; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY publication_projects_runtime ON public.publication_projects TO duta_app USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role])) WITH CHECK (((created_by = public.current_app_user_id()) AND public.current_app_has_org_role(organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role, 'SECRETARY'::public.organization_role, 'STAFF'::public.organization_role])));


--
-- Name: publication_templates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.publication_templates ENABLE ROW LEVEL SECURITY;

--
-- Name: reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

--
-- Name: entity_responsible_persons responsible_owner_manage; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY responsible_owner_manage ON public.entity_responsible_persons TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_responsible_persons.entity_id) AND (e.owner_user_id = auth.uid()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_responsible_persons.entity_id) AND (e.owner_user_id = auth.uid())))));


--
-- Name: entity_responsible_persons responsible_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY responsible_read ON public.entity_responsible_persons FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = entity_responsible_persons.entity_id) AND (e.owner_user_id = auth.uid())))) OR public.has_platform_role('verification_reviewer'::public.platform_role)));


--
-- Name: sellers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;

--
-- Name: sellers sellers_admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY sellers_admin_all ON public.sellers TO duta_app USING (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role])) WITH CHECK (public.current_app_has_role(ARRAY['ORG_ADMIN'::public.user_role, 'SUPER_ADMIN'::public.user_role]));


--
-- Name: sellers sellers_marketplace_entity_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY sellers_marketplace_entity_read ON public.sellers FOR SELECT TO duta_app USING (((entity_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.entities e
  WHERE ((e.id = sellers.entity_id) AND ((e.owner_user_id = public.current_app_user_id()) OR ((sellers.organization_id IS NOT NULL) AND public.current_app_has_org_role(sellers.organization_id, ARRAY['OWNER'::public.organization_role, 'ADMIN'::public.organization_role]))))))));


--
-- Name: sellers sellers_public_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY sellers_public_read ON public.sellers FOR SELECT TO anon, authenticated, duta_app USING (((status = 'ACTIVE'::public.record_status) OR (user_id = auth.uid())));


--
-- Name: sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: user_platform_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_platform_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: user_platform_roles user_platform_roles_self_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_platform_roles_self_read ON public.user_platform_roles FOR SELECT TO authenticated USING (((user_id = auth.uid()) AND (revoked_at IS NULL)));


--
-- Name: user_presence_checks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_presence_checks ENABLE ROW LEVEL SECURITY;

--
-- Name: user_verifications user_verification_self_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY user_verification_self_read ON public.user_verifications FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR public.has_platform_role('verification_reviewer'::public.platform_role)));


--
-- Name: user_verifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_verifications ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_runtime_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_runtime_select ON public.users FOR SELECT TO duta_app USING ((id = public.current_app_user_id()));


--
-- Name: users users_runtime_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_runtime_update ON public.users FOR UPDATE TO duta_app USING ((id = public.current_app_user_id())) WITH CHECK ((id = public.current_app_user_id()));


--
-- Name: verification_evidence; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.verification_evidence ENABLE ROW LEVEL SECURITY;

--
-- Name: verification_evidence verification_evidence_privileged_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY verification_evidence_privileged_read ON public.verification_evidence FOR SELECT TO authenticated USING (public.has_platform_role('verification_reviewer'::public.platform_role));


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA public TO duta_app;
GRANT USAGE ON SCHEMA public TO duta_system;


--
-- Name: FUNCTION consume_ai_usage(p_user uuid, p_units integer, p_limit integer, p_request_id text); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.consume_ai_usage(p_user uuid, p_units integer, p_limit integer, p_request_id text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.consume_ai_usage(p_user uuid, p_units integer, p_limit integer, p_request_id text) TO duta_app;


--
-- Name: FUNCTION current_app_has_org_role(org_id uuid, allowed public.organization_role[]); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.current_app_has_org_role(org_id uuid, allowed public.organization_role[]) FROM PUBLIC;
GRANT ALL ON FUNCTION public.current_app_has_org_role(org_id uuid, allowed public.organization_role[]) TO duta_app;
GRANT ALL ON FUNCTION public.current_app_has_org_role(org_id uuid, allowed public.organization_role[]) TO duta_system;


--
-- Name: FUNCTION current_app_has_role(allowed public.user_role[]); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.current_app_has_role(allowed public.user_role[]) FROM PUBLIC;
GRANT ALL ON FUNCTION public.current_app_has_role(allowed public.user_role[]) TO duta_app;
GRANT ALL ON FUNCTION public.current_app_has_role(allowed public.user_role[]) TO duta_system;


--
-- Name: FUNCTION current_app_user_id(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.current_app_user_id() FROM PUBLIC;
GRANT ALL ON FUNCTION public.current_app_user_id() TO duta_app;
GRANT ALL ON FUNCTION public.current_app_user_id() TO duta_system;


--
-- Name: FUNCTION delete_current_app_user(); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.delete_current_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION public.delete_current_app_user() TO duta_app;


--
-- Name: FUNCTION has_org_role(org_id uuid, allowed public.organization_role[]); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[]) FROM PUBLIC;
GRANT ALL ON FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[]) TO anon;
GRANT ALL ON FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[]) TO authenticated;
GRANT ALL ON FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[]) TO duta_app;


--
-- Name: FUNCTION has_platform_role(required_role public.platform_role); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.has_platform_role(required_role public.platform_role) FROM PUBLIC;
GRANT ALL ON FUNCTION public.has_platform_role(required_role public.platform_role) TO authenticated;


--
-- Name: FUNCTION has_system_role(allowed public.user_role[]); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION public.has_system_role(allowed public.user_role[]) FROM PUBLIC;
GRANT ALL ON FUNCTION public.has_system_role(allowed public.user_role[]) TO anon;
GRANT ALL ON FUNCTION public.has_system_role(allowed public.user_role[]) TO authenticated;
GRANT ALL ON FUNCTION public.has_system_role(allowed public.user_role[]) TO duta_app;


--
-- Name: TABLE ai_telemetry_events; Type: ACL; Schema: public; Owner: -
--

GRANT INSERT ON TABLE public.ai_telemetry_events TO duta_app;


--
-- Name: TABLE ai_usage_buckets; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.ai_usage_buckets TO duta_app;


--
-- Name: TABLE audit_logs; Type: ACL; Schema: public; Owner: -
--

GRANT INSERT ON TABLE public.audit_logs TO duta_app;
GRANT INSERT ON TABLE public.audit_logs TO duta_system;


--
-- Name: TABLE communities; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.communities TO duta_app;


--
-- Name: TABLE community_members; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.community_members TO duta_app;


--
-- Name: TABLE entities; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.entities TO duta_app;


--
-- Name: TABLE entity_eligibilities; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.entity_eligibilities TO duta_app;


--
-- Name: TABLE entity_responsible_persons; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.entity_responsible_persons TO duta_app;


--
-- Name: TABLE entity_verifications; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.entity_verifications TO duta_app;


--
-- Name: TABLE external_job_listings; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.external_job_listings TO duta_app;


--
-- Name: TABLE jobs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.jobs TO duta_app;


--
-- Name: TABLE meeting_transcripts; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.meeting_transcripts TO duta_app;


--
-- Name: TABLE moderation_actions; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.moderation_actions TO duta_app;


--
-- Name: TABLE moderation_case_reports; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.moderation_case_reports TO duta_app;


--
-- Name: TABLE moderation_cases; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.moderation_cases TO duta_app;


--
-- Name: TABLE moderation_evidence; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.moderation_evidence TO duta_app;


--
-- Name: TABLE official_sources; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.official_sources TO duta_app;


--
-- Name: TABLE organization_documents; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.organization_documents TO duta_app;


--
-- Name: TABLE organization_members; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.organization_members TO duta_app;


--
-- Name: TABLE organization_membership_applications; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.organization_membership_applications TO duta_app;


--
-- Name: TABLE organizations; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.organizations TO duta_app;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.products TO duta_app;


--
-- Name: TABLE publication_projects; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.publication_projects TO duta_app;


--
-- Name: TABLE sellers; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.sellers TO duta_app;


--
-- Name: TABLE user_platform_roles; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.user_platform_roles TO authenticated;


--
-- Name: TABLE user_presence_checks; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.user_presence_checks TO duta_app;


--
-- Name: TABLE user_verifications; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.user_verifications TO duta_app;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.name; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(name) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.city; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(city) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.state; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(state) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.hometown; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(hometown) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.profession; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(profession) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.interests; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(interests) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.profile_visibility; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(profile_visibility) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.location_visibility; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(location_visibility) ON TABLE public.users TO duta_app;


--
-- Name: COLUMN users.updated_at; Type: ACL; Schema: public; Owner: -
--

GRANT UPDATE(updated_at) ON TABLE public.users TO duta_app;


--
-- Name: TABLE verification_evidence; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.verification_evidence TO duta_app;


--
-- PostgreSQL database dump complete
--

\unrestrict 6hQeiF5GN4EGpvRNpsrqjJgg38Wd8HTbQ9KPTeBsv8KiebAi0vBRJAWsXlEwWqm


-- DB-RB2 provisioning ledger: this records the canonical baseline and governed forward chain only.
CREATE TABLE public.duta_provisioning_ledger (
  sequence integer PRIMARY KEY,
  kind text NOT NULL CHECK (kind IN ('BASELINE','FORWARD_MIGRATION')),
  identity text NOT NULL UNIQUE,
  checksum text NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now(),
  tool_version text NOT NULL,
  CONSTRAINT duta_provisioning_ledger_sequence_ck CHECK ((kind='BASELINE' AND sequence=0) OR (kind='FORWARD_MIGRATION' AND sequence BETWEEN 39 AND 45))
);
ALTER TABLE public.duta_provisioning_ledger ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.duta_provisioning_ledger FROM PUBLIC, anon, authenticated, duta_app, duta_system;
