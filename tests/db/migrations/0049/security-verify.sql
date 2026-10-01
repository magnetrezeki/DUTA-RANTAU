DO $$
BEGIN
  IF to_regclass('public.entities') IS NULL THEN
    RAISE EXCEPTION '0049 security verification failed: public.entities missing';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_class
    WHERE oid = 'public.entities'::regclass
      AND relrowsecurity
  ) THEN
    RAISE EXCEPTION
      '0049 security verification failed: migration unexpectedly enabled RLS';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM pg_policy
    WHERE polrelid = 'public.entities'::regclass
  ) THEN
    RAISE EXCEPTION
      '0049 security verification failed: migration unexpectedly created policies';
  END IF;
END
$$;
