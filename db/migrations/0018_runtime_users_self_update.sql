GRANT UPDATE (
  name,
  city,
  state,
  hometown,
  profession,
  interests,
  profile_visibility,
  location_visibility,
  updated_at
)
ON TABLE public.users
TO duta_app;

DROP POLICY IF EXISTS users_runtime_update
ON public.users;

CREATE POLICY users_runtime_update
ON public.users
FOR UPDATE
TO duta_app
USING (
  id = public.current_app_user_id()
)
WITH CHECK (
  id = public.current_app_user_id()
);
