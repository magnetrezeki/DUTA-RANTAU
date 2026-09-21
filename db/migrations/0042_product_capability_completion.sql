-- 0042: owner-scoped capability completion for moderated contributions.
-- Local validation only. Not applied to shared staging or Production.
BEGIN;

ALTER TYPE public.record_status ADD VALUE IF NOT EXISTS 'REJECTED' AFTER 'ACTIVE';
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'COMPLIANCE_ADMIN';
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'VERIFICATION_REVIEWER';
COMMIT;
BEGIN;

-- A draft/pending job may enter moderation before employer eligibility is
-- approved. Publication remains impossible without an active eligible entity.
CREATE OR REPLACE FUNCTION public.enforce_job_posting_safety()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE employer_type public.entity_type; employer_status public.record_status; employer_name text; eligibility_current boolean;
BEGIN
  IF NEW.employer_entity_id IS NULL THEN RAISE EXCEPTION 'job employer entity is required'; END IF;
  SELECT entity_type,record_status,display_name INTO employer_type,employer_status,employer_name FROM public.entities WHERE id=NEW.employer_entity_id;
  IF employer_type NOT IN ('business','organisation') THEN RAISE EXCEPTION 'job posting is not supported for this entity type'; END IF;
  IF NEW.posting_kind IS DISTINCT FROM 'direct_employer' THEN RAISE EXCEPTION 'candidate placement and agency posting are not supported'; END IF;
  SELECT EXISTS(SELECT 1 FROM public.entity_eligibilities ee WHERE ee.entity_id=NEW.employer_entity_id AND ee.eligibility_type='employer' AND ee.status='approved' AND (ee.expires_at IS NULL OR ee.expires_at>now())) INTO eligibility_current;
  IF NEW.status='ACTIVE' AND (employer_status<>'ACTIVE' OR NOT eligibility_current) THEN RAISE EXCEPTION 'job publication requires active eligible employer'; END IF;
  NEW.employer:=employer_name; NEW.employer_eligibility_snapshot:=CASE WHEN eligibility_current THEN 'approved' ELSE 'pending' END;
  IF NEW.status='ACTIVE' AND NEW.published_at IS NULL THEN NEW.published_at:=now(); END IF;
  RETURN NEW;
END $$;

ALTER FUNCTION public.enforce_marketplace_product_compliance() SECURITY DEFINER;
ALTER FUNCTION public.enforce_marketplace_product_compliance() SET search_path='';

