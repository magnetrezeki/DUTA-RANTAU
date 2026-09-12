#!/usr/bin/env node
// POSIX/CI counterpart of scripts/run-local-db-tests.ps1.
//
// LOCAL TEST ONLY. NOT FOR PRODUCTION. NEVER POINT THIS AT A HOSTED DATABASE.
//
// Applies tests/db/bootstrap-local-test.sql, tests/db/seed-local-test.sql and
// tests/db/verify-local-test.sql to a disposable loopback PostgreSQL database,
// then runs the APP_DATABASE_URL-blocked tests against it.
//
// Unlike the PowerShell runner this needs no psql and no Docker: SQL is applied
// through the `pg` driver the application already depends on, so the documented
// local-test procedure also works on Linux and macOS CI runners.
//
// Usage:
//   node scripts/run-local-db-tests.mjs \
//     --local-url     "postgresql://duta_app:pw@127.0.0.1:55433/duta_local_test" \
//     --bootstrap-url "postgresql://postgres:pw@127.0.0.1:55433/duta_local_test" \
//     --app-password-env DUTA_LOCAL_APP_PASSWORD \
//     --execute [--full-suite]
//
// Connection strings may instead be supplied as DUTA_LOCAL_DATABASE_URL and
// DUTA_LOCAL_BOOTSTRAP_DATABASE_URL. Prefer the environment form: `npm run
// test:db -- --local-url ...` echoes argv into the log, credentials included.
//
// Without --execute this is a dry run: it validates the targets and exits.

import { spawn } from "node:child_process";
import console from "node:console";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath, URL } from "node:url";
import pg from "pg";

const REPOSITORY_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SQL_FILES = ["bootstrap-local-test.sql", "seed-local-test.sql", "verify-local-test.sql"];
const TARGETED_TESTS = ["tests/source-integrity.test.ts", "tests/ai-router.test.ts"];
const ALLOWED_HOSTS = new Set(["localhost", "127.0.0.1", "::1"]);
const FORBIDDEN_HOST = /supabase\.co|supabase|production|prod/i;
const DATABASE_NAME = /^duta_local_test(?:_[a-z0-9_]+)?$/;

function fail(message) {
  console.error(`[local-db-tests] ${message}`);
  process.exit(1);
}

function parseArgs(argv) {
  const options = {
    localUrl: null,
    bootstrapUrl: null,
    appPasswordEnv: "DUTA_LOCAL_APP_PASSWORD",
    execute: false,
    fullSuite: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--execute") options.execute = true;
    else if (argument === "--full-suite") options.fullSuite = true;
    else if (argument === "--local-url") options.localUrl = argv[++index];
    else if (argument === "--bootstrap-url") options.bootstrapUrl = argv[++index];
    else if (argument === "--app-password-env") options.appPasswordEnv = argv[++index];
    else fail(`Unknown argument: ${argument}`);
  }

  // Environment fallbacks exist so connection strings never need to appear in
  // argv. `npm run test:db -- ...` echoes its arguments verbatim, which would
  // otherwise print embedded credentials into CI logs.
  if (!options.localUrl) options.localUrl = process.env.DUTA_LOCAL_DATABASE_URL ?? null;
  if (!options.bootstrapUrl) options.bootstrapUrl = process.env.DUTA_LOCAL_BOOTSTRAP_DATABASE_URL ?? null;

  return options;
}

