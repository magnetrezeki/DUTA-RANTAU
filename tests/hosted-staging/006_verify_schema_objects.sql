-- STAGING SECURITY TEST ONLY. One read-only Supabase SQL Editor result set.
-- Run before 002_security_policies.sql. It creates, changes, and deletes nothing.
WITH
expected_tables(table_name) AS (
  VALUES ('profiles'), ('organizations'), ('organization_members'), ('jobs'), ('audit_logs')
),
target_tables AS (
  SELECT t.table_name
  FROM information_schema.tables t
  WHERE t.table_schema='public' AND t.table_type='BASE TABLE'
    AND t.table_name IN (SELECT table_name FROM expected_tables)
),
required_columns(table_name, column_name, data_type, is_nullable) AS (
  VALUES
    ('profiles','id','uuid','NO'),
    ('organizations','owner_id','uuid','NO'),
    ('organization_members','organization_id','uuid','NO'),
    ('organization_members','user_id','uuid','NO'),
    ('organization_members','role','text','NO'),
    ('jobs','organization_id','uuid','NO'),
    ('jobs','owner_id','uuid','NO'),
    ('audit_logs','actor_id','uuid','NO'),
    ('audit_logs','organization_id','uuid','YES')
),
expected_primary_keys(table_name, expected_columns) AS (
  VALUES
    ('profiles', ARRAY['id']::text[]),
    ('organizations', ARRAY['id']::text[]),
    ('organization_members', ARRAY['organization_id','user_id']::text[]),
    ('jobs', ARRAY['id']::text[]),
    ('audit_logs', ARRAY['id']::text[])
),
expected_foreign_keys(table_name, column_name, referenced_table, referenced_column, delete_rule) AS (
  VALUES
    ('profiles','id','auth.users','id','CASCADE'),
    ('organizations','owner_id','public.profiles','id','RESTRICT'),
    ('organization_members','organization_id','public.organizations','id','CASCADE'),
    ('organization_members','user_id','public.profiles','id','CASCADE'),
    ('jobs','organization_id','public.organizations','id','CASCADE'),
    ('jobs','owner_id','public.profiles','id','RESTRICT'),
    ('audit_logs','actor_id','public.profiles','id','RESTRICT'),
    ('audit_logs','organization_id','public.organizations','id','SET NULL')
),
metrics AS (
  SELECT
    (SELECT count(*) FROM target_tables) AS intended_table_count,
    (SELECT count(*) FROM expected_tables e WHERE NOT EXISTS (SELECT 1 FROM target_tables t WHERE t.table_name=e.table_name)) AS missing_intended_tables,
    (SELECT count(*) FROM information_schema.tables t WHERE t.table_schema='public' AND t.table_type='BASE TABLE' AND t.table_name NOT IN (SELECT table_name FROM expected_tables)) AS unexpected_public_tables,
    (SELECT count(*) FROM required_columns e LEFT JOIN information_schema.columns c ON c.table_schema='public' AND c.table_name=e.table_name AND c.column_name=e.column_name WHERE c.column_name IS NULL OR c.data_type<>e.data_type OR c.is_nullable<>e.is_nullable) AS security_column_gaps,
    (SELECT count(*) FROM expected_primary_keys e WHERE NOT EXISTS (
      SELECT 1 FROM pg_constraint c WHERE c.contype::text='p' AND c.conrelid=to_regclass('public.'||e.table_name)
        AND ARRAY(SELECT a.attname::text FROM unnest(c.conkey) WITH ORDINALITY k(attnum, ordinality) JOIN pg_attribute a ON a.attrelid=c.conrelid AND a.attnum=k.attnum ORDER BY k.ordinality)::text[]=e.expected_columns
    )) AS primary_key_gaps,
    (SELECT count(*) FROM expected_foreign_keys e WHERE NOT EXISTS (
      SELECT 1 FROM pg_constraint c
      JOIN LATERAL unnest(c.conkey) WITH ORDINALITY k(attnum, ordinality) ON true
      JOIN LATERAL unnest(c.confkey) WITH ORDINALITY rk(attnum, ordinality) ON rk.ordinality=k.ordinality
      JOIN pg_attribute a ON a.attrelid=c.conrelid AND a.attnum=k.attnum
      JOIN pg_attribute ra ON ra.attrelid=c.confrelid AND ra.attnum=rk.attnum
      JOIN pg_class rel ON rel.oid=c.conrelid JOIN pg_namespace n ON n.oid=rel.relnamespace
      JOIN pg_class rrel ON rrel.oid=c.confrelid JOIN pg_namespace rn ON rn.oid=rrel.relnamespace
      WHERE c.contype::text='f' AND format('%I.%I',n.nspname,rel.relname)='public.'||e.table_name
        AND a.attname::text=e.column_name AND format('%I.%I',rn.nspname,rrel.relname)=e.referenced_table
        AND ra.attname::text=e.referenced_column
        AND CASE c.confdeltype::text WHEN 'c' THEN 'CASCADE' WHEN 'r' THEN 'RESTRICT' WHEN 'n' THEN 'SET NULL' ELSE c.confdeltype::text END=e.delete_rule
    )) AS foreign_key_gaps,
    (SELECT count(*) FROM pg_constraint c WHERE c.conrelid=to_regclass('public.organization_members') AND c.contype::text='c' AND pg_get_constraintdef(c.oid) LIKE '%OWNER%' AND pg_get_constraintdef(c.oid) LIKE '%ADMIN%' AND pg_get_constraintdef(c.oid) LIKE '%MEMBER%') AS role_constraints_found,
    (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname::text='public' AND c.relname::text IN (SELECT table_name FROM expected_tables) AND c.relrowsecurity) AS rls_tables_enabled,
    (SELECT count(*) FROM pg_policies p WHERE p.schemaname='public' AND p.tablename IN (SELECT table_name FROM expected_tables)) AS policy_count,
    (SELECT count(*) FROM information_schema.role_table_grants g WHERE g.table_schema='public' AND g.table_name IN (SELECT table_name FROM expected_tables) AND g.grantee='authenticated' AND g.privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE')) AS authenticated_write_grants,
    (SELECT count(*) FROM information_schema.role_table_grants g WHERE g.table_schema='public' AND g.table_name IN (SELECT table_name FROM expected_tables) AND g.grantee='PUBLIC' AND g.privilege_type IN ('INSERT','UPDATE','DELETE','TRUNCATE')) AS public_write_grants
),
checks AS (
  SELECT 'intended_table_count'::text AS check_name, '5'::text AS expected, intended_table_count::text AS actual, CASE WHEN intended_table_count=5 THEN 'PASS' ELSE 'FAIL' END AS status FROM metrics
  UNION ALL SELECT 'missing_intended_tables','0',missing_intended_tables::text,CASE WHEN missing_intended_tables=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'unexpected_public_tables','0',unexpected_public_tables::text,CASE WHEN unexpected_public_tables=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'primary_key_check','PASS',CASE WHEN primary_key_gaps=0 THEN 'PASS' ELSE primary_key_gaps::text||' missing/mismatched' END,CASE WHEN primary_key_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'foreign_key_check','PASS',CASE WHEN foreign_key_gaps=0 THEN 'PASS' ELSE foreign_key_gaps::text||' missing/mismatched' END,CASE WHEN foreign_key_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'role_constraint_check','OWNER,ADMIN,MEMBER',CASE WHEN role_constraints_found>0 THEN 'OWNER,ADMIN,MEMBER' ELSE 'MISSING/MISMATCH' END,CASE WHEN role_constraints_found>0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'rls_status','5 enabled',rls_tables_enabled::text||' enabled',CASE WHEN rls_tables_enabled=5 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'policy_count','0',policy_count::text,CASE WHEN policy_count=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'broad_authenticated_write_grants','0',authenticated_write_grants::text,CASE WHEN authenticated_write_grants=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'public_write_grants','0',public_write_grants::text,CASE WHEN public_write_grants=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
  UNION ALL SELECT 'unexpected_security_sensitive_column_gaps','0',security_column_gaps::text,CASE WHEN security_column_gaps=0 THEN 'PASS' ELSE 'FAIL' END FROM metrics
),
final_checks AS (
  SELECT * FROM checks
  UNION ALL
  SELECT 'overall_pre_002_schema_status','PASS',CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END,CASE WHEN NOT EXISTS (SELECT 1 FROM checks WHERE status='FAIL') THEN 'PASS' ELSE 'FAIL' END
)
SELECT check_name, expected, actual, status
FROM final_checks
ORDER BY CASE WHEN check_name='overall_pre_002_schema_status' THEN 2 ELSE 1 END, check_name;
