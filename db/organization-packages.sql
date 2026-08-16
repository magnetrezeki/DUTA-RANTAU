-- DUTA RANTAU: Paket Organisasi + Sekretaris Digital & Publikasi
-- Run once after the original supabase-bootstrap.sql.
BEGIN;
CREATE TABLE "meeting_transcripts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"meeting_id" uuid NOT NULL,
	"created_by" uuid NOT NULL,
	"language" text DEFAULT 'id' NOT NULL,
	"transcript" text NOT NULL,
	"summary" text NOT NULL,
	"action_items" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"consent_confirmed" boolean DEFAULT false NOT NULL,
	"audio_deleted_at" timestamp with time zone NOT NULL,
	"approved_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_attendance" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"event_id" uuid,
	"meeting_id" uuid,
	"user_id" uuid NOT NULL,
	"status" text NOT NULL,
	"checked_in_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_branches" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"name" text NOT NULL,
	"state" text,
	"city" text,
	"contact" text,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_payments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"subscription_id" uuid NOT NULL,
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

CREATE TABLE "organization_subscriptions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"plan" text DEFAULT 'FREE' NOT NULL,
	"status" text DEFAULT 'ACTIVE' NOT NULL,
	"price_myr" numeric(10, 2) DEFAULT '0' NOT NULL,
	"provider" text,
	"provider_reference" text,
	"start_date" timestamp with time zone DEFAULT now() NOT NULL,
	"renewal_date" timestamp with time zone,
	"cancelled_at" timestamp with time zone,
	"grace_ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "organization_tasks" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"assignee_id" uuid,
	"created_by" uuid NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"due_at" timestamp with time zone,
	"status" text DEFAULT 'OPEN' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "publication_projects" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid NOT NULL,
	"created_by" uuid NOT NULL,
	"approved_by" uuid,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"prompt" text,
	"content" jsonb NOT NULL,
	"status" text DEFAULT 'DRAFT' NOT NULL,
	"published_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "publication_templates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"organization_id" uuid,
	"name" text NOT NULL,
	"type" text NOT NULL,
	"category" text NOT NULL,
	"schema" jsonb NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "meeting_transcripts" ADD CONSTRAINT "meeting_transcripts_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "meeting_transcripts" ADD CONSTRAINT "meeting_transcripts_meeting_id_organization_meetings_id_fk" FOREIGN KEY ("meeting_id") REFERENCES "public"."organization_meetings"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "meeting_transcripts" ADD CONSTRAINT "meeting_transcripts_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "organization_attendance" ADD CONSTRAINT "organization_attendance_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_attendance" ADD CONSTRAINT "organization_attendance_event_id_events_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_attendance" ADD CONSTRAINT "organization_attendance_meeting_id_organization_meetings_id_fk" FOREIGN KEY ("meeting_id") REFERENCES "public"."organization_meetings"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_attendance" ADD CONSTRAINT "organization_attendance_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_branches" ADD CONSTRAINT "organization_branches_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_payments" ADD CONSTRAINT "organization_payments_subscription_id_organization_subscriptions_id_fk" FOREIGN KEY ("subscription_id") REFERENCES "public"."organization_subscriptions"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_subscriptions" ADD CONSTRAINT "organization_subscriptions_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_tasks" ADD CONSTRAINT "organization_tasks_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "organization_tasks" ADD CONSTRAINT "organization_tasks_assignee_id_users_id_fk" FOREIGN KEY ("assignee_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "organization_tasks" ADD CONSTRAINT "organization_tasks_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "publication_projects" ADD CONSTRAINT "publication_projects_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "publication_projects" ADD CONSTRAINT "publication_projects_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "publication_projects" ADD CONSTRAINT "publication_projects_approved_by_users_id_fk" FOREIGN KEY ("approved_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "publication_templates" ADD CONSTRAINT "publication_templates_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "publication_templates" ADD CONSTRAINT "publication_templates_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;
CREATE UNIQUE INDEX "meeting_transcript_meeting_uq" ON "meeting_transcripts" USING btree ("meeting_id");
CREATE UNIQUE INDEX "org_attendance_uq" ON "organization_attendance" USING btree ("organization_id","event_id","meeting_id","user_id");
CREATE INDEX "org_branch_idx" ON "organization_branches" USING btree ("organization_id","active");
CREATE UNIQUE INDEX "org_payment_provider_ref_uq" ON "organization_payments" USING btree ("provider","provider_reference");
CREATE UNIQUE INDEX "org_subscription_org_uq" ON "organization_subscriptions" USING btree ("organization_id");
CREATE INDEX "org_task_idx" ON "organization_tasks" USING btree ("organization_id","status");
CREATE INDEX "publication_project_idx" ON "publication_projects" USING btree ("organization_id","status","type");
CREATE INDEX "publication_template_idx" ON "publication_templates" USING btree ("organization_id","type","active");
ALTER TABLE public.organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_transcripts ENABLE ROW LEVEL SECURITY;
CREATE POLICY org_subscription_read ON public.organization_subscriptions FOR SELECT TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY org_subscription_manage ON public.organization_subscriptions FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER']::public.organization_role[]) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY org_payment_read ON public.organization_payments FOR SELECT TO authenticated USING (EXISTS(SELECT 1 FROM public.organization_subscriptions s WHERE s.id=subscription_id AND public.has_org_role(s.organization_id,ARRAY['OWNER']::public.organization_role[])) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY org_branch_read ON public.organization_branches FOR SELECT TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','TREASURER','STAFF','MEMBER']::public.organization_role[]));
CREATE POLICY org_branch_manage ON public.organization_branches FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]));
CREATE POLICY org_attendance_read ON public.organization_attendance FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));
CREATE POLICY org_attendance_manage ON public.organization_attendance FOR ALL TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));
CREATE POLICY org_task_scope ON public.organization_tasks FOR SELECT TO authenticated USING (assignee_id=auth.uid() OR created_by=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY org_task_manage ON public.organization_tasks FOR ALL TO authenticated USING (created_by=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY publication_template_read ON public.publication_templates FOR SELECT TO authenticated USING (organization_id IS NULL OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF','MEMBER']::public.organization_role[]));
CREATE POLICY publication_template_manage ON public.publication_templates FOR ALL TO authenticated USING (organization_id IS NOT NULL AND public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]) OR public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY publication_project_read ON public.publication_projects FOR SELECT TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));
CREATE POLICY publication_project_create ON public.publication_projects FOR INSERT TO authenticated WITH CHECK (created_by=auth.uid() AND public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));
CREATE POLICY publication_project_update ON public.publication_projects FOR UPDATE TO authenticated USING (created_by=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]));
CREATE POLICY transcript_read ON public.meeting_transcripts FOR SELECT TO authenticated USING (public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY transcript_create ON public.meeting_transcripts FOR INSERT TO authenticated WITH CHECK (created_by=auth.uid() AND consent_confirmed=true AND public.has_org_role(organization_id,ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));
CREATE POLICY transcript_update ON public.meeting_transcripts FOR UPDATE TO authenticated USING (created_by=auth.uid() OR public.has_org_role(organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[]));

INSERT INTO public.organization_subscriptions (organization_id,plan,status,price_myr) SELECT id,'FREE','ACTIVE',0 FROM public.organizations ON CONFLICT (organization_id) DO NOTHING;
COMMIT;
