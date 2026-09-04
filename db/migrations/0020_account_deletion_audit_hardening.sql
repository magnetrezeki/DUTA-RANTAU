BEGIN;

ALTER TABLE public.audit_logs
  DROP CONSTRAINT IF EXISTS audit_logs_actor_id_users_id_fk;

ALTER TABLE public.audit_logs
  ADD CONSTRAINT audit_logs_actor_id_users_id_fk
  FOREIGN KEY (actor_id)
  REFERENCES public.users(id)
  ON DELETE SET NULL;

DROP POLICY IF EXISTS audit_user_insert
ON public.audit_logs;

CREATE POLICY audit_user_insert
ON public.audit_logs
FOR INSERT
TO duta_app
WITH CHECK (
  actor_id = public.current_app_user_id()
  AND action IN (
    'profile_update',
    'source_change',
    'organization.create',
    'organization.application_submitted',
    'organization.reviewed',
    'publication.create_draft',
    'secretary.create_draft',
    'meeting.audio_transcribed',
    'member.phone_verified',
    'member.location_verified',
    'member.location_manual_review',
    'member.selfie_uploaded',
    'member.reviewed',
    'content_admin_create',
    'content_admin_update',
    'content_admin_delete',
    'account_deletion'
  )
);

COMMIT;
