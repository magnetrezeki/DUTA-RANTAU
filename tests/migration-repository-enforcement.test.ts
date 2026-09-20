import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { cpSync, existsSync, mkdtempSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { afterAll, afterEach, describe, expect, it } from 'vitest';
// The guard is deliberately dependency-free Node ESM rather than TypeScript.
// @ts-expect-error No declaration file is needed for the executable guard.
import { checkMigrationAuthority } from '../scripts/check-migration-authority.mjs';

const repositoryRoot = resolve(__dirname, '..');
const temporaryRoots: string[] = [];

function runGit(root: string, args: string[]) {
  return execFileSync('git', args, { cwd: root, encoding: 'utf8' }).trim();
}
function write(root: string, relative: string, contents: string) {
  const target = join(root, relative);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, contents);
}
function readManifest(root: string) {
  return JSON.parse(readFileSync(join(root, 'db/migrations/forward-manifest.json'), 'utf8'));
}
function writeManifest(root: string, manifest: unknown) {
  write(root, 'db/migrations/forward-manifest.json', `${JSON.stringify(manifest, null, 2)}\n`);
}
function commit(root: string, message: string) {
  runGit(root, ['add', '.']);
  runGit(root, ['commit', '-m', message]);
  return runGit(root, ['rev-parse', 'HEAD']);
}
function initializeFixture(root: string) {
  cpSync(join(repositoryRoot, 'db/migrations'), join(root, 'db/migrations'), { recursive: true });
  // Start every fixture from the real frozen historical set and an empty
  // forward lifecycle. Strip the whole governed forward namespace
  // generically rather than by hardcoded filename, so introducing a new
  // forward migration cannot silently break this suite.
  for (const name of readdirSync(join(root, 'db/migrations'))) {
    if (/^\d{4}_.+\.sql$/.test(name) && Number(name.slice(0, 4)) >= 39) {
      rmSync(join(root, 'db/migrations', name));
    }
  }
  const manifest = readManifest(root);
  manifest.migrations = [];
  writeManifest(root, manifest);
  write(root, 'package.json', JSON.stringify({ scripts: { build: 'next build', start: 'next start' } }, null, 2));
  runGit(root, ['init']);
  runGit(root, ['config', 'user.email', 'ma05@example.test']);
  runGit(root, ['config', 'user.name', 'MA-05 fixture']);
  runGit(root, ['config', 'core.autocrlf', 'false']);
  commit(root, 'baseline');
}
const fixtureTemplate = mkdtempSync(join(tmpdir(), 'duta-ma05-template-'));
initializeFixture(fixtureTemplate);
function createFixture() {
  const root = mkdtempSync(join(tmpdir(), 'duta-ma05-'));
  cpSync(fixtureTemplate, root, { recursive: true });
  temporaryRoots.push(root);
  return root;
}
function entry(status: string, introducedCommit: string | null = null, checksum: string | null = null): any {
  return {
    number: '0039', filename: '0039_example.sql', purpose: 'Example governed migration',
    dependsOn: { migrations: [], tables: [], columns: [], functions: [], roles: [], extensions: [], security: [] },
    checksum, introducedCommit, schemaEffect: 'ADDITIVE', securityEffects: ['NONE'],
    requiresRlsValidation: false, requiresDataBackfill: false, dataEffect: 'NONE',
    rollback: { classification: 'REVERSIBLE' },
    validationContract: status === 'PROPOSED' || status === 'REVIEWED'
      ? { status: 'PENDING_MA03', reference: null }
      : { status: 'DEFINED', reference: 'docs/duta-v2.5/migrations/0039_VALIDATION.md' },
    status,
  };
}
function addProposed(root: string) {
  write(root, 'db/migrations/0039_example.sql', 'create table public.example (id integer);\n');
  const manifest = readManifest(root);
  manifest.migrations = [entry('PROPOSED')];
  writeManifest(root, manifest);
  return commit(root, 'propose 0039');
}
function addAccepted(root: string, introducedCommit: string) {
  write(root, 'docs/duta-v2.5/migrations/0039_VALIDATION.md', '# validation\n');
  write(root, 'tests/db/migrations/0039/prestate.sql', 'select 1;\n');
  write(root, 'tests/db/migrations/0039/verify.sql', 'select 1;\n');
  const manifest = readManifest(root);
  const sql = readFileSync(join(root, 'db/migrations/0039_example.sql'));
  manifest.migrations = [entry('AUTHORITY_ACCEPTED', introducedCommit, `sha256:${createHash('sha256').update(sql).digest('hex')}`)];
  writeManifest(root, manifest);
  commit(root, 'accept 0039');
}
function addProposedEntry(root: string, number: string, dependencies: string[] = []) {
  write(root, `db/migrations/${number}_example.sql`, 'select 1;\n');
  const manifest = readManifest(root);
  const next = entry('PROPOSED');
  next.number = number;
  next.filename = `${number}_example.sql`;
  next.dependsOn.migrations = dependencies;
  manifest.migrations.push(next);
  writeManifest(root, manifest);
}
function expectFailure(root: string, code: string) {
  expect(() => checkMigrationAuthority(root)).toThrow(code);
}

