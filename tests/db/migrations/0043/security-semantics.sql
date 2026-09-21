\set ON_ERROR_STOP on

-- The duta_app UPDATE policy intentionally exposes no organization-member
-- mutation path. The trigger remediation must not turn identity repair into a
-- role-management capability.
BEGIN;
SELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
DO $$
DECLARE changed integer;
BEGIN
  UPDATE public.organization_members SET role='ADMIN'
  WHERE organization_id='50000000-0000-4000-8000-000000000001'
    AND user_id='11111111-1111-4111-8111-111111111111';
  GET DIAGNOSTICS changed=ROW_COUNT;
  IF changed<>0 THEN RAISE EXCEPTION 'self escalation was permitted'; END IF;

  UPDATE public.organization_members SET role='ADMIN'
  WHERE organization_id='51000000-0000-4000-8000-000000000001'
    AND user_id='22222222-2222-4222-8222-222222222222';
  GET DIAGNOSTICS changed=ROW_COUNT;
  IF changed<>0 THEN RAISE EXCEPTION 'cross-organization administration was permitted'; END IF;

  UPDATE public.organizations SET verification='DUTA_VERIFIED'
  WHERE id='50000000-0000-4000-8000-000000000001';
  GET DIAGNOSTICS changed=ROW_COUNT;
  IF changed<>0 THEN RAISE EXCEPTION 'verification escalation was permitted'; END IF;
END
$$;
ROLLBACK;

BEGIN;
SELECT set_config('app.user_id','22222222-2222-4222-8222-222222222222',true);
DO $$
DECLARE changed integer;
BEGIN
  UPDATE public.organization_members SET role='ADMIN'
  WHERE organization_id='50000000-0000-4000-8000-000000000001'
    AND user_id='11111111-1111-4111-8111-111111111111';
  GET DIAGNOSTICS changed=ROW_COUNT;
  IF changed<>0 THEN RAISE EXCEPTION 'unrelated member administration was permitted'; END IF;
END
$$;
ROLLBACK;

\echo 0043_SECURITY_SEMANTICS=PASS
