-- Supabase-native Row Level Security. Apply after both Drizzle migrations.
-- Identity comes from auth.uid(); elevated roles are stored only in public.users.

CREATE OR REPLACE FUNCTION public.has_system_role(allowed public.user_role[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = ANY(allowed) AND u.suspended_at IS NULL)
$$;

CREATE OR REPLACE FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.organization_members m WHERE m.organization_id=org_id AND m.user_id=auth.uid() AND m.role=ANY(allowed) AND m.member_status='ACTIVE')
$$;

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_finances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_self_select ON public.users FOR SELECT TO authenticated USING (id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY users_self_update ON public.users FOR UPDATE TO authenticated USING (id=auth.uid()) WITH CHECK (id=auth.uid());
CREATE POLICY users_self_delete ON public.users FOR DELETE TO authenticated USING (id=auth.uid());

CREATE POLICY memberships_owner ON public.memberships FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY payments_owner ON public.payments FOR SELECT TO authenticated USING (EXISTS(SELECT 1 FROM public.memberships m WHERE m.id=membership_id AND m.user_id=auth.uid()) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY notifications_owner_select ON public.notifications FOR SELECT TO authenticated USING (user_id=auth.uid());
CREATE POLICY notifications_owner_update ON public.notifications FOR UPDATE TO authenticated USING (user_id=auth.uid()) WITH CHECK (user_id=auth.uid());

CREATE POLICY official_sources_public ON public.official_sources FOR SELECT TO anon,authenticated USING (active=true);
CREATE POLICY official_sources_editor ON public.official_sources FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY contents_public ON public.contents FOR SELECT TO anon,authenticated USING (status='ACTIVE');
CREATE POLICY contents_editor ON public.contents FOR ALL TO authenticated USING (author_id=auth.uid() OR public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (author_id=auth.uid() OR public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));

CREATE POLICY jobs_public ON public.jobs FOR SELECT TO anon,authenticated USING (status='ACTIVE' OR owner_id=auth.uid());
CREATE POLICY jobs_owner_insert ON public.jobs FOR INSERT TO authenticated WITH CHECK (owner_id=auth.uid() AND status='PENDING');
CREATE POLICY jobs_owner_update ON public.jobs FOR UPDATE TO authenticated USING (owner_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (owner_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY jobs_owner_delete ON public.jobs FOR DELETE TO authenticated USING (owner_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));

CREATE POLICY communities_public ON public.communities FOR SELECT TO anon,authenticated USING ((visibility='PUBLIC' AND status='ACTIVE') OR owner_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY communities_owner_insert ON public.communities FOR INSERT TO authenticated WITH CHECK (owner_id=auth.uid() AND status='PENDING');
CREATE POLICY communities_owner_manage ON public.communities FOR UPDATE TO authenticated USING (owner_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY community_members_scope ON public.community_members FOR SELECT TO authenticated USING (user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.communities c WHERE c.id=community_id AND c.owner_id=auth.uid()));
CREATE POLICY community_join ON public.community_members FOR INSERT TO authenticated WITH CHECK (user_id=auth.uid());
CREATE POLICY community_leave ON public.community_members FOR DELETE TO authenticated USING (user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.communities c WHERE c.id=community_id AND c.owner_id=auth.uid()));

CREATE POLICY organizations_public ON public.organizations FOR SELECT TO anon,authenticated USING (status='ACTIVE' OR public.has_org_role(id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[]) OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY organizations_create ON public.organizations FOR INSERT TO authenticated WITH CHECK (status='PENDING');
CREATE POLICY organizations_manage ON public.organizations FOR UPDATE TO authenticated USING (public.has_org_role(id,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY org_members_read ON public.organization_members FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[]));
CREATE POLICY org_members_manage ON public.organization_members FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])) WITH CHECK (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR user_id=auth.uid());
CREATE POLICY org_permissions_read ON public.organization_permissions FOR SELECT TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[]));
CREATE POLICY org_permissions_manage ON public.organization_permissions FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]));
CREATE POLICY org_finance_scope ON public.organization_finances FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','TREASURER']::public.organization_role[])) WITH CHECK (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','TREASURER']::public.organization_role[]));
CREATE POLICY org_documents_scope ON public.organization_documents FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[])) WITH CHECK (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));
CREATE POLICY org_meetings_scope ON public.organization_meetings FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[])) WITH CHECK (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY org_letters_scope ON public.organization_letters FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[])) WITH CHECK (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY events_public ON public.events FOR SELECT TO anon,authenticated USING (status='ACTIVE' OR (organization_id IS NOT NULL AND public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[])));
CREATE POLICY events_org_manage ON public.events FOR ALL TO authenticated USING (organization_id IS NOT NULL AND public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));

CREATE POLICY sellers_public ON public.sellers FOR SELECT TO anon,authenticated USING (status='ACTIVE' OR user_id=auth.uid());
CREATE POLICY sellers_owner ON public.sellers FOR ALL TO authenticated USING (user_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (user_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY products_public ON public.products FOR SELECT TO anon,authenticated USING (status='ACTIVE' OR EXISTS(SELECT 1 FROM public.sellers s WHERE s.id=seller_id AND s.user_id=auth.uid()));
CREATE POLICY products_seller ON public.products FOR ALL TO authenticated USING (EXISTS(SELECT 1 FROM public.sellers s WHERE s.id=seller_id AND s.user_id=auth.uid())) WITH CHECK (EXISTS(SELECT 1 FROM public.sellers s WHERE s.id=seller_id AND s.user_id=auth.uid()));

CREATE POLICY ai_owner ON public.ai_conversations FOR ALL TO authenticated USING (user_id=auth.uid()) WITH CHECK (user_id=auth.uid());
CREATE POLICY reports_create ON public.reports FOR INSERT TO authenticated WITH CHECK (reporter_id=auth.uid() AND status='OPEN');
CREATE POLICY reports_review ON public.reports FOR SELECT TO authenticated USING (reporter_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY reports_moderate ON public.reports FOR UPDATE TO authenticated USING (public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY audit_admin ON public.audit_logs FOR SELECT TO authenticated USING (public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
-- public.sessions is retained for migration compatibility but denied to client roles; Supabase Auth owns active sessions.
