BEGIN;

GRANT SELECT ON TABLE public.jobs TO duta_app;
GRANT SELECT ON TABLE public.products TO duta_app;
GRANT SELECT ON TABLE public.communities TO duta_app;

DROP POLICY IF EXISTS jobs_public ON public.jobs;
CREATE POLICY jobs_public
ON public.jobs
FOR SELECT
TO anon, authenticated, duta_app
USING (
  status = 'ACTIVE'
  OR owner_id = auth.uid()
);

DROP POLICY IF EXISTS products_public ON public.products;
CREATE POLICY products_public
ON public.products
FOR SELECT
TO anon, authenticated, duta_app
USING (
  status = 'ACTIVE'
  OR EXISTS (
    SELECT 1
    FROM public.sellers s
    WHERE s.id = products.seller_id
      AND s.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS communities_public ON public.communities;
CREATE POLICY communities_public
ON public.communities
FOR SELECT
TO anon, authenticated, duta_app
USING (
  (visibility = 'PUBLIC' AND status = 'ACTIVE')
  OR owner_id = auth.uid()
  OR public.has_system_role(
    ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]
  )
);

COMMIT;
