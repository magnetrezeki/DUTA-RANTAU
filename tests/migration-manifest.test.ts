import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const repositoryRoot = resolve(__dirname, '..');
const migrationDirectory = resolve(repositoryRoot, 'db/migrations');
const manifestPath = resolve(migrationDirectory, 'forward-manifest.json');
const baselinePath = resolve(migrationDirectory, 'forward-authority-baseline.json');

const manifest = JSON.parse(readFileSync(manifestPath, 'utf8')) as Record<string, unknown>;
const baseline = JSON.parse(readFileSync(baselinePath, 'utf8')) as Record<string, unknown>;

const historicalFilePattern = /^(\d{4})_.+\.sql$/;
const acceptedChecksumPattern = /^sha256:[a-f0-9]{64}$/;
const sha256Pattern = /^[a-f0-9]{64}$/;
const gitShaPattern = /^[a-f0-9]{40}$/;
const forwardStatuses = new Set(['PROPOSED', 'REVIEWED', 'AUTHORITY_ACCEPTED', 'SUPERSEDED']);
const schemaEffects = new Set(['NONE', 'ADDITIVE', 'ALTERING', 'DESTRUCTIVE', 'MIXED']);
const securityEffects = new Set([
  'NONE',
  'AUTHORIZATION',
  'RLS',
  'ROLE_GRANT',
  'SECURITY_FUNCTION',
  'AUTHENTICATION',
  'MULTIPLE',
]);
const dataEffects = new Set(['NONE', 'BACKFILL', 'TRANSFORM', 'DELETE', 'MIXED']);
const rollbackClassifications = new Set([
  'REVERSIBLE',
  'FORWARD_FIX_ONLY',
  'DATA_BACKUP_REQUIRED',
  'MANUAL_RECOVERY',
  'IRREVERSIBLE',
]);
const forbiddenAppliedStateKeys = new Set([
  'applied',
  'appliedat',
  'executed',
  'executedat',
  'deployed',
  'deploymentstatus',
  'environment',
  'stagingapplied',
  'productionapplied',
  'databasestate',
]);

type ForwardMigration = Record<string, unknown>;

function sha256(filePath: string): string {
  return createHash('sha256').update(readFileSync(filePath)).digest('hex');
}

function historicalEntriesFromFilenames(filenames: string[]) {
  const entries = filenames
    .filter((filename) => filename.endsWith('.sql'))
    .map((filename) => {
      const numericPrefix = filename.match(/^(\d{4})/);
      if (numericPrefix === null || Number(numericPrefix[1]) > 38) return null;
      if (!historicalFilePattern.test(filename)) {
        throw new Error(`Malformed historical migration filename: ${filename}`);
      }
      return { filename, number: numericPrefix[1] };
    })
    .filter((entry): entry is { filename: string; number: string } => entry !== null)
    .sort((left, right) => left.filename.localeCompare(right.filename));

  expect(new Set(entries.map((entry) => entry.number)).size, 'historical migration numbers must be unique').toBe(entries.length);
  return entries;
}

function getHistoricalFiles() {
  return historicalEntriesFromFilenames(readdirSync(migrationDirectory));
}

function assertHistoricalSetMatchesManifest(
  actualFiles: Array<{ filename: string; number: string }>,
  integrityFiles: Record<string, unknown>[],
): void {
  expect(actualFiles).toHaveLength(35);
  expect(integrityFiles).toHaveLength(35);
  expect(integrityFiles.map((entry) => entry.filename)).toEqual(actualFiles.map((entry) => entry.filename));
  expect(new Set(integrityFiles.map((entry) => entry.number)).size).toBe(35);
}

function expectPlainObject(value: unknown, label: string): asserts value is Record<string, unknown> {
  expect(value, `${label} must be an object`).toBeTypeOf('object');
  expect(value, `${label} must not be null`).not.toBeNull();
  expect(Array.isArray(value), `${label} must not be an array`).toBe(false);
}

function assertNoAppliedStateKeys(value: unknown): void {
  if (Array.isArray(value)) {
    value.forEach(assertNoAppliedStateKeys);
    return;
  }
  if (value === null || typeof value !== 'object') return;

  for (const [key, nestedValue] of Object.entries(value)) {
    const canonicalKey = key.toLowerCase().replace(/[^a-z0-9]/g, '');
    expect(forbiddenAppliedStateKeys.has(canonicalKey), `forbidden applied-state key: ${key}`).toBe(false);
    assertNoAppliedStateKeys(nestedValue);
  }
}

function assertDependencyShape(value: unknown): void {
  expectPlainObject(value, 'dependsOn');
  const expectedKeys = ['migrations', 'tables', 'columns', 'functions', 'roles', 'extensions', 'security'];
  expect(Object.keys(value).sort()).toEqual(expectedKeys.sort());
  expectedKeys.forEach((key) => {
    expect(value[key], `dependsOn.${key}`).toEqual(expect.any(Array));
    (value[key] as unknown[]).forEach((identifier) => {
      expect(typeof identifier, `dependsOn.${key} values must be strings`).toBe('string');
      expect((identifier as string).trim().length, `dependsOn.${key} values must not be blank`).toBeGreaterThan(0);
    });
  });
}

