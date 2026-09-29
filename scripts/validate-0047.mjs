/* global console, process */
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createHash, randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const docker = process.env.DOCKER_EXE || 'docker';
const name = `duta-r47-${randomUUID()}`;
const database = 'r47_disposable';
const migration = 'db/migrations/0047_official_news_transition_execute_hardening.sql';
const read = (relative) => readFileSync(path.join(root, relative), 'utf8');
const hash = (relative) => createHash('sha256').update(readFileSync(path.join(root, relative))).digest('hex');
const run = (args, input) => execFileSync(docker, args, { cwd: root, input, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
const sql = (text) => run(['exec', '-i', '--user', 'postgres', name, 'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', database], text);
const pass = (marker) => console.log(`${marker}=PASS`);
let created = false;
try {
  assert.equal(hash('db/migrations/0045_official_news_editorial_foundation.sql'), '55d87fb56764c47419fd61b5a85ed6d8772b6aa376c8119e4335480ddf2c8059');
  assert.equal(hash('db/migrations/0046_official_news_public_publishing_contract.sql'), 'fe6f75a5393ad376968d9c8bfd416c5d3edeb5394cd00b8251154e605a550a65');
  run(['run', '-d', '--rm', '--name', name, '-e', 'POSTGRES_HOST_AUTH_METHOD=trust', '-e', `POSTGRES_DB=${database}`, 'postgres:17-alpine']); created = true;
  let ready = false;
  for (let attempt = 0; attempt < 60; attempt += 1) { try { run(['exec', name, 'pg_isready', '-U', 'postgres', '-d', database]); ready = true; break; } catch { Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 1000); } }
  assert(ready, 'disposable PostgreSQL 17 did not become ready');
  sql(read('db/baselines/DUTA_V2_5_BASELINE_V1.sql'));
  const manifest = JSON.parse(read('db/migrations/forward-manifest.json'));
  for (const entry of manifest.migrations.filter((entry) => Number(entry.number) >= 39 && Number(entry.number) <= 46)) { assert.equal(entry.status, 'AUTHORITY_ACCEPTED'); assert.equal(hash(`db/migrations/${entry.filename}`), entry.checksum.slice(7)); sql(read(`db/migrations/${entry.filename}`)); }
  pass('CANONICAL_0039_TO_0046_PROVISIONING');
  assert.match(sql("SELECT has_function_privilege('anon','public.transition_official_news_story(uuid,public.official_news_event_type)','EXECUTE')::text;"), /true/);
  sql(read(migration)); sql(read('tests/db/migrations/0047/verify.sql')); sql(read('tests/db/migrations/0047/security-verify.sql')); pass('0047_PRIVILEGE_HARDENING');
  sql("INSERT INTO public.users(id,email,name,role) VALUES ('10000000-0000-4000-8000-000000000047','fixture-0047@example.test','Fixture','EDITOR'); INSERT INTO public.official_sources(id,institution,channel,url,category,priority,source_purpose,active,last_checked) VALUES ('20000000-0000-4000-8000-000000000047','Fixture','WEBSITE','https://fixture.test/0047','news','P1','NEWS',true,now()); INSERT INTO public.official_news_stories(id,display_title,concise_summary,what_text,five_w_context,content_type,canonical_official_source_id,canonical_url,created_by) VALUES ('30000000-0000-4000-8000-000000000047','Fixture','Summary','What','{\"version\":1,\"who\":{\"state\":\"NOT_STATED\"},\"where\":{\"state\":\"NOT_STATED\"},\"when\":{\"state\":\"NOT_STATED\"},\"why\":{\"state\":\"NOT_STATED\"}}','NOTICE','20000000-0000-4000-8000-000000000047','https://fixture.test/0047/story','10000000-0000-4000-8000-000000000047'); INSERT INTO public.official_news_story_source_references(story_id,official_source_id,original_url,canonical_url,created_by) VALUES ('30000000-0000-4000-8000-000000000047','20000000-0000-4000-8000-000000000047','https://fixture.test/0047/original','https://fixture.test/0047/story','10000000-0000-4000-8000-000000000047'); BEGIN; SET LOCAL ROLE duta_app; SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000047',true); SELECT public.assign_official_news_public_slug('30000000-0000-4000-8000-000000000047','fixture-0047'); SELECT public.transition_official_news_story('30000000-0000-4000-8000-000000000047','VERIFIED_BY_EDITOR'); SELECT public.transition_official_news_story('30000000-0000-4000-8000-000000000047','PUBLISHED'); ROLLBACK;"); pass('DUTA_APP_TRANSITION_REGRESSION');
  sql("BEGIN; SET LOCAL ROLE anon; DO $$ BEGIN BEGIN PERFORM public.transition_official_news_story('30000000-0000-4000-8000-000000000047','PUBLISHED'); RAISE EXCEPTION 'anon transition unexpectedly executed'; EXCEPTION WHEN insufficient_privilege THEN NULL; END; END $$; ROLLBACK;"); pass('ANON_TRANSITION_DENIAL');
  console.log(`0047_SHA256=${hash(migration)}`);
} catch (error) {
  console.error(error.stderr?.toString() || error.message);
  if (created) {
    try { console.error(run(['logs', name])); } catch { /* container may already be gone */ }
  }
  process.exitCode = 1;
}
finally { if (created) { try { run(['rm', '-f', name]); pass('DISPOSABLE_CLEANUP'); } catch { console.error('DISPOSABLE_CLEANUP=FAIL'); process.exitCode = 1; } } }
