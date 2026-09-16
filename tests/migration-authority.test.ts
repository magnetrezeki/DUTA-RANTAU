import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const repositoryRoot = resolve(__dirname, '..');
const contractPath = resolve(repositoryRoot, 'docs/duta-v2.5/MIGRATION_VALIDATION_CONTRACT.md');
const templatePath = resolve(repositoryRoot, 'docs/duta-v2.5/MIGRATION_TEMPLATE.md');
const migrationDirectory = resolve(repositoryRoot, 'db/migrations');
const manifestPath = resolve(migrationDirectory, 'forward-manifest.json');

const readText = (path: string) => readFileSync(path, 'utf8');
const requireMarkers = (text: string, markers: string[]) => {
  for (const marker of markers) expect(text, `missing marker: ${marker}`).toContain(marker);
};
const requirePatterns = (text: string, patterns: RegExp[]) => {
  for (const pattern of patterns) expect(text, `missing pattern: ${pattern}`).toMatch(pattern);
};

describe('MA-03 migration validation contract', () => {
  it('provides the contract and template without a governed migration artifact', () => {
    expect(existsSync(contractPath)).toBe(true);
    expect(existsSync(templatePath)).toBe(true);
    expect(readdirSync(migrationDirectory).some((name) => /^0039.*\.sql$/.test(name))).toBe(false);
    expect(existsSync(resolve(repositoryRoot, 'tests/db/migrations/0039'))).toBe(false);
    expect(existsSync(resolve(repositoryRoot, 'docs/duta-v2.5/migrations/0039_VALIDATION.md'))).toBe(false);
    expect(JSON.parse(readText(manifestPath)).migrations).toEqual([]);
  });

  it('preserves locked authority language, boundaries, and lifecycle', () => {
    const contract = readText(contractPath);
    requireMarkers(contract, [
      'DOCUMENT_STATUS | ACTIVE_VALIDATION_CONTRACT', 'FORWARD_ONLY_DIRECT_SQL',
      'FROZEN_HISTORICAL_EVIDENCE', 'LEGACY_FROZEN_METADATA', '0038', '0039',
      'PROPOSED', 'REVIEWED', 'AUTHORITY_ACCEPTED', 'SUPERSEDED',
      'MA-04 owns', 'MA-05 will own', 'AUTHORITY_ACCEPTED is the immutability point'
    ]);
    requirePatterns(contract, [
      /does not establish\s+historical replay authority, fresh database authority, environment applied\s+state, staging execution, production execution, or deployment authority/,
    ]);
  });

  it('defines two-commit provenance and all dependency categories', () => {
    const contract = readText(contractPath);
    requireMarkers(contract, [
      'two-commit model is REQUIRED', 'Commit A', 'Commit B', 'earliest non-merge commit',
      'unique introduction event', 'Rename-based provenance is rejected',
      'exempt from retrospective', 'dependsOn.migrations', '.tables', '.columns', '.functions',
      '.roles', '.extensions', '.security', 'number alone is insufficient evidence',
      'schema-qualified tables', 'Functions use a schema-qualified'
    ]);
    requirePatterns(contract, [/path reuse\s+is prohibited/]);
  });

  it('defines separate pre-state, local validation, security, data, and rollback obligations', () => {
    const contract = readText(contractPath);
    requireMarkers(contract, [
      'DECLARED_PRESTATE', 'LOCAL_PRESTATE', 'TARGET_PRESTATE', 'owned by MA-04',
      'duta_local_test', 'synthetic data only', 'Production dumps, staging dumps, real user data',
      'REUSABLE_WITH_MIGRATION_SPECIFIC_PRESTATE',
      'security-verify with negative/adversarial behavior', 'FORCE RLS decision',
      'AUTHORIZATION requires positive authorized and negative unauthorized cases', 'ROLE_GRANT',
      'SECURITY_FUNCTION', 'AUTHENTICATION validation is limited',
      'NONE`, `BACKFILL`, `TRANSFORM`, `DELETE`, or `MIXED`', 'IDEMPOTENCY_DECISION',
      'partial-failure consideration', 'REVERSIBLE', 'FORWARD_FIX_ONLY',
      'DATA_BACKUP_REQUIRED', 'MANUAL_RECOVERY', 'IRREVERSIBLE', 'DOWN_MIGRATION_REQUIRED: NO',
      'validationContract.reference'
    ]);
    requirePatterns(contract, [/Full historical\s+replay is UNSUPPORTED/, /MULTIPLE\s+requires/]);
  });

  it('provides a generic template and explicit environment separation', () => {
    const template = readText(templatePath);
    requireMarkers(template, [
      'DOCUMENT_STATUS | TEMPLATE_ONLY', 'NOT_A_MIGRATION_RECORD', 'NNNN',
      'Identity', 'Purpose', 'Authority status and dependencies', 'DECLARED_PRESTATE',
      'LOCAL_PRESTATE', 'TARGET_PRESTATE', 'SQL design', 'Schema effect', 'Security effects',
      'RLS decision', 'Data effect', 'Idempotency decision', 'Transaction policy',
      'Operational risk', 'Expected post-state', 'Validation artifacts',
      'Security and data validation', 'Rollback/recovery', 'Provenance and acceptance evidence',
      'Environment-state disclaimer', 'does not prove local\nexecution, staging execution, production execution, or deployment'
    ]);
    expect(template).not.toContain('0039_lowercase_slug.sql');
  });
});
