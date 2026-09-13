import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const migration = readFileSync('db/migrations/0034_ai_fair_use_foundation.sql', 'utf8');
const telemetryMigration = readFileSync('db/migrations/0035_ai_telemetry_foundation.sql', 'utf8');
const correlationMigration = readFileSync('db/migrations/0036_ai_telemetry_correlation.sql', 'utf8');

describe('AI fair-use migration contract', () => {
  it('is transactional and maintains a server-only quota boundary', () => {
    expect(migration.trimStart()).toMatch(/^--[^\n]*\nBEGIN;/);
    expect(migration.trimEnd()).toMatch(/COMMIT;$/);
    expect(migration).toContain('actor_id := public.current_app_user_id()');
    expect(migration).toContain('p_user IS DISTINCT FROM actor_id');
    expect(migration).toContain('p_limit > 30');
    expect(migration).toContain("REVOKE ALL ON FUNCTION public.consume_ai_usage(uuid, integer, integer, text) FROM PUBLIC");
  });

  it('deduplicates a server-generated request before charging a quota bucket', () => {
    expect(migration).toContain('CREATE TABLE IF NOT EXISTS public.ai_usage_requests');
    expect(migration).toContain('PRIMARY KEY (user_id, period_start, request_id)');
    expect(migration).toContain('ON CONFLICT (user_id, period_start, request_id) DO NOTHING');
    expect(migration.indexOf('INSERT INTO public.ai_usage_requests')).toBeLessThan(migration.indexOf('INSERT INTO public.ai_usage_buckets'));
  });

  it('keeps telemetry and correlation DDL atomic', () => {
    for (const sql of [telemetryMigration, correlationMigration]) {
      expect(sql.trimStart()).toMatch(/^BEGIN;/);
      expect(sql.trimEnd()).toMatch(/COMMIT;$/);
    }
  });
});
