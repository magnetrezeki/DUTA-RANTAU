BEGIN;

CREATE POLICY users_runtime_select
ON public.users
FOR SELECT
TO duta_app
USING (id = public.current_app_user_id());

COMMIT;
