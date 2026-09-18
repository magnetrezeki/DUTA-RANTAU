-- 0040: correct provider default ACL inheritance exposed by migration 0039.
--
-- This forward-only correction removes public API role privileges from the
-- two sensitive governance tables and prevents future tables created by the
-- postgres migration owner in schema public from inheriting those privileges.
-- service_role is deliberately preserved as a provider administrative role.
BEGIN;

REVOKE ALL PRIVILEGES ON TABLE
  public.official_source_governance,
  public.official_source_evidence
FROM anon, authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL PRIVILEGES ON TABLES FROM anon, authenticated;

COMMIT;
