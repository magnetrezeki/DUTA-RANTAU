-- STAGING SECURITY TEST ONLY. Never run against production.
-- This SQL Editor harness uses the approved synthetic fixture UUIDs and rolls back every persistent write.
-- It requires a controlled staging executor able to SET LOCAL ROLE authenticated.
-- Direct PostgREST tests using the two ordinary Auth sessions remain mandatory:
-- claim simulation validates database policy behavior, not gateway token handling.
-- Do not substitute production or non-fixture identities.

BEGIN;
CREATE TEMP TABLE security_behavioral_results (
  test_name text PRIMARY KEY,
  actor text NOT NULL,
  expected text NOT NULL,
  actual text NOT NULL,
  status text NOT NULL CHECK (status IN ('PASS', 'FAIL'))
) ON COMMIT DROP;

CREATE OR REPLACE FUNCTION pg_temp.assert_result(test_name text, passed boolean, test_detail text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO security_behavioral_results (test_name, actor, expected, actual, status)
  VALUES (
    test_name,
    CASE WHEN test_name IN ('T09','T10') THEN 'User B' ELSE 'User A' END,
    CASE test_name
      WHEN 'T01' THEN 'ALLOW own-profile read'
      WHEN 'T02' THEN 'DENY cross-user profile read'
      WHEN 'T03' THEN 'ALLOW own-profile update'
      WHEN 'T04' THEN 'ALLOW Organization A read'
      WHEN 'T05' THEN 'DENY Organization B read'
      WHEN 'T06' THEN 'DENY Organization B membership read'
      WHEN 'T07' THEN 'ALLOW Job A read'
      WHEN 'T08' THEN 'DENY cross-user profile update'
      WHEN 'T09' THEN 'DENY MEMBER to ADMIN and OWNER escalation'
      WHEN 'T10' THEN 'DENY peer-role and organization update'
      WHEN 'T11' THEN 'DENY cross-organization Job B update'
      WHEN 'T12' THEN 'ALLOW own audit; deny spoofed, cross-org, and delete writes'
    END,
    test_detail,
    CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END
  );
END $$;

DO $$ BEGIN
  PERFORM set_config('app.security.account_a_uuid', '128d19d8-fe70-4847-8b2e-e1c2d124539e', true);
  PERFORM set_config('app.security.account_b_uuid', 'ead4dbce-c4a1-4241-a244-66448e264b79', true);
  PERFORM set_config('app.security.org_a_uuid', '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7', true);
  PERFORM set_config('app.security.org_b_uuid', 'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0', true);
  PERFORM set_config('app.security.job_a_uuid', 'c3a31ab8-b2cc-440b-bacd-479205f01de2', true);
  PERFORM set_config('app.security.job_b_uuid', 'f9e2eb86-4e57-4141-b2bc-62a16a879cc9', true);
  PERFORM set_config('app.security.audit_allowed_uuid', '6ed26cbd-23a5-4ff4-9432-0709e216447a', true);
  PERFORM set_config('app.security.audit_spoof_uuid', 'fa6a77f7-589e-44fe-8c22-7b2f4e89a1d2', true);
  PERFORM set_config('app.security.audit_cross_org_uuid', '2a365a5d-0bd3-4819-8d80-e75c0fd70fe5', true);
END $$;

-- Fail early for wrong placeholder substitution or an unexpected fixture shape.
DO $$
BEGIN
  IF current_setting('app.security.account_a_uuid')::uuid = current_setting('app.security.account_b_uuid')::uuid THEN
    RAISE EXCEPTION 'Accounts A and B must be distinct';
  END IF;
  IF (SELECT count(*) FROM public.profiles WHERE id IN (current_setting('app.security.account_a_uuid')::uuid, current_setting('app.security.account_b_uuid')::uuid)) <> 2
    OR (SELECT count(*) FROM public.organizations WHERE id IN (current_setting('app.security.org_a_uuid')::uuid, current_setting('app.security.org_b_uuid')::uuid)) <> 2
    OR (SELECT count(*) FROM public.jobs WHERE id IN (current_setting('app.security.job_a_uuid')::uuid, current_setting('app.security.job_b_uuid')::uuid)) <> 2
    OR NOT EXISTS (SELECT 1 FROM public.organization_members WHERE organization_id=current_setting('app.security.org_a_uuid')::uuid AND user_id=current_setting('app.security.account_a_uuid')::uuid AND role='OWNER')
    OR NOT EXISTS (SELECT 1 FROM public.organization_members WHERE organization_id=current_setting('app.security.org_a_uuid')::uuid AND user_id=current_setting('app.security.account_b_uuid')::uuid AND role='MEMBER')
    OR NOT EXISTS (SELECT 1 FROM public.organization_members WHERE organization_id=current_setting('app.security.org_b_uuid')::uuid AND user_id=current_setting('app.security.account_b_uuid')::uuid AND role='OWNER') THEN
    RAISE EXCEPTION 'Synthetic fixture precondition failed';
  END IF;
END $$;

SET LOCAL ROLE authenticated;

-- T01-T08: A's own access and B's cross-user isolation.
DO $$ BEGIN
  PERFORM set_config('request.jwt.claim.sub', '128d19d8-fe70-4847-8b2e-e1c2d124539e', true);
  PERFORM set_config('request.jwt.claims', format('{"sub":"%s","role":"authenticated"}', '128d19d8-fe70-4847-8b2e-e1c2d124539e'), true);
END $$;
DO $$ DECLARE rows_found integer; changed integer; BEGIN
  SELECT count(*) INTO rows_found FROM public.profiles WHERE id=current_setting('app.security.account_a_uuid')::uuid;
  PERFORM pg_temp.assert_result('T01', rows_found=1, 'A reads own profile');
  SELECT count(*) INTO rows_found FROM public.profiles WHERE id=current_setting('app.security.account_b_uuid')::uuid;
  PERFORM pg_temp.assert_result('T02', rows_found=0, 'A cannot read B profile');
  UPDATE public.profiles SET private_note='temporary-a-test' WHERE id=current_setting('app.security.account_a_uuid')::uuid;
  GET DIAGNOSTICS changed=ROW_COUNT;
  PERFORM pg_temp.assert_result('T03', changed=1, 'A updates own disposable field; transaction rolls back');
  SELECT count(*) INTO rows_found FROM public.organizations WHERE id=current_setting('app.security.org_a_uuid')::uuid;
  PERFORM pg_temp.assert_result('T04', rows_found=1, 'A reads Organisation A');
  SELECT count(*) INTO rows_found FROM public.organizations WHERE id=current_setting('app.security.org_b_uuid')::uuid;
  PERFORM pg_temp.assert_result('T05', rows_found=0, 'A cannot read Organisation B');
  SELECT count(*) INTO rows_found FROM public.organization_members WHERE organization_id=current_setting('app.security.org_b_uuid')::uuid;
  PERFORM pg_temp.assert_result('T06', rows_found=0, 'A cannot enumerate Organisation B membership');
  SELECT count(*) INTO rows_found FROM public.jobs WHERE id=current_setting('app.security.job_a_uuid')::uuid;
  PERFORM pg_temp.assert_result('T07', rows_found=1, 'A reads Job A');
  UPDATE public.profiles SET private_note='forbidden' WHERE id=current_setting('app.security.account_b_uuid')::uuid;
  GET DIAGNOSTICS changed=ROW_COUNT;
  PERFORM pg_temp.assert_result('T08', changed=0, 'A cannot update B profile');
END $$;

-- T09-T10: B is a MEMBER of Organisation A and must not gain or change roles.
DO $$ BEGIN
  PERFORM set_config('request.jwt.claim.sub', 'ead4dbce-c4a1-4241-a244-66448e264b79', true);
  PERFORM set_config('request.jwt.claims', format('{"sub":"%s","role":"authenticated"}', 'ead4dbce-c4a1-4241-a244-66448e264b79'), true);
END $$;
DO $$ DECLARE changed integer; denied_admin boolean:=false; denied_owner boolean:=false; denied_peer boolean:=false; BEGIN
  BEGIN
    UPDATE public.organization_members SET role='ADMIN'
      WHERE organization_id=current_setting('app.security.org_a_uuid')::uuid
        AND user_id=current_setting('app.security.account_b_uuid')::uuid;
  EXCEPTION WHEN insufficient_privilege THEN denied_admin:=true;
  END;
  BEGIN
    UPDATE public.organization_members SET role='OWNER'
      WHERE organization_id=current_setting('app.security.org_a_uuid')::uuid
        AND user_id=current_setting('app.security.account_b_uuid')::uuid;
  EXCEPTION WHEN insufficient_privilege THEN denied_owner:=true;
  END;
  PERFORM pg_temp.assert_result('T09', denied_admin AND denied_owner, 'B MEMBER cannot self-assign ADMIN or OWNER');
  BEGIN
    UPDATE public.organization_members SET role='MEMBER'
      WHERE organization_id=current_setting('app.security.org_a_uuid')::uuid AND user_id=current_setting('app.security.account_a_uuid')::uuid;
  EXCEPTION WHEN insufficient_privilege THEN denied_peer:=true;
  END;
  UPDATE public.organizations SET name='forbidden-b-update' WHERE id=current_setting('app.security.org_a_uuid')::uuid;
  GET DIAGNOSTICS changed=ROW_COUNT;
  PERFORM pg_temp.assert_result('T10', denied_peer AND changed=0, 'B MEMBER cannot change A owner role or organisation');
END $$;

-- T11-T12: cross-job denial and append-only audit isolation.
DO $$ BEGIN
  PERFORM set_config('request.jwt.claim.sub', '128d19d8-fe70-4847-8b2e-e1c2d124539e', true);
  PERFORM set_config('request.jwt.claims', format('{"sub":"%s","role":"authenticated"}', '128d19d8-fe70-4847-8b2e-e1c2d124539e'), true);
END $$;
DO $$ DECLARE changed integer; allowed_audit boolean:=false; denied_spoof boolean:=false; denied_cross_org boolean:=false; denied_delete boolean:=false; BEGIN
  UPDATE public.jobs SET title='forbidden-a-update' WHERE id=current_setting('app.security.job_b_uuid')::uuid;
  GET DIAGNOSTICS changed=ROW_COUNT;
  PERFORM pg_temp.assert_result('T11', changed=0, 'A cannot update Job B');
  BEGIN
    INSERT INTO public.audit_logs (id,actor_id,organization_id,action,entity_type,entity_id)
      VALUES (current_setting('app.security.audit_allowed_uuid')::uuid, current_setting('app.security.account_a_uuid')::uuid, current_setting('app.security.org_a_uuid')::uuid, 'synthetic.job_note', 'job', current_setting('app.security.job_a_uuid')::uuid);
    allowed_audit:=true;
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    INSERT INTO public.audit_logs (id,actor_id,organization_id,action,entity_type,entity_id)
      VALUES (current_setting('app.security.audit_spoof_uuid')::uuid, current_setting('app.security.account_b_uuid')::uuid, current_setting('app.security.org_b_uuid')::uuid, 'synthetic.job_note', 'job', current_setting('app.security.job_b_uuid')::uuid);
  EXCEPTION WHEN insufficient_privilege THEN denied_spoof:=true;
  END;
  BEGIN
    INSERT INTO public.audit_logs (id,actor_id,organization_id,action,entity_type,entity_id)
      VALUES (current_setting('app.security.audit_cross_org_uuid')::uuid, current_setting('app.security.account_a_uuid')::uuid, current_setting('app.security.org_b_uuid')::uuid, 'synthetic.job_note', 'job', current_setting('app.security.job_b_uuid')::uuid);
  EXCEPTION WHEN insufficient_privilege THEN denied_cross_org:=true;
  END;
  BEGIN
    DELETE FROM public.jobs WHERE id=current_setting('app.security.job_b_uuid')::uuid;
  EXCEPTION WHEN insufficient_privilege THEN denied_delete:=true;
  END;
  PERFORM pg_temp.assert_result('T12', allowed_audit AND denied_spoof AND denied_cross_org AND denied_delete,
    'Audit is actor-bound and append-only; cross-org audit and Job B delete deny');
END $$;

INSERT INTO security_behavioral_results (test_name, actor, expected, actual, status)
SELECT
  'overall_behavioral_rls_status',
  'System',
  'PASS',
  CASE WHEN count(*)=12 AND bool_and(status='PASS') THEN 'PASS' ELSE 'FAIL' END,
  CASE WHEN count(*)=12 AND bool_and(status='PASS') THEN 'PASS' ELSE 'FAIL' END
FROM security_behavioral_results;

SELECT test_name, actor, expected, actual, status
FROM security_behavioral_results
ORDER BY CASE WHEN test_name='overall_behavioral_rls_status' THEN 2 ELSE 1 END, test_name;
ROLLBACK;