afterEach(() => {
  while (temporaryRoots.length) rmSync(temporaryRoots.pop()!, { recursive: true, force: true });
});
afterAll(() => rmSync(fixtureTemplate, { recursive: true, force: true }));

describe('MA-05 repository migration enforcement', { timeout: 30_000 }, () => {
  it('accepts the governed forward lifecycle and exposes the package guard command', () => {
    expect(checkMigrationAuthority(repositoryRoot)).toEqual({ historicalCount: 35, forwardCount: 3 });
    expect(readManifest(repositoryRoot).migrations).toEqual([
      expect.objectContaining({
        number: '0039', status: 'AUTHORITY_ACCEPTED',
        checksum: 'sha256:5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30',
        introducedCommit: '9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5',
      }),
      expect.objectContaining({
        number: '0040', status: 'AUTHORITY_ACCEPTED',
        checksum: 'sha256:b59dcfea09b1ebbc023783eff4e280e3e74bfe04bfe34a6d741a21839bbc4697',
        introducedCommit: '0b2f0e97007ba5647e9888a2d286a06b57c70f60',
      }),
      expect.objectContaining({
        number: '0041', status: 'PROPOSED',
        checksum: null, introducedCommit: null,
        validationContract: { status: 'PENDING_MA03', reference: null },
      }),
    ]);
    expect(JSON.parse(readFileSync(join(repositoryRoot, 'package.json'), 'utf8')).scripts['migration:check'])
      .toBe('node scripts/check-migration-authority.mjs');
  });

  it('rejects malformed, duplicate, and unmanifested forward artifacts', () => {
    for (const filename of ['39_x.sql', '0039x.sql', '0039-.sql', '0039.sql.bak', '00039_example.sql']) {
      const root = createFixture();
      write(root, `db/migrations/${filename}`, 'select 1;\n');
      expectFailure(root, 'MALFORMED_FORWARD_FILENAME');
    }
    const root = createFixture();
    write(root, 'db/migrations/0039_example.sql', 'select 1;\n');
    expectFailure(root, 'UNMANIFESTED_FORWARD_SQL');
    const duplicateRoot = createFixture();
    write(duplicateRoot, 'db/migrations/0039_first.sql', 'select 1;\n');
    write(duplicateRoot, 'db/migrations/0039_second.sql', 'select 1;\n');
    expectFailure(duplicateRoot, 'DUPLICATE_FORWARD_NUMBER');
  });

  it('accepts proposed Commit A metadata but rejects an invalid lifecycle and path traversal', () => {
    const root = createFixture();
    addProposed(root);
    expect(checkMigrationAuthority(root).forwardCount).toBe(1);
    const manifest = readManifest(root);
    manifest.migrations[0].status = 'UNREVIEWED';
    writeManifest(root, manifest);
    expectFailure(root, 'INVALID_LIFECYCLE');
    manifest.migrations[0].status = 'PROPOSED';
    manifest.migrations[0].filename = '../0039_escape.sql';
    writeManifest(root, manifest);
    expectFailure(root, 'INVALID_CANONICAL_PATH');
  });

  it('enforces accepted checksum, validation artifacts, and immutable accepted SQL and metadata', () => {
    const root = createFixture();
    const introduction = addProposed(root);
    addAccepted(root, introduction);
    expect(checkMigrationAuthority(root).forwardCount).toBe(1);
    rmSync(join(root, 'docs/duta-v2.5/migrations/0039_VALIDATION.md'));
    expectFailure(root, 'VALIDATION_REFERENCE');
    write(root, 'docs/duta-v2.5/migrations/0039_VALIDATION.md', '# validation\n');
    write(root, 'db/migrations/0039_example.sql', 'create table public.changed (id integer);\n');
    expectFailure(root, 'ACCEPTED_CHECKSUM_MISMATCH');
    runGit(root, ['checkout', '--', 'db/migrations/0039_example.sql']);
    const manifest = readManifest(root);
    manifest.migrations[0].purpose = 'Mutated after acceptance';
    writeManifest(root, manifest);
    expectFailure(root, 'ACCEPTED_METADATA_MUTATION');
  });

  it('requires a real earliest non-merge introduction commit and rejects fake provenance', () => {
    const root = createFixture();
    const introduction = addProposed(root);
    addAccepted(root, introduction);
    const manifest = readManifest(root);
    manifest.migrations[0].introducedCommit = runGit(root, ['rev-parse', 'HEAD~2']);
    writeManifest(root, manifest);
    expectFailure(root, 'INTRODUCED_COMMIT_NOT_EARLIEST_ADD');
  });

  it('rejects a merge commit as introducedCommit', () => {
    const root = createFixture();
    const introduction = addProposed(root);
    runGit(root, ['checkout', '-b', 'evidence-branch']);
    write(root, 'merge-evidence.txt', 'merge evidence\n');
    commit(root, 'branch evidence');
    runGit(root, ['checkout', 'master']);
    runGit(root, ['merge', '--no-ff', 'evidence-branch', '-m', 'merge evidence branch']);
    const mergeCommit = runGit(root, ['rev-parse', 'HEAD']);
    addAccepted(root, mergeCommit);
    expectFailure(root, 'MERGE_INTRODUCTION');
  });

  it('rejects a later containing commit as provenance', () => {
    const laterRoot = createFixture();
    const introduction = addProposed(laterRoot);
    write(laterRoot, 'evidence.txt', 'later commit still contains 0039\n');
    commit(laterRoot, 'intermediate commit containing SQL');
    const laterCommit = runGit(laterRoot, ['rev-parse', 'HEAD']);
    addAccepted(laterRoot, laterCommit);
    expectFailure(laterRoot, 'INTRODUCED_COMMIT_NOT_EARLIEST_ADD');
  });

  it('rejects delete and re-add path reuse', () => {
    const reuseRoot = createFixture();
    const reuseIntroduction = addProposed(reuseRoot);
    addAccepted(reuseRoot, reuseIntroduction);
    runGit(reuseRoot, ['rm', 'db/migrations/0039_example.sql']);
    commit(reuseRoot, 'delete 0039');
    write(reuseRoot, 'db/migrations/0039_example.sql', 'create table public.example (id integer);\n');
    commit(reuseRoot, 're-add 0039');
    expectFailure(reuseRoot, 'PATH_REUSE_OR_NONUNIQUE_ADD');
  });

  it('rejects rename-based provenance', () => {
    const renameRoot = createFixture();
    const renameIntroduction = addProposed(renameRoot);
    addAccepted(renameRoot, renameIntroduction);
    runGit(renameRoot, ['mv', 'db/migrations/0039_example.sql', 'db/migrations/0039_temporary.sql']);
    commit(renameRoot, 'rename 0039 aside');
    runGit(renameRoot, ['mv', 'db/migrations/0039_temporary.sql', 'db/migrations/0039_example.sql']);
    commit(renameRoot, 'restore 0039 path');
    expectFailure(renameRoot, 'RENAME_PROVENANCE');
  });

  it('rejects unsafe dependency declarations and applied-state leakage', () => {
    const root = createFixture();
    addProposed(root);
    const manifest = readManifest(root);
    manifest.migrations[0].dependsOn.migrations = ['0039'];
    writeManifest(root, manifest);
    expectFailure(root, 'SELF_DEPENDENCY');
    manifest.migrations[0].dependsOn.migrations = ['0038'];
    writeManifest(root, manifest);
    expectFailure(root, 'HISTORICAL_NUMBER_ONLY_DEPENDENCY');
    manifest.migrations[0].dependsOn.migrations = [];
    manifest.migrations[0].staging_applied = true;
    writeManifest(root, manifest);
    expectFailure(root, 'APPLIED_STATE_FIELD');
  });

  it('rejects future, missing, and cyclic governed dependencies', () => {
    const futureRoot = createFixture();
    addProposed(futureRoot);
    addProposedEntry(futureRoot, '0040');
    const futureManifest = readManifest(futureRoot);
    futureManifest.migrations[0].dependsOn.migrations = ['0040'];
    writeManifest(futureRoot, futureManifest);
    expectFailure(futureRoot, 'FUTURE_DEPENDENCY');

    const missingRoot = createFixture();
    addProposed(missingRoot);
    addProposedEntry(missingRoot, '0041', ['0040']);
    expectFailure(missingRoot, 'MISSING_FORWARD_DEPENDENCY');

    const cycleRoot = createFixture();
    addProposed(cycleRoot);
    addProposedEntry(cycleRoot, '0040', ['0039']);
    const cycleManifest = readManifest(cycleRoot);
    cycleManifest.migrations[0].dependsOn.migrations = ['0040'];
    writeManifest(cycleRoot, cycleManifest);
    expectFailure(cycleRoot, 'FORWARD_DEPENDENCY_CYCLE');
  });

  it('keeps SUPERSEDED entries at acceptance-grade integrity', () => {
    const root = createFixture();
    const introduction = addProposed(root);
    addAccepted(root, introduction);
    const manifest = readManifest(root);
    manifest.migrations[0].status = 'SUPERSEDED';
    manifest.migrations[0].checksum = null;
    writeManifest(root, manifest);
    expectFailure(root, 'ACCEPTED_CHECKSUM_MISMATCH');
  });

  it('rejects a migration execution command hidden in automatic lifecycle scripts', () => {
    const root = createFixture();
    const packageJson = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
    packageJson.scripts.build = 'drizzle-kit migrate && next build';
    write(root, 'package.json', JSON.stringify(packageJson));
    expectFailure(root, 'AUTOMATIC_MIGRATION_EXECUTION');
  });
});