DROP POLICY IF EXISTS entities_runtime_owner ON public.entities;
DROP POLICY IF EXISTS entities_marketplace_actor_read ON public.entities;
CREATE POLICY entities_runtime_owner_read ON public.entities FOR SELECT TO duta_app
USING (owner_user_id=public.current_app_user_id());
CREATE POLICY entities_runtime_owner_insert ON public.entities FOR INSERT TO duta_app
WITH CHECK (owner_user_id=public.current_app_user_id() AND record_status='PENDING' AND legal_status_verified IS NULL);
CREATE POLICY entities_runtime_owner_update ON public.entities FOR UPDATE TO duta_app
USING (owner_user_id=public.current_app_user_id() AND record_status IN ('PENDING','REJECTED'))
WITH CHECK (owner_user_id=public.current_app_user_id() AND record_status IN ('PENDING','REJECTED') AND legal_status_verified IS NULL);
CREATE POLICY entities_runtime_platform_review ON public.entities FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['SUPER_ADMIN']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY entities_runtime_platform_read ON public.entities FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY entity_eligibilities_runtime_owner ON public.entity_eligibilities FOR INSERT TO duta_app
WITH CHECK (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()) AND status='pending');
DROP POLICY IF EXISTS jobs_employer_entity_write ON public.jobs;
CREATE POLICY jobs_runtime_owner ON public.jobs FOR ALL TO duta_app
USING (owner_id=public.current_app_user_id())
WITH CHECK (owner_id=public.current_app_user_id() AND status IN ('DRAFT','PENDING','REJECTED','ARCHIVED'));
CREATE POLICY jobs_runtime_moderator ON public.jobs FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY jobs_runtime_moderator_read ON public.jobs FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY sellers_runtime_owner ON public.sellers FOR ALL TO duta_app
USING (user_id=public.current_app_user_id())
WITH CHECK (user_id=public.current_app_user_id() AND trust_level='USER_GENERATED');
CREATE POLICY products_runtime_moderator ON public.products FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY products_runtime_moderator_read ON public.products FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
DROP POLICY IF EXISTS products_marketplace_entity_write ON public.products;
CREATE POLICY products_runtime_owner ON public.products FOR ALL TO duta_app
USING (EXISTS(SELECT 1 FROM public.sellers s WHERE s.id=seller_id AND s.user_id=public.current_app_user_id()))
WITH CHECK (status IN ('DRAFT','PENDING','REJECTED','ARCHIVED') AND EXISTS(SELECT 1 FROM public.sellers s WHERE s.id=seller_id AND s.user_id=public.current_app_user_id()));
CREATE POLICY entity_eligibilities_runtime_reviewer ON public.entity_eligibilities FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['COMPLIANCE_ADMIN']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['COMPLIANCE_ADMIN']::public.user_role[]));
CREATE POLICY entity_eligibilities_runtime_reviewer_read ON public.entity_eligibilities FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['COMPLIANCE_ADMIN']::public.user_role[]));
DROP POLICY IF EXISTS communities_admin_all ON public.communities;
CREATE POLICY communities_runtime_public ON public.communities FOR SELECT TO duta_app USING (status='ACTIVE' OR owner_id=public.current_app_user_id());
CREATE POLICY communities_runtime_owner ON public.communities FOR INSERT TO duta_app WITH CHECK (owner_id=public.current_app_user_id() AND status='PENDING' AND trust_level='USER_GENERATED');
CREATE POLICY communities_runtime_owner_update ON public.communities FOR UPDATE TO duta_app
USING (owner_id=public.current_app_user_id() AND status IN ('PENDING','REJECTED'))
WITH CHECK (owner_id=public.current_app_user_id() AND status IN ('PENDING','REJECTED') AND trust_level='USER_GENERATED');
CREATE POLICY communities_runtime_moderator ON public.communities FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY communities_runtime_moderator_read ON public.communities FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
DROP POLICY IF EXISTS community_member_join_with_access_scope ON public.community_members;
CREATE OR REPLACE FUNCTION public.current_app_can_add_community_membership(target_community uuid,target_user uuid,target_role text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT target_user=public.current_app_user_id() AND EXISTS(
    SELECT 1 FROM public.communities c WHERE c.id=target_community
      AND ((target_role='MEMBER' AND c.status='ACTIVE') OR (target_role='OWNER' AND c.owner_id=public.current_app_user_id()))
  )
$$;
REVOKE ALL ON FUNCTION public.current_app_can_add_community_membership(uuid,uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_app_can_add_community_membership(uuid,uuid,text) TO duta_app;
CREATE POLICY community_members_runtime_self_read ON public.community_members FOR SELECT TO duta_app
USING (user_id=public.current_app_user_id());
CREATE POLICY community_members_runtime_self_join ON public.community_members FOR INSERT TO duta_app
WITH CHECK (public.current_app_can_add_community_membership(community_id,user_id,role));
CREATE POLICY community_members_runtime_self_leave ON public.community_members FOR DELETE TO duta_app
USING (user_id=public.current_app_user_id() AND role<>'OWNER');
CREATE POLICY organizations_runtime_owner_insert ON public.organizations FOR INSERT TO duta_app
WITH CHECK (status='PENDING' AND verification='USER_GENERATED' AND EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()));
CREATE POLICY organizations_runtime_owner_read ON public.organizations FOR SELECT TO duta_app
USING (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()));
CREATE POLICY organizations_runtime_owner_update ON public.organizations FOR UPDATE TO duta_app
USING (status IN ('PENDING','REJECTED') AND EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()))
WITH CHECK (status IN ('PENDING','REJECTED') AND verification='USER_GENERATED' AND EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()));
DROP POLICY IF EXISTS organizations_admin_update ON public.organizations;
CREATE POLICY organizations_runtime_platform_update ON public.organizations FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['SUPER_ADMIN']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['SUPER_ADMIN']::public.user_role[]) AND status IN ('DRAFT','PENDING','REJECTED','ARCHIVED'));
CREATE POLICY organizations_runtime_moderator ON public.organizations FOR UPDATE TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]))
WITH CHECK (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY organizations_runtime_moderator_read ON public.organizations FOR SELECT TO duta_app
USING (public.current_app_has_role(ARRAY['MODERATOR']::public.user_role[]));
CREATE POLICY organization_members_runtime_owner_insert ON public.organization_members FOR INSERT TO duta_app
WITH CHECK (user_id=public.current_app_user_id() AND role='OWNER' AND EXISTS(SELECT 1 FROM public.organizations o JOIN public.entities e ON e.id=o.entity_id WHERE o.id=organization_id AND e.owner_user_id=public.current_app_user_id()));
CREATE POLICY responsible_runtime_owner_insert ON public.entity_responsible_persons FOR INSERT TO duta_app
WITH CHECK (user_id=public.current_app_user_id() AND EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id()));
CREATE POLICY notifications_runtime_owner ON public.notifications FOR SELECT TO duta_app USING (user_id=public.current_app_user_id());
CREATE POLICY notifications_runtime_create_self ON public.notifications FOR INSERT TO duta_app WITH CHECK (user_id=public.current_app_user_id());
CREATE POLICY notifications_runtime_mark_read ON public.notifications FOR UPDATE TO duta_app USING (user_id=public.current_app_user_id()) WITH CHECK (user_id=public.current_app_user_id());

-- Publication and factual verification are separate decisions. Moderators may
-- publish a USER_GENERATED organization without asserting DUTA verification;
-- archived records remain terminal.
CREATE OR REPLACE FUNCTION public.protect_organization_archival()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF OLD.status='ARCHIVED'::public.record_status AND NEW.status<>'ARCHIVED'::public.record_status THEN
    RAISE EXCEPTION 'Archived organization cannot be reactivated';
  END IF;
  RETURN NEW;
END $$;

GRANT SELECT,INSERT,UPDATE ON public.entities,public.entity_eligibilities,public.jobs,public.sellers,public.products,public.communities,public.community_members,public.organizations,public.organization_members,public.entity_responsible_persons,public.notifications TO duta_app;
GRANT DELETE ON public.community_members TO duta_app;

DROP POLICY IF EXISTS audit_user_insert ON public.audit_logs;
CREATE POLICY audit_user_insert ON public.audit_logs FOR INSERT TO duta_app WITH CHECK (
 actor_id=public.current_app_user_id() AND action IN ('profile_update','source_change','organization.create','organization.application_submitted','organization.reviewed','publication.create_draft','secretary.create_draft','meeting.audio_transcribed','member.phone_verified','member.location_verified','member.location_manual_review','member.selfie_uploaded','member.reviewed','content_admin_create','content_admin_update','content_admin_delete','account_deletion','job.submitted','product.submitted','community.submitted')
);

COMMIT;
