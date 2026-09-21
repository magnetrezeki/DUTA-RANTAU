\set ON_ERROR_STOP on
INSERT INTO public.users(id,email,name,role) VALUES
('11111111-1111-4111-8111-111111111111','owner@test','Owner','USER'),
('22222222-2222-4222-8222-222222222222','other@test','Other','USER'),
('33333333-3333-4333-8333-333333333333','mod@test','Moderator','MODERATOR'),
('44444444-4444-4444-8444-444444444444','review@test','Reviewer','COMPLIANCE_ADMIN'),
('55555555-5555-4555-8555-555555555555','admin@test','Admin','SUPER_ADMIN');

SET ROLE duta_app;
BEGIN;
SELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
INSERT INTO public.entities(id,entity_type,display_name,slug,owner_user_id,record_status,legal_status) VALUES
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','business','Owner Business','owner-business','11111111-1111-4111-8111-111111111111','PENDING','unknown'),
('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','organisation','Owner Org','owner-org','11111111-1111-4111-8111-111111111111','PENDING','unknown');
INSERT INTO public.entity_eligibilities(id,entity_id,eligibility_type,status,decision_source) VALUES
('aaaaaaaa-0000-4000-8000-000000000001','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','employer','pending','manual_review'),
('aaaaaaaa-0000-4000-8000-000000000002','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','commercial','pending','manual_review');
INSERT INTO public.jobs(id,owner_id,employer_entity_id,posting_kind,title,employer,description,employment_type,status) VALUES('10000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','direct_employer','Draft Job','Owner Business','Long enough description','full_time','PENDING');
INSERT INTO public.sellers(id,user_id,entity_id,name,trust_level,status) VALUES('20000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Owner Seller','USER_GENERATED','ACTIVE');
INSERT INTO public.products(id,seller_id,seller_entity_id,name,description,category,status) VALUES('30000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001','aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Draft Product','Long enough product','ordinary_goods','PENDING');
INSERT INTO public.communities(id,owner_id,name,description,category,status,trust_level,community_access_scope) VALUES('40000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','Owner Community','Community description','social','PENDING','USER_GENERATED','pre_arrival_allowed');
\echo OWNER_MEMBERSHIP_INSERT
INSERT INTO public.community_members(community_id,user_id,role) VALUES('40000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','OWNER');
INSERT INTO public.organizations(id,entity_id,name,type,description,verification,status) VALUES('50000000-0000-4000-8000-000000000001','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Owner Org','association','Org description','USER_GENERATED','PENDING');
INSERT INTO public.organization_members(organization_id,user_id,role) VALUES('50000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','OWNER');
INSERT INTO public.entity_responsible_persons(entity_id,user_id,role,status,is_primary) VALUES('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','11111111-1111-4111-8111-111111111111','OWNER_REPRESENTATIVE','active',true);
INSERT INTO public.notifications(id,user_id,type,priority,title,body) VALUES('60000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','TEST','NORMAL','Own','Body');
UPDATE public.jobs SET title='Owner Edited' WHERE id='10000000-0000-4000-8000-000000000001';
UPDATE public.products SET name='Owner Edited' WHERE id='30000000-0000-4000-8000-000000000001';
UPDATE public.communities SET name='Owner Edited' WHERE id='40000000-0000-4000-8000-000000000001';
UPDATE public.organizations SET name='Owner Edited' WHERE id='50000000-0000-4000-8000-000000000001';
COMMIT;

BEGIN;
SELECT set_config('app.user_id','22222222-2222-4222-8222-222222222222',true);
UPDATE public.jobs SET title='ILLEGAL' WHERE id='10000000-0000-4000-8000-000000000001';
UPDATE public.products SET name='ILLEGAL' WHERE id='30000000-0000-4000-8000-000000000001';
UPDATE public.communities SET name='ILLEGAL' WHERE id='40000000-0000-4000-8000-000000000001';
UPDATE public.organizations SET name='ILLEGAL' WHERE id='50000000-0000-4000-8000-000000000001';
DO $$BEGIN IF EXISTS(SELECT 1 FROM public.notifications WHERE id='60000000-0000-4000-8000-000000000001') THEN RAISE EXCEPTION 'non-recipient read notification'; END IF; END$$;
COMMIT;

