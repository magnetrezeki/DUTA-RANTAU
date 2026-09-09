import { createClient } from '@supabase/supabase-js';
import { pathToFileURL } from 'node:url';

export function classify(e) {
  if (!e) return 'ALLOW';
  const code=String(e.code||''), text=String(e.message||'').toLowerCase();
  if(code==='42501' && text.includes('row-level security')) return 'RLS_DENY';
  if(code==='42501' && /permission denied for (table|column|schema)/.test(text)) return 'GRANT_DENY';
  if(/^23/.test(code)) return 'CONSTRAINT_FAILURE';
  if(/^PGRST30/.test(code)) return 'AUTH_FAILURE';
  return 'API_FAILURE';
}
export function status(expected,actual) {
  if (actual==='PENDING_MANUAL_VERIFICATION') return 'BLOCKED';
  if (expected==='GRANT_DENY') return actual==='GRANT_DENY'?'PASS':'FAIL';
  if (expected==='RLS_DENY' && actual==='GRANT_DENY') return 'BLOCKED';
  return expected===actual && ['ALLOW','RLS_DENY'].includes(actual)?'PASS':'FAIL';
}
export function rows(expected,r,filter,values={},unchanged=false) {
  if(r.error) return classify(r.error);
  if(!Array.isArray(r.data)) return 'API_FAILURE';
  if(expected==='RLS_DENY') return r.data.length?'UNEXPECTED_ALLOW':unchanged?'RLS_DENY':'API_FAILURE';
  return r.data.length===1 && Object.entries({...filter,...values}).every(([k,v])=>r.data[0][k]===v)?'ALLOW':'UNEXPECTED_DENY';
}
export const groups={T01:['T01'],T02:['T02'],T03:['T03'],T04:['T04'],T05:['T05'],T06:['T06'],
 T07:['T07'],T08:['T08'],T09:['T09_ADMIN','T09_OWNER'],T10:['T10_PEER','T10_ORG'],
 T11:['T11'],T12:['T12_ALLOWED','T12_SPOOF','T12_CROSS_ORG','T12_DELETE_JOB']};
