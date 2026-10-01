-- REVIEW-ONLY CANDIDATE 0048.
-- Structural reconciliation only; do not execute against Production.
-- Preserves existing functions, triggers, RLS, policies, grants, roles, and ACLs.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $$
DECLARE
  jobs_columns integer;
BEGIN
  IF to_regclass('public.jobs') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.jobs is missing';
  END IF;
  IF to_regclass('public.entities') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.entities is missing';
  END IF;

  SELECT count(*) INTO jobs_columns
  FROM pg_attribute a
  WHERE a.attrelid = 'public.jobs'::regclass
    AND a.attnum > 0
    AND NOT a.attisdropped;
  IF jobs_columns <> 17 THEN
    RAISE EXCEPTION 'precondition failed: public.jobs column count is %, expected 17', jobs_columns;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_attribute WHERE attrelid='public.jobs'::regclass AND attname IN
    ('employer_entity_id','posting_kind','employer_eligibility_snapshot','published_at') AND NOT attisdropped) THEN
    RAISE EXCEPTION 'precondition failed: one or more reconciliation columns already exist';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='public.jobs'::regclass AND conname='jobs_employer_entity_id_fkey') THEN
    RAISE EXCEPTION 'precondition failed: jobs_employer_entity_id_fkey already exists';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname='jobs_employer_entity_idx' AND relnamespace='public'::regnamespace) THEN
    RAISE EXCEPTION 'precondition failed: jobs_employer_entity_idx already exists';
  END IF;
END $$;

LOCK TABLE public.jobs IN ACCESS EXCLUSIVE MODE;

ALTER TABLE public.jobs
  ADD COLUMN employer_entity_id uuid,
  ADD COLUMN posting_kind text,
  ADD COLUMN employer_eligibility_snapshot text,
  ADD COLUMN published_at timestamptz;

ALTER TABLE public.jobs
  ADD CONSTRAINT jobs_employer_entity_id_fkey
  FOREIGN KEY (employer_entity_id)
  REFERENCES public.entities(id)
  MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT DEFERRABLE;

CREATE INDEX jobs_employer_entity_idx
  ON public.jobs (employer_entity_id, status);

COMMIT;
