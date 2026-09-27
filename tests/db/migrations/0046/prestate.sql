-- 0046 prestate: accepted 0045 News editorial schema is present before 0046.
SELECT to_regclass('public.official_news_stories') IS NOT NULL AS official_news_stories_exists;
SELECT to_regclass('public.official_news_story_source_references') IS NOT NULL AS source_references_exist;
SELECT to_regclass('public.official_news_events') IS NOT NULL AS news_events_exist;
