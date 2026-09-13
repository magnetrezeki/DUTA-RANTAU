import { describe, expect, it } from 'vitest';
import { readFileSync, readdirSync } from 'node:fs';
import { resolve } from 'node:path';

const read = (p: string) => readFileSync(resolve(__dirname, p), 'utf8');
const rlsSql = read('../db/migrations/0038_core_runtime_rls_enforcement.sql');

// Every core application table the canonical chain (0000-0037) left with
// RLS off. After 0038 all of these must be RLS-on (default-deny model).
const RLS_OFF_BEFORE: string[] = [
  'ai_conversations',
  'audit_logs',
  'communities',
  'contents',
  'meeting_transcripts',
  'memberships',
  'notifications',
  'official_contacts',
  'official_evidence',
  'official_offices',
  'official_sources',
  'organization_attendance',
  'organization_branches',
  'organization_documents',
  'organization_finances',
  'organization_letters',
  'organization_meetings',
  'organization_members',
  'organization_payments',
  'organization_permissions',
  'organization_subscriptions',
  'organization_tasks',
  'organizations',
  'payments',
  'publication_projects',
  'publication_templates',
  'reports',
  'sellers',
  'sessions',
  'users',
];

const EXPECTED_0038_POLICIES = [
  'sellers_public_read',
  'organizations_runtime_read',
  'organization_members_runtime_read',
  'organization_subscriptions_runtime_read',
  'organization_documents_runtime',
  'publication_projects_runtime',
  'meeting_transcripts_runtime',
  'audit_system_insert',
] as const;