function assertAcceptedMigration(entry: ForwardMigration): void {
  expect(typeof entry.filename).toBe('string');
  expect(String(entry.filename)).toMatch(new RegExp(`^${entry.number}_[a-z0-9_]+\\.sql$`));
  const filePath = resolve(migrationDirectory, String(entry.filename));
  expect(existsSync(filePath), `${entry.filename} must exist`).toBe(true);
  expect(entry.checksum).toMatch(acceptedChecksumPattern);
  expect(entry.checksum).toBe(`sha256:${sha256(filePath)}`);
  expect(typeof entry.introducedCommit).toBe('string');
  expect(String(entry.introducedCommit)).toMatch(gitShaPattern);
  expect(() => execFileSync('git', ['cat-file', '-e', `${entry.introducedCommit}:${entry.filename}`], {
    cwd: repositoryRoot,
    stdio: 'ignore',
  })).not.toThrow();
  assertDependencyShape(entry.dependsOn);
  expectPlainObject(entry.rollback, 'rollback');
  expect(rollbackClassifications.has(String(entry.rollback.classification))).toBe(true);
  expectPlainObject(entry.validationContract, 'validationContract');
  expect(entry.validationContract.status).not.toBe('PENDING_MA03');
  expect(typeof entry.validationContract.reference).toBe('string');
  expect(String(entry.validationContract.reference).trim().length).toBeGreaterThan(0);
}

function assertForwardMigration(entry: ForwardMigration): void {
  assertNoAppliedStateKeys(entry);
  expect(typeof entry.number).toBe('string');
  expect(String(entry.number)).toMatch(/^\d{4}$/);
  expect(Number(entry.number)).toBeGreaterThanOrEqual(39);
  expect(typeof entry.purpose).toBe('string');
  expect(String(entry.purpose).trim()).toBe(String(entry.purpose));
  expect(String(entry.purpose).trim().length).toBeGreaterThan(0);
  expect(forwardStatuses.has(String(entry.status))).toBe(true);
  expect(schemaEffects.has(String(entry.schemaEffect))).toBe(true);
  expect(entry.securityEffects).toEqual(expect.any(Array));
  expect((entry.securityEffects as unknown[]).length).toBeGreaterThan(0);
  (entry.securityEffects as unknown[]).forEach((effect) => expect(securityEffects.has(String(effect))).toBe(true));
  const effects = entry.securityEffects as string[];
  if (effects.includes('NONE') || effects.includes('MULTIPLE')) expect(effects).toHaveLength(1);
  expect(typeof entry.requiresRlsValidation).toBe('boolean');
  if (effects.includes('RLS')) expect(entry.requiresRlsValidation).toBe(true);
  expect(typeof entry.requiresDataBackfill).toBe('boolean');
  expect(dataEffects.has(String(entry.dataEffect))).toBe(true);
  if (entry.requiresDataBackfill === true) expect(entry.dataEffect).not.toBe('NONE');
  if (entry.dataEffect === 'BACKFILL') expect(entry.requiresDataBackfill).toBe(true);

  if (entry.status === 'AUTHORITY_ACCEPTED' || entry.status === 'SUPERSEDED') {
    assertAcceptedMigration(entry);
    return;
  }

  if (entry.introducedCommit !== null) expect(String(entry.introducedCommit)).toMatch(gitShaPattern);
  if (entry.checksum !== null) expect(String(entry.checksum)).toMatch(acceptedChecksumPattern);
  expectPlainObject(entry.validationContract, 'validationContract');
  expect(entry.validationContract.status).toBe('PENDING_MA03');
  expect(entry.validationContract.reference).toBeNull();
}