// Mirrors Get-SafeLocalDatabaseTarget: loopback-only, non-hosted, correctly named.
function assertSafeLocalTarget(label, connectionUrl) {
  if (!connectionUrl) {
    fail(`--${label} is required (or set the matching DUTA_LOCAL_* environment variable).`);
  }
  let uri;
  try {
    uri = new URL(connectionUrl);
  } catch {
    fail(`The ${label} database URL is malformed.`);
  }

  if (!["postgres:", "postgresql:"].includes(uri.protocol)) {
    fail(`The ${label} database URL must use postgres or postgresql.`);
  }
  const host = uri.hostname.replace(/^\[|\]$/g, "").toLowerCase();
  if (!host) fail(`The ${label} database URL must include a host.`);
  if (FORBIDDEN_HOST.test(host)) {
    fail(`Hosted Supabase and production-style hosts are prohibited (${label}).`);
  }
  if (!ALLOWED_HOSTS.has(host)) {
    fail(`Only localhost, 127.0.0.1, or ::1 may be used (${label}).`);
  }

  const database = uri.pathname.replace(/^\//, "");
  if (!database) fail(`The ${label} database URL must name a database.`);
  if (!DATABASE_NAME.test(database)) {
    fail(`The ${label} database name must be duta_local_test or a duta_local_test_* variant.`);
  }
  return { uri, host, database };
}

function redacted(target) {
  const port = target.uri.port ? `:${target.uri.port}` : "";
  return `${target.uri.protocol}//<redacted>@${target.host}${port}/${target.database}`;
}

// psql meta-commands are not SQL. Only \set is expected; anything else is a
// guard failure rather than something to silently drop.
function stripPsqlMetaCommands(file, sql) {
  const lines = sql.split("\n");
  const meta = lines.filter((line) => line.trimStart().startsWith("\\"));
  const unexpected = meta.filter((line) => !line.trimStart().startsWith("\\set"));
  if (unexpected.length > 0) {
    fail(`${file} contains unsupported psql meta-commands: ${unexpected.join(", ")}`);
  }
  return lines.filter((line) => !line.trimStart().startsWith("\\")).join("\n");
}

function runNpmTest(args, appDatabaseUrl) {
  return new Promise((resolve, reject) => {
    const child = spawn("npm", ["test", "--", ...args], {
      cwd: REPOSITORY_ROOT,
      stdio: "inherit",
      // APP_DATABASE_URL is scoped to this child process only.
      env: { ...process.env, APP_DATABASE_URL: appDatabaseUrl },
    });
    child.on("error", reject);
    child.on("close", (code) => resolve(code ?? 1));
  });
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const target = assertSafeLocalTarget("local-url", options.localUrl);
  const bootstrap = assertSafeLocalTarget("bootstrap-url", options.bootstrapUrl);

  if (target.database !== bootstrap.database) {
    fail("The application and bootstrap URLs must target the same isolated local-test database.");
  }

  console.log(`[local-db-tests] validated isolated target: ${redacted(target)}`);

  if (!options.execute) {
    console.log("[local-db-tests] dry run only. Re-run with --execute after preparing the disposable local database.");
    return;
  }

  const appPassword = process.env[options.appPasswordEnv];
  if (!appPassword) {
    fail(`${options.appPasswordEnv} must hold the disposable duta_app password. It is never logged.`);
  }

  const sqlPaths = SQL_FILES.map((file) => {
    const full = path.join(REPOSITORY_ROOT, "tests", "db", file);
    if (!fs.existsSync(full)) fail(`Required local-test file is missing: ${full}`);
    return { file, full };
  });

  const client = new pg.Client({ connectionString: options.bootstrapUrl });
  await client.connect();
  try {
    for (const { file, full } of sqlPaths) {
      const sql = stripPsqlMetaCommands(file, fs.readFileSync(full, "utf8"));
      await client.query(sql);
      console.log(`[local-db-tests] applied ${file}`);
    }
    // Matches run-disposable-local-db-tests.ps1: the password is assigned after
    // bootstrap creates the restricted role, and is never written to disk.
    await client.query(`ALTER ROLE duta_app PASSWORD '${appPassword.replace(/'/g, "''")}'`);
    console.log("[local-db-tests] duta_app password assigned (process-local)");
  } finally {
    await client.end();
  }

  const targeted = await runNpmTest(TARGETED_TESTS, options.localUrl);
  if (targeted !== 0) fail("The APP_DATABASE_URL-blocked tests failed.");
  console.log("[local-db-tests] targeted database tests passed");

  if (options.fullSuite) {
    const full = await runNpmTest([], options.localUrl);
    if (full !== 0) fail("The full test suite failed.");
    console.log("[local-db-tests] full test suite passed");
  }
}

main().catch((error) => {
  console.error(`[local-db-tests] ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
});
