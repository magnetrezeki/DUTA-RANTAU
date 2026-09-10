-- Day 8H: additive marketplace compliance foundation. No legacy seller or listing is approved, deleted, or unpublished.
DO $$ BEGIN CREATE TYPE public.marketplace_risk_tier AS ENUM ('GREEN','YELLOW','RED'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint
DO $$ BEGIN CREATE TYPE public.marketplace_compliance_review_status AS ENUM ('not_required','pending','approved','rejected','not_applicable'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
--> statement-breakpoint

ALTER TABLE public.products ADD COLUMN IF NOT EXISTS seller_entity_id uuid REFERENCES public.entities(id);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS risk_tier public.marketplace_risk_tier;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS commercial_eligibility_snapshot text;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS compliance_review_status public.marketplace_compliance_review_status;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS published_at timestamptz;
CREATE INDEX IF NOT EXISTS products_seller_entity_idx ON public.products(seller_entity_id,status);
--> statement-breakpoint

-- Category risk is platform policy, never seller input. This intentionally small map is not a legal catalogue.
CREATE OR REPLACE FUNCTION public.enforce_marketplace_product_compliance()
RETURNS trigger LANGUAGE plpgsql AS $$
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
DROP TRIGGER IF EXISTS products_marketplace_compliance ON public.products;
CREATE TRIGGER products_marketplace_compliance
BEFORE INSERT OR UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.enforce_marketplace_product_compliance();
--> statement-breakpoint

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- These narrow reads let the runtime inspect only the actor's own seller/entity authority.
DROP POLICY IF EXISTS sellers_marketplace_entity_read ON public.sellers;
CREATE POLICY sellers_marketplace_entity_read ON public.sellers
FOR SELECT TO duta_app
USING (
  entity_id IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.entities e WHERE e.id=sellers.entity_id
      AND (e.owner_user_id=public.current_app_user_id()
        OR (sellers.organization_id IS NOT NULL AND public.current_app_has_org_role(sellers.organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])))
  )
);
DROP POLICY IF EXISTS entities_marketplace_actor_read ON public.entities;
CREATE POLICY entities_marketplace_actor_read ON public.entities
FOR SELECT TO duta_app
USING (
  owner_user_id=public.current_app_user_id()
  OR EXISTS (SELECT 1 FROM public.organizations o WHERE o.entity_id=entities.id AND public.current_app_has_org_role(o.id,ARRAY['OWNER','ADMIN']::public.organization_role[]))
);
DROP POLICY IF EXISTS organization_members_marketplace_authority_read ON public.organization_members;
CREATE POLICY organization_members_marketplace_authority_read ON public.organization_members
FOR SELECT TO duta_app
USING (user_id=public.current_app_user_id());
DROP POLICY IF EXISTS entity_eligibility_marketplace_actor_read ON public.entity_eligibilities;
CREATE POLICY entity_eligibility_marketplace_actor_read ON public.entity_eligibilities
FOR SELECT TO duta_app
USING (
  EXISTS (SELECT 1 FROM public.entities e WHERE e.id=entity_id AND e.owner_user_id=public.current_app_user_id())
  OR EXISTS (SELECT 1 FROM public.organizations o WHERE o.entity_id=entity_id AND public.current_app_has_org_role(o.id,ARRAY['OWNER','ADMIN']::public.organization_role[]))
);
GRANT SELECT ON public.sellers, public.entities, public.organization_members, public.entity_eligibilities TO duta_app;
DROP POLICY IF EXISTS products_admin_all ON public.products;
DROP POLICY IF EXISTS products_seller ON public.products;
DROP POLICY IF EXISTS products_marketplace_entity_write ON public.products;

-- A runtime actor may manage only a seller attached to an entity they own or administer.
CREATE POLICY products_marketplace_entity_write ON public.products
FOR ALL TO duta_app
USING (
  EXISTS (
    SELECT 1 FROM public.sellers s JOIN public.entities e ON e.id=s.entity_id
    WHERE s.id=products.seller_id AND s.entity_id=products.seller_entity_id
      AND (e.owner_user_id=public.current_app_user_id()
        OR (s.organization_id IS NOT NULL AND public.current_app_has_org_role(s.organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])))
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.sellers s JOIN public.entities e ON e.id=s.entity_id
    WHERE s.id=products.seller_id AND s.entity_id=products.seller_entity_id
      AND (e.owner_user_id=public.current_app_user_id()
        OR (s.organization_id IS NOT NULL AND public.current_app_has_org_role(s.organization_id,ARRAY['OWNER','ADMIN']::public.organization_role[])))
  )
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.products TO duta_app;