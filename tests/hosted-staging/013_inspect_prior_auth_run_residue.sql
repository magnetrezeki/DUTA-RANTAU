-- STAGING ONLY. Read-only inspection of exact known fixture and behavioral IDs.
WITH f AS (
  SELECT
    '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid a,
    'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid b,
    '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid org_a,
    'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid org_b,
    'c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid job_a,
    'f9e2eb86-4e57-4141-b2bc-62a16a879cc9'::uuid job_b,
    '1c4d3f78-1fe7-447a-a9dc-847daaa0193a'::uuid audit_a,
    'bd6c4ffb-dc63-49ef-9e2f-e1b0ad00c6aa'::uuid audit_b,
    '6ed26cbd-23a5-4ff4-9432-0709e216447a'::uuid behavior_audit,
    'fa6a77f7-589e-44fe-8c22-7b2f4e89a1d2'::uuid spoof_audit,
    '2a365a5d-0bd3-4819-8d80-e75c0fd70fe5'::uuid cross_audit
), m AS (
 SELECT
 (SELECT count(*) FROM public.profiles p,f WHERE p.id IN(f.a,f.b)) profiles,
 (SELECT count(*) FROM public.organizations o,f WHERE o.id IN(f.org_a,f.org_b)) orgs,
 (SELECT count(*) FROM public.organization_members x,f WHERE (x.organization_id,x.user_id) IN ((f.org_a,f.a),(f.org_a,f.b),(f.org_b,f.b))) members,
 (SELECT count(*) FROM public.jobs j,f WHERE j.id IN(f.job_a,f.job_b)) jobs,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id IN(f.audit_a,f.audit_b)) baseline_audits,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id=f.behavior_audit) behavior_count,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id=f.behavior_audit AND l.actor_id=f.a AND l.organization_id=f.org_a AND l.entity_id=f.job_a AND l.action='synthetic.job_note' AND l.entity_type='job') behavior_identity,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id IN(f.spoof_audit,f.cross_audit)) unexpected_audits,
 (SELECT count(*) FROM public.organization_members x,f WHERE (x.organization_id IN(f.org_a,f.org_b) OR x.user_id IN(f.a,f.b)) AND NOT ((x.organization_id=f.org_a AND x.user_id=f.a AND x.role='OWNER') OR (x.organization_id=f.org_a AND x.user_id=f.b AND x.role='MEMBER') OR (x.organization_id=f.org_b AND x.user_id=f.b AND x.role='OWNER'))) member_residue,
 (SELECT count(*) FROM public.jobs j,f WHERE (j.id IN(f.job_a,f.job_b) OR j.organization_id IN(f.org_a,f.org_b) OR j.owner_id IN(f.a,f.b)) AND NOT ((j.id=f.job_a AND j.organization_id=f.org_a AND j.owner_id=f.a) OR (j.id=f.job_b AND j.organization_id=f.org_b AND j.owner_id=f.b))) job_residue
), c AS (
 SELECT 'baseline_profile_count'::text check_name,'2' expected,profiles::text actual,CASE WHEN profiles=2 THEN 'PASS' ELSE 'FAIL' END status FROM m
 UNION ALL SELECT 'baseline_organization_count','2',orgs::text,CASE WHEN orgs=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_membership_count','3',members::text,CASE WHEN members=3 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_job_count','2',jobs::text,CASE WHEN jobs=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_audit_count','2 or 3', (baseline_audits+behavior_count)::text,CASE WHEN baseline_audits=2 AND behavior_count IN(0,1) THEN 'INFO' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'behavioral_audit_test_row_count','0 or 1',behavior_count::text,CASE WHEN behavior_count IN(0,1) THEN 'INFO' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'behavioral_audit_test_row_identity','exact dedicated row if present',behavior_identity::text,CASE WHEN behavior_count=0 OR behavior_identity=1 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'behavioral_audit_actor_linkage','User A if present',behavior_identity::text,CASE WHEN behavior_count=0 OR behavior_identity=1 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'behavioral_audit_org_resource_linkage','Organization A / Job A if present',behavior_identity::text,CASE WHEN behavior_count=0 OR behavior_identity=1 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'reversible_test_residue_count','0',(member_residue+job_residue)::text,CASE WHEN member_residue+job_residue=0 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_fixture_relationships','PASS',CASE WHEN profiles=2 AND orgs=2 AND members=3 AND jobs=2 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN profiles=2 AND orgs=2 AND members=3 AND jobs=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'unexpected_synthetic_test_rows','0',unexpected_audits::text,CASE WHEN unexpected_audits=0 THEN 'PASS' ELSE 'FAIL' END FROM m
), s AS (
 SELECT *, CASE WHEN NOT EXISTS(SELECT 1 FROM c WHERE status='FAIL') THEN
   CASE WHEN (SELECT behavior_count FROM m)=0 THEN 'CLEAN' WHEN (SELECT behavior_count FROM m)=1 THEN 'EXPECTED_AUDIT_RESIDUE_ONLY' ELSE 'UNEXPECTED_RESIDUE' END ELSE 'UNEXPECTED_RESIDUE' END residue_state FROM c
)
SELECT check_name,expected,actual,status FROM s
UNION ALL SELECT 'prior_run_residue_state','CLEAN / EXPECTED_AUDIT_RESIDUE_ONLY / UNEXPECTED_RESIDUE',(SELECT residue_state FROM s LIMIT 1),CASE WHEN (SELECT residue_state FROM s LIMIT 1)='UNEXPECTED_RESIDUE' THEN 'FAIL' ELSE 'INFO' END
UNION ALL SELECT 'safe_for_retest_preparation','PASS',CASE WHEN (SELECT residue_state FROM s LIMIT 1) IN('CLEAN','EXPECTED_AUDIT_RESIDUE_ONLY') THEN 'PASS' ELSE 'FAIL' END,CASE WHEN (SELECT residue_state FROM s LIMIT 1) IN('CLEAN','EXPECTED_AUDIT_RESIDUE_ONLY') THEN 'PASS' ELSE 'FAIL' END
ORDER BY check_name;