describe('0038 core runtime RLS enforcement migration', () => {
  it('enables RLS on every core table the chain left unprotected', () => {
    for (const table of RLS_OFF_BEFORE) {
      expect(rlsSql, `missing ENABLE for ${table}`).toMatch(
        new RegExp(`ALTER TABLE public\\.${table} ENABLE ROW LEVEL SECURITY;`)
      );
    }
  });

  it('never disables RLS and adds no FORCE RLS or BYPASSRLS', () => {
    // Comments are stripped: the header documents what this migration does
    // NOT add, which would otherwise match a naive keyword scan.
    const statements = rlsSql
      .split('\n')
      .filter((line) => !line.trim().startsWith('--'))
      .join('\n');
    expect(statements).not.toMatch(/DISABLE ROW LEVEL SECURITY/i);
    expect(statements).not.toMatch(/FORCE ROW LEVEL SECURITY/i);
    expect(statements).not.toMatch(/BYPASSRLS/i);
  });

  it('grants only the minimal enabling privileges for the audited call-sites', () => {
    const statements = rlsSql
      .split('\n')
      .filter((line) => !line.trim().startsWith('--'))
      .join('\n');
    const grants = [...statements.matchAll(/^GRANT ([^\n]+) TO ([\w, ]+);/gm)].map((m) => ({ what: m[1].trim(), to: m[2].trim() }));
    expect(grants).toEqual([
      { what: 'SELECT, INSERT, UPDATE ON public.organization_documents', to: 'duta_app' },
      { what: 'SELECT, INSERT, UPDATE ON public.publication_projects', to: 'duta_app' },
      { what: 'SELECT, INSERT, UPDATE ON public.meeting_transcripts', to: 'duta_app' },
      { what: 'INSERT ON public.audit_logs', to: 'duta_system' },
    ]);
    // No broad grants, nothing for client roles, nothing for service_role.
    expect(statements).not.toMatch(/\bGRANT ALL\b/i);
    expect(statements).not.toMatch(/\bGRANT[^;]*\bTO\s+(anon|authenticated|service_role)\b/i);
  });

  it('imports no legacy db/rls.sql policy bulk and no role escalation', () => {
    for (const legacy of [
      'users_self_select',
      'users_self_update',
      'users_self_delete',
      'org_members_read',
      'org_members_manage',
      'payments_owner',
      'official_evidence_read',
      'ai_owner',
      'notifications_owner_select',
      'reports_moderate',
      'community_join',
    ]) {
      expect(rlsSql, `legacy policy name leaked: ${legacy}`).not.toContain(legacy);
    }
    expect(rlsSql).not.toMatch(/ALTER ROLE|CREATE ROLE/i);
  });

  it('creates exactly the eight expected narrow policies', () => {
    const created = [...rlsSql.matchAll(/CREATE POLICY (\w+)/g)].map((m) => m[1]);
    expect(created).toHaveLength(EXPECTED_0038_POLICIES.length);
    for (const name of EXPECTED_0038_POLICIES) {
      expect(created, `missing policy ${name}`).toContain(name);
    }
  });

  it('does not re-create policies the chain already provides', () => {
    for (const existing of [
      'organizations_admin_update',
      'organizations_admin_insert',
      'organizations_runtime_select',
      'audit_logs_content_admin',
      'audit_user_insert',
      'users_runtime_select',
      'users_runtime_update',
    ]) {
      expect(rlsSql, `duplicates chain policy ${existing}`).not.toMatch(
        new RegExp(`CREATE POLICY ${existing}\\b`)
      );
    }
  });

  it('exposes anon/authenticated ONLY through the sellers directory read', () => {
    const policyBlocks = rlsSql.split(/CREATE POLICY /).slice(1);
    for (const block of policyBlocks) {
      const name = block.slice(0, block.indexOf(' '));
      const toClause = block.match(/\bTO\s+([^\n]+)/)?.[1] ?? '';
      const isClient = /(^|,|\s)anon(,|\s|$)|(^|,|\s)authenticated(,|\s|$)/.test(toClause);
      if (name === 'sellers_public_read') {
        expect(toClause).toMatch(/anon/);
        expect(toClause).toMatch(/authenticated/);
        // staging-parity expression: active directory rows or own row
        expect(block).toMatch(/status = 'ACTIVE' OR user_id = auth\.uid\(\)/);
      } else {
        expect(isClient, `${name} must not grant client roles`).toBe(false);
      }
    }
  });

  it('keeps the audit addition write-only, system-role-only, and operation-bound', () => {
    const sysInsert = rlsSql.match(/CREATE POLICY audit_system_insert[\s\S]*?;$/m)?.[0] ?? '';
    expect(sysInsert).toContain('FOR INSERT TO duta_system');
    expect(sysInsert).toContain("current_setting('app.system_operation', true) <> ''");
    // No audit READ policy is added by this migration for any role, and no
    // duta_app audit policy is re-added (0020's audit_user_insert and
    // 0009's audit_logs_content_admin already cover the duta_app paths).
    expect(rlsSql).not.toMatch(/FOR SELECT TO duta_system/);
    expect(rlsSql).not.toMatch(/CREATE POLICY audit[_a-z]* ON public\.audit_logs\s*\nFOR INSERT TO duta_app/);
  });

  it('scopes the public organization read to ACTIVE organizations', () => {
    const orgRead = rlsSql.match(/CREATE POLICY organizations_runtime_read[\s\S]*?;$/m)?.[0] ?? '';
    expect(orgRead).toContain('FOR SELECT TO duta_app');
    expect(orgRead).toContain("status = 'ACTIVE'::public.record_status");
  });

  it('applies the authorized historical column corrections exactly', () => {
    const m23 = read('../db/migrations/0023_entity_legal_status_foundation.sql');
    const m27 = read('../db/migrations/0027_community_membership_growth_foundation.sql');
    // Authorized fixes present...
    expect(m23).toContain("),o.status,'registration_not_verified'");
    expect(m23).toContain("c.owner_id,c.status,'informal_group'");
    expect(m27).toContain("AND c.status='ACTIVE'");
    // ...and no broken references remain in either file (boundary-aware so
    // that the qualified enum type "public.record_status" does not match).
    expect(m23).not.toMatch(/(^|[^A-Za-z0-9_])o\.record_status/);
    expect(m23).not.toMatch(/(^|[^A-Za-z0-9_])c\.record_status/);
    expect(m27).not.toMatch(/(^|[^A-Za-z0-9_])c\.record_status/);
  });

  it('leaves no invalid .record_status reference in any migration', () => {
    const dir = resolve(__dirname, '../db/migrations');
    const files = readdirSync(dir).filter((f) => /^\d{4}_.*\.sql$/.test(f));
    // Qualifiers allowed for a dotted record_status reference:
    //  - 'public'  (the enum TYPE, e.g. "record_status public.record_status" / casts)
    //  - 'e' / 'entities' (the entities table, which really has a record_status column)
    const allowed = new Set(['public', 'e', 'entities']);
    for (const file of files) {
      const sql = read(`../db/migrations/${file}`);
      for (const m of sql.matchAll(/([A-Za-z_][A-Za-z0-9_]*)\.record_status/g)) {
        expect(allowed.has(m[1]), `${file}: invalid record_status reference '${m[0]}'`).toBe(true);
      }
    }
  });

  it('leaves the drizzle journal unchanged (0037/0038 not journaled)', () => {
    const journal = JSON.parse(read('../db/migrations/meta/_journal.json')) as { entries: Array<{ tag: string }> };
    expect(journal.entries).toHaveLength(10);
    const tags = journal.entries.map((e) => e.tag);
    expect(tags).not.toContain('0037_runtime_identity_helpers');
    expect(tags).not.toContain('0038_core_runtime_rls_enforcement');
  });
});
