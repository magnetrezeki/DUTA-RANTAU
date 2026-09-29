\set ON_ERROR_STOP on
DO $$ DECLARE target regprocedure := 'public.transition_official_news_story(uuid,public.official_news_event_type)'::regprocedure; BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_roles owner ON owner.oid=p.proowner WHERE p.oid=target AND p.prosecdef AND owner.rolname='postgres') THEN RAISE EXCEPTION 'accepted 0045 security-definer contract changed'; END IF;
  IF has_function_privilege('anon', target, 'EXECUTE') OR has_function_privilege('authenticated', target, 'EXECUTE') THEN RAISE EXCEPTION 'public transition execute remains'; END IF;
END $$;
