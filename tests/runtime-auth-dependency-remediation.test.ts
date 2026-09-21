import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const read = (path: string) => readFileSync(resolve(process.cwd(), path), 'utf8');

describe('0043 runtime auth dependency remediation', () => {
  const sql = read('db/migrations/0043_runtime_auth_dependency_remediation.sql');
  const bridge = read('db/migrations/0011_runtime_identity_bridge.sql');

  it('keeps duta_app outside the provider-owned auth schema', () => {
    expect(sql).not.toMatch(/GRANT\s+USAGE\s+ON\s+SCHEMA\s+auth\s+TO\s+duta_app/i);
    expect(sql).not.toMatch(/GRANT[^;]+ON\s+(?:TABLE\s+)?auth\./i);
    expect(sql).toContain('ALTER POLICY jobs_public ON public.jobs TO anon, authenticated');
    expect(sql).toContain('ALTER POLICY products_public ON public.products TO anon, authenticated');
  });

  it('uses a locked least-privilege runtime organization helper', () => {
    expect(sql).toContain('public.current_app_user_id()');
    expect(sql).toContain("SET search_path = ''");
    expect(sql).toContain('OWNER TO postgres');
    expect(bridge).toContain('SECURITY DEFINER');
    expect(bridge).toContain("SET search_path = ''");
    expect(bridge).toContain('REVOKE ALL ON FUNCTION public.current_app_has_org_role');
    expect(bridge).toContain('GRANT EXECUTE ON FUNCTION public.current_app_has_org_role');
    expect(sql).not.toMatch(/NEW\.user_id\s*=\s*auth\.uid\s*\(/);
  });
});
