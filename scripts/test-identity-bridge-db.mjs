/* global console, process, setTimeout */
/**
 * Narrow Layer-E regression proof for the identity-bridge invariant, using the
 * same disposable PostgreSQL pattern as scripts/test-ai-quota-db.mjs.
 *
 * It applies the real governed db/migrations/0035_ai_telemetry_foundation.sql
 * against a real restricted duta_app role and asserts, at the database layer,
 * that ai_telemetry_insert_self is only satisfiable when the transaction has
 * established a matching app.user_id.
 *
 * No schema change, no application endpoint, no governed database touched.
 */
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const docker = process.env.DOCKER_BIN || 'docker';
const container = `duta-identity-bridge-test-${process.pid}`;
const database = 'duta_identity_bridge_test';
const migration = readFileSync('db/migrations/0035_ai_telemetry_foundation.sql', 'utf8');
const userA = '00000000-0000-4000-8000-0000000000a1';
const userB = '00000000-0000-4000-8000-0000000000b2';

const columns = '(user_ref,intent,risk,sensitivity,model_class,source_requirement,quota_outcome,weighted_units,input_tokens,output_tokens,success)';

function assert(condition, message) { if (!condition) throw new Error(message); }
function psql(statement, { allowFailure = false } = {}) {
  try {
    return execFileSync(docker, ['exec', '-i', container, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', database, '-At'], { input: statement, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
  } catch (error) {
    if (allowFailure) return String(error.stderr || error.message);
    throw error;
  }
}
function scalar(statement) { return psql(statement).split(/\r?\n/).filter(Boolean).at(-1); }
function quoted(value) { return `'${String(value).replaceAll("'", "''")}'`; }
function insert(actor, userRef) {
  return psql(`BEGIN;
SET LOCAL ROLE duta_app;
${actor === null ? '' : `SELECT set_config('app.user_id', ${quoted(actor)}, true);`}
INSERT INTO public.ai_telemetry_events ${columns} VALUES (${userRef === null ? 'NULL' : `${quoted(userRef)}::uuid`},'GENERAL','low','PUBLIC','L1_SIMPLE','NONE','allowed',1,1,0,true);
COMMIT;`, { allowFailure: true });
}
function insertAllowed(actor, userRef) { return !/ERROR:/.test(insert(actor, userRef)); }

async function main() {
  const results = [];
  const check = (name, fn) => { fn(); results.push(name); };
  try {
    execFileSync(docker, ['run', '-d', '--rm', '--name', container, '-e', 'POSTGRES_PASSWORD=local-test-only', '-e', `POSTGRES_DB=${database}`, 'postgres:16-alpine'], { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
    for (let attempt = 0; attempt < 30; attempt++) {
      try { psql('SELECT 1;'); break; } catch { if (attempt === 29) throw new Error('local PostgreSQL did not become ready'); await new Promise(resolve => setTimeout(resolve, 500)); }
    }

    psql(`CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN;
CREATE ROLE duta_app NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE TABLE public.users (id uuid PRIMARY KEY);
INSERT INTO public.users(id) VALUES (${quoted(userA)}), (${quoted(userB)});
CREATE FUNCTION public.current_app_user_id() RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$ SELECT NULLIF(current_setting('app.user_id', true), '')::uuid $$;
REVOKE ALL ON FUNCTION public.current_app_user_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_app_user_id() TO duta_app;`);
    psql(migration);

    check('restricted runtime role', () => {
      assert(scalar("SELECT NOT rolsuper AND NOT rolbypassrls AND NOT rolcreatedb AND NOT rolcreaterole AND NOT rolreplication FROM pg_roles WHERE rolname='duta_app';") === 't', 'duta_app is not a restricted role');
      assert(scalar("SELECT count(*)::text FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace JOIN pg_roles r ON r.oid=c.relowner WHERE n.nspname='public' AND r.rolname='duta_app';") === '0', 'duta_app owns a table and could bypass RLS');
      assert(scalar("SELECT relrowsecurity::text FROM pg_class WHERE oid='public.ai_telemetry_events'::regclass;") === 'true', 'ai_telemetry_events RLS is disabled');
      assert(scalar("SELECT count(*)::text FROM pg_policies WHERE schemaname='public' AND tablename='ai_telemetry_events' AND policyname='ai_telemetry_insert_self';") === '1', 'governed telemetry policy is missing');
    });

    check('matching actor is permitted', () => {
      assert(insertAllowed(userA, userA), 'matching actor context was not permitted');
      assert(scalar(`SELECT count(*)::text FROM public.ai_telemetry_events WHERE user_ref=${quoted(userA)}::uuid;`) === '1', 'permitted insert did not persist exactly once');
    });

    check('missing identity fails closed', () => {
      assert(!insertAllowed(null, userA), 'insert without app.user_id was allowed');
      assert(!insertAllowed('', userA), 'insert with a blank app.user_id was allowed');
      assert(scalar('SELECT public.current_app_user_id() IS NULL;') === 't', 'blank identity was not NULL');
    });

    check('mismatched actor and null owner fail closed', () => {
      assert(!insertAllowed(userA, userB), 'actor A writing as user B was allowed');
      assert(!insertAllowed(userA, null), 'actor A writing an unowned row was allowed');
      assert(scalar(`SELECT count(*)::text FROM public.ai_telemetry_events WHERE user_ref IS DISTINCT FROM ${quoted(userA)}::uuid;`) === '0', 'a denied write persisted another actor row');
      assert(scalar('SELECT count(*)::text FROM public.ai_telemetry_events;') === '1', 'denied writes changed the table');
    });

    check('transaction-local identity does not leak after commit or rollback', () => {
      assert(scalar(`BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id', ${quoted(userA)}, true);COMMIT;
BEGIN;SET LOCAL ROLE duta_app;SELECT coalesce(public.current_app_user_id()::text, 'NULL');ROLLBACK;`) === 'NULL', 'identity leaked after commit');
      assert(scalar(`BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id', ${quoted(userA)}, true);ROLLBACK;
BEGIN;SET LOCAL ROLE duta_app;SELECT coalesce(public.current_app_user_id()::text, 'NULL');ROLLBACK;`) === 'NULL', 'identity leaked after rollback');
    });

    check('runtime role keeps least privilege', () => {
      assert(scalar("SELECT has_table_privilege('duta_app','public.ai_telemetry_events','INSERT') AND NOT has_table_privilege('duta_app','public.ai_telemetry_events','SELECT,UPDATE,DELETE');") === 't', 'duta_app telemetry privileges exceed INSERT-only');
      assert(scalar("SELECT NOT has_table_privilege('anon','public.ai_telemetry_events','SELECT,INSERT,UPDATE,DELETE') AND NOT has_table_privilege('authenticated','public.ai_telemetry_events','SELECT,INSERT,UPDATE,DELETE');") === 't', 'anon/authenticated hold telemetry privileges');
      assert(scalar("SELECT NOT has_schema_privilege('duta_app','public','CREATE');") === 't', 'duta_app can create schema objects');
      assert(scalar("SELECT NOT EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='ai_telemetry_events' AND cmd='SELECT');") === 't', 'telemetry became readable');
    });

    console.log(`Identity bridge DB proof PASS (${results.length} checks): ${results.join(', ')}`);
  } finally {
    try { execFileSync(docker, ['rm', '-f', container], { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }); } catch { /* best-effort cleanup after a failed bootstrap */ }
  }
}

main().catch(error => { console.error(`Identity bridge DB proof FAIL: ${error instanceof Error ? error.message : String(error)}`); process.exitCode = 1; });
