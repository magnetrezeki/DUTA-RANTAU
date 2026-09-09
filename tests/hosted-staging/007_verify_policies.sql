-- STAGING SECURITY TEST ONLY. Run after 002_security_policies.sql and before 003.
-- This query is read-only and returns one Supabase SQL Editor result set.
WITH
expected_tables(table_name) AS (
  VALUES ('profiles'), ('organizations'), ('organization_members'), ('jobs'), ('audit_logs')
),
expected_policies(policy_name, table_name, command, qual_fragment, check_fragment) AS (
  VALUES
    ('security_profiles_self_select','profiles','SELECT','id=auth.uid()',NULL::text),
    ('security_profiles_self_update','profiles','UPDATE','id=auth.uid()','id=auth.uid()'),
    ('security_members_self_select','organization_members','SELECT','user_id=auth.uid()',NULL::text),
    ('security_organizations_member_select','organizations','SELECT','member.organization_id=organizations.id',NULL::text),
    ('security_organizations_owner_update','organizations','UPDATE','owner_id=auth.uid()','owner_id=auth.uid()'),
    ('security_jobs_member_select','jobs','SELECT','owner_id=auth.uid()',NULL::text),
    ('security_jobs_owner_update','jobs','UPDATE','owner_id=auth.uid()','owner_id=auth.uid()'),
    ('security_audit_actor_insert','audit_logs','INSERT',NULL::text,'actor_id=auth.uid()')
),
deployed_policies AS (
  SELECT
    p.policyname::text AS policy_name,
    p.tablename::text AS table_name,
    p.cmd::text AS command,
    p.roles::text[] AS roles,
    lower(regexp_replace(coalesce(p.qual, ''), '[[:space:]]+', '', 'g')) AS qual_normalized,
    lower(regexp_replace(coalesce(p.with_check, ''), '[[:space:]]+', '', 'g')) AS check_normalized
  FROM pg_policies p
  WHERE p.schemaname::text = 'public'
),
target_policies AS (
  SELECT * FROM deployed_policies
  WHERE table_name IN (SELECT table_name FROM expected_tables)
),
metrics AS (
  SELECT
    (SELECT count(*) FROM target_policies) AS deployed_target_policy_count,
    (SELECT count(*) FROM expected_policies e WHERE EXISTS (
      SELECT 1 FROM deployed_policies d WHERE d.policy_name=e.policy_name AND d.table_name=e.table_name
    )) AS intended_policy_count,
    (SELECT count(*) FROM deployed_policies d WHERE NOT EXISTS (
      SELECT 1 FROM expected_policies e WHERE e.policy_name=d.policy_name AND e.table_name=d.table_name
    )) AS unexpected_policy_count,
    (SELECT count(*) FROM expected_policies e WHERE NOT EXISTS (
      SELECT 1 FROM deployed_policies d WHERE d.policy_name=e.policy_name AND d.table_name=e.table_name
    )) AS expected_policy_target_gaps,
    (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname::text='public' AND c.relname::text IN (SELECT table_name FROM expected_tables) AND c.relrowsecurity) AS rls_tables_enabled,
    (SELECT count(*) FROM information_schema.role_table_grants g WHERE g.table_schema='public' AND g.table_name IN (SELECT table_name FROM expected_tables)
      AND g.grantee='authenticated' AND g.privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE')) AS authenticated_write_grants,
    (SELECT count(*) FROM information_schema.role_table_grants g WHERE g.table_schema='public' AND g.table_name IN (SELECT table_name FROM expected_tables)
      AND g.grantee='PUBLIC' AND g.privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE')) AS public_write_grants,
    (SELECT count(*) FROM target_policies d WHERE d.command IN ('UPDATE','DELETE','ALL')
      AND regexp_replace(d.qual_normalized, '[()]', '', 'g') = 'true') AS using_true_write_policies,
    (SELECT count(*) FROM target_policies d WHERE d.command IN ('INSERT','UPDATE','ALL')
      AND regexp_replace(d.check_normalized, '[()]', '', 'g') = 'true') AS with_check_true_write_policies,
    (SELECT count(*) FROM target_policies d WHERE array_to_string(d.roles, ',') ILIKE '%service_role%'
      OR d.qual_normalized ILIKE '%service_role%' OR d.check_normalized ILIKE '%service_role%') AS service_role_dependencies,
    (SELECT count(*) FROM target_policies d WHERE array_to_string(d.roles, ',') ILIKE '%bypassrls%'
      OR d.qual_normalized ILIKE '%bypassrls%' OR d.check_normalized ILIKE '%bypassrls%') AS bypassrls_dependencies,
    (SELECT count(*) FROM target_policies d WHERE array_to_string(d.roles, ',') ILIKE '%superuser%'
      OR d.qual_normalized ILIKE '%superuser%' OR d.check_normalized ILIKE '%superuser%') AS superuser_dependencies,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_members_self_select' AND d.command<>'SELECT') AS membership_write_policy_count,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_organizations_owner_update'
      AND (d.qual_normalized NOT LIKE '%owner_id=auth.uid()%' OR d.check_normalized NOT LIKE '%owner_id=auth.uid()%')) AS organization_owner_transition_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_jobs_owner_update'
      AND (d.qual_normalized NOT LIKE '%owner_id=auth.uid()%' OR d.qual_normalized NOT LIKE '%member.organization_id=jobs.organization_id%'
        OR d.check_normalized NOT LIKE '%owner_id=auth.uid()%' OR d.check_normalized NOT LIKE '%member.organization_id=jobs.organization_id%')) AS job_owner_transition_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_organizations_member_select'
      AND (d.qual_normalized NOT LIKE '%member.organization_id=organizations.id%' OR d.qual_normalized NOT LIKE '%member.user_id=auth.uid()%')) AS organization_membership_isolation_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_jobs_member_select'
      AND (d.qual_normalized NOT LIKE '%member.organization_id=jobs.organization_id%' OR d.qual_normalized NOT LIKE '%member.user_id=auth.uid()%')) AS job_membership_isolation_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_profiles_self_update'
      AND (d.qual_normalized NOT LIKE '%id=auth.uid()%' OR d.check_normalized NOT LIKE '%id=auth.uid()%')) AS profile_self_isolation_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.policy_name='security_audit_actor_insert'
      AND (d.command<>'INSERT' OR d.check_normalized NOT LIKE '%actor_id=auth.uid()%' OR d.check_normalized NOT LIKE '%job.owner_id=auth.uid()%')) AS audit_insert_structure_gaps,
    (SELECT count(*) FROM target_policies d WHERE d.table_name='audit_logs' AND d.policy_name<>'security_audit_actor_insert') AS unexpected_audit_policies,
    (SELECT count(*) FROM target_policies) - (SELECT count(DISTINCT policy_name) FROM target_policies) AS duplicate_policy_names,
    (SELECT count(*) FROM expected_policies e WHERE NOT EXISTS (
      SELECT 1 FROM deployed_policies d WHERE d.policy_name=e.policy_name AND d.table_name=e.table_name AND d.command=e.command
        AND d.roles=ARRAY['authenticated']::text[]
        AND (e.qual_fragment IS NULL OR d.qual_normalized LIKE '%'||e.qual_fragment||'%')
        AND (e.check_fragment IS NULL OR d.check_normalized LIKE '%'||e.check_fragment||'%')
    )) AS policy_definition_match_gaps
),
checks AS (
  SELECT 'intended_policy_count'::text AS check_name, '8'::text AS expected, intended_policy_count::text AS actual, CASE WHEN intended_policy_count=8 THEN 'PASS' ELSE 'FAIL' END AS status FROM metrics
  UNION ALL SELECT 'unexpected_policy_count','0',unexpected_policy_count::text,CASE WHEN unexpected_policy_count=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'target_table_check','profiles,organizations,organization_members,jobs,audit_logs only',CASE WHEN expected_policy_target_gaps=0 AND unexpected_policy_count=0 THEN 'EXPECTED TARGETS ONLY' ELSE expected_policy_target_gaps::text||' expected target gaps' END,CASE WHEN expected_policy_target_gaps=0 AND unexpected_policy_count=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'rls_status','5 enabled',rls_tables_enabled::text||' enabled',CASE WHEN rls_tables_enabled=5 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'broad_authenticated_write_grants','0',authenticated_write_grants::text,CASE WHEN authenticated_write_grants=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'public_write_grants','0',public_write_grants::text,CASE WHEN public_write_grants=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'using_true_write_policies','0',using_true_write_policies::text,CASE WHEN using_true_write_policies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'with_check_true_write_policies','0',with_check_true_write_policies::text,CASE WHEN with_check_true_write_policies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'service_role_dependency','0',service_role_dependencies::text,CASE WHEN service_role_dependencies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'bypassrls_dependency','0',bypassrls_dependencies::text,CASE WHEN bypassrls_dependencies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'superuser_dependency','0',superuser_dependencies::text,CASE WHEN superuser_dependencies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'privilege_escalation_policy_structure','PASS',CASE WHEN membership_write_policy_count=0 AND organization_owner_transition_gaps=0 AND job_owner_transition_gaps=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN membership_write_policy_count=0 AND organization_owner_transition_gaps=0 AND job_owner_transition_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'cross_org_policy_structure','PASS',CASE WHEN organization_membership_isolation_gaps=0 AND job_membership_isolation_gaps=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN organization_membership_isolation_gaps=0 AND job_membership_isolation_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'cross_user_policy_structure','PASS',CASE WHEN profile_self_isolation_gaps=0 AND job_owner_transition_gaps=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN profile_self_isolation_gaps=0 AND job_owner_transition_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'audit_log_append_only_structure','PASS',CASE WHEN audit_insert_structure_gaps=0 AND unexpected_audit_policies=0 THEN 'PASS' ELSE 'FAIL' END,CASE WHEN audit_insert_structure_gaps=0 AND unexpected_audit_policies=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'duplicate_or_overlapping_unexpected_policies','0',duplicate_policy_names::text,CASE WHEN duplicate_policy_names=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'effective_policy_definition_match','PASS',CASE WHEN policy_definition_match_gaps=0 THEN 'PASS' ELSE policy_definition_match_gaps::text||' gaps' END,CASE WHEN policy_definition_match_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
),
final_checks AS (
  SELECT * FROM checks
  UNION ALL
  SELECT 'overall_post_002_policy_status','PASS',CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END,CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END
)
SELECT check_name, expected, actual, status
FROM final_checks
ORDER BY CASE WHEN check_name='overall_post_002_policy_status' THEN 2 ELSE 1 END, check_name;
