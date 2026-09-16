/* global console, process */
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const HISTORICAL_CEILING = 38;
const FIRST_FORWARD = 39;
const FORWARD_FILENAME = /^(\d{4})_([a-z0-9]+(?:_[a-z0-9]+)*)\.sql$/;
const HISTORICAL_FILENAME = /^(\d{4})_.+\.sql$/;
const SHA256 = /^[a-f0-9]{64}$/;
const GIT_SHA = /^[a-f0-9]{40}$/;
const STATUSES = new Set(['PROPOSED', 'REVIEWED', 'AUTHORITY_ACCEPTED', 'SUPERSEDED']);
const SCHEMA_EFFECTS = new Set(['NONE', 'ADDITIVE', 'ALTERING', 'DESTRUCTIVE', 'MIXED']);
const SECURITY_EFFECTS = new Set(['NONE', 'AUTHORIZATION', 'RLS', 'ROLE_GRANT', 'SECURITY_FUNCTION', 'AUTHENTICATION', 'MULTIPLE']);
const DATA_EFFECTS = new Set(['NONE', 'BACKFILL', 'TRANSFORM', 'DELETE', 'MIXED']);
const ROLLBACKS = new Set(['REVERSIBLE', 'FORWARD_FIX_ONLY', 'DATA_BACKUP_REQUIRED', 'MANUAL_RECOVERY', 'IRREVERSIBLE']);
const DEPENDENCY_KEYS = ['migrations', 'tables', 'columns', 'functions', 'roles', 'extensions', 'security'];
const APPLIED_KEYS = new Set(['applied', 'appliedat', 'executed', 'executedat', 'deployed', 'deploymentstatus', 'environment', 'stagingapplied', 'productionapplied', 'databasestate']);
const IMMUTABLE_FIELDS = ['number', 'filename', 'purpose', 'dependsOn', 'checksum', 'introducedCommit', 'schemaEffect', 'securityEffects', 'requiresRlsValidation', 'requiresDataBackfill', 'dataEffect', 'rollback', 'validationContract'];

export class GovernanceError extends Error {
  constructor(code, message) {
    super(`${code}: ${message}`);
    this.code = code;
  }
}

