-- 0038: Core runtime RLS enforcement for fresh bootstrap (POST-8L-H2B).
--
-- SECURITY PURPOSE:
--   The canonical chain 0000-0037 enables ROW LEVEL SECURITY only on the
--   0023-0033 foundation tables. Every other application table (users,
--   official_sources, audit_logs, organizations, organization_members,
--   sellers, sessions, payments, ...) is left RLS-off, while Supabase's
--   default privileges grant anon/authenticated/service_role broad
--   table privileges. On a fresh Option-B bootstrap (no legacy db/rls.sql
--   layer) that leaves core application data readable and writable by
--   anonymous clients (PROVEN in the H2A disposable replay, including
--   users.email/phone/password_hash and audit_logs forgery).
--
--   This migration closes that gap with the runtime identity model:
--   A. ENABLE ROW LEVEL SECURITY on every remaining core application table
--      (default-deny: a table with RLS on and no policy admits no rows for
--      that role).
--   B. Preserves every policy created by earlier migrations (none dropped,
--      none altered).
--   C. Adds only the narrow policies the current application demonstrably
--      requires (server-side paths in app/lib code and the products_public
--      cross-table reference in 0016). Follows the scoping conventions
--      established by 0008/0009 (admin role scope + archival trigger),
--      0011 (identity functions), and 0028 (actor-scoped duta_app reads).
--      NOTE: 0009 already provides organizations_runtime_select (admin
--      duta_app read), organizations_admin_insert (USER_GENERATED creation),
--      organizations_admin_update (admin update with ACTIVE/verification
--      guard), the protect_organization_archival trigger, and
--      audit_logs_content_admin (admin audit inserts). This migration does
--      NOT re-create or alter any of those.
--   D. Adds NO legacy db/rls.sql policy, NO anon/authenticated/service_role
--      table grant, NO broad grant, NO FORCE ROW LEVEL SECURITY, NO
--      BYPASSRLS. It does add the minimal table grants (Section F) required
--      to make the new policies and the documented application paths
--      functional: 0010 intentionally starts the application roles with no
--      table privileges ("least-privilege grants are added only after
--      runtime call-sites have been audited"), following the same
--      policy+grant pattern 0028 uses for the marketplace read path.
--
-- FORCE RLS DECISION (H2B.9):
--   Not used. All application tables are owned by the migration/admin role
--   (postgres), which must retain the owner bypass for DDL and for the
--   SECURITY DEFINER functions (delete_current_app_user, protect_*). No
--   application role (duta_app/duta_system) owns any table and none has
--   BYPASSRLS, so ordinary ENABLE ROW LEVEL SECURITY is sufficient.
--
-- TABLES INTENTIONALLY LEFT WITH NO NEW POLICY (default deny; the legacy
-- client paths are superseded by the runtime model and no current app code
-- path requires them — report product paths for later explicit policies):
--   ai_conversations, contents, memberships, payments, notifications,
--   official_offices, official_contacts, official_evidence,
--   organization_finances, organization_meetings, organization_letters,
--   organization_payments, organization_permissions, organization_branches,
--   organization_attendance, organization_tasks, publication_templates,
--   reports, sessions (sessions: same model as the legacy file documented,
--   "retained for migration compatibility but denied to client roles").
--
-- NON-ACTIVE ORGANIZATION VISIBILITY:
--   0009's organizations_runtime_select covers duta_app reads only under an
--   ORG_ADMIN/SUPER_ADMIN transaction context. The public organization
--   pages read organizations server-side without such a context, so
--   organizations_runtime_read (this migration) exposes ACTIVE
--   (public) organizations to the server role only. Non-active orgs
--   remain server-admin and owner paths only.

BEGIN;

-- ---------------------------------------------------------------------------
-- A. Enable RLS on every core application table the chain left unprotected.
-- ---------------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meeting_transcripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_offices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_finances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.publication_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- B. Client-visible policy (the only new anon/authenticated exposure).
-- ---------------------------------------------------------------------------
-- 0016's products_public policy (TO anon, authenticated, duta_app)
-- references sellers.user_id in a cross-table EXISTS. Under RLS that
-- reference is subject to sellers' own RLS, so the store-directory rows must
-- be visible under the same expression the runtime products flow assumes.
-- The expression is identical to the historical sellers_public scope
-- (staging parity, not a new exposure; the sellers table carries no
-- sensitive columns: id, user_id, organization_id, name, description,
-- trust_level, status, timestamps).
CREATE POLICY sellers_public_read ON public.sellers
FOR SELECT TO anon, authenticated, duta_app
USING (status = 'ACTIVE' OR user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- C. Server-side (duta_app) read policies required by current app code.
-- ---------------------------------------------------------------------------
-- Public organization pages read organizations server-side as duta_app
-- without an admin transaction context (0009's organizations_runtime_select
-- requires ORG_ADMIN/SUPER_ADMIN). Expose ACTIVE (public) organizations to
-- the server role only; no client role is granted anything here.
CREATE POLICY organizations_runtime_read ON public.organizations
FOR SELECT TO duta_app
USING (status = 'ACTIVE'::public.record_status);

-- Organization access decisions (lib/services/organization-access) look up
-- explicit member/subscription rows after application authorization, so
-- these are server-role-only reads.
CREATE POLICY organization_members_runtime_read ON public.organization_members
FOR SELECT TO duta_app
USING (true);

CREATE POLICY organization_subscriptions_runtime_read ON public.organization_subscriptions
FOR SELECT TO duta_app
USING (true);

-- ---------------------------------------------------------------------------
-- D. Server-side (duta_app) organization-feature writes, following the 0028
--    actor-scoped convention and the 0011 identity functions.
-- ---------------------------------------------------------------------------
-- Secretary document generation (app/api/organizations/[id]/secretary/generate
-- inserts organization_documents with author_id = the verified actor).
CREATE POLICY organization_documents_runtime ON public.organization_documents
FOR ALL TO duta_app
USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]))
WITH CHECK (public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));

