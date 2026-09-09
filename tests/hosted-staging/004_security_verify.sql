-- STAGING SECURITY TEST ONLY. Run after the one-time 003 fixture seed.
-- Read-only Supabase SQL Editor verifier that returns one visible result set.
WITH
fixture AS (
  SELECT
    '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid AS account_a,
    'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid AS account_b,
    '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid AS org_a,
    'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid AS org_b,
    'c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid AS job_a,
    'f9e2eb86-4e57-4141-b2bc-62a16a879cc9'::uuid AS job_b,
    '1c4d3f78-1fe7-447a-a9dc-847daaa0193a'::uuid AS audit_a,
    'bd6c4ffb-dc63-49ef-9e2f-e1b0ad00c6aa'::uuid AS audit_b
),
expected_memberships(organization_id, user_id, role) AS (
  SELECT org_a, account_a, 'OWNER'::text FROM fixture
  UNION ALL SELECT org_b, account_b, 'OWNER'::text FROM fixture
  UNION ALL SELECT org_a, account_b, 'MEMBER'::text FROM fixture
),
metrics AS (
  SELECT
    (SELECT count(*) FROM public.profiles p CROSS JOIN fixture f WHERE p.id IN (f.account_a, f.account_b)) AS profile_count,
    (SELECT count(*) FROM public.organizations o CROSS JOIN fixture f WHERE o.id IN (f.org_a, f.org_b)) AS organization_count,
    (SELECT count(*) FROM public.organization_members m CROSS JOIN fixture f
      WHERE (m.organization_id,m.user_id) IN ((f.org_a,f.account_a),(f.org_b,f.account_b),(f.org_a,f.account_b))) AS membership_count,
    (SELECT count(*) FROM public.jobs j CROSS JOIN fixture f WHERE j.id IN (f.job_a, f.job_b)) AS job_count,
    (SELECT count(*) FROM public.audit_logs a CROSS JOIN fixture f WHERE a.id IN (f.audit_a, f.audit_b)) AS audit_count,
    (SELECT count(*) FROM public.profiles p CROSS JOIN fixture f JOIN auth.users u ON u.id=f.account_a
      WHERE p.id=f.account_a) AS profile_a_auth_matches,
    (SELECT count(*) FROM public.profiles p CROSS JOIN fixture f JOIN auth.users u ON u.id=f.account_b
      WHERE p.id=f.account_b) AS profile_b_auth_matches,
    (SELECT count(*) FROM public.organizations o CROSS JOIN fixture f WHERE o.id=f.org_a AND o.owner_id=f.account_a) AS user_a_owns_org_a,
    (SELECT count(*) FROM public.organizations o CROSS JOIN fixture f WHERE o.id=f.org_b AND o.owner_id=f.account_b) AS user_b_owns_org_b,
    (SELECT count(*) FROM public.organization_members m CROSS JOIN fixture f
      WHERE m.organization_id=f.org_a AND m.user_id=f.account_b AND m.role='MEMBER') AS user_b_member_org_a,
    (SELECT count(*) FROM public.jobs j CROSS JOIN fixture f
      WHERE j.id=f.job_a AND j.organization_id=f.org_a) AS job_a_org_linkage,
    (SELECT count(*) FROM public.jobs j CROSS JOIN fixture f
      WHERE j.id=f.job_a AND j.owner_id=f.account_a AND j.employer='Synthetic Employer A') AS job_a_owner_employer_linkage,
    (SELECT count(*) FROM public.audit_logs a CROSS JOIN fixture f
      WHERE (a.id=f.audit_a AND a.actor_id=f.account_a) OR (a.id=f.audit_b AND a.actor_id=f.account_b)) AS audit_actor_linkage_count,
    (SELECT count(*) FROM public.audit_logs a CROSS JOIN fixture f JOIN public.jobs j ON j.id=a.entity_id
      WHERE (a.id=f.audit_a AND a.organization_id=f.org_a AND j.organization_id=f.org_a AND j.id=f.job_a)
         OR (a.id=f.audit_b AND a.organization_id=f.org_b AND j.organization_id=f.org_b AND j.id=f.job_b)) AS audit_resource_org_linkage_count,
    (SELECT count(*) FROM public.organization_members m CROSS JOIN fixture f
      WHERE (m.organization_id IN (f.org_a,f.org_b) OR m.user_id IN (f.account_a,f.account_b))
        AND NOT EXISTS (SELECT 1 FROM expected_memberships e
          WHERE e.organization_id=m.organization_id AND e.user_id=m.user_id AND e.role=m.role))
    + (SELECT count(*) FROM public.jobs j CROSS JOIN fixture f
      WHERE (j.id IN (f.job_a,f.job_b) OR j.organization_id IN (f.org_a,f.org_b) OR j.owner_id IN (f.account_a,f.account_b))
        AND NOT ((j.id=f.job_a AND j.organization_id=f.org_a AND j.owner_id=f.account_a)
              OR (j.id=f.job_b AND j.organization_id=f.org_b AND j.owner_id=f.account_b)))
    + (SELECT count(*) FROM public.audit_logs a CROSS JOIN fixture f
      WHERE (a.id IN (f.audit_a,f.audit_b) OR a.actor_id IN (f.account_a,f.account_b) OR a.organization_id IN (f.org_a,f.org_b)
        OR a.entity_id IN (f.job_a,f.job_b))
        AND NOT ((a.id=f.audit_a AND a.actor_id=f.account_a AND a.organization_id=f.org_a AND a.entity_id=f.job_a)
              OR (a.id=f.audit_b AND a.actor_id=f.account_b AND a.organization_id=f.org_b AND a.entity_id=f.job_b))) AS unexpected_fixture_rows,
    (SELECT count(*) - count(DISTINCT fixture_id) FROM (
      SELECT account_a AS fixture_id FROM fixture UNION ALL SELECT account_b FROM fixture
      UNION ALL SELECT org_a FROM fixture UNION ALL SELECT org_b FROM fixture
      UNION ALL SELECT job_a FROM fixture UNION ALL SELECT job_b FROM fixture
      UNION ALL SELECT audit_a FROM fixture UNION ALL SELECT audit_b FROM fixture
    ) fixture_ids) AS duplicate_fixture_ids,
    (SELECT count(*) FROM expected_memberships e WHERE NOT EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id=e.organization_id AND m.user_id=e.user_id AND m.role=e.role
    )) AS membership_role_gaps
),
checks AS (
  SELECT 'profile_count'::text AS check_name, '2'::text AS expected, profile_count::text AS actual, CASE WHEN profile_count=2 THEN 'PASS' ELSE 'FAIL' END AS status FROM metrics
  UNION ALL SELECT 'organization_count','2',organization_count::text,CASE WHEN organization_count=2 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'organization_membership_count','3',membership_count::text,CASE WHEN membership_count=3 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'job_count','2',job_count::text,CASE WHEN job_count=2 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'audit_log_count','2',audit_count::text,CASE WHEN audit_count=2 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'profile_a_matches_auth_a','PASS',CASE WHEN profile_a_auth_matches=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN profile_a_auth_matches=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'profile_b_matches_auth_b','PASS',CASE WHEN profile_b_auth_matches=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN profile_b_auth_matches=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'user_a_owns_org_a','PASS',CASE WHEN user_a_owns_org_a=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN user_a_owns_org_a=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'user_b_owns_org_b','PASS',CASE WHEN user_b_owns_org_b=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN user_b_owns_org_b=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'user_b_member_of_org_a','PASS',CASE WHEN user_b_member_org_a=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN user_b_member_org_a=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'job_a_org_linkage','PASS',CASE WHEN job_a_org_linkage=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN job_a_org_linkage=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'job_a_owner_employer_linkage','PASS',CASE WHEN job_a_owner_employer_linkage=1 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN job_a_owner_employer_linkage=1 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'audit_actor_linkage','PASS',CASE WHEN audit_actor_linkage_count=2 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN audit_actor_linkage_count=2 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'audit_resource_org_linkage','PASS',CASE WHEN audit_resource_org_linkage_count=2 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN audit_resource_org_linkage_count=2 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'unexpected_fixture_rows','0',unexpected_fixture_rows::text,CASE WHEN unexpected_fixture_rows=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'duplicate_fixture_ids','0',duplicate_fixture_ids::text,CASE WHEN duplicate_fixture_ids=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'fixture_role_integrity','PASS',CASE WHEN membership_role_gaps=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN membership_role_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
),
final_checks AS (
  SELECT * FROM checks
  UNION ALL
  SELECT 'overall_fixture_status','PASS',CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END,CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END
)
SELECT check_name, expected, actual, status
FROM final_checks
ORDER BY CASE WHEN check_name='overall_fixture_status' THEN 2 ELSE 1 END, check_name;