function fail(code, message) { throw new GovernanceError(code, message); }
function readJson(file) {
  try { return JSON.parse(readFileSync(file, 'utf8')); }
  catch { fail('MANIFEST_PARSE_ERROR', `cannot parse ${toRepoPath(file)}`); }
}
function hashFile(file) { return createHash('sha256').update(readFileSync(file)).digest('hex'); }
function toRepoPath(file, root = process.cwd()) { return path.relative(root, file).split(path.sep).join('/'); }
function isPlainObject(value) { return value !== null && typeof value === 'object' && !Array.isArray(value); }
function safeResolve(root, relative) {
  if (typeof relative !== 'string' || path.isAbsolute(relative)) fail('INVALID_PATH', 'manifest filename must be a relative path');
  const target = path.resolve(root, relative);
  const base = path.resolve(root);
  if (target !== base && !target.startsWith(`${base}${path.sep}`)) fail('PATH_TRAVERSAL', `path escapes repository: ${relative}`);
  return target;
}
function assertString(value, code, label) {
  if (typeof value !== 'string' || value.trim() === '') fail(code, `${label} must be a non-empty string`);
}
function canonicalAppliedKey(key) { return String(key).toLowerCase().replace(/[^a-z0-9]/g, ''); }
function assertNoAppliedState(value) {
  if (Array.isArray(value)) return value.forEach(assertNoAppliedState);
  if (!isPlainObject(value)) return;
  for (const [key, nested] of Object.entries(value)) {
    if (APPLIED_KEYS.has(canonicalAppliedKey(key))) fail('APPLIED_STATE_FIELD', `manifest contains prohibited applied-state key: ${key}`);
    assertNoAppliedState(nested);
  }
}
function runGit(root, args) {
  try { return execFileSync('git', args, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim(); }
  catch { fail('GIT_UNAVAILABLE_OR_INVALID', `cannot establish required Git evidence for ${args[0]}`); }
}
function verifyGitAvailable(root) { runGit(root, ['--version']); }
function stable(value) {
  if (Array.isArray(value)) return `[${value.map(stable).join(',')}]`;
  if (isPlainObject(value)) return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${stable(value[key])}`).join(',')}}`;
  return JSON.stringify(value);
}

function historicalFiles(migrationDir) {
  const entries = [];
  for (const name of readdirSync(migrationDir)) {
    const full = path.join(migrationDir, name);
    if (!statSync(full).isFile() || !name.endsWith('.sql')) continue;
    const numericPrefix = name.match(/^(\d+)/);
    if (!numericPrefix || Number(numericPrefix[1]) > HISTORICAL_CEILING) continue;
    if (!HISTORICAL_FILENAME.test(name)) fail('MALFORMED_HISTORICAL_FILENAME', name);
    entries.push({ number: numericPrefix[1], filename: name });
  }
  entries.sort((a, b) => a.filename.localeCompare(b.filename));
  if (new Set(entries.map((entry) => entry.number)).size !== entries.length) fail('DUPLICATE_HISTORICAL_NUMBER', 'historical migration number is duplicated');
  return entries;
}

function verifyHistorical(root, manifest) {
  const migrationDir = path.join(root, 'db', 'migrations');
  const integrity = manifest.historicalIntegrity;
  if (!isPlainObject(integrity) || integrity.algorithm !== 'SHA-256' || !Array.isArray(integrity.files)) fail('HISTORICAL_INTEGRITY_INVALID', 'locked historicalIntegrity is invalid');
  const actual = historicalFiles(migrationDir);
  if (actual.length !== 35 || integrity.files.length !== 35) fail('HISTORICAL_COUNT', `expected 35 historical migrations, found ${actual.length}`);
  const expectedGaps = ['0004', '0005', '0006', '0007'];
  if (stable(integrity.missingNumbers) !== stable(expectedGaps)) fail('HISTORICAL_GAPS', 'locked historical gaps differ');
  if (stable(actual.map((entry) => entry.filename)) !== stable(integrity.files.map((entry) => entry.filename))) fail('HISTORICAL_FILESET', 'historical migration filenames differ from locked manifest');
  for (const entry of integrity.files) {
    if (!isPlainObject(entry) || !SHA256.test(entry.sha256 ?? '')) fail('HISTORICAL_HASH_FORMAT', 'historical checksum is invalid');
    const file = safeResolve(migrationDir, entry.filename);
    if (!existsSync(file) || hashFile(file) !== entry.sha256) fail('HISTORICAL_HASH_MISMATCH', String(entry.filename));
  }
}

function discoverForwardFiles(migrationDir) {
  const canonical = [];
  for (const name of readdirSync(migrationDir)) {
    const full = path.join(migrationDir, name);
    if (!statSync(full).isFile()) continue;
    const digits = name.match(/^(\d+)/);
    if (!digits || Number(digits[1]) < FIRST_FORWARD) continue;
    const match = name.match(FORWARD_FILENAME);
    if (!match || Number(match[1]) < FIRST_FORWARD) fail('MALFORMED_FORWARD_FILENAME', name);
    canonical.push({ number: match[1], filename: name, file: full });
  }
  canonical.sort((a, b) => Number(a.number) - Number(b.number) || a.filename.localeCompare(b.filename));
  const duplicate = canonical.find((item, index) => index > 0 && item.number === canonical[index - 1].number);
  if (duplicate) fail('DUPLICATE_FORWARD_NUMBER', `${duplicate.number}: ${duplicate.filename}`);
  return canonical;
}

function assertDependencies(entry, allEntries) {
  if (!isPlainObject(entry.dependsOn) || stable(Object.keys(entry.dependsOn).sort()) !== stable([...DEPENDENCY_KEYS].sort())) fail('DEPENDENCY_SHAPE', entry.number);
  for (const key of DEPENDENCY_KEYS) {
    const values = entry.dependsOn[key];
    if (!Array.isArray(values) || values.some((value) => typeof value !== 'string' || value.trim() === '')) fail('DEPENDENCY_VALUE', `${entry.number}.${key}`);
    if (new Set(values).size !== values.length) fail('DUPLICATE_DEPENDENCY', `${entry.number}.${key}`);
  }
  const migrations = entry.dependsOn.migrations;
  for (const dependency of migrations) {
    if (!/^\d{4}$/.test(dependency)) fail('INVALID_MIGRATION_DEPENDENCY', `${entry.number}: ${dependency}`);
    const value = Number(dependency);
    if (value === Number(entry.number)) fail('SELF_DEPENDENCY', entry.number);
    if (value > Number(entry.number)) fail('FUTURE_DEPENDENCY', `${entry.number}: ${dependency}`);
    if (value >= FIRST_FORWARD && !allEntries.has(dependency)) fail('MISSING_FORWARD_DEPENDENCY', `${entry.number}: ${dependency}`);
  }
  if (migrations.some((value) => Number(value) <= HISTORICAL_CEILING)) {
    const objectDependencies = ['tables', 'columns', 'functions', 'roles', 'extensions', 'security'].flatMap((key) => entry.dependsOn[key]);
    if (objectDependencies.length === 0) fail('HISTORICAL_NUMBER_ONLY_DEPENDENCY', entry.number);
  }
}

function assertNoForwardCycles(entries) {
  const byNumber = new Map(entries.map((entry) => [entry.number, entry]));
  const visiting = new Set();
  const visited = new Set();
  const walk = (number) => {
    if (visiting.has(number)) fail('FORWARD_DEPENDENCY_CYCLE', number);
    if (visited.has(number)) return;
    visiting.add(number);
    const dependencies = Array.isArray(byNumber.get(number).dependsOn?.migrations)
      ? byNumber.get(number).dependsOn.migrations
      : [];
    for (const dependency of dependencies) if (dependency !== number && byNumber.has(dependency)) walk(dependency);
    visiting.delete(number); visited.add(number);
  };
  entries.forEach((entry) => walk(entry.number));
}

function historyEvents(root, targetPath) {
  const output = runGit(root, ['log', '--format=@@%H', '--name-status', '-M', 'HEAD', '--', 'db/migrations']);
  const events = { adds: [], deletes: [], renames: [] };
  let commit = null;
  for (const line of output.split(/\r?\n/)) {
    if (line.startsWith('@@')) { commit = line.slice(2); continue; }
    if (!commit || line === '') continue;
    const parts = line.split('\t');
    const status = parts[0] ?? '';
    if (status === 'A' && parts[1] === targetPath) events.adds.push(commit);
    if (status === 'D' && parts[1] === targetPath) events.deletes.push(commit);
    if (status.startsWith('R') && (parts[1] === targetPath || parts[2] === targetPath)) events.renames.push(commit);
  }
  return events;
}

function verifyProvenance(root, entry) {
  verifyGitAvailable(root);
  if (runGit(root, ['rev-parse', '--is-shallow-repository']) === 'true') fail('SHALLOW_HISTORY', entry.number);
  if (!GIT_SHA.test(entry.introducedCommit ?? '')) fail('INTRODUCED_COMMIT_FORMAT', entry.number);
  const parentParts = runGit(root, ['rev-list', '--parents', '-n', '1', entry.introducedCommit]).split(' ');
  if (parentParts.length > 2) fail('MERGE_INTRODUCTION', entry.filename);
  const target = `db/migrations/${entry.filename}`;
  const events = historyEvents(root, target);
  if (events.renames.length) fail('RENAME_PROVENANCE', entry.filename);
  if (events.deletes.length || events.adds.length !== 1) fail('PATH_REUSE_OR_NONUNIQUE_ADD', entry.filename);
  const actual = events.adds[0];
  if (entry.introducedCommit !== actual) fail('INTRODUCED_COMMIT_NOT_EARLIEST_ADD', `${entry.number}: expected ${actual}`);
  try { execFileSync('git', ['cat-file', '-e', `${actual}:${target}`], { cwd: root, stdio: 'ignore' }); }
  catch { fail('INTRODUCED_COMMIT_MISSING_PATH', entry.filename); }
}

function manifestAt(root, commit) {
  try { return JSON.parse(execFileSync('git', ['show', `${commit}:db/migrations/forward-manifest.json`], { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] })); }
  catch { return null; }
}
function verifyAcceptedImmutability(root, entry) {
  const commits = runGit(root, ['log', '--format=%H', 'HEAD', '--', 'db/migrations/forward-manifest.json']).split(/\r?\n/).filter(Boolean);
  const snapshots = commits.map((commit) => manifestAt(root, commit)).filter(Boolean)
    .map((manifest) => manifest.migrations?.find((candidate) => candidate.number === entry.number))
    .filter((candidate) => candidate && ['AUTHORITY_ACCEPTED', 'SUPERSEDED'].includes(candidate.status));
  if (snapshots.length === 0) fail('ACCEPTED_HISTORY_MISSING', entry.number);
  const first = snapshots.at(-1);
  for (const field of IMMUTABLE_FIELDS) if (stable(first[field]) !== stable(entry[field])) fail('ACCEPTED_METADATA_MUTATION', `${entry.number}.${field}`);
}

