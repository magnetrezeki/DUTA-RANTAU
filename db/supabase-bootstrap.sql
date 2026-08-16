-- DUTA RANTAU Supabase bootstrap
-- Generated 16 Aug 2026. Run once in Supabase SQL Editor on an empty project.
BEGIN;

-- db/migrations/0000_next_marrow.sql
CREATE TYPE "public"."organization_role" AS ENUM('OWNER', 'ADMIN', 'SECRETARY', 'TREASURER', 'STAFF', 'MEMBER');
CREATE TYPE "public"."record_status" AS ENUM('DRAFT', 'PENDING', 'ACTIVE', 'SUSPENDED', 'ARCHIVED');
CREATE TYPE "public"."trust_level" AS ENUM('OFFICIAL_VERIFIED', 'INSTITUTION_VERIFIED', 'DUTA_VERIFIED', 'COMMUNITY_VERIFIED', 'USER_GENERATED');
CREATE TYPE "public"."user_role" AS ENUM('USER', 'MEMBER', 'VERIFIED_MEMBER', 'SELLER', 'ORG_ADMIN', 'ORG_STAFF', 'MODERATOR', 'EDITOR', 'SUPER_ADMIN');
CREATE TABLE "ai_conversations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"intent" text,
	"messages" jsonb NOT NULL,
	"source_ids" uuid[],
	"confidence" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "audit_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"actor_id" uuid,
	"organization_id" uuid,
	"action" text NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" text,
	"metadata" jsonb,
	"ip_hash" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "contents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"author_id" uuid,
	"title" text NOT NULL,
	"slug" text NOT NULL,
	"body" text NOT NULL,
	"type" text NOT NULL,
	"category" text,
	"state" text,
	"city" text,
	"trust_level" "trust_level" DEFAULT 'USER_GENERATED' NOT NULL,
	"source_id" uuid,
	"status" "record_status" DEFAULT 'DRAFT' NOT NULL,
	"published_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid,
	"title" text NOT NULL,
	"description" text,
	"location" text,
	"starts_at" timestamp with time zone NOT NULL,
	"capacity" integer,
	"registration_enabled" boolean DEFAULT true,
	"status" "record_status" DEFAULT 'DRAFT' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "jobs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"owner_id" uuid,
	"title" text NOT NULL,
	"employer" text NOT NULL,
	"description" text NOT NULL,
	"state" text,
	"city" text,
	"salary_text" text,
	"employment_type" text NOT NULL,
	"requirements" text,
	"language" text,
	"application_method" text,
	"trust_level" "trust_level" DEFAULT 'USER_GENERATED' NOT NULL,
	"expires_at" timestamp with time zone,
	"status" "record_status" DEFAULT 'PENDING' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "memberships" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"plan" text NOT NULL,
	"status" text NOT NULL,
	"price_myr" numeric(10, 2),
	"start_date" timestamp with time zone,
	"renewal_date" timestamp with time zone,
	"cancelled_at" timestamp with time zone,
	"eastel_bonus_status" text DEFAULT 'NOT_CLAIMED',
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "official_sources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"institution" text NOT NULL,
	"channel" text NOT NULL,
	"url" text NOT NULL,
	"category" text NOT NULL,
	"priority" text NOT NULL,
	"trust_level" "trust_level" DEFAULT 'OFFICIAL_VERIFIED' NOT NULL,
	"last_checked" timestamp with time zone NOT NULL,
	"checksum" text,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_finances" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"actor_id" uuid NOT NULL,
	"type" text NOT NULL,
	"amount" numeric(14, 2) NOT NULL,
	"description" text NOT NULL,
	"transaction_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_permissions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"role" "organization_role" NOT NULL,
	"permission" text NOT NULL
);

