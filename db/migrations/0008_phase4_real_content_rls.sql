-- Phase 4 — real content management RLS.
-- Local PostgreSQL identity bridge only. No demo/runtime fallback data.
-- The explicit transaction boundary prevents a partial policy/grant rollout.
BEGIN;

GRANT INSERT, UPDATE, DELETE ON public.jobs TO duta_app;
GRANT INSERT, UPDATE, DELETE ON public.official_sources TO duta_app;

CREATE POLICY jobs_admin_all ON public.jobs FOR ALL TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[])) WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY communities_admin_all ON public.communities FOR ALL TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[])) WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY sellers_admin_all ON public.sellers FOR ALL TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[])) WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY products_admin_all ON public.products FOR ALL TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[])) WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY official_sources_admin_all ON public.official_sources FOR ALL TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[])) WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY organizations_admin_insert ON public.organizations FOR INSERT TO duta_app WITH CHECK(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]) AND status IN ('PENDING','ACTIVE') AND verification='DUTA_VERIFIED');
CREATE POLICY organizations_admin_delete ON public.organizations FOR DELETE TO duta_app USING(public.current_app_has_role(ARRAY['ORG_ADMIN','SUPER_ADMIN']::public.user_role[]));

CREATE OR REPLACE FUNCTION public.protect_moderation_fields() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
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

DROP POLICY IF EXISTS audit_user_insert ON public.audit_logs;
CREATE POLICY audit_user_insert ON public.audit_logs FOR INSERT TO duta_app WITH CHECK(
  actor_id=public.current_app_user_id() AND action IN (
    'profile_update','source_change','organization.create','organization.application_submitted','organization.reviewed',
    'publication.create_draft','secretary.create_draft','meeting.audio_transcribed',
    'member.phone_verified','member.location_verified','member.location_manual_review','member.selfie_uploaded','member.reviewed',
    'content_admin_create','content_admin_update','content_admin_delete'
  )
);

COMMIT;
