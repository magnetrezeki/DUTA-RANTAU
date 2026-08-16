-- DUTA RANTAU Supabase bootstrap
-- Run once in Supabase SQL Editor on an empty project.
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
-- db/migrations/0002_reflective_magdalene.sql
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
-- db/migrations/0003_stiff_sunspot.sql
CREATE TABLE "official_contacts" (
	"id" text PRIMARY KEY NOT NULL,
	"office_id" text NOT NULL,
	"label" text NOT NULL,
	"display_number" text NOT NULL,
	"e164" text NOT NULL,
	"channel" text NOT NULL,
	"purpose" text NOT NULL,
	"warning" text,
	"whatsapp_confirmed" boolean DEFAULT false NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"last_checked" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "official_evidence" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"office_id" text,
	"institution" text NOT NULL,
	"evidence_type" text NOT NULL,
	"file_path" text NOT NULL,
	"captured_at" timestamp with time zone NOT NULL,
	"effective_date" timestamp with time zone,
	"verification_status" text DEFAULT 'SUPPLIED_OFFICIAL_SCREENSHOT' NOT NULL,
	"extracted_data" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE "official_offices" (
	"id" text PRIMARY KEY NOT NULL,
	"institution" text NOT NULL,
	"city" text NOT NULL,
	"region" text NOT NULL,
	"latitude" numeric(9, 6) NOT NULL,
	"longitude" numeric(9, 6) NOT NULL,
	"official_url" text NOT NULL,
	"source_channel" text NOT NULL,
	"last_checked" timestamp with time zone NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "official_contacts" ADD CONSTRAINT "official_contacts_office_id_official_offices_id_fk" FOREIGN KEY ("office_id") REFERENCES "public"."official_offices"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "official_evidence" ADD CONSTRAINT "official_evidence_office_id_official_offices_id_fk" FOREIGN KEY ("office_id") REFERENCES "public"."official_offices"("id") ON DELETE set null ON UPDATE no action;
CREATE INDEX "official_contact_office_idx" ON "official_contacts" USING btree ("office_id","active");
CREATE UNIQUE INDEX "official_evidence_path_uq" ON "official_evidence" USING btree ("file_path");
CREATE INDEX "official_evidence_office_idx" ON "official_evidence" USING btree ("office_id","evidence_type");
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
ALTER TABLE public.organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_transcripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_offices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_evidence ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_self_select ON public.users FOR SELECT TO authenticated USING (id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY users_self_update ON public.users FOR UPDATE TO authenticated USING (id=auth.uid()) WITH CHECK (id=auth.uid());
CREATE POLICY users_self_delete ON public.users FOR DELETE TO authenticated USING (id=auth.uid());

CREATE POLICY memberships_owner ON public.memberships FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY payments_owner ON public.payments FOR SELECT TO authenticated USING (EXISTS(SELECT 1 FROM public.memberships m WHERE m.id=membership_id AND m.user_id=auth.uid()) OR public.has_system_role(ARRAY['SUPER_ADMIN']::public.user_role[]));
CREATE POLICY notifications_owner_select ON public.notifications FOR SELECT TO authenticated USING (user_id=auth.uid());
CREATE POLICY notifications_owner_update ON public.notifications FOR UPDATE TO authenticated USING (user_id=auth.uid()) WITH CHECK (user_id=auth.uid());

CREATE POLICY official_sources_public ON public.official_sources FOR SELECT TO anon,authenticated USING (active=true);
CREATE POLICY official_offices_public ON public.official_offices FOR SELECT TO anon,authenticated USING (active=true);
CREATE POLICY official_contacts_public ON public.official_contacts FOR SELECT TO anon,authenticated USING (active=true);
CREATE POLICY official_evidence_read ON public.official_evidence FOR SELECT TO authenticated USING (true);
CREATE POLICY official_offices_editor ON public.official_offices FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY official_contacts_editor ON public.official_contacts FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY official_evidence_editor ON public.official_evidence FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
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
-- public.sessions is retained for migration compatibility but denied to client roles; Supabase Auth owns active sessions.

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

-- Emergency directory and 28 supplied evidence records
INSERT INTO public.official_offices (id,institution,city,region,latitude,longitude,official_url,source_channel,last_checked,active) VALUES
('kbri-kl','KBRI Kuala Lumpur','Kuala Lumpur','Semenanjung Malaysia',3.139,101.687,'https://kemlu.go.id/kualalumpur','Halaman resmi KBRI Kuala Lumpur — Pelayanan Perlindungan WNI & BHI; lampiran tarif dari kanal resmi','2026-08-17T00:00:00Z',true),
('kjri-jb','KJRI Johor Bahru','Johor Bahru','Johor',1.4927,103.7414,'https://kemlu.go.id/johorbahru','Kanal resmi KJRI Johor Bahru pada poster tarif','2026-08-10T00:00:00Z',true),
('kjri-penang','KJRI Penang','George Town','Pulau Pinang',5.4141,100.3288,'https://kemlu.go.id/penang','Profil resmi KJRI Penang yang disertakan','2026-08-10T00:00:00Z',true),
('kjri-kuching','KJRI Kuching','Kuching','Sarawak',1.5533,110.3592,'https://kemlu.go.id/kuching','Poster dan akun resmi KJRI Kuching yang disertakan','2026-08-10T00:00:00Z',true),
('kjri-kk','KJRI Kota Kinabalu','Kota Kinabalu','Sabah',5.9804,116.0735,'https://kemlu.go.id/kotakinabalu','Pengumuman resmi TEMAN BAIK KJRI Kota Kinabalu yang disertakan','2026-08-10T00:00:00Z',true),
('kri-tawau','KRI Tawau','Tawau','Sabah Timur',4.2448,117.8912,'https://kemlu.go.id/tawau','Pengumuman dan profil resmi KRI Tawau yang disertakan','2026-08-10T00:00:00Z',true) ON CONFLICT (id) DO UPDATE SET institution=excluded.institution,city=excluded.city,region=excluded.region,latitude=excluded.latitude,longitude=excluded.longitude,official_url=excluded.official_url,source_channel=excluded.source_channel,last_checked=excluded.last_checked,active=true;
INSERT INTO public.official_contacts (id,office_id,label,display_number,e164,channel,purpose,warning,whatsapp_confirmed,active,last_checked) VALUES
('kl-protection-wa','kbri-kl','WhatsApp Perlindungan WNI','+60 17 500 7047','60175007047','WHATSAPP_CONFIRMED','Perlindungan WNI','Diverifikasi pada halaman resmi KBRI Kuala Lumpur; periksa kembali kanal resmi jika tidak tersambung.',true,true,'2026-08-17T00:00:00Z'),
('jb-pengaduan','kjri-jb','Pengaduan / Ksatria','+60 10 528 8040','60105288040','WHATSAPP_CONFIRMED','Pengaduan dan bantuan kasus',NULL,true,true,'2026-08-10T00:00:00Z'),
('penang-protection','kjri-penang','Pengaduan & Perlindungan WNI','+60 10 949 1859','60109491859','HOTLINE_MOBILE','Pengaduan dan perlindungan WNI','Sumber menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('penang-service','kjri-penang','Pelayanan KJRI Penang','+60 11 1246 0970','601112460970','HOTLINE_MOBILE','Informasi pelayanan','Sumber menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('kuching-general','kjri-kuching','Pengaduan Umum','+60 16 886 6734','60168866734','HOTLINE_MOBILE','Pengaduan umum','Poster menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('kuching-death','kjri-kuching','Kematian WNI','+60 16 889 9734','60168899734','HOTLINE_MOBILE','Bantuan kematian WNI',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-labour','kjri-kuching','Ketenagakerjaan','+60 12 880 1288','60128801288','HOTLINE_MOBILE','Masalah ketenagakerjaan',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-immigration','kjri-kuching','Imigrasi','+60 10 595 4699','60105954699','HOTLINE_MOBILE','Informasi imigrasi',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-apowakim','kjri-kuching','APOWAKIM Imigrasi','+60 10 954 6570','60109546570','WHATSAPP_CONFIRMED','Pendaftaran paspor/SPLP melalui WhatsApp resmi','Bukan nomor darurat umum; gunakan khusus layanan paspor/SPLP.',true,true,'2026-08-10T00:00:00Z'),
('kk-hotline','kjri-kk','Hotline KJRI Kota Kinabalu','+60 14 606 0067','60146060067','HOTLINE_MOBILE','Pertanyaan dan informasi lain',NULL,false,true,'2026-08-10T00:00:00Z'),
('kk-appointment','kjri-kk','TEMAN BAIK — Jadwal Temu Janji','+62 857 2030 5600','6285720305600','APPOINTMENT_ONLY','Hanya menyampaikan jadwal temu janji','Bukan hotline darurat dan bukan untuk pertanyaan umum.',false,true,'2026-08-10T00:00:00Z'),
('tawau-immigration','kri-tawau','Keimigrasian Mendesak','+60 11 1623 0800','601116230800','HOTLINE_MOBILE','Keperluan keimigrasian mendesak','Nomor dibaca dari poster resmi yang disertakan; verifikasi kembali pada kanal resmi.',false,true,'2026-08-10T00:00:00Z'),
('tawau-consular','kri-tawau','Kekonsuleran Mendesak','+60 19 822 6800','60198226800','HOTLINE_MOBILE','Keperluan kekonsuleran mendesak',NULL,false,true,'2026-08-10T00:00:00Z'),
('tawau-office','kri-tawau','Telepon Kantor','+60 89 772 052','6089772052','PHONE','Kontak kantor KRI Tawau',NULL,false,true,'2026-08-10T00:00:00Z') ON CONFLICT (id) DO UPDATE SET label=excluded.label,display_number=excluded.display_number,e164=excluded.e164,channel=excluded.channel,purpose=excluded.purpose,warning=excluded.warning,whatsapp_confirmed=excluded.whatsapp_confirmed,active=true,last_checked=excluded.last_checked;
INSERT INTO public.official_evidence (office_id,institution,evidence_type,file_path,captured_at,verification_status,extracted_data) VALUES
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.34.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.34.jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35 (1).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35 (3).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35 (3).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35.jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.36 (2).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.36 (2).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.36.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.36.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.06.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.06.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.07 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.07 (1).jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.07.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.07.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.08 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.08 (1).jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.08.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.08.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.09.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.09.jpeg"}'::jsonb),
('kbri-kl','KBRI Kuala Lumpur','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.05.36.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.05.36.jpeg"}'::jsonb),
('kbri-kl','KBRI Kuala Lumpur','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.05.37.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.05.37.jpeg"}'::jsonb),
('kjri-jb','KJRI Johor Bahru','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.18.01.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.18.01.jpeg"}'::jsonb),
('kjri-jb','KJRI Johor Bahru','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.18.02.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.18.02.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.08.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.08.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.09.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.09.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.10.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.10.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.59.31.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.59.31.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.53 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.53 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.53.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.53.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54 (2).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54 (2).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.55.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.55.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.56 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.56 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.56.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.56.jpeg"}'::jsonb) ON CONFLICT (file_path) DO UPDATE SET office_id=excluded.office_id,institution=excluded.institution,evidence_type=excluded.evidence_type,captured_at=excluded.captured_at,verification_status=excluded.verification_status,extracted_data=excluded.extracted_data,updated_at=now();

COMMIT;
