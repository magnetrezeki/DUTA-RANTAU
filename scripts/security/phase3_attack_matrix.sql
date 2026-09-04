-- LOCAL_STAGING ONLY. Requires PHASE3_TEST_FIXTURE data. No production use.
CREATE OR REPLACE FUNCTION pg_temp.assert_denied(command text,label text) RETURNS void LANGUAGE plpgsql AS $$DECLARE denied boolean:=false;BEGIN BEGIN EXECUTE command;EXCEPTION WHEN OTHERS THEN denied:=true;END;IF NOT denied THEN RAISE EXCEPTION 'SECURITY FAIL: % allowed',label;END IF;END$$;
CREATE OR REPLACE FUNCTION pg_temp.assert_count(command text,expected bigint,label text) RETURNS void LANGUAGE plpgsql AS $$DECLARE n bigint;BEGIN EXECUTE command INTO n;IF n<>expected THEN RAISE EXCEPTION 'SECURITY FAIL: %, expected %, got %',label,expected,n;END IF;END$$;

-- Missing identity fails closed for protected rows.
BEGIN;SET LOCAL ROLE duta_app;SELECT pg_temp.assert_count('select count(*) from public.users',0,'missing identity users');SELECT pg_temp.assert_denied('insert into public.jobs(title,employer,description,employment_type) values (''x'',''x'',''x'',''FULL_TIME'')','missing identity job insert');ROLLBACK;
BEGIN;SET LOCAL ROLE duta_app;SELECT pg_temp.assert_count('select count(*) from public.members',0,'missing identity members');SELECT pg_temp.assert_denied('insert into public.members(user_id,phone_number) values (''10000000-0000-4000-8000-000000000001'',''+60129999999'')','missing identity member insert');ROLLBACK;

-- Malformed identity fails closed.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','not-a-uuid',true);SELECT pg_temp.assert_denied('select public.current_app_user_id()','malformed identity');ROLLBACK;

-- User A own/cross-user and privilege escalation.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000001',true);SELECT pg_temp.assert_count('select count(*) from public.users where id=''10000000-0000-4000-8000-000000000001''',1,'A reads A');SELECT pg_temp.assert_count('select count(*) from public.users where id=''10000000-0000-4000-8000-000000000002''',0,'A reads B');SELECT pg_temp.assert_denied('update public.users set name=''attack'' where id=''10000000-0000-4000-8000-000000000002''','A updates B');SELECT pg_temp.assert_denied('delete from public.users where id=''10000000-0000-4000-8000-000000000002''','A deletes B');SELECT pg_temp.assert_count('select count(*) from public.members where user_id=''10000000-0000-4000-8000-000000000001''',1,'A reads A member');SELECT pg_temp.assert_count('select count(*) from public.members where user_id=''10000000-0000-4000-8000-000000000002''',0,'A reads B member');SELECT pg_temp.assert_denied('update public.members set status=''ACTIVE'' where user_id=''10000000-0000-4000-8000-000000000001''','A activates own membership');SELECT pg_temp.assert_denied('update public.users set role=''SUPER_ADMIN'' where id=''10000000-0000-4000-8000-000000000001''','A self role escalation');ROLLBACK;

-- User B symmetric isolation.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000002',true);SELECT pg_temp.assert_count('select count(*) from public.users where id=''10000000-0000-4000-8000-000000000002''',1,'B reads B');SELECT pg_temp.assert_count('select count(*) from public.users where id=''10000000-0000-4000-8000-000000000001''',0,'B reads A');ROLLBACK;

-- Cross-organization and role/permission forgery.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000003',true);SELECT pg_temp.assert_count('select count(*) from public.organization_members where organization_id=''20000000-0000-4000-8000-000000000002''',0,'Org A member reads Org B membership');SELECT pg_temp.assert_denied('insert into public.organization_members(organization_id,user_id,role,member_status) values (''20000000-0000-4000-8000-000000000002'',''10000000-0000-4000-8000-000000000003'',''OWNER'',''ACTIVE'')','self owner escalation');SELECT pg_temp.assert_denied('insert into public.organization_permissions(organization_id,role,permission) values (''20000000-0000-4000-8000-000000000001'',''MEMBER'',''finance.manage'')','member permission forgery');SELECT pg_temp.assert_count('select count(*) from public.organization_finances where organization_id=''20000000-0000-4000-8000-000000000002''',0,'cross org finance');SELECT pg_temp.assert_count('select count(*) from public.organization_payments op join public.organization_subscriptions s on s.id=op.subscription_id where s.organization_id=''20000000-0000-4000-8000-000000000002''',0,'cross org payment');ROLLBACK;

