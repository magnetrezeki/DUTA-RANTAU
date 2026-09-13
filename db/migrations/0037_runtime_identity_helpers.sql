-- 0037: Runtime identity helper functions (isolated from legacy db/rls.sql).
--
-- POST-8L-H2A (Option B): the current runtime migrations (0016, 0023, 0024,
-- 0025, 0026, 0027, 0029, 0030) reference public.has_system_role and
-- public.has_org_role. Their only in-repository definition lived in the
-- legacy/mixed db/rls.sql layer, which also installs a broad legacy
-- anon/authenticated policy set. This migration isolates ONLY the two
-- read-only identity helpers so a fresh staging database can bootstrap the
-- current runtime architecture without importing any legacy policy.
--
-- SECURITY:
--   - read-only SELECT EXISTS bodies: no writes, no dynamic SQL
--   - STABLE, SECURITY DEFINER, fixed search_path='' (all references are
--     schema-qualified)
--   - identity is auth.uid() (Supabase JWT claim) only; there is no
--     client-controlled role input outside the fixed role arrays that appear
--     in policy expressions
--   - least privilege (mirrors 0029's has_platform_role pattern): EXECUTE is
--     revoked from PUBLIC and granted only to the roles whose policies
--     consume the helpers (anon, authenticated, duta_app)
--
-- NUMBERING / EXECUTION:
--   Release chronology number: 0037 (next unused number; no existing
--   migration is renumbered or rewritten).
--   Fresh-bootstrap execution position: AFTER 0000-0003, 0010 and 0011
--   (0010 must precede this file because the EXECUTE grants target the
--   duta_app role created there) and BEFORE the first helper consumer
--   (0016). See the canonical fresh-database bootstrap runbook.
--   The drizzle journal is intentionally NOT updated: fresh bootstrap uses
--   explicit direct-SQL execution, never drizzle-kit migrate.

BEGIN;

CREATE OR REPLACE FUNCTION public.has_system_role(allowed public.user_role[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = ANY(allowed) AND u.suspended_at IS NULL)
$$;

CREATE OR REPLACE FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[])
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (SELECT 1 FROM public.organization_members m WHERE m.organization_id=org_id AND m.user_id=auth.uid() AND m.role=ANY(allowed) AND m.member_status='ACTIVE')
$$;

REVOKE ALL ON FUNCTION public.has_system_role(public.user_role[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_system_role(public.user_role[]) TO anon, authenticated, duta_app;

REVOKE ALL ON FUNCTION public.has_org_role(uuid, public.organization_role[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.has_org_role(uuid, public.organization_role[]) TO anon, authenticated, duta_app;

COMMIT;
