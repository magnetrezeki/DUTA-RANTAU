DO $$
DECLARE
  column_count integer;
BEGIN
  IF to_regtype('public.entity_type') IS NULL THEN
    RAISE EXCEPTION '0049 verification failed: public.entity_type missing';
  END IF;

  IF to_regtype('public.legal_status') IS NULL THEN
    RAISE EXCEPTION '0049 verification failed: public.legal_status missing';
  END IF;

  IF to_regclass('public.entities') IS NULL THEN
    RAISE EXCEPTION '0049 verification failed: public.entities missing';
  END IF;

  SELECT count(*)
    INTO column_count
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'entities';

  IF column_count <> 16 THEN
    RAISE EXCEPTION
      '0049 verification failed: expected 16 entities columns, found %',
      column_count;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'entities'
      AND indexname = 'entities_pkey'
  ) THEN
    RAISE EXCEPTION '0049 verification failed: entities_pkey missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'entities'
      AND indexname = 'entities_slug_uq'
  ) THEN
    RAISE EXCEPTION '0049 verification failed: entities_slug_uq missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'entities'
      AND indexname = 'entities_type_idx'
  ) THEN
    RAISE EXCEPTION '0049 verification failed: entities_type_idx missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'entities'
      AND indexname = 'entities_owner_idx'
  ) THEN
    RAISE EXCEPTION '0049 verification failed: entities_owner_idx missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'entities'
      AND indexname = 'entities_legal_status_idx'
  ) THEN
    RAISE EXCEPTION '0049 verification failed: entities_legal_status_idx missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.entities'::regclass
      AND conname = 'entities_legal_verified_requires_claim'
      AND contype = 'c'
  ) THEN
    RAISE EXCEPTION
      '0049 verification failed: entities legal verification check missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.entities'::regclass
      AND conname = 'entities_owner_user_id_fkey'
      AND contype = 'f'
  ) THEN
    RAISE EXCEPTION
      '0049 verification failed: owner_user_id foreign key missing';
  END IF;
END
$$;
