import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const read = (p: string) => readFileSync(resolve(__dirname, p), 'utf8');
const helperSql = read('../db/migrations/0037_runtime_identity_helpers.sql');

describe('0037 runtime identity helper migration', () => {
  it('defines both read-only identity helpers with safe properties', () => {
    expect(helperSql).toContain('CREATE OR REPLACE FUNCTION public.has_system_role(allowed public.user_role[])');
    expect(helperSql).toContain('CREATE OR REPLACE FUNCTION public.has_org_role(org_id uuid, allowed public.organization_role[])');
    expect(helperSql).toContain('RETURNS boolean');
    expect(helperSql).toContain('LANGUAGE sql STABLE SECURITY DEFINER');
    expect(helperSql).toContain("SET search_path = ''");
    // Identity comes exclusively from the Supabase JWT claim, never from an
    // application-supplied role claim.
    expect(helperSql).toContain('auth.uid()');
    expect(helperSql).not.toContain('app.user_id');
    // Read-only: no write statements in the helper bodies.
    expect(helperSql).not.toMatch(/\bINSERT INTO\b|\bUPDATE \b|\bDELETE FROM\b/i);
  });

  it('does not import the legacy db/rls.sql policy bulk', () => {
    expect(helperSql).not.toMatch(/CREATE POLICY/i);
    expect(helperSql).not.toContain('users_self_select');
    expect(helperSql).not.toContain('org_members_manage');
    expect(helperSql).not.toContain('payments_owner');
    expect(helperSql).not.toContain('ENABLE ROW LEVEL SECURITY');
    expect(helperSql).not.toMatch(/ALTER TABLE/i);
  });

  it('grants no table privileges and no role escalation', () => {
    expect(helperSql).not.toMatch(/GRANT\s+(SELECT|INSERT|UPDATE|DELETE|ALL)\s+ON\s+TABLE/i);
    expect(helperSql).not.toMatch(/GRANT\s+(SELECT|INSERT|UPDATE|DELETE|ALL)\s+ON\s+ALL\s+TABLES/i);
    expect(helperSql).not.toMatch(/GRANT\s+USAGE\s+ON\s+SCHEMA/i);
    expect(helperSql).not.toMatch(/ALTER\s+ROLE|CREATE\s+ROLE/i);
    expect(helperSql).not.toMatch(/GRANT\s+(SUPERUSER|BYPASSRLS|CREATEROLE|CREATEDB|REPLICATION)/i);
  });

  it('keeps function execute least-privilege (revoked from PUBLIC, named roles only)', () => {
    expect(helperSql).toMatch(/REVOKE ALL ON FUNCTION public\.has_system_role\(public\.user_role\[\]\) FROM PUBLIC/);
    expect(helperSql).toMatch(/REVOKE ALL ON FUNCTION public\.has_org_role\(uuid, public\.organization_role\[\]\) FROM PUBLIC/);
    expect(helperSql).toMatch(/GRANT EXECUTE ON FUNCTION public\.has_system_role\(public\.user_role\[\]\) TO anon, authenticated, duta_app/);
    expect(helperSql).toMatch(/GRANT EXECUTE ON FUNCTION public\.has_org_role\(uuid, public\.organization_role\[\]\) TO anon, authenticated, duta_app/);
    expect(helperSql).not.toMatch(/GRANT EXECUTE[^;]*service_role/i);
    expect(helperSql).not.toMatch(/GRANT EXECUTE[^;]*duta_system/i);
  });

  it('satisfies every current migration helper reference', () => {
    const consumers: Array<[string, boolean, boolean]> = [
      // [file, needs has_system_role, needs has_org_role]
      ['0016_runtime_content_select.sql', true, false],
      ['0023_entity_legal_status_foundation.sql', true, false],
      ['0024_presence_responsible_person_foundation.sql', true, false],
      ['0025_verification_foundation.sql', true, false],
      ['0026_eligibility_permission_foundation.sql', true, false],
      ['0027_community_membership_growth_foundation.sql', false, true],
      ['0029_admin_rbac_foundation.sql', false, true],
      ['0030_event_safety_paid_event_foundation.sql', false, true],
    ];
    for (const [file, needsSystem, needsOrg] of consumers) {
      const sql = read(`../db/migrations/${file}`);
      const usesSystem = /(?<![a-z_])has_system_role\s*\(/.test(sql);
      const usesOrg = /(?<![a-z_])has_org_role\s*\(/.test(sql);
      expect(usesSystem, `${file} has_system_role usage drifted from the recorded consumer map`).toBe(needsSystem);
      expect(usesOrg, `${file} has_org_role usage drifted from the recorded consumer map`).toBe(needsOrg);
      if (needsSystem) expect(helperSql).toContain('public.has_system_role(allowed public.user_role[])');
      if (needsOrg) expect(helperSql).toContain('public.has_org_role(org_id uuid, allowed public.organization_role[])');
    }
  });

  it('keeps existing RBAC/RLS static invariants intact', () => {
    const rbac = read('../db/migrations/0029_admin_rbac_foundation.sql');
    expect(rbac).toContain("public.has_platform_role('verification_reviewer')");
    expect(rbac).toContain("members cannot change their own role");
    expect(rbac).not.toContain("public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']");
    const removeBroad = read('../db/migrations/0021_remove_broad_audit_self_insert.sql');
    expect(removeBroad).toContain('DROP POLICY IF EXISTS audit_logs_self_insert');
  });

  it('leaves the drizzle journal unchanged (no 0037 entry)', () => {
    const journal = JSON.parse(read('../db/migrations/meta/_journal.json')) as { entries: Array<{ tag: string }> };
    expect(journal.entries).toHaveLength(10);
    expect(journal.entries.map((e) => e.tag)).not.toContain('0037_runtime_identity_helpers');
  });
});