function validateEntry(root, entry, allEntries, forwardFiles) {
  assertNoAppliedState(entry);
  if (!isPlainObject(entry) || !/^\d{4}$/.test(entry.number ?? '') || Number(entry.number) < FIRST_FORWARD) fail('INVALID_FORWARD_NUMBER', String(entry?.number));
  if (!STATUSES.has(entry.status)) fail('INVALID_LIFECYCLE', entry.number);
  if (!FORWARD_FILENAME.test(entry.filename ?? '') || !entry.filename.startsWith(`${entry.number}_`)) fail('INVALID_CANONICAL_PATH', entry.number);
  assertString(entry.purpose, 'INVALID_PURPOSE', entry.number);
  if (!SCHEMA_EFFECTS.has(entry.schemaEffect) || !Array.isArray(entry.securityEffects) || entry.securityEffects.length === 0 || entry.securityEffects.some((effect) => !SECURITY_EFFECTS.has(effect))) fail('INVALID_EFFECT_CLASSIFICATION', entry.number);
  if (entry.securityEffects.includes('NONE') || entry.securityEffects.includes('MULTIPLE')) if (entry.securityEffects.length !== 1) fail('INVALID_SECURITY_EFFECT_COMBINATION', entry.number);
  if (typeof entry.requiresRlsValidation !== 'boolean' || (entry.securityEffects.includes('RLS') && !entry.requiresRlsValidation)) fail('INVALID_RLS_REQUIREMENT', entry.number);
  if (typeof entry.requiresDataBackfill !== 'boolean' || !DATA_EFFECTS.has(entry.dataEffect) || (entry.dataEffect === 'BACKFILL' && !entry.requiresDataBackfill) || (entry.requiresDataBackfill && entry.dataEffect === 'NONE')) fail('INVALID_DATA_REQUIREMENT', entry.number);
  if (!isPlainObject(entry.rollback) || !ROLLBACKS.has(entry.rollback.classification)) fail('INVALID_ROLLBACK', entry.number);
  assertDependencies(entry, allEntries);
  const file = safeResolve(path.join(root, 'db', 'migrations'), entry.filename);
  if (!existsSync(file) || !forwardFiles.has(entry.filename)) fail('MANIFEST_SQL_MISSING', entry.filename);
  if (!isPlainObject(entry.validationContract)) fail('INVALID_VALIDATION_CONTRACT', entry.number);

  const accepted = entry.status === 'AUTHORITY_ACCEPTED' || entry.status === 'SUPERSEDED';
  if (!accepted) {
    if (entry.introducedCommit !== null || entry.checksum !== null || entry.validationContract.status !== 'PENDING_MA03' || entry.validationContract.reference !== null) fail('PRE_ACCEPTANCE_METADATA', entry.number);
    return;
  }
  if (!/^sha256:[a-f0-9]{64}$/.test(entry.checksum ?? '') || entry.checksum !== `sha256:${hashFile(file)}`) fail('ACCEPTED_CHECKSUM_MISMATCH', entry.number);
  const validationPath = `docs/duta-v2.5/migrations/${entry.number}_VALIDATION.md`;
  if (entry.validationContract.status === 'PENDING_MA03' || entry.validationContract.reference !== validationPath || !existsSync(safeResolve(root, validationPath))) fail('VALIDATION_REFERENCE', entry.number);
  const fixtureRoot = path.join(root, 'tests', 'db', 'migrations', entry.number);
  for (const name of ['prestate.sql', 'verify.sql']) if (!existsSync(path.join(fixtureRoot, name))) fail('VALIDATION_ARTIFACT_MISSING', `${entry.number}/${name}`);
  if (!entry.securityEffects.includes('NONE') && !existsSync(path.join(fixtureRoot, 'security-verify.sql'))) fail('SECURITY_VALIDATION_ARTIFACT_MISSING', entry.number);
  verifyProvenance(root, entry);
  verifyAcceptedImmutability(root, entry);
}

