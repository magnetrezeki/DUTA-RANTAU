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
--> statement-breakpoint
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
--> statement-breakpoint
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
--> statement-breakpoint
ALTER TABLE "official_contacts" ADD CONSTRAINT "official_contacts_office_id_official_offices_id_fk" FOREIGN KEY ("office_id") REFERENCES "public"."official_offices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "official_evidence" ADD CONSTRAINT "official_evidence_office_id_official_offices_id_fk" FOREIGN KEY ("office_id") REFERENCES "public"."official_offices"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "official_contact_office_idx" ON "official_contacts" USING btree ("office_id","active");--> statement-breakpoint
CREATE UNIQUE INDEX "official_evidence_path_uq" ON "official_evidence" USING btree ("file_path");--> statement-breakpoint
CREATE INDEX "official_evidence_office_idx" ON "official_evidence" USING btree ("office_id","evidence_type");