-- 0046 poststate: public contract objects and slug column are present.
SELECT EXISTS (
  SELECT 1 FROM information_schema.columns
  WHERE table_schema='public' AND table_name='official_news_stories'
    AND column_name='public_slug' AND data_type='text'
) AS public_slug_exists;
SELECT to_regclass('public.official_news_public_stories') IS NOT NULL AS public_projection_exists;
SELECT to_regprocedure('public.assign_official_news_public_slug(uuid,text)') IS NOT NULL AS governed_assignment_exists;