describe('forward migration manifest', () => {
  it('binds to the locked MA-01 authority baseline', () => {
    expect(manifest.authorityVersion).toBe(1);
    expect(manifest.manifestSchemaVersion).toBe(1);
    expect(manifest.authorityModel).toBe('FORWARD_ONLY_DIRECT_SQL');
    expect(manifest.historicalCeiling).toBe('0038');
    expect(manifest.firstForwardMigration).toBe('0039');
    expectPlainObject(manifest.repositoryBaseline, 'repositoryBaseline');
    expect(manifest.repositoryBaseline).toEqual({
      file: 'db/migrations/forward-authority-baseline.json',
      head: baseline.repositoryBaseline && (baseline.repositoryBaseline as Record<string, unknown>).head,
      tree: baseline.repositoryBaseline && (baseline.repositoryBaseline as Record<string, unknown>).tree,
    });
    expect(manifest.authorityModel).toBe(baseline.authorityModel);
    expect(manifest.historicalCeiling).toBe(baseline.historicalMigrationCeiling);
    expect(manifest.firstForwardMigration).toBe(baseline.firstForwardMigration);
  });

  it('pins the complete frozen historical SQL set for mutation detection only', () => {
    expectPlainObject(manifest.historicalIntegrity, 'historicalIntegrity');
    const integrity = manifest.historicalIntegrity;
    expect(integrity.purpose).toBe('MUTATION_DETECTION_ONLY');
    expect(integrity.algorithm).toBe('SHA-256');
    expect(integrity.baselineHead).toBe('3602a09a3b85161eae45101eb8339c68591612ea');
    expect(integrity.baselineTree).toBe('6676178a4a8c7131c2f95679303e33c8ed7a2305');
    expect(integrity.missingNumbers).toEqual(['0004', '0005', '0006', '0007']);

    const actualFiles = getHistoricalFiles();
    const actualNumbers = actualFiles.map((entry) => Number(entry.number));
    const actualGaps = Array.from({ length: 39 }, (_, number) => number)
      .filter((number) => !actualNumbers.includes(number))
      .map((number) => String(number).padStart(4, '0'));
    expect(actualGaps).toEqual(integrity.missingNumbers);

    expect(integrity.files).toEqual(expect.any(Array));
    const integrityFiles = integrity.files as Record<string, unknown>[];
    assertHistoricalSetMatchesManifest(actualFiles, integrityFiles);

    integrityFiles.forEach((entry) => {
      expect(typeof entry.number).toBe('string');
      expect(typeof entry.filename).toBe('string');
      expect(String(entry.filename)).toMatch(new RegExp(`^${entry.number}_.+\\.sql$`));
      expect(entry.sha256).toMatch(sha256Pattern);
      expect(entry.sha256).toBe(sha256(resolve(migrationDirectory, String(entry.filename))));
      expect(Object.keys(entry).sort()).toEqual(['filename', 'number', 'sha256']);
    });
  });

  it('recognizes the current first governed migration as proposed without applied-state authority', () => {
    const migrations = manifest.migrations as Array<Record<string, unknown>>;
    expect(migrations).toHaveLength(1);

    const [migration] = migrations;
    expect(migration).toMatchObject({
      number: '0039',
      filename: '0039_source_registry_governance_foundation.sql',
      status: 'PROPOSED',
      checksum: null,
      introducedCommit: null,
      schemaEffect: 'ADDITIVE',
      securityEffects: ['RLS', 'AUTHORIZATION'],
      requiresRlsValidation: true,
      requiresDataBackfill: false,
      dataEffect: 'NONE',
      validationContract: {
        status: 'PENDING_MA03',
        reference: null,
      },
    });

    expect(readdirSync(migrationDirectory)).toContain(migration.filename);
    expect(() => assertNoAppliedStateKeys(migration)).not.toThrow();
  });

  it('rejects malformed or added files in the frozen historical namespace', () => {
    const actualFiles = getHistoricalFiles();
    const integrityFiles = (manifest.historicalIntegrity as Record<string, unknown>).files as Record<string, unknown>[];
    expect(() => historicalEntriesFromFilenames(['0004.sql'])).toThrow('Malformed historical migration filename');
    expect(() => historicalEntriesFromFilenames(['0038.sql'])).toThrow('Malformed historical migration filename');
    expect(() => historicalEntriesFromFilenames(['0038_extra.sql', '0038_runtime.sql'])).toThrow('historical migration numbers must be unique');
    expect(() => assertHistoricalSetMatchesManifest(
      [...actualFiles, { filename: '0004_new.sql', number: '0004' }],
      integrityFiles,
    )).toThrow();
  });

  it('rejects separator and nesting variants of applied-state keys', () => {
    const blockedKeys = [
      'appliedAt', 'applied_at', 'applied-at', 'Applied At',
      'executedAt', 'executed_at', 'executed-at',
      'deploymentStatus', 'deployment_status', 'deployment-status',
      'stagingApplied', 'staging_applied', 'staging-applied',
      'productionApplied', 'production_applied', 'production-applied',
      'databaseState', 'database_state', 'database-state',
    ];
    blockedKeys.forEach((key) => expect(() => assertNoAppliedStateKeys({ [key]: true })).toThrow());
    expect(() => assertNoAppliedStateKeys({ metadata: { applied_at: true } })).toThrow();
    expect(() => assertNoAppliedStateKeys({ metadata: [{ database_state: true }] })).toThrow();
  });

  it('rejects non-string and blank dependency identifiers', () => {
    const dependencyKeys = ['migrations', 'tables', 'columns', 'functions', 'roles', 'extensions', 'security'];
    const validDependencies = Object.fromEntries(dependencyKeys.map((key) => [key, ['valid.identifier']]));
    [[{}], [39], [null], [['nested']], [''] , ['   '], [true]].forEach((invalidValues) => {
      expect(() => assertDependencyShape({ ...validDependencies, tables: invalidValues })).toThrow();
    });
  });

  it('validates future governed migration metadata without environment state', () => {
    expect(manifest.migrations).toEqual(expect.any(Array));
    const migrations = manifest.migrations as ForwardMigration[];
    migrations.forEach(assertForwardMigration);
    const sortedNumbers = migrations.map((entry) => Number(entry.number)).sort((left, right) => left - right);
    expect(new Set(sortedNumbers).size).toBe(sortedNumbers.length);
    sortedNumbers.forEach((number, index) => expect(number).toBe(39 + index));
  });
});
