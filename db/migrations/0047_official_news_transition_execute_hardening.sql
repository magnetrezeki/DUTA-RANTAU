-- 0047: Restrict the News workflow transition entry point to the application role.
BEGIN;

REVOKE EXECUTE ON FUNCTION public.transition_official_news_story(uuid, public.official_news_event_type) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.transition_official_news_story(uuid, public.official_news_event_type) FROM anon;
REVOKE EXECUTE ON FUNCTION public.transition_official_news_story(uuid, public.official_news_event_type) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.transition_official_news_story(uuid, public.official_news_event_type) TO duta_app;

COMMIT;
