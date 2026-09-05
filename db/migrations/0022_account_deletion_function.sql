BEGIN;

CREATE OR REPLACE FUNCTION public.delete_current_app_user()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  target_id uuid;
  deleted_count integer;
BEGIN
  target_id := public.current_app_user_id();

  IF target_id IS NULL THEN
    RAISE EXCEPTION 'Application identity is required';
  END IF;

  DELETE FROM public.users
  WHERE id = target_id;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  RETURN deleted_count = 1;
END;
$function$;

REVOKE ALL
ON FUNCTION public.delete_current_app_user()
FROM PUBLIC, anon, authenticated, service_role, duta_system;

GRANT EXECUTE
ON FUNCTION public.delete_current_app_user()
TO duta_app;

COMMIT;
