/* global console, process, setTimeout */
import { execFileSync, spawn } from 'node:child_process';
import { readFileSync } from 'node:fs';

const docker = process.env.DOCKER_BIN || 'docker';
const container = `duta-ai-quota-test-${process.pid}`;
const database = 'duta_ai_quota_test';
const migration = readFileSync('db/migrations/0034_ai_fair_use_foundation.sql', 'utf8');
const userA = '00000000-0000-4000-8000-0000000000a1';
const userB = '00000000-0000-4000-8000-0000000000b2';
const userC = '00000000-0000-4000-8000-0000000000c3';
const userD = '00000000-0000-4000-8000-0000000000d4';
const userE = '00000000-0000-4000-8000-0000000000e5';

function fail(message) { throw new Error(message); }
function assert(condition, message) { if (!condition) fail(message); }
function dockerExec(args, input) {
  return execFileSync(docker, args, { input, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
}
function sql(statement, { allowFailure = false } = {}) {
  try {
    return dockerExec(['exec', '-i', container, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', database, '-At', '-F', '|'], statement);
  } catch (error) {
    if (allowFailure) return String(error.stderr || error.message);
    throw error;
  }
}
function scalar(statement) { return sql(statement).split(/\r?\n/).filter(Boolean).at(-1); }
function quoted(value) { return `'${String(value).replaceAll("'", "''")}'`; }
function call(actor, target, units, limit, requestId, timezone) {
  return sql(`BEGIN;
SET LOCAL ROLE duta_app;
SELECT set_config('app.user_id', ${quoted(actor)}, true);
${timezone ? `SET LOCAL TIME ZONE ${quoted(timezone)};` : ''}
SELECT public.consume_ai_usage(${quoted(target)}::uuid, ${units}, ${limit}, ${quoted(requestId)});
COMMIT;`).split(/\r?\n/).map(line => line.trim()).includes('t');
}
function callFails(actor, target, units, limit, requestId) {
  const result = sql(`BEGIN; SET LOCAL ROLE duta_app; SELECT set_config('app.user_id', ${quoted(actor)}, true); SELECT public.consume_ai_usage(${quoted(target)}::uuid, ${units}, ${limit}, ${quoted(requestId)}); COMMIT;`, { allowFailure: true });
  return /ERROR:|verified application identity is required|invalid ai quota/.test(result);
}
function concurrentCall(actor, target, units, requestId) {
  return new Promise((resolve, reject) => {
    const child = spawn(docker, ['exec', '-i', container, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', database, '-At'], { stdio: ['pipe', 'pipe', 'pipe'] });
    let stdout = ''; let stderr = '';
    child.stdout.on('data', data => { stdout += data; });
    child.stderr.on('data', data => { stderr += data; });
    child.on('error', reject);
    child.on('close', code => {
      if (code !== 0) reject(new Error(stderr));
      else resolve(stdout.split(/\r?\n/).map(line => line.trim()).includes('t'));
    });
    child.stdin.end(`BEGIN; SET LOCAL ROLE duta_app; SELECT set_config('app.user_id', ${quoted(actor)}, true); SELECT pg_sleep(0.2); SELECT public.consume_ai_usage(${quoted(target)}::uuid, ${units}, 30, ${quoted(requestId)}); COMMIT;`);
  });
}

async function main() {
  const results = [];
  const check = (name, fn) => { fn(); results.push(name); };
  try {
    dockerExec(['run', '-d', '--rm', '--name', container, '-e', 'POSTGRES_PASSWORD=local-test-only', '-e', `POSTGRES_DB=${database}`, 'postgres:16-alpine']);
    for (let attempt = 0; attempt < 30; attempt++) {
      try { sql('SELECT 1;'); break; } catch { if (attempt === 29) throw new Error('local PostgreSQL did not become ready'); await new Promise(resolve => setTimeout(resolve, 500)); }
    }

    sql(`CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN; CREATE TABLE public.users (id uuid PRIMARY KEY); INSERT INTO public.users(id) VALUES (${quoted(userA)}), (${quoted(userB)}), (${quoted(userC)}), (${quoted(userD)}), (${quoted(userE)});`);
    const atomicFailure = sql(migration, { allowFailure: true });
    check('migration atomicity', () => {
      assert(/duta_app/.test(atomicFailure), 'migration failure was not controlled by the missing duta_app role');
      assert(scalar("SELECT to_regclass('public.ai_usage_buckets') IS NULL AND to_regprocedure('public.consume_ai_usage(uuid,integer,integer,text)') IS NULL;") === 't', 'partial migration state survived rollback');
    });

    sql(`CREATE ROLE duta_app NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE FUNCTION public.current_app_user_id() RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$ SELECT NULLIF(current_setting('app.user_id', true), '')::uuid $$;
REVOKE ALL ON FUNCTION public.current_app_user_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_app_user_id() TO duta_app;`);
    sql(migration);
    check('valid actor', () => {
      assert(call(userA, userA, 2, 30, 'valid-a'), 'valid actor was not allowed');
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userA)}::uuid;`) === '2', 'valid actor did not increment exactly once');
      assert(scalar(`SELECT count(*)::text FROM public.ai_usage_requests WHERE user_id=${quoted(userA)}::uuid AND request_id='valid-a';`) === '1', 'valid request ledger was not written exactly once');
    });
    check('null actor and mismatch actor', () => {
      assert(callFails('', userA, 1, 30, 'null-actor'), 'null actor did not fail closed');
      assert(callFails(userA, userB, 1, 30, 'mismatch'), 'actor mismatch did not fail closed');
      assert(scalar(`SELECT count(*)::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userB)}::uuid;`) === '0', 'mismatch changed another user bucket');
    });
    check('invalid units and limits', () => {
      for (const [units, limit] of [[0,30],[-1,30],[31,30],[1,0],[1,-1],[1,31],[1,60]]) assert(callFails(userA, userA, units, limit, `invalid-${units}-${limit}`), `invalid quota accepted ${units}/${limit}`);
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userA)}::uuid;`) === '2', 'invalid quota changed usage');
    });
    check('quota denial and denied replay', () => {
      assert(call(userD, userD, 30, 30, 'fill-d'), 'could not fill quota');
      assert(!call(userD, userD, 1, 30, 'denied-d'), 'over-quota request was allowed');
      assert(!call(userD, userD, 1, 30, 'denied-d'), 'denied request replay returned false success');
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userD)}::uuid;`) === '30', 'quota denial exceeded 30');
      assert(scalar(`SELECT count(*)::text FROM public.ai_usage_requests WHERE user_id=${quoted(userD)}::uuid AND request_id='denied-d';`) === '0', 'denied replay ledger survived');
    });
    check('successful replay', () => {
      assert(call(userB, userB, 3, 30, 'replay-b'), 'first replay request failed');
      assert(call(userB, userB, 3, 30, 'replay-b'), 'successful replay was not idempotently allowed');
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userB)}::uuid;`) === '3', 'successful replay double charged');
    });
    const sameId = await Promise.all([concurrentCall(userC, userC, 4, 'same-concurrent'), concurrentCall(userC, userC, 4, 'same-concurrent')]);
    check('concurrent same request id', () => {
      assert(sameId.every(Boolean), 'same request replay did not return idempotent success');
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userC)}::uuid;`) === '4', 'same request concurrency charged more than once');
      assert(scalar(`SELECT count(*)::text FROM public.ai_usage_requests WHERE user_id=${quoted(userC)}::uuid AND request_id='same-concurrent';`) === '1', 'same request concurrency produced ambiguous ledger rows');
    });
    assert(call(userE, userE, 29, 30, 'near-limit'), 'could not establish near-limit quota');
    const differentIds = await Promise.all([concurrentCall(userE, userE, 1, 'different-a'), concurrentCall(userE, userE, 1, 'different-b')]);
    check('concurrent different request ids', () => {
      assert(differentIds.filter(Boolean).length === 1, 'near-limit concurrent requests did not have exactly one allowed result');
      assert(scalar(`SELECT usage_units::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userE)}::uuid;`) === '30', 'concurrent different ids exceeded the ceiling');
    });
    check('UTC period boundary', () => {
      assert(call(userC, userC, 1, 30, 'utc-period', 'Asia/Kuala_Lumpur'), 'UTC boundary call failed');
      assert(scalar(`SELECT date_part('hour', period_start AT TIME ZONE 'UTC')::text || ':' || date_part('minute', period_start AT TIME ZONE 'UTC')::text FROM public.ai_usage_buckets WHERE user_id=${quoted(userC)}::uuid LIMIT 1;`) === '0:0', 'bucket period is not UTC midnight');
    });
    check('security catalog', () => {
      assert(scalar("SELECT relrowsecurity::text FROM pg_class WHERE oid='public.ai_usage_buckets'::regclass;") === 'true', 'bucket RLS is disabled');
      assert(scalar("SELECT relrowsecurity::text FROM pg_class WHERE oid='public.ai_usage_requests'::regclass;") === 'true', 'request RLS is disabled');
      assert(scalar("SELECT has_function_privilege('public', 'public.consume_ai_usage(uuid,integer,integer,text)', 'EXECUTE')::text;") === 'false', 'PUBLIC retains function execution');
      assert(scalar("SELECT (has_function_privilege('anon'::name, 'public.consume_ai_usage(uuid,integer,integer,text)'::regprocedure, 'EXECUTE') OR has_function_privilege('authenticated'::name, 'public.consume_ai_usage(uuid,integer,integer,text)'::regprocedure, 'EXECUTE'))::text;") === 'false', 'anon/authenticated retain function execution');
      assert(scalar("SELECT prosecdef::text FROM pg_proc WHERE oid='public.consume_ai_usage(uuid,integer,integer,text)'::regprocedure;") === 'true', 'quota function is not security definer');
      const searchPath = scalar("SELECT coalesce(array_to_string(proconfig, ','), '') FROM pg_proc WHERE oid='public.consume_ai_usage(uuid,integer,integer,text)'::regprocedure;");
      assert(searchPath === 'search_path=' || searchPath === 'search_path=""', `quota function search_path is not empty (${searchPath})`);
      assert(scalar("SELECT NOT rolsuper AND NOT rolbypassrls FROM pg_roles WHERE rolname='duta_app';") === 't', 'duta_app has privileged role attributes');
      assert(scalar("SELECT has_table_privilege('duta_app', 'public.ai_usage_buckets', 'SELECT') AND NOT has_table_privilege('duta_app', 'public.ai_usage_buckets', 'INSERT,UPDATE,DELETE') AND NOT has_table_privilege('duta_app', 'public.ai_usage_requests', 'SELECT,INSERT,UPDATE,DELETE');") === 't', 'duta_app direct table privileges exceed the intended read-only boundary');
      assert(scalar("SELECT NOT has_table_privilege('public', 'public.ai_usage_buckets', 'SELECT,INSERT,UPDATE,DELETE') AND NOT has_table_privilege('public', 'public.ai_usage_requests', 'SELECT,INSERT,UPDATE,DELETE');") === 't', 'PUBLIC has broad quota-table privileges');
    });
    console.log(`AI DB quota proof PASS (${results.length} assertions): ${results.join(', ')}`);
  } finally {
    try { dockerExec(['rm', '-f', container]); } catch { /* best-effort cleanup after a failed bootstrap */ }
  }
}

main().catch(error => { console.error(`AI DB quota proof FAIL: ${error instanceof Error ? error.message : String(error)}`); process.exitCode = 1; });
