DO $$ BEGIN CREATE TYPE public.presence_status AS ENUM ('pending','verified','failed','expired','revoked'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.presence_method AS ENUM ('malaysian_phone','device_location','manual_review','provider_assertion'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.responsible_person_status AS ENUM ('pending','active','inactive','revoked'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS public.user_presence_checks (id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,country_code text NOT NULL,status public.presence_status NOT NULL DEFAULT 'pending',method public.presence_method NOT NULL,checked_at timestamptz,expires_at timestamptz,created_at timestamptz NOT NULL DEFAULT now(),updated_at timestamptz NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS presence_user_idx ON public.user_presence_checks(user_id,status);
CREATE INDEX IF NOT EXISTS presence_expiry_idx ON public.user_presence_checks(expires_at);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS public.entity_responsible_persons (id uuid PRIMARY KEY DEFAULT gen_random_uuid(),entity_id uuid NOT NULL REFERENCES public.entities(id) ON DELETE CASCADE,user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,role text NOT NULL,status public.responsible_person_status NOT NULL DEFAULT 'pending',is_primary boolean NOT NULL DEFAULT false,appointed_at timestamptz,ended_at timestamptz,created_at timestamptz NOT NULL DEFAULT now(),updated_at timestamptz NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS responsible_entity_idx ON public.entity_responsible_persons(entity_id,status);
CREATE INDEX IF NOT EXISTS responsible_user_idx ON public.entity_responsible_persons(user_id,status);
CREATE UNIQUE INDEX IF NOT EXISTS responsible_primary_active_uq ON public.entity_responsible_persons(entity_id) WHERE is_primary = true AND status = 'active';
--> statement-breakpoint
ALTER TABLE public.user_presence_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_responsible_persons ENABLE ROW LEVEL SECURITY;
CREATE POLICY presence_self_read ON public.user_presence_checks FOR SELECT TO authenticated USING (user_id=auth.uid() OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY responsible_read ON public.entity_responsible_persons FOR SELECT TO authenticated USING (user_id=auth.uid() OR EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
CREATE POLICY responsible_owner_manage ON public.entity_responsible_persons FOR ALL TO authenticated USING (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (EXISTS(SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=auth.uid()) OR public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]));
GRANT SELECT ON public.user_presence_checks TO duta_app;
GRANT SELECT, INSERT, UPDATE ON public.entity_responsible_persons TO duta_app;
