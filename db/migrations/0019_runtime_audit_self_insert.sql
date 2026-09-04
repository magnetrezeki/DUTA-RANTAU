CREATE POLICY audit_logs_self_insert
ON public.audit_logs
FOR INSERT
TO duta_app
WITH CHECK (
  actor_id = public.current_app_user_id()
);