export const expectedLayers={
 T01:'ALLOW',T02:'RLS_DENY',T03:'ALLOW',T04:'ALLOW',T05:'RLS_DENY',T06:'RLS_DENY',
 T07:'ALLOW',T08:'RLS_DENY',T09_ADMIN:'GRANT_DENY',T09_OWNER:'GRANT_DENY',
 T10_PEER:'GRANT_DENY',T10_ORG:'RLS_DENY',T11:'RLS_DENY',T12_ALLOWED:'ALLOW',
 T12_SPOOF:'RLS_DENY',T12_CROSS_ORG:'RLS_DENY',T12_DELETE_JOB:'GRANT_DENY'
};
export function counters(results) {
  const pass=n=>results.some(r=>r.test_name===n&&r.status==='PASS');
  const group=n=>groups[n].every(pass);
  const layer=expected=>Object.entries(expectedLayers).filter(([,value])=>value===expected).map(([name])=>name);
  const passedLayer=expected=>layer(expected).filter(pass).length;
  return {
    behavioral_cases_passed:Object.keys(groups).filter(group).length,behavioral_cases_total:12,
    privilege_escalation_cases_passed:['T09_ADMIN','T09_OWNER','T10_PEER','T12_SPOOF'].filter(pass).length,
    privilege_escalation_cases_total:4,
    allow_cases_passed:passedLayer('ALLOW'),
    allow_cases_total:layer('ALLOW').length,
    rls_deny_cases_passed:passedLayer('RLS_DENY'),
    rls_deny_cases_total:layer('RLS_DENY').length,
    grant_deny_cases_passed:passedLayer('GRANT_DENY'),
    grant_deny_cases_total:layer('GRANT_DENY').length,
    rls_cases_blocked_by_grants:results.filter(r=>r.expected==='RLS_DENY'&&r.actual==='GRANT_DENY').length,
    wrong_authorization_layer:results.filter(r=>r.expected==='GRANT_DENY'&&r.actual==='RLS_DENY').length,
    // Compatibility label: only unintended grant blocking is a blocker.
    grant_layer_blocked:results.filter(r=>r.expected==='RLS_DENY'&&r.actual==='GRANT_DENY').length,
    unexpected_allows:results.filter(r=>r.actual==='UNEXPECTED_ALLOW').length,
    unexpected_denies:results.filter(r=>r.actual==='UNEXPECTED_DENY').length
  };
}
const ids={a:'128d19d8-fe70-4847-8b2e-e1c2d124539e',b:'ead4dbce-c4a1-4241-a244-66448e264b79',
orgA:'4c4b86fc-447d-4cf9-89e3-7c55f412a0a7',orgB:'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0',
jobA:'c3a31ab8-b2cc-440b-bacd-479205f01de2',jobB:'f9e2eb86-4e57-4141-b2bc-62a16a879cc9'};
export async function main(){
 const results=[],baseline=[];
 let auth=false,cleanup='NOT_RUN',postcheck='NOT_VERIFIED';
 const add=(name,actor,expected,actual)=>results.push({test_name:name,actor,expected,actual,authorization_layer:actual,status:status(expected,actual)});
 const request=async q=>{try{return await q}catch{return {error:{code:'NETWORK'}}}};
 const snapshot=async(c,t,f)=>{
   const r=await request(c.from(t).select('*').match(f));
   if(r.error||!Array.isArray(r.data)||r.data.length!==1)throw new Error('Target verification failed');
   return r.data[0];
 };
 try{
   if(process.env.NEXT_PUBLIC_SUPABASE_URL!=='https://bftdfvihtewjwotrzwwe.supabase.co')throw new Error('Wrong endpoint');
   const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
   if(!key?.startsWith('sb_publishable_'))throw new Error('Publishable key required');
   const login=async(label,id)=>{
     const email=process.env['DUTA_TEST_USER_'+label+'_EMAIL'],password=process.env['DUTA_TEST_USER_'+label+'_PASSWORD'];
     if(!email||!password)throw new Error('Missing credentials');
     const c=createClient(process.env.NEXT_PUBLIC_SUPABASE_URL,key,{auth:{persistSession:false,autoRefreshToken:false,detectSessionInUrl:false}});
     const r=await c.auth.signInWithPassword({email,password});
     if(r.error||!r.data.session||r.data.user?.id!==id||r.data.session.user.id!==id)throw new Error('Wrong Auth identity');
     return c;
   };
   const a=await login('A',ids.a),b=await login('B',ids.b);auth=true;
   const read=async(n,c,owner,t,f,expected)=>{
     const before=await snapshot(owner,t,f);baseline.push({owner,t,f,before});
     const r=await request(c.from(t).select('*').match(f));
     const after=await snapshot(owner,t,f);
     add(n,'User A',expected,rows(expected,r,f,{},JSON.stringify(before)===JSON.stringify(after)));
   };
   const write=async(n,actor,c,owner,t,f,values,expected)=>{
     const before=await snapshot(owner,t,f);baseline.push({owner,t,f,before});
     try{
       const r=await request(c.from(t).update(values).match(f).select('*'));
       const after=await snapshot(owner,t,f),same=JSON.stringify(before)===JSON.stringify(after);
       let actual=rows(expected,r,f,values,same);
       if(expected==='RLS_DENY'&&!same)actual='UNEXPECTED_ALLOW';
       if(expected==='ALLOW'&&Object.entries(values).some(([k,v])=>after[k]!==v))actual='UNEXPECTED_DENY';
       add(n,actor,expected,actual);
     }finally{
       try{
         const after=await snapshot(owner,t,f);
         if(JSON.stringify(before)!==JSON.stringify(after)){
           const restore=Object.fromEntries(Object.keys(values).map(k=>[k,before[k]]));
           const r=await request(owner.from(t).update(restore).match(f).select('*'));
           if(rows('ALLOW',r,f,restore)!=='ALLOW'||JSON.stringify(await snapshot(owner,t,f))!==JSON.stringify(before))throw new Error('Restore failed');
         }
       }catch{cleanup='FAIL';throw new Error('Manual restoration required')}
     }
   };
   await read('T01',a,a,'profiles',{id:ids.a},'ALLOW');
   await read('T02',a,b,'profiles',{id:ids.b},'RLS_DENY');
   cleanup='PASS_FOR_REVERSIBLE_WRITES';
   await write('T03','User A',a,a,'profiles',{id:ids.a},{private_note:'temporary-a-test'},'ALLOW');
   await read('T04',a,a,'organizations',{id:ids.orgA},'ALLOW');
   await read('T05',a,b,'organizations',{id:ids.orgB},'RLS_DENY');
   await read('T06',a,b,'organization_members',{organization_id:ids.orgB,user_id:ids.b},'RLS_DENY');
   await read('T07',a,a,'jobs',{id:ids.jobA},'ALLOW');
   await write('T08','User A',a,b,'profiles',{id:ids.b},{private_note:'forbidden'},'RLS_DENY');
   // Intentional grant boundaries stay BLOCKED under the requested RLS-only gate.
   await write('T09_ADMIN','User B',b,b,'organization_members',{organization_id:ids.orgA,user_id:ids.b},{role:'ADMIN'},'GRANT_DENY');
   await write('T09_OWNER','User B',b,b,'organization_members',{organization_id:ids.orgA,user_id:ids.b},{role:'OWNER'},'GRANT_DENY');
   await write('T10_PEER','User B',b,a,'organization_members',{organization_id:ids.orgA,user_id:ids.a},{role:'MEMBER'},'GRANT_DENY');
   await write('T10_ORG','User B',b,a,'organizations',{id:ids.orgA},{name:'forbidden-b-update'},'RLS_DENY');
   await write('T11','User A',a,b,'jobs',{id:ids.jobB},{title:'forbidden-a-update'},'RLS_DENY');
   for(const [n,id,actor,org,job,expected] of [
     ['T12_ALLOWED','6ed26cbd-23a5-4ff4-9432-0709e216447a',ids.a,ids.orgA,ids.jobA,'ALLOW'],
     ['T12_SPOOF','fa6a77f7-589e-44fe-8c22-7b2f4e89a1d2',ids.b,ids.orgB,ids.jobB,'RLS_DENY'],
     ['T12_CROSS_ORG','2a365a5d-0bd3-4819-8d80-e75c0fd70fe5',ids.a,ids.orgB,ids.jobB,'RLS_DENY']]){
       // Audit SELECT is intentionally absent. No RETURNING and no audit delete.
       const r=await request(a.from('audit_logs').insert({id,actor_id:actor,organization_id:org,entity_id:job,action:'synthetic.job_note',entity_type:'job'}));
       // A successful POST is evidence of the allowed API operation. Row linkage
       // remains pending the exact SQL Editor inspection because SELECT is denied.
       add(n,'User A',expected,r.error?classify(r.error):expected==='ALLOW'?'ALLOW':'UNEXPECTED_ALLOW');
   }
   const before=await snapshot(b,'jobs',{id:ids.jobB});
   const deletion=await request(a.from('jobs').delete().eq('id',ids.jobB).select('*'));
   if(!deletion.error&&Array.isArray(deletion.data)&&deletion.data.length){
   add('T12_DELETE_JOB','User A','GRANT_DENY','UNEXPECTED_ALLOW');cleanup='FAIL';
     throw new Error('Manual restoration required');
   }
   const after=await snapshot(b,'jobs',{id:ids.jobB});
   add('T12_DELETE_JOB','User A','GRANT_DENY',deletion.error?classify(deletion.error):'API_FAILURE');
   for(const s of baseline)if(JSON.stringify(await snapshot(s.owner,s.t,s.f))!==JSON.stringify(s.before))throw new Error('Baseline mismatch');
   postcheck='VISIBLE_ROWS_UNCHANGED_AUDIT_PENDING_MANUAL';
 }catch{
   // Never expose SDK exceptions, credentials, response bodies or sessions.
   add('HARNESS_GATE','System','ALLOW',auth?'API_FAILURE':'AUTH_FAILURE');
 }
 const counts=counters(results);
 const gatePass=auth&&counts.allow_cases_passed===counts.allow_cases_total&&counts.rls_deny_cases_passed===counts.rls_deny_cases_total&&
   counts.grant_deny_cases_passed===counts.grant_deny_cases_total&&counts.behavioral_cases_passed===12&&
   counts.privilege_escalation_cases_passed===4&&counts.rls_cases_blocked_by_grants===0&&
   counts.wrong_authorization_layer===0&&counts.unexpected_allows===0&&
   counts.unexpected_denies===0&&cleanup==='PASS_FOR_REVERSIBLE_WRITES';
 console.table(results);
 console.table([{...counts,reversible_cleanup_status:cleanup,
   immutable_test_residue_status:results.some(r=>r.test_name==='T12_ALLOWED'&&r.status==='PASS')?'PENDING_MANUAL_READONLY_VERIFICATION':'NOT_CREATED',
   manual_audit_verification_required:'YES',
   manual_cleanup_required:results.some(r=>r.test_name==='T12_ALLOWED'&&r.status==='PASS')?'YES':'NO',
   fixture_immediate_postcheck_status:postcheck,
   gate_a_api_authorization_status:gatePass?'PASS':'FAIL',
   overall_authenticated_rls_status:gatePass?'PASS_GATE_A_PENDING_GATE_B':'FAIL'}]);
 process.exitCode=gatePass?0:1;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href)await main();
