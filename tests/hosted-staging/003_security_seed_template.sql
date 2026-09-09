-- STAGING SECURITY TEST FIXTURE ONLY. UUIDs below map only the confirmed
-- synthetic staging Auth users and synthetic fixture resources.

-- Execute once as the approved staging bootstrap administrator, never as an app user.
BEGIN;
INSERT INTO public.profiles (id, display_name, private_note) VALUES
  ('128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid, 'Synthetic Account A', 'synthetic-private-a'),
  ('ead4dbce-c4a1-4241-a244-66448e264b79'::uuid, 'Synthetic Account B', 'synthetic-private-b');
INSERT INTO public.organizations (id, name, owner_id) VALUES
  ('4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid, 'Synthetic Organization A', '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid),
  ('a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid, 'Synthetic Organization B', 'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid);
INSERT INTO public.organization_members (organization_id, user_id, role) VALUES
  ('4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid, '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid, 'OWNER'),
  ('a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid, 'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid, 'OWNER'),
  ('4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid, 'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid, 'MEMBER');
INSERT INTO public.jobs (id, organization_id, owner_id, title, employer, status) VALUES
  ('c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid, '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid, '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid, 'Synthetic Job A', 'Synthetic Employer A', 'DRAFT'),
  ('f9e2eb86-4e57-4141-b2bc-62a16a879cc9'::uuid, 'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid, 'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid, 'Synthetic Job B', 'Synthetic Employer B', 'DRAFT');
INSERT INTO public.audit_logs (id, actor_id, organization_id, action, entity_type, entity_id) VALUES
  ('1c4d3f78-1fe7-447a-a9dc-847daaa0193a'::uuid, '128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid, '4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid, 'synthetic.seed', 'job', 'c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid),
  ('bd6c4ffb-dc63-49ef-9e2f-e1b0ad00c6aa'::uuid, 'ead4dbce-c4a1-4241-a244-66448e264b79'::uuid, 'a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0'::uuid, 'synthetic.seed', 'job', 'f9e2eb86-4e57-4141-b2bc-62a16a879cc9'::uuid);
COMMIT;
