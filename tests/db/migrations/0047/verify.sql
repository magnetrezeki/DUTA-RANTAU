\set ON_ERROR_STOP on
DO $$ BEGIN
  IF NOT has_function_privilege('duta_app', 'public.transition_official_news_story(uuid,public.official_news_event_type)', 'EXECUTE') THEN RAISE EXCEPTION 'duta_app transition execute missing'; END IF;
  IF has_function_privilege('anon', 'public.transition_official_news_story(uuid,public.official_news_event_type)', 'EXECUTE') OR has_function_privilege('authenticated', 'public.transition_official_news_story(uuid,public.official_news_event_type)', 'EXECUTE') THEN RAISE EXCEPTION 'public API role transition execute remains'; END IF;
END $$;
