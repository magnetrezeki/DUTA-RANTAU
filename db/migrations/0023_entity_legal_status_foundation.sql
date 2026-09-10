-- Additive Day 8B entity foundation. Legal claims are deliberately separate from verified facts.
DO $$ BEGIN CREATE TYPE public.entity_type AS ENUM ('business','community','organisation'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.legal_status AS ENUM ('registered','registered_under_other_law','foreign_registered','registration_pending','registration_not_verified','informal_group','unknown'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS public.entities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), entity_type public.entity_type NOT NULL, display_name text NOT NULL, slug text NOT NULL,
  owner_user_id uuid REFERENCES public.users(id), record_status public.record_status NOT NULL DEFAULT 'PENDING',
  legal_status public.legal_status NOT NULL DEFAULT 'unknown', legal_status_claim public.legal_status, legal_status_verified public.legal_status,
  registration_authority text, registration_type text, registration_number text, jurisdiction text, operating_country text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT entities_legal_verified_requires_claim CHECK (legal_status_verified IS NULL OR legal_status_claim IS NOT NULL)
);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS entities_slug_uq ON public.entities(slug);
CREATE INDEX IF NOT EXISTS entities_type_idx ON public.entities(entity_type);
CREATE INDEX IF NOT EXISTS entities_owner_idx ON public.entities(owner_user_id);
CREATE INDEX IF NOT EXISTS entities_legal_status_idx ON public.entities(legal_status);
--> statement-breakpoint
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS entity_id uuid REFERENCES public.entities(id);
ALTER TABLE public.communities ADD COLUMN IF NOT EXISTS entity_id uuid REFERENCES public.entities(id);
ALTER TABLE public.sellers ADD COLUMN IF NOT EXISTS entity_id uuid REFERENCES public.entities(id);
CREATE UNIQUE INDEX IF NOT EXISTS organizations_entity_uq ON public.organizations(entity_id) WHERE entity_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS communities_entity_uq ON public.communities(entity_id) WHERE entity_id IS NOT NULL;
--> statement-breakpoint
INSERT INTO public.entities (entity_type,display_name,slug,owner_user_id,record_status,legal_status)
SELECT 'organisation',o.name,'organisation-' || o.id::text,(SELECT m.user_id FROM public.organization_members m WHERE m.organization_id=o.id AND m.role='OWNER' ORDER BY m.joined_at LIMIT 1),o.record_status,'registration_not_verified'
FROM public.organizations o WHERE o.entity_id IS NULL
ON CONFLICT (slug) DO NOTHING;
UPDATE public.organizations o SET entity_id=e.id FROM public.entities e WHERE o.entity_id IS NULL AND e.slug='organisation-' || o.id::text;
INSERT INTO public.entities (entity_type,display_name,slug,owner_user_id,record_status,legal_status)
SELECT 'community',c.name,'community-' || c.id::text,c.owner_id,c.record_status,'informal_group'
FROM public.communities c WHERE c.entity_id IS NULL
ON CONFLICT (slug) DO NOTHING;
UPDATE public.communities c SET entity_id=e.id FROM public.entities e WHERE c.entity_id IS NULL AND e.slug='community-' || c.id::text;
--> statement-breakpoint
ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;
CREATE POLICY entities_public_read ON public.entities FOR SELECT TO anon,authenticated USING (record_status='ACTIVE' OR owner_user_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY entities_owner_insert ON public.entities FOR INSERT TO authenticated WITH CHECK (owner_user_id=auth.uid() AND legal_status_verified IS NULL);
CREATE POLICY entities_owner_update ON public.entities FOR UPDATE TO authenticated USING (owner_user_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (owner_user_id=auth.uid() AND legal_status_verified IS NULL OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
GRANT SELECT, INSERT, UPDATE ON public.entities TO duta_app;
