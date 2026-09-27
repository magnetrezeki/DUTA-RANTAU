/* global console, process */
import { execFileSync } from 'node:child_process';
import { createHash, randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { setTimeout } from 'node:timers';
import assert from 'node:assert/strict';
import { checkMigrationAuthority } from './check-migration-authority.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const docker=process.env.DOCKER_EXE || 'C:/Users/User/AppData/Local/Programs/DockerDesktop/resources/bin/docker.exe';
const name=`duta-r46-astra-${randomUUID()}`;
const database='r46_disposable';
const candidate='db/migrations/0046_official_news_public_publishing_contract.sql';
const read=p=>readFileSync(path.join(root,p),'utf8');
const hash=p=>createHash('sha256').update(readFileSync(path.join(root,p))).digest('hex');
const sha=hash(candidate);
const expectedSha='fe6f75a5393ad376968d9c8bfd416c5d3edeb5394cd00b8251154e605a550a65';
const results=[];
function pass(marker){ results.push(marker); console.log(`${marker}=PASS`); }
function run(args,input){return execFileSync(docker,args,{input,encoding:'utf8',stdio:['pipe','pipe','pipe'],maxBuffer:16*1024*1024});}
function sql(query,db=database){return run(['exec','-i',name,'psql','-X','-q','-A','-t','-v','ON_ERROR_STOP=1','-U','postgres','-d',db],query).trim();}
function check(marker,condition,context=''){sql(`${context} DO $$ BEGIN IF (${condition}) IS DISTINCT FROM TRUE THEN RAISE EXCEPTION '${marker}'; END IF; END $$;`);pass(marker);}
function deny(marker,statement,state='42501',actorContext=''){sql(`${actorContext} DO $$ BEGIN BEGIN ${statement}; RAISE EXCEPTION 'expected rejection absent' USING ERRCODE='ZX001'; EXCEPTION WHEN SQLSTATE '${state}' THEN NULL; END; END $$;`);pass(marker);}
const id=n=>`a0000000-0000-4000-8000-${String(n).padStart(12,'0')}`;
const editor=id(1),other=id(2),moderator=id(3),user=id(4),source=id(10),sourceB=id(11);
const actor=who=>`SET ROLE duta_app; SELECT set_config('app.user_id','${who}',false);`;
const publicRole=actor('');
const w=`'{"version":1,"who":{"state":"NOT_STATED"},"where":{"state":"NOT_STATED"},"when":{"state":"NOT_STATED"},"why":{"state":"NOT_STATED"}}'`;
function story(n,extraColumns='',extraValues=''){return `INSERT INTO public.official_news_stories(id,display_title,concise_summary,what_text,five_w_context,content_type,canonical_official_source_id,canonical_url,created_by${extraColumns}) VALUES('${id(n)}','DUTA title ${n}','DUTA summary','What',${w},'NOTICE','${source}','https://example.invalid/post/${n}','${editor}'${extraValues});`;}
function ref(n,src=source,suffix='',refId=n){return `INSERT INTO public.official_news_story_source_references(id,story_id,official_source_id,original_url,canonical_url,created_by,created_at) VALUES('${id(1000+refId)}','${id(n)}','${src}','https://example.invalid/original/${n}${suffix}','https://example.invalid/post/${n}','${editor}','2026-01-01T00:00:00Z');`;}
function assign(n,slug){return `SELECT public.assign_official_news_public_slug('${id(n)}','${slug}');`;}
function transition(n,event){return `SELECT public.transition_official_news_story('${id(n)}','${event}');`;}
const protectedFiles=['db/schema.ts','db/migrations/0045_official_news_editorial_foundation.sql','tests/db/migrations/0045/runtime-security.sql','tests/db/migrations/0045/runtime-adversarial.sql'];
const before=new Map(protectedFiles.map(p=>[p,hash(p)]));
let created=false;
try {
  assert.equal(sha,expectedSha,'candidate checksum');
  const governance=checkMigrationAuthority(root);
  assert.equal(governance.forwardCount,8); assert.equal(governance.candidateCount,0);
  const manifest=JSON.parse(read('db/migrations/forward-manifest.json'));
  const accepted0046=manifest.migrations.find(m => m.number === '0046');
  assert(accepted0046 && accepted0046.status==='AUTHORITY_ACCEPTED'
    && accepted0046.filename==='0046_official_news_public_publishing_contract.sql'
    && accepted0046.checksum===`sha256:${sha}`);
  const baseline=JSON.parse(read('db/baselines/DUTA_V2_5_BASELINE_V1.json'));
  // Pin the accepted baseline bytes separately from candidate authority.
  assert.equal(hash('db/baselines/DUTA_V2_5_BASELINE_V1.sql'),'94107afd6ea93c71f308ef51a45153ae908ae43139c8cb69dd53d9288ee36b8e');
  assert(baseline);
  run(['run','-d','--rm','--name',name,'--label','duta.validation=0046-astra','-e','POSTGRES_HOST_AUTH_METHOD=trust','-e',`POSTGRES_DB=${database}`,'postgres:17-alpine']);
  created=true;
  let stable=0;
  for(let i=0;i<60;i++){
    try {assert.equal(sql('select 1'),'1');stable++;}catch{stable=0;}
    if(stable===3)break;
    await new Promise(resolve=>setTimeout(resolve,1000));
  }
  assert.equal(stable,3); assert.equal(sql('show server_version_num').slice(0,2),'17');pass('POSTGRES17_STABLE_SQL_READINESS');
  sql(read('db/baselines/DUTA_V2_5_BASELINE_V1.sql'));pass('CANONICAL_BASELINE_APPLY');
  for(const m of manifest.migrations.filter(m => m.number !== '0046')){
    assert.equal(m.status,'AUTHORITY_ACCEPTED');assert.equal(`sha256:${hash(`db/migrations/${m.filename}`)}`,m.checksum);
    sql(read(`db/migrations/${m.filename}`));pass(`${m.number}_APPLY`);
  }
  sql(`INSERT INTO public.users(id,email,name,role) VALUES
  ('${editor}','a@fixture.invalid','A','EDITOR'),('${other}','b@fixture.invalid','B','EDITOR'),
  ('${moderator}','m@fixture.invalid','M','MODERATOR'),('${user}','u@fixture.invalid','U','USER');
  INSERT INTO public.official_sources(id,institution,channel,url,category,priority,source_purpose,active,last_checked) VALUES
  ('${source}','Mission A','WEBSITE','https://example.invalid/a','news','P1','NEWS',true,now()),
  ('${sourceB}','Mission B','WEBSITE','https://example.invalid/b','news','P1','NEWS',true,now());`);
  const preStates=[['DRAFT','DRAFT','CURRENT'],['VERIFIED_BY_EDITOR','DRAFT','CURRENT'],['READY_FOR_REVIEW','DRAFT','CURRENT'],['VERIFIED_BY_EDITOR','PUBLISHED','CURRENT'],['VERIFIED_BY_EDITOR','WITHDRAWN','WITHDRAWN'],['VERIFIED_BY_EDITOR','SUPERSEDED','SUPERSEDED']];
  for(let i=0;i<preStates.length;i++){
    const [review,pub,correction]=preStates[i];
    sql(story(20+i,',review_state,publication_state,correction_state,published_at,published_by',`, '${review}','${pub}','${correction}',${i>=3?'now()':'NULL'},${i>=3?`'${editor}'`:'NULL'}`)+ref(20+i));
  }
  sql(`UPDATE public.official_news_stories SET risk_classification='HIGH_RISK',risk_reasons=ARRAY['SAFETY']::public.official_news_risk_reason[] WHERE id='${id(22)}';`);
  const pre=sql('select jsonb_agg(to_jsonb(s) order by id) from public.official_news_stories s');
  assert.equal(hash(candidate),sha);sql(read(candidate));pass('0046_APPLY');
  const post=sql("select jsonb_agg(to_jsonb(s)-'public_slug' order by id) from public.official_news_stories s");
  assert.equal(post,pre);
  for(let i=0;i<6;i++) check(`PREEXISTING_${['DRAFT','REVIEW','MODERATION','PUBLISHED','WITHDRAWN','SUPERSEDED'][i]}_MIGRATION`, `(select ${i>=3?`public_slug='news-${id(20+i).replaceAll('-','')}'`:'public_slug IS NULL'} from public.official_news_stories where id='${id(20+i)}')`);
  const authorityBefore=sql('select jsonb_agg(to_jsonb(s) order by id) from public.official_sources s');
  // Real governed assignment and state transition, no compatibility adapter installed.
  sql(actor(editor)+assign(20,'draft-first')+assign(20,'draft-corrected'));
  check('AUTHORIZED_DRAFT_SLUG_ASSIGNMENT',`(select public_slug='draft-corrected' from public.official_news_stories where id='${id(20)}')`,actor(editor));
  check('DRAFT_SLUG_CORRECTION_BEFORE_PUBLICATION',`(select count(*)=2 from public.official_news_events where story_id='${id(20)}' and metadata->>'field'='public_slug')`,actor(editor));
  for(const who of [other,user,moderator,''])deny(`SLUG_DENIED_${who||'PUBLIC'}`,`PERFORM public.assign_official_news_public_slug('${id(20)}','hijacked')`,'42501',actor(who));
  deny('INVALID_SLUG_DENIED',`PERFORM public.assign_official_news_public_slug('${id(20)}','Bad Slug')`,'23514',actor(editor));
  deny('UNSAFE_SLUG_DENIED',`PERFORM public.assign_official_news_public_slug('${id(20)}','../unsafe')`,'23514',actor(editor));
  deny('NULL_SLUG_DENIED',`PERFORM public.assign_official_news_public_slug('${id(20)}',NULL)`,'23514',actor(editor));
  sql(actor(editor)+story(35)+ref(35));
  deny('DUPLICATE_SLUG_DENIED',`PERFORM public.assign_official_news_public_slug('${id(35)}','draft-corrected')`,'23505',actor(editor));
  deny('PUBLICATION_WITHOUT_SLUG_DENIED',`PERFORM public.transition_official_news_story('${id(21)}','PUBLISHED')`,'23514',actor(editor));
  // Gate 1B reproduction: an accepted pre-0046 routine review can receive its first slug and publish without administrative repair.
  sql(actor(editor)+assign(21,'historical-verified')+transition(21,'PUBLISHED'));
  check('PREEXISTING_VERIFIED_STORY_RECOVERABLE',`(select public_slug='historical-verified' and publication_state='PUBLISHED' from public.official_news_stories where id='${id(21)}')`,actor(editor));
  check('INFLIGHT_SLUG_ASSIGNMENT_AUDITED',`(select metadata->>'operation'='ASSIGNED' and metadata->>'old_slug' is null and metadata->>'new_slug'='historical-verified' from public.official_news_events where story_id='${id(21)}' and event_type='DRAFT_UPDATED' order by occurred_at desc,id desc limit 1)`,actor(editor));
  deny('NON_OWNING_EDITOR_INFLIGHT_DENIAL',`PERFORM public.assign_official_news_public_slug('${id(22)}','hijacked-moderation')`,'42501',actor(other));
  deny('ORDINARY_USER_INFLIGHT_DENIAL',`PERFORM public.assign_official_news_public_slug('${id(22)}','hijacked-moderation')`,'42501',actor(user));
  deny('MODERATOR_PREAPPROVAL_SLUG_DENIAL',`PERFORM public.assign_official_news_public_slug('${id(22)}','hijacked-moderation')`,'42501',actor(moderator));
  // Gate 1B moderation reproduction: Editor assigns only a missing slug, then the accepted Moderator approval and explicit publication transition remain required.
  sql(actor(editor)+assign(22,'historical-moderation')+actor(moderator)+transition(22,'APPROVED')+actor(editor)+transition(22,'PUBLISHED'));
  check('PREEXISTING_MODERATION_STORY_RECOVERABLE',`(select public_slug='historical-moderation' and review_state='APPROVED' and publication_state='PUBLISHED' from public.official_news_stories where id='${id(22)}')`,actor(editor));
  deny('DIRECT_SLUG_UPDATE_BYPASS_DENIED',`UPDATE public.official_news_stories SET public_slug='bypassed' WHERE id='${id(21)}'`,'42501',actor(editor));
  // Post-0046 stories may progress before their first governed assignment; the slug gate cannot strand them either.
  sql(actor(editor)+story(30)+ref(30)+transition(30,'VERIFIED_BY_EDITOR')+assign(30,'post0046-inflight')+transition(30,'PUBLISHED'));
  check('NEW_POST0046_INFLIGHT_STORY_RECOVERABLE',`(select public_slug='post0046-inflight' and publication_state='PUBLISHED' from public.official_news_stories where id='${id(30)}')`,actor(editor));
  // A Moderator may only complete first-slug assignment after the accepted high-risk approval transition.
  sql(actor(editor)+story(36)+ref(36));
  sql(`UPDATE public.official_news_stories SET risk_classification='HIGH_RISK',risk_reasons=ARRAY['SAFETY']::public.official_news_risk_reason[] WHERE id='${id(36)}';`);
  sql(actor(editor)+transition(36,'SUBMITTED_FOR_REVIEW')+actor(moderator)+transition(36,'APPROVED')+assign(36,'moderator-approved')+transition(36,'PUBLISHED'));
  check('MODERATOR_APPROVED_MISSING_SLUG_ASSIGNMENT',`(select public_slug='moderator-approved' and publication_state='PUBLISHED' and approved_by='${moderator}' from public.official_news_stories where id='${id(36)}')`,actor(moderator));
  sql(actor(editor)+transition(20,'VERIFIED_BY_EDITOR')+transition(20,'PUBLISHED'));
  deny('PUBLISHED_SLUG_IMMUTABILITY',`UPDATE public.official_news_stories SET public_slug='changed' WHERE id='${id(20)}'`,'23514');
  sql(`UPDATE public.official_news_stories SET display_title='Edited title' WHERE id='${id(20)}';`);
  check('TITLE_EDIT_SLUG_STABLE',`(select public_slug='draft-corrected' from public.official_news_stories where id='${id(20)}')`);
  // Test one, same-source many, then cross-mission many; exact cardinality at each step.
  check('SINGLE_REFERENCE_CARDINALITY',`(select count(*)=1 from public.official_news_public_stories where id='${id(20)}')`,publicRole);
  sql(ref(20,source,'-alternate',90));
  check('SAME_SOURCE_MULTI_REFERENCE_CARDINALITY',`(select count(*)=1 from public.official_news_public_stories where id='${id(20)}')`,publicRole);
  sql(ref(20,sourceB,'-mission-b',91)+ref(30,sourceB,'-mission-b',92));
  check('MULTI_REFERENCE_NO_DUPLICATE_PUBLIC_STORY',`(select count(*)=2 and count(distinct id)=2 from public.official_news_public_stories where id IN ('${id(20)}','${id(30)}'))`,publicRole);
  check('ATTRIBUTION_PERMALINK_PAIRING',`(select official_source_institution='Mission A' and original_url='https://example.invalid/original/20' and jsonb_array_length(source_references)=3 from public.official_news_public_stories where id='${id(20)}')`,publicRole);
  check('DETAIL_BY_SLUG_SINGULAR',"(select count(*)=1 from public.official_news_public_stories where public_slug='draft-corrected')",publicRole);
  // Every non-public state has a persisted row and reference before exclusion is queried.
  sql(story(31,',review_state',",'REJECTED'")+ref(31)+story(32)+ref(32));
  sql(`UPDATE public.official_news_stories SET public_slug='news-'||replace(id::text,'-','') WHERE id IN ('${id(31)}','${id(32)}');`);
  for(const n of [24,25,31,32]){
    check(`EXCLUDED_FIXTURE_${n}_EXISTS`,`exists(select 1 from public.official_news_stories where id='${id(n)}')`);
    check(`PUBLIC_LIST_EXCLUDES_${n}`,`not exists(select 1 from public.official_news_public_stories where id='${id(n)}')`,publicRole);
    check(`PUBLIC_DETAIL_EXCLUDES_${n}`,`not exists(select 1 from public.official_news_public_stories where public_slug='news-${id(n).replaceAll('-','')}')`,publicRole);
  }
  for(const n of [24,25,31])deny(`TERMINAL_STATE_SLUG_ASSIGNMENT_DENIED_${n}`,`PERFORM public.assign_official_news_public_slug('${id(n)}','terminal-change')`,'42501',actor(editor));
  check('DUTA_APP_PUBLIC_PROJECTION_LIST_READ',"current_user='duta_app' and (select count(*)=6 from public.official_news_public_stories)",publicRole);
  check('DUTA_APP_PUBLIC_PROJECTION_DETAIL_READ',"(select display_title='Edited title' and concise_summary='DUTA summary' from public.official_news_public_stories where public_slug='draft-corrected')",publicRole);
  check('UNKNOWN_SLUG_ABSENT',"not exists(select 1 from public.official_news_public_stories where public_slug='unknown')",publicRole);
  // Fail closed when publication flags and review status disagree, even for privileged reads.
  sql(story(33,',public_slug,publication_state,published_at,published_by,review_state',`, 'inconsistent-review','PUBLISHED',now(),'${editor}','REJECTED'`)+ref(33));
  check('INCONSISTENT_REVIEW_NOT_PUBLIC',"not exists(select 1 from public.official_news_public_stories where public_slug='inconsistent-review')",publicRole);
  sql(story(34,',public_slug,publication_state,published_at,published_by,review_state',`, 'missing-canonical','PUBLISHED',now(),'${editor}','VERIFIED_BY_EDITOR'`)+ref(34,sourceB));
  check('MISSING_CANONICAL_REFERENCE_FAILS_CLOSED',"not exists(select 1 from public.official_news_public_stories where public_slug='missing-canonical')",publicRole);
  for(const role of ['anon','authenticated'])deny(`${role}_PROJECTION_DENIED`,'PERFORM * FROM public.official_news_public_stories','42501',`SET ROLE ${role};`);
  check('PUBLIC_PROJECTION_NARROW',"(select array_agg(column_name::text order by ordinal_position)=ARRAY['id','public_slug','display_title','concise_summary','content_type','published_at','updated_at','source_published_at','canonical_url','original_url','original_source_published_at','official_source_institution','official_source_channel','source_references'] from information_schema.columns where table_schema='public' and table_name='official_news_public_stories')");
  check('DUTA_APP_ACCEPTED_0045_AUTHORITY_PRESERVED',"has_table_privilege('duta_app','public.official_news_stories','SELECT') and not has_table_privilege('anon','public.official_news_stories','SELECT')");
  check('PUBLIC_ROLE_NON_BYPASS',"(select not rolsuper and not rolbypassrls from pg_roles where rolname=current_user)",publicRole);
  sql(actor(moderator)+transition(20,'WITHDRAWN'));
  check('WITHDRAWAL_PUBLIC_DETAIL_ABSENT',"not exists(select 1 from public.official_news_public_stories where public_slug='draft-corrected')",publicRole);
  deny('WITHDRAWN_SLUG_IMMUTABLE',`UPDATE public.official_news_stories SET public_slug='changed' WHERE id='${id(20)}'`,'23514');
  assert.equal(sql('select jsonb_agg(to_jsonb(s) order by id) from public.official_sources s'),authorityBefore);pass('OFFICIAL_SOURCE_AUTHORITY_UNCHANGED');
  check('PUBLIC_SLUG_DATABASE_TYPE',"exists(select 1 from information_schema.columns where table_schema='public' and table_name='official_news_stories' and column_name='public_slug' and data_type='text' and is_nullable='YES')");
  // Separate run-owned database for immutable accepted regression fixtures.
  sql('CREATE DATABASE r46_regression TEMPLATE r46_disposable;','postgres');
  sql('DELETE FROM public.official_news_story_source_references; DELETE FROM public.official_news_events; DELETE FROM public.official_news_stories;','r46_regression');
  let legacy=read('tests/db/migrations/0045/runtime-security.sql');
  legacy=legacy.replace(/INSERT INTO public.users\(id,role\) VALUES[\s\S]*?;/,`INSERT INTO public.users(id,email,name,role) VALUES ${['EDITOR','MODERATOR','USER','EDITOR'].map((role,i)=>`('10000000-0000-4000-8000-00000000000${i+1}','legacy${i}@fixture.invalid','Legacy','${role}')`).join(',')};`);
  legacy=legacy.replace('source_purpose,active) VALUES','source_purpose,active,last_checked) VALUES').replaceAll("'NEWS',true)","'NEWS',true,'2026-01-01')").replaceAll("'NEWS',false)","'NEWS',false,'2026-01-01')").replaceAll("'CONSULAR_SERVICE',true)","'CONSULAR_SERVICE',true,'2026-01-01')");
  const install=`CREATE FUNCTION public.r46_legacy_slug() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
  IF NEW.id::text LIKE '30000000-0000-4000-8000-%' AND NEW.publication_state='PUBLISHED' AND NEW.public_slug IS NULL THEN NEW.public_slug:='legacy-'||replace(NEW.id::text,'-',''); END IF; RETURN NEW; END $$;
  CREATE TRIGGER r46_legacy_slug BEFORE INSERT OR UPDATE ON public.official_news_stories FOR EACH ROW EXECUTE FUNCTION public.r46_legacy_slug();`;
  sql(install,'r46_regression');
  try{
    const runtime=sql(legacy,'r46_regression');assert(runtime.includes('0045_RUNTIME_SECURITY=PASS'));
    assert.equal(sql("select count(*) from public.official_sources where id IN ('20000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000003') and (not active or source_purpose='CONSULAR_SERVICE')",'r46_regression'),'2');
    const adversarial=sql(read('tests/db/migrations/0045/runtime-adversarial.sql'),'r46_regression');
    for(const marker of ['0045_ADVERSARIAL_SECURITY','ROUTINE_EDITOR_TRANSITION','EDITOR_OWN_DRAFT_EDIT','DIRECT_STATE_ESCALATION_DENIAL','ORDINARY_USER_DENIAL','EDITOR_AB_ISOLATION','HIGH_RISK_MODERATION','SOURCE_REJECTION','AUDIT_ATOMICITY','SECURITY_DEFINER_PRIVILEGE','WITHDRAWAL','SUPERSESSION','IDEMPOTENCY','FUNCTIONAL_SEARCH'])assert(adversarial.includes(`${marker}=PASS`),marker);
    pass('0045_REGRESSION_COMPATIBILITY');
  }finally{sql('DROP TRIGGER r46_legacy_slug ON public.official_news_stories; DROP FUNCTION public.r46_legacy_slug();','r46_regression');}
  for(const db of [database,'r46_regression'])assert.equal(sql("select (not exists(select 1 from pg_trigger where tgname like 'r46_legacy%') and not exists(select 1 from pg_proc where proname like 'r46_legacy%'))::text",db),'true');
  pass('COMPATIBILITY_ARTIFACT_ABSENCE');
  assert.equal(hash(candidate),sha);
  for(const [p,digest] of before)assert.equal(hash(p),digest,p);
  console.log(`CANONICAL_0046_SHA256=${sha}`);
  pass('DISPOSABLE_FULL_CHAIN');
} catch(error){
  console.error(error.stderr?.toString() || error.message);process.exitCode=1;
} finally {
  if(created){
    try {run(['rm','-f',name]); assert.equal(run(['ps','-a','--filter',`name=^/${name}$`,'--format','{{.Names}}']).trim(),'');pass('DISPOSABLE_CLEANUP');}
    catch(error){console.error(`CLEANUP_FAILED:${error.message}`);process.exitCode=1;}
  }
}