BEGIN;
SELECT set_config('app.user_id','55555555-5555-4555-8555-555555555555',true);
UPDATE public.entities SET record_status='ACTIVE' WHERE id IN('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
UPDATE public.products SET status='ACTIVE' WHERE id='30000000-0000-4000-8000-000000000001';
DO $$BEGIN IF EXISTS(SELECT 1 FROM public.products WHERE id='30000000-0000-4000-8000-000000000001' AND status='ACTIVE') THEN RAISE EXCEPTION 'super admin inherited moderation'; END IF; END$$;
COMMIT;

BEGIN;
SELECT set_config('app.user_id','44444444-4444-4444-8444-444444444444',true);
UPDATE public.entity_eligibilities SET status='approved',reviewed_by='44444444-4444-4444-8444-444444444444',approved_at=now() WHERE entity_id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
COMMIT;

BEGIN;
SELECT set_config('app.user_id','33333333-3333-4333-8333-333333333333',true);
UPDATE public.jobs SET status='ACTIVE' WHERE id='10000000-0000-4000-8000-000000000001';
UPDATE public.products SET status='ACTIVE' WHERE id='30000000-0000-4000-8000-000000000001';
UPDATE public.communities SET status='ACTIVE' WHERE id='40000000-0000-4000-8000-000000000001';
UPDATE public.organizations SET status='ACTIVE' WHERE id='50000000-0000-4000-8000-000000000001';
COMMIT;

BEGIN;
SELECT set_config('app.user_id','22222222-2222-4222-8222-222222222222',true);
\echo MEMBER_JOIN_INSERT
INSERT INTO public.community_members(community_id,user_id,role) VALUES('40000000-0000-4000-8000-000000000001','22222222-2222-4222-8222-222222222222','MEMBER');
DO $$BEGIN IF NOT EXISTS(SELECT 1 FROM public.community_members WHERE community_id='40000000-0000-4000-8000-000000000001' AND user_id='22222222-2222-4222-8222-222222222222') THEN RAISE EXCEPTION 'join not persistent'; END IF; END$$;
DELETE FROM public.community_members WHERE community_id='40000000-0000-4000-8000-000000000001' AND user_id='22222222-2222-4222-8222-222222222222';
DO $$BEGIN IF EXISTS(SELECT 1 FROM public.community_members WHERE community_id='40000000-0000-4000-8000-000000000001' AND user_id='22222222-2222-4222-8222-222222222222') THEN RAISE EXCEPTION 'leave not persistent'; END IF; END$$;
COMMIT;

BEGIN;
SELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
DO $$BEGIN IF (SELECT count(*) FROM public.notifications WHERE id='60000000-0000-4000-8000-000000000001')<>1 THEN RAISE EXCEPTION 'recipient cannot read own notification'; END IF; IF (SELECT verification FROM public.organizations WHERE id='50000000-0000-4000-8000-000000000001')<>'USER_GENERATED' THEN RAISE EXCEPTION 'publication fabricated verification'; END IF; END$$;
COMMIT;
RESET ROLE;

DO $$BEGIN
IF (SELECT title FROM public.jobs WHERE id='10000000-0000-4000-8000-000000000001')<>'Owner Edited' THEN RAISE EXCEPTION 'job owner isolation failed'; END IF;
IF (SELECT name FROM public.products WHERE id='30000000-0000-4000-8000-000000000001')<>'Owner Edited' THEN RAISE EXCEPTION 'product owner isolation failed'; END IF;
IF (SELECT status FROM public.jobs WHERE id='10000000-0000-4000-8000-000000000001')<>'ACTIVE' OR (SELECT status FROM public.products WHERE id='30000000-0000-4000-8000-000000000001')<>'ACTIVE' OR (SELECT status FROM public.communities WHERE id='40000000-0000-4000-8000-000000000001')<>'ACTIVE' OR (SELECT status FROM public.organizations WHERE id='50000000-0000-4000-8000-000000000001')<>'ACTIVE' THEN RAISE EXCEPTION 'moderation publication failed'; END IF;
END$$;