CREATE TABLE "organization_members" (
	"organization_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"role" "organization_role" DEFAULT 'MEMBER' NOT NULL,
	"member_status" text DEFAULT 'ACTIVE' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organizations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"type" text NOT NULL,
	"description" text,
	"state" text,
	"city" text,
	"logo_url" text,
	"contact" text,
	"verification" "trust_level" DEFAULT 'USER_GENERATED' NOT NULL,
	"status" "record_status" DEFAULT 'PENDING' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "products" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"seller_id" uuid NOT NULL,
	"name" text NOT NULL,
	"description" text NOT NULL,
	"category" text NOT NULL,
	"price_myr" numeric(12, 2),
	"images" jsonb DEFAULT '[]'::jsonb,
	"state" text,
	"city" text,
	"status" "record_status" DEFAULT 'PENDING' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "reports" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"reporter_id" uuid,
	"entity_type" text NOT NULL,
	"entity_id" uuid NOT NULL,
	"category" text NOT NULL,
	"details" text,
	"status" text DEFAULT 'OPEN' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "sellers" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"organization_id" uuid,
	"name" text NOT NULL,
	"description" text,
	"trust_level" "trust_level" DEFAULT 'USER_GENERATED' NOT NULL,
	"status" "record_status" DEFAULT 'PENDING' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" text NOT NULL,
	"password_hash" text,
	"name" text NOT NULL,
	"phone" text,
	"avatar_url" text,
	"city" text,
	"state" text,
	"hometown" text,
	"profession" text,
	"interests" text[],
	"role" "user_role" DEFAULT 'USER' NOT NULL,
	"email_verified_at" timestamp with time zone,
	"profile_visibility" text DEFAULT 'PRIVATE' NOT NULL,
	"location_visibility" text DEFAULT 'PRIVATE' NOT NULL,
	"suspended_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "ai_conversations" ADD CONSTRAINT "ai_conversations_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "contents" ADD CONSTRAINT "contents_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "contents" ADD CONSTRAINT "contents_source_id_official_sources_id_fk" FOREIGN KEY ("source_id") REFERENCES "public"."official_sources"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "events" ADD CONSTRAINT "events_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "memberships" ADD CONSTRAINT "memberships_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_finances" ADD CONSTRAINT "organization_finances_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_finances" ADD CONSTRAINT "organization_finances_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "organization_permissions" ADD CONSTRAINT "organization_permissions_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "products" ADD CONSTRAINT "products_seller_id_sellers_id_fk" FOREIGN KEY ("seller_id") REFERENCES "public"."sellers"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporter_id_users_id_fk" FOREIGN KEY ("reporter_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "sellers" ADD CONSTRAINT "sellers_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "sellers" ADD CONSTRAINT "sellers_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
CREATE INDEX "audit_actor_idx" ON "audit_logs" USING btree ("actor_id","created_at");
CREATE UNIQUE INDEX "content_slug_uq" ON "contents" USING btree ("slug");
CREATE INDEX "jobs_search_idx" ON "jobs" USING btree ("state","city","employment_type");
CREATE UNIQUE INDEX "sources_url_uq" ON "official_sources" USING btree ("url");
CREATE INDEX "source_institution_idx" ON "official_sources" USING btree ("institution");
CREATE INDEX "finance_org_idx" ON "organization_finances" USING btree ("organization_id","transaction_at");
CREATE UNIQUE INDEX "org_permission_uq" ON "organization_permissions" USING btree ("organization_id","role","permission");
CREATE UNIQUE INDEX "org_member_uq" ON "organization_members" USING btree ("organization_id","user_id");
CREATE UNIQUE INDEX "session_token_uq" ON "sessions" USING btree ("token_hash");
CREATE INDEX "session_user_idx" ON "sessions" USING btree ("user_id");
CREATE UNIQUE INDEX "users_email_uq" ON "users" USING btree ("email");
CREATE INDEX "users_location_idx" ON "users" USING btree ("state","city");
-- db/migrations/0001_glorious_scarlet_witch.sql
CREATE TABLE "communities" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"owner_id" uuid,
	"name" text NOT NULL,
	"description" text,
	"category" text NOT NULL,
	"state" text,
	"city" text,
	"visibility" text DEFAULT 'PUBLIC' NOT NULL,
	"trust_level" "trust_level" DEFAULT 'USER_GENERATED' NOT NULL,
	"status" "record_status" DEFAULT 'PENDING' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "community_members" (
	"community_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"role" text DEFAULT 'MEMBER' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "notifications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"type" text NOT NULL,
	"priority" text NOT NULL,
	"title" text NOT NULL,
	"body" text NOT NULL,
	"read_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_documents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"author_id" uuid NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"storage_key" text,
	"content" text,
	"status" "record_status" DEFAULT 'DRAFT' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_letters" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"number" text,
	"direction" text NOT NULL,
	"title" text NOT NULL,
	"content" text,
	"approval_status" text DEFAULT 'DRAFT' NOT NULL,
	"approved_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_meetings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"title" text NOT NULL,
	"agenda" text,
	"minutes" text,
	"starts_at" timestamp with time zone NOT NULL,
	"location" text,
	"status" "record_status" DEFAULT 'DRAFT' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "payments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"membership_id" uuid NOT NULL,
	"provider" text NOT NULL,
	"provider_reference" text,
	"amount_myr" numeric(10, 2) NOT NULL,
	"status" text NOT NULL,
	"invoice_number" text,
	"failure_code" text,
	"paid_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "communities" ADD CONSTRAINT "communities_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "community_members" ADD CONSTRAINT "community_members_community_id_communities_id_fk" FOREIGN KEY ("community_id") REFERENCES "public"."communities"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "community_members" ADD CONSTRAINT "community_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_documents" ADD CONSTRAINT "organization_documents_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_documents" ADD CONSTRAINT "organization_documents_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "organization_letters" ADD CONSTRAINT "organization_letters_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_letters" ADD CONSTRAINT "organization_letters_approved_by_users_id_fk" FOREIGN KEY ("approved_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "organization_meetings" ADD CONSTRAINT "organization_meetings_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "payments" ADD CONSTRAINT "payments_membership_id_memberships_id_fk" FOREIGN KEY ("membership_id") REFERENCES "public"."memberships"("id") ON DELETE cascade ON UPDATE no action;
CREATE INDEX "community_location_idx" ON "communities" USING btree ("state","city","category");
CREATE UNIQUE INDEX "community_member_uq" ON "community_members" USING btree ("community_id","user_id");
CREATE INDEX "notification_user_idx" ON "notifications" USING btree ("user_id","read_at");
CREATE INDEX "org_document_idx" ON "organization_documents" USING btree ("organization_id","type");
CREATE INDEX "org_letter_idx" ON "organization_letters" USING btree ("organization_id","direction");
CREATE UNIQUE INDEX "payment_provider_ref_uq" ON "payments" USING btree ("provider","provider_reference");
-- Supabase Auth profile synchronization
-- Run after Drizzle migrations in the Supabase SQL Editor.
-- Keeps authorization roles in public.users; never trusts role from signup metadata.
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id,email,name,city,role,profile_visibility,location_visibility,created_at,updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email,''),
    COALESCE(NULLIF(NEW.raw_user_meta_data ->> 'name',''), split_part(COALESCE(NEW.email,''),'@',1), 'Kawan Rantau'),
    NULLIF(NEW.raw_user_meta_data ->> 'city',''),
    'USER',
    'PRIVATE',
    'PRIVATE',
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_auth_user();

-- Row Level Security
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

-- 27 approved official channels from supplied data KBRI KJRI.pdf
INSERT INTO public.official_sources (institution,channel,url,category,priority,trust_level,last_checked,active) VALUES
  ('KBRI Kuala Lumpur','Situs resmi','https://kemlu.go.id/kualalumpur','kantor, konsuler, perlindungan, imigrasi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KBRI Kuala Lumpur','Instagram','https://www.instagram.com/indonesiainkualalumpur/','pengumuman, konsuler, perlindungan, imigrasi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KBRI Kuala Lumpur','Facebook','https://www.facebook.com/IndonesianEmbassyKualaLumpur/','pengumuman, konsuler, perlindungan','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KBRI Kuala Lumpur','X','https://x.com/kbrikualalumpur','informasi resmi dan konsuler','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KBRI Kuala Lumpur','YouTube','https://www.youtube.com/@kbrikualalumpur','informasi resmi dan konsuler','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Johor Bahru','Situs resmi','https://kemlu.go.id/johorbahru','kantor, konsuler, imigrasi, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Johor Bahru','Instagram','https://www.instagram.com/indonesiainjb/','layanan dan pengumuman resmi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Johor Bahru','Facebook','https://www.facebook.com/IndonesianInJohorBahru/','layanan, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Penang','Situs resmi','https://kemlu.go.id/penang','kantor, konsuler, imigrasi, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Penang','Instagram','https://www.instagram.com/indonesiainpenang/','pengumuman dan layanan resmi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Penang','Facebook','https://www.facebook.com/indonesiainpenang/','layanan, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Penang','X','https://x.com/IndonesiaPenang','informasi konsuler dan peringatan lokal','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Penang','YouTube','https://www.youtube.com/channel/UCQ6aLdnF6UFNDjP-1_QqHpw','publikasi layanan dan informasi resmi','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Kota Kinabalu','Situs resmi','https://kemlu.go.id/kotakinabalu','kantor, konsuler, imigrasi, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Kota Kinabalu','Instagram','https://www.instagram.com/indonesiainkotakinabalu/','layanan dan pengumuman resmi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Kuching','Situs resmi','https://kemlu.go.id/kuching','kantor, konsuler, imigrasi, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Kuching','Instagram','https://www.instagram.com/indonesiainkuching/','layanan dan pengumuman resmi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KJRI Kuching','Facebook','https://www.facebook.com/kjrikuching/','layanan, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KRI Tawau','Situs resmi','https://kemlu.go.id/tawau','kantor, konsuler, imigrasi, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KRI Tawau','Instagram','https://www.instagram.com/indonesiaintawau/','layanan dan pengumuman resmi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KRI Tawau','Facebook','https://www.facebook.com/konsulatritawau/','layanan, perlindungan, komunitas','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('KRI Tawau','X','https://x.com/indonesiaintwu','konsuler, imigrasi, perlindungan, komunitas','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('Atase Tenaga Kerja','Instagram','https://www.instagram.com/atnaker.kl/','pekerja migran, ketenagakerjaan, perlindungan, repatriasi','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('Atase Hukum','Instagram','https://www.instagram.com/atkum.kualalumpur/','hukum, perlindungan, bantuan hukum','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('Atase Pendidikan dan Kebudayaan','Instagram','https://www.instagram.com/atdikbud_kualalumpur/','pendidikan, pelajar, beasiswa, kebudayaan','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('Atase Perhubungan','Instagram','https://www.instagram.com/ataseperhubungan.kl/','transportasi, pelaut, perjalanan','P0','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true),
  ('Atase Perdagangan','Instagram','https://www.instagram.com/atdag.kualalumpur/','perdagangan, bisnis, ekspor, ekonomi','P1','OFFICIAL_VERIFIED','2026-08-16T00:00:00Z',true)
ON CONFLICT (url) DO UPDATE SET institution=excluded.institution,channel=excluded.channel,category=excluded.category,priority=excluded.priority,last_checked=excluded.last_checked,active=true,updated_at=now();

COMMIT;
