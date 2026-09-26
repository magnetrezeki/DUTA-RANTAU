-- LOCAL/DISPOSABLE DATABASE ONLY. Run after 0045.
\set ON_ERROR_STOP on
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname='official_news_stories') THEN RAISE EXCEPTION 'News stories table missing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='official_news_stories' AND policyname='official_news_stories_public_read') THEN RAISE EXCEPTION 'public News visibility policy missing'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='official_news_search_idx') THEN RAISE EXCEPTION 'null-safe News search index missing'; END IF;
END $$;
