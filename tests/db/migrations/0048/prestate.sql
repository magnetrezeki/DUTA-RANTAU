DO $$ DECLARE n integer; BEGIN
 IF to_regclass('public.jobs') IS NULL OR to_regclass('public.entities') IS NULL THEN RAISE EXCEPTION '0048 prestate relations missing'; END IF;
 SELECT count(*) INTO n FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attnum>0 AND NOT attisdropped;
 IF n<>17 THEN RAISE EXCEPTION '0048 prestate jobs columns %, expected 17',n; END IF;
 IF EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attname IN ('employer_entity_id','posting_kind','employer_eligibility_snapshot','published_at') AND NOT attisdropped) THEN RAISE EXCEPTION '0048 prestate reconciliation column exists'; END IF;
 IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.jobs'::regclass AND conname='jobs_employer_entity_id_fkey') OR EXISTS (SELECT 1 FROM pg_class WHERE relname='jobs_employer_entity_idx' AND relnamespace='public'::regnamespace) THEN RAISE EXCEPTION '0048 prestate structural object exists'; END IF;
END $$;
