-- STAGING ONLY. Run manually after a successful authenticated harness run.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.audit_logs WHERE id='6ed26cbd-23a5-4ff4-9432-0709e216447a'::uuid AND actor_id='128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid AND organization_id='4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid AND entity_id='c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid AND action='synthetic.job_note' AND entity_type='job') THEN RAISE EXCEPTION 'Expected authenticated test residue is absent or does not match'; END IF;
END $$;
DELETE FROM public.audit_logs WHERE id='6ed26cbd-23a5-4ff4-9432-0709e216447a'::uuid AND actor_id='128d19d8-fe70-4847-8b2e-e1c2d124539e'::uuid AND organization_id='4c4b86fc-447d-4cf9-89e3-7c55f412a0a7'::uuid AND entity_id='c3a31ab8-b2cc-440b-bacd-479205f01de2'::uuid AND action='synthetic.job_note' AND entity_type='job';
