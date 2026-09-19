-- 0041: Audit-write privilege reconciliation for the application runtime role
--
-- DEFECT (pre-existing; predates the identity-bridge remediation and RC-3):
--   0008 creates audit_user_insert            FOR INSERT TO duta_app
--   0009 creates audit_logs_content_admin     FOR INSERT TO duta_app
--   0020 re-creates audit_user_insert         FOR INSERT TO duta_app
--   0038 section E states, verbatim, that "duta_app audit inserts (including
--        'account_deletion' and 'content_admin_archive') are already covered
--        by the chain".
--
--   They are not. No migration in the chain issues
--   GRANT INSERT ON public.audit_logs TO duta_app. 0038 section F grants
--   audit_logs INSERT to duta_system only.
--
--   A permissive policy without the underlying table privilege is inert: the
--   privilege check runs before RLS is evaluated, so every duta_app audit
--   insert fails with 42501 "permission denied for table audit_logs" and the
--   two governed policies can never decide. Verified on a disposable
--   PostgreSQL instance loaded with the real governed migration set:
--   without this grant, audit writes fail at the GRANT layer; with it, the
--   same write succeeds for a valid actor and is RLS-denied for a missing or
--   mismatched actor.
--
-- SCOPE:
--   Grants ONLY the privilege that the chain's existing policies already
--   authorize. No policy is created, altered, or dropped. No row requirement
--   is relaxed: audit_user_insert still requires
--   actor_id = current_app_user_id() AND action IN (<governed allowlist>),
--   and audit_logs_content_admin still requires an admin actor. RLS remains
--   the deciding layer. No SELECT, UPDATE, DELETE, or TRUNCATE is granted.
--
-- FORWARD-ONLY. No historical migration is rewritten.
-- Not applied to any shared, staging, or Production database.

BEGIN;

GRANT INSERT ON public.audit_logs TO duta_app;

COMMIT;
