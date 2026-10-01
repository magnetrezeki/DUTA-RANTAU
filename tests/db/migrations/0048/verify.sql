DO $$ DECLARE n integer; t text; BEGIN
 SELECT count(*) INTO n FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attnum>0 AND NOT attisdropped; IF n<>21 THEN RAISE EXCEPTION '0048 poststate columns %, expected 21',n; END IF;
 FOREACH t IN ARRAY ARRAY['employer_entity_id','posting_kind','employer_eligibility_snapshot','published_at'] LOOP IF NOT EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attname=t AND NOT attnotnull AND NOT attisdropped) THEN RAISE EXCEPTION '0048 column contract failed %',t; END IF; END LOOP;
 IF (SELECT format_type(atttypid,atttypmod) FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attname='employer_entity_id')<>'uuid' OR (SELECT format_type(atttypid,atttypmod) FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attname='published_at')<>'timestamp with time zone' THEN RAISE EXCEPTION '0048 type contract failed'; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.jobs'::regclass AND conname='jobs_employer_entity_id_fkey' AND pg_get_constraintdef(oid,true)='FOREIGN KEY (employer_entity_id) REFERENCES entities(id)') THEN RAISE EXCEPTION '0048 FK contract failed'; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_index WHERE indexrelid='public.jobs_employer_entity_idx'::regclass AND indisvalid AND indisready) THEN RAISE EXCEPTION '0048 index contract failed'; END IF;
END $$;
