DO $$
BEGIN
  IF to_regclass('public.users') IS NULL THEN
    RAISE EXCEPTION '0049 prestate failed: public.users missing';
  END IF;

  IF to_regtype('public.record_status') IS NULL THEN
    RAISE EXCEPTION '0049 prestate failed: public.record_status missing';
  END IF;

  IF to_regclass('public.entities') IS NOT NULL THEN
    RAISE EXCEPTION '0049 prestate failed: public.entities already exists';
  END IF;

  IF to_regtype('public.entity_type') IS NOT NULL THEN
    RAISE EXCEPTION '0049 prestate failed: public.entity_type already exists';
  END IF;

  IF to_regtype('public.legal_status') IS NOT NULL THEN
    RAISE EXCEPTION '0049 prestate failed: public.legal_status already exists';
  END IF;
END
$$;