function verifyNoAutomaticMigration(root) {
  const packagePath = path.join(root, 'package.json');
  if (!existsSync(packagePath)) return;
  const scripts = readJson(packagePath).scripts ?? {};
  for (const [name, command] of Object.entries(scripts)) {
    if (!['build', 'start', 'deploy', 'postbuild', 'prestart', 'predeploy'].includes(name)) continue;
    if (typeof command === 'string' && /(drizzle-kit\s+migrate|\bdb:migrate\b|\bpsql\b|\bpostgres(?:ql)?\b.*\s-f)/i.test(command)) fail('AUTOMATIC_MIGRATION_EXECUTION', name);
  }
}

export function checkMigrationAuthority(root = process.cwd()) {
  const manifestPath = path.join(root, 'db', 'migrations', 'forward-manifest.json');
  if (!existsSync(manifestPath)) fail('MANIFEST_MISSING', 'db/migrations/forward-manifest.json');
  const manifest = readJson(manifestPath);
  assertNoAppliedState(manifest);
  if (manifest.authorityVersion !== 1 || manifest.manifestSchemaVersion !== 1 || manifest.authorityModel !== 'FORWARD_ONLY_DIRECT_SQL' || manifest.historicalCeiling !== '0038' || manifest.firstForwardMigration !== '0039') fail('AUTHORITY_MODEL_MISMATCH', 'locked migration authority is not present');
  verifyHistorical(root, manifest);
  if (!Array.isArray(manifest.migrations)) fail('FORWARD_MANIFEST_INVALID', 'migrations must be an array');
  const files = discoverForwardFiles(path.join(root, 'db', 'migrations'));
  const entries = manifest.migrations;
  const byNumber = new Map();
  for (const entry of entries) {
    if (!isPlainObject(entry) || byNumber.has(entry.number)) fail('DUPLICATE_MANIFEST_NUMBER', String(entry?.number));
    byNumber.set(entry.number, entry);
  }
  const forwardNames = new Set(files.map((file) => file.filename));
  for (const file of files) if (!byNumber.has(file.number)) fail('UNMANIFESTED_FORWARD_SQL', file.filename);
  assertNoForwardCycles(entries);
  for (const entry of entries) validateEntry(root, entry, byNumber, forwardNames);
  const ordered = [...byNumber.keys()].map(Number).sort((a, b) => a - b);
  ordered.forEach((number, index) => { if (number !== FIRST_FORWARD + index) fail('FORWARD_NUMBER_SEQUENCE', String(number)); });
  verifyNoAutomaticMigration(root);
  return { historicalCount: 35, forwardCount: files.length };
}

const invokedAsCli = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (invokedAsCli) {
  try {
    const result = checkMigrationAuthority(process.cwd());
    console.log(`MIGRATION_AUTHORITY_CHECK: PASS (historical=${result.historicalCount}, forward=${result.forwardCount})`);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'unknown failure';
    console.error(`MIGRATION_AUTHORITY_CHECK: FAIL\n${message}`);
    process.exitCode = 1;
  }
}