-- Organization application is denied for a non-ACTIVE member.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000001',true);SELECT pg_temp.assert_denied('insert into public.organizations(applicant_id,name,type,category,registration_number,status,application_status,verification) values (''10000000-0000-4000-8000-000000000001'',''attack org'',''TEST'',''TEST'',''ATTACK'',''PENDING'',''PENDING_REVIEW'',''USER_GENERATED'')','non-active member organization insert');ROLLBACK;

-- ADMIN may review, but normal users may not.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000007',true);UPDATE public.members SET status='SUSPENDED',reviewed_by='10000000-0000-4000-8000-000000000007',reviewed_at=now() WHERE user_id='10000000-0000-4000-8000-000000000003';ROLLBACK;

-- Organization archival and workflow hardening.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000007',true);SELECT pg_temp.assert_denied('delete from public.organizations where id=''20000000-0000-4000-8000-000000000001''','admin physical organization delete');SELECT pg_temp.assert_denied('insert into public.organizations(name,type,status,verification,application_status) values (''attack active'',''TEST'',''ACTIVE'',''DUTA_VERIFIED'',''PENDING_REVIEW'')','admin direct active verified organization insert');UPDATE public.organizations SET status='ARCHIVED' WHERE id='20000000-0000-4000-8000-000000000001';ROLLBACK;
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000007',true);INSERT INTO public.organizations(name,type,status,verification,application_status) VALUES ('PHASE4_TEST_DRAFT','TEST','PENDING','USER_GENERATED','PENDING_REVIEW');ROLLBACK;

-- Job, financial, subscription and audit mutations denied.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000001',true);SELECT pg_temp.assert_denied('insert into public.jobs(owner_id,title,employer,description,employment_type,status,trust_level) values (''10000000-0000-4000-8000-000000000001'',''attack'',''attack'',''attack'',''FULL_TIME'',''PENDING'',''USER_GENERATED'')','unauthorized job insert');SELECT pg_temp.assert_denied('update public.jobs set status=''ACTIVE'' where id=''70000000-0000-4000-8000-000000000001''','job publish');SELECT pg_temp.assert_denied('insert into public.payments(membership_id,provider,amount_myr,status) values (gen_random_uuid(),''attack'',1,''PAID'')','payment insert');SELECT pg_temp.assert_denied('update public.organization_subscriptions set plan=''PRO'' where organization_id=''20000000-0000-4000-8000-000000000002''','subscription forgery');SELECT pg_temp.assert_denied('delete from public.audit_logs','audit deletion');ROLLBACK;

-- Commit cleanup.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000001',true);SELECT public.current_app_user_id();COMMIT;
BEGIN;SET LOCAL ROLE duta_app;DO $$BEGIN IF public.current_app_user_id() IS NOT NULL THEN RAISE EXCEPTION 'SECURITY FAIL: commit identity leak';END IF;END$$;ROLLBACK;

-- Rollback cleanup.
BEGIN;SET LOCAL ROLE duta_app;SELECT set_config('app.user_id','10000000-0000-4000-8000-000000000001',true);ROLLBACK;
BEGIN;SET LOCAL ROLE duta_app;DO $$BEGIN IF public.current_app_user_id() IS NOT NULL THEN RAISE EXCEPTION 'SECURITY FAIL: rollback identity leak';END IF;END$$;ROLLBACK;

-- Runtime privilege escalation DDL denied.
BEGIN;SET LOCAL ROLE duta_app;SELECT pg_temp.assert_denied('create table public.phase3_attack_should_not_exist(id int)','CREATE TABLE');SELECT pg_temp.assert_denied('alter table public.users add column phase3_attack text','ALTER TABLE');SELECT pg_temp.assert_denied('create role phase3_attack_role','CREATE ROLE');ROLLBACK;

SELECT 'PHASE3_ATTACK_MATRIX_SQL_PASS' AS result;
