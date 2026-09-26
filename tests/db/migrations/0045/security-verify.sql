\set ON_ERROR_STOP on
-- Synthetic runtime proof: duta_app is the only application database role.
INSERT INTO public.users(id,role) VALUES
 ('10000000-0000-4000-8000-000000000001','EDITOR'),('10000000-0000-4000-8000-000000000002','MODERATOR'),('10000000-0000-4000-8000-000000000003','USER'),('10000000-0000-4000-8000-000000000004','EDITOR');
INSERT INTO public.official_sources(id,institution,channel,url,category,priority,source_purpose,active) VALUES
 ('20000000-0000-4000-8000-000000000001','Synthetic','INSTAGRAM','https://instagram.com/synthetic','news','P1','NEWS',true),
 ('20000000-0000-4000-8000-000000000002','Inactive','INSTAGRAM','https://instagram.com/inactive','news','P1','NEWS',false),
 ('20000000-0000-4000-8000-000000000003','Service','WEBSITE','https://example.test','service','P0','CONSULAR_SERVICE',true);
INSERT INTO public.official_news_stories(id,display_title,concise_summary,what_text,five_w_context,content_type,canonical_official_source_id,canonical_url,created_by,review_state,publication_state,correction_state,published_by,published_at) VALUES
 ('30000000-0000-4000-8000-000000000001','Current','Summary','What','{"version":1,"who":{"state":"NOT_STATED"},"where":{"state":"NOT_STATED"},"when":{"state":"NOT_STATED"},"why":{"state":"NOT_STATED"}}','NOTICE','20000000-0000-4000-8000-000000000001','https://instagram.com/p/current','10000000-0000-4000-8000-000000000001','VERIFIED_BY_EDITOR','PUBLISHED','CURRENT','10000000-0000-4000-8000-000000000001',now()),
 ('30000000-0000-4000-8000-000000000002','Draft','Summary','What','{"version":1,"who":{"state":"NOT_STATED"},"where":{"state":"NOT_STATED"},"when":{"state":"NOT_STATED"},"why":{"state":"NOT_STATED"}}','NOTICE','20000000-0000-4000-8000-000000000001','https://instagram.com/p/draft','10000000-0000-4000-8000-000000000001','DRAFT','DRAFT','CURRENT',NULL,NULL);
INSERT INTO public.official_news_story_source_references(story_id,official_source_id,original_url,canonical_url,created_by,intake_idempotency_key) VALUES('30000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001','https://instagram.com/p/current','https://instagram.com/p/current','10000000-0000-4000-8000-000000000001','40000000-0000-4000-8000-000000000001');
BEGIN; SET LOCAL ROLE duta_app;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.official_news_stories)<>1 THEN RAISE EXCEPTION 'public RLS visibility invariant failed'; END IF;
 IF (SELECT count(*) FROM public.official_news_story_source_references)<>1 THEN RAISE EXCEPTION 'public source-reference RLS failed'; END IF;
 IF has_table_privilege('duta_app','public.official_news_events','UPDATE') OR has_table_privilege('duta_app','public.official_news_events','DELETE') THEN RAISE EXCEPTION 'audit mutability grant'; END IF;
END $$;
ROLLBACK;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace CROSS JOIN LATERAL unnest(p.proconfig) cfg WHERE n.nspname='public' AND p.proname='transition_official_news_story' AND p.prosecdef AND cfg IN ('search_path=','search_path=""')) THEN RAISE EXCEPTION 'security definer metadata failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_indexes WHERE indexname='official_news_search_idx') THEN RAISE EXCEPTION 'search index missing'; END IF;
END $$;
SELECT '0045_RUNTIME_SECURITY=PASS';
