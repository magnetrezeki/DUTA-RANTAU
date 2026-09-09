-- STAGING ONLY. Read-only verification after 010 cleanup.
WITH f AS (
 SELECT '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid a,'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid b,
 '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid oa,'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid ob,
 'c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid ja,'f9e2eb86-4e57-4141-b2bc-62a16a879cc9'::uuid jb,
 '1c4d3f78-1fe7-447a-a9dc-847daaa0193a'::uuid aa,'bd6c4ffb-dc63-49ef-9e2f-e1b0ad00c6aa'::uuid ab,
 '6ed26cbd-23a5-4ff4-9432-0709e216447a'::uuid ar,'fa6a77f7-589e-44fe-8c22-7b2f4e89a1d2'::uuid aspoof,'2a365a5d-0bd3-4819-8d80-e75c0fd70fe5'::uuid across
),m AS (
 SELECT (SELECT count(*) FROM public.profiles p,f WHERE p.id IN(f.a,f.b)) profiles,
 (SELECT count(*) FROM public.organizations o,f WHERE o.id IN(f.oa,f.ob)) orgs,
 (SELECT count(*) FROM public.organization_members x,f WHERE (x.organization_id,x.user_id) IN((f.oa,f.a),(f.oa,f.b),(f.ob,f.b))) members,
 (SELECT count(*) FROM public.jobs j,f WHERE j.id IN(f.ja,f.jb)) jobs,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id IN(f.aa,f.ab)) audits,
 (SELECT count(*) FROM public.audit_logs l,f WHERE l.id IN(f.ar,f.aspoof,f.across)) residue
),c AS (
 SELECT 'behavioral_test_audit_residue_count'::text check_name,'0' expected,residue::text actual,CASE WHEN residue=0 THEN 'PASS' ELSE 'FAIL' END status FROM m
 UNION ALL SELECT 'baseline_profile_count','2',profiles::text,CASE WHEN profiles=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_organization_count','2',orgs::text,CASE WHEN orgs=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_membership_count','3',members::text,CASE WHEN members=3 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_job_count','2',jobs::text,CASE WHEN jobs=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'baseline_audit_count','2',audits::text,CASE WHEN audits=2 THEN 'PASS' ELSE 'FAIL' END FROM m
 UNION ALL SELECT 'no_other_behavioral_test_residue','PASS',CASE WHEN residue=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN residue=0 THEN 'PASS' ELSE 'FAIL' END FROM m
)
SELECT check_name,expected,actual,status FROM c
UNION ALL SELECT 'overall_post_cleanup_status','PASS',CASE WHEN NOT EXISTS(SELECT 1 FROM c WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END,CASE WHEN NOT EXISTS(SELECT 1 FROM c WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END
ORDER BY check_name;
