-- DUTA RANTAU Production forward reconciliation.
-- Restore only the missing canonical public.entities structural foundation.
-- No backfill. No RLS/policy/grant changes. No existing-row mutation.

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.users') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.users is missing';
  END IF;

  IF to_regtype('public.record_status') IS NULL THEN
    RAISE EXCEPTION 'precondition failed: public.record_status is missing';
  END IF;

  IF to_regclass('public.entities') IS NOT NULL THEN
    RAISE EXCEPTION 'precondition failed: public.entities already exists';
  END IF;
END
$$;

DO $$
BEGIN
  CREATE TYPE public.entity_type AS ENUM (
    'business',
    'community',
    'organisation'
  );
EXCEPTION
  WHEN duplicate_object THEN
    RAISE EXCEPTION 'precondition failed: public.entity_type already exists';
END
$$;

DO $$
BEGIN
  CREATE TYPE public.legal_status AS ENUM (
    'registered',
    'registered_under_other_law',
    'foreign_registered',
    'registration_pending',
    'registration_not_verified',
    'informal_group',
    'unknown'
  );
EXCEPTION
  WHEN duplicate_object THEN
    RAISE EXCEPTION 'precondition failed: public.legal_status already exists';
END
$$;

CREATE TABLE public.entities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type public.entity_type NOT NULL,
  display_name text NOT NULL,
  slug text NOT NULL,
  owner_user_id uuid REFERENCES public.users(id),
  record_status public.record_status NOT NULL DEFAULT 'PENDING',
  legal_status public.legal_status NOT NULL DEFAULT 'unknown',
  legal_status_claim public.legal_status,
  legal_status_verified public.legal_status,
  registration_authority text,
  registration_type text,
  registration_number text,
  jurisdiction text,
  operating_country text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT entities_legal_verified_requires_claim
    CHECK (
      legal_status_verified IS NULL
      OR legal_status_claim IS NOT NULL
    )
);

CREATE UNIQUE INDEX entities_slug_uq
  ON public.entities(slug);

CREATE INDEX entities_type_idx
  ON public.entities(entity_type);

CREATE INDEX entities_owner_idx
  ON public.entities(owner_user_id);

CREATE INDEX entities_legal_status_idx
  ON public.entities(legal_status);

COMMIT;