-- Secretary publication drafts (inserts publication_projects with
-- created_by = the verified actor; legacy publication_project_* scope).
CREATE POLICY publication_projects_runtime ON public.publication_projects
FOR ALL TO duta_app
USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]))
WITH CHECK (created_by = public.current_app_user_id()
  AND public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY','STAFF']::public.organization_role[]));

-- Meeting transcription (inserts meeting_transcripts with created_by = the
-- verified actor; consent requirement preserved from the historical scope).
CREATE POLICY meeting_transcripts_runtime ON public.meeting_transcripts
FOR ALL TO duta_app
USING (public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]))
WITH CHECK (created_by = public.current_app_user_id()
  AND consent_confirmed = true
  AND public.current_app_has_org_role(organization_id, ARRAY['OWNER','ADMIN','SECRETARY']::public.organization_role[]));

-- ---------------------------------------------------------------------------
-- E. Audit write coverage for the one current app path no existing policy
--    covers: security audit events written by the system role. Without it,
--    the RLS activation would silently drop live audit events (login
--    attempts, admin denials, moderation decisions, role changes).
--    NOTE: duta_app audit inserts (including 'account_deletion' and
--    'content_admin_archive') are already covered by the chain:
--    0020's audit_user_insert (self actor, action whitelist that includes
--    'account_deletion') and 0009's audit_logs_content_admin (admin actor).
--    Arbitrary actions remain denied. No audit read policy is added for any
--    role (audit internals stay restricted to the chain's policies).
-- ---------------------------------------------------------------------------
-- Security audit events are written by the system role through
-- withSystemTransaction (lib/audit/security-audit.ts), which verifies the
-- restricted role and sets app.system_operation for the transaction only.
CREATE POLICY audit_system_insert ON public.audit_logs
FOR INSERT TO duta_system
WITH CHECK (current_setting('app.system_operation', true) <> '');

-- ---------------------------------------------------------------------------
-- F. Minimal enabling grants for the audited call-sites the new policies
--    cover (no other table privilege is granted to any application role):
--    - organization_documents / publication_projects / meeting_transcripts:
--      secretary and transcription routes (server-side, org-scoped policies
--      above);
--    - audit_logs INSERT for the system role (security audit path above).
-- ---------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON public.organization_documents TO duta_app;
GRANT SELECT, INSERT, UPDATE ON public.publication_projects TO duta_app;
GRANT SELECT, INSERT, UPDATE ON public.meeting_transcripts TO duta_app;
GRANT INSERT ON public.audit_logs TO duta_system;

COMMIT;
