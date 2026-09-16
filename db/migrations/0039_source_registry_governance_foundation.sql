-- 0039: additive official-source governance foundation.
--
-- Commit A lifecycle: PROPOSED only. This artifact establishes no local,
-- staging, production, deployment, ingestion, publication, or runtime-review
-- authority. Existing official_sources rows remain unclassified.
BEGIN;

CREATE TYPE public.source_purpose AS ENUM ('NEWS', 'CONSULAR_SERVICE', 'CONTACT');
CREATE TYPE public.official_source_currentness AS ENUM ('UNKNOWN', 'CURRENT', 'STALE', 'REVIEW_REQUIRED');

ALTER TABLE public.official_sources
  ADD COLUMN source_purpose public.source_purpose DEFAULT NULL;

CREATE TABLE public.official_source_governance (
  source_id uuid PRIMARY KEY REFERENCES public.official_sources(id) ON DELETE RESTRICT ON UPDATE NO ACTION,
  identity_verified boolean NOT NULL DEFAULT false,
  official_source_verified boolean NOT NULL DEFAULT false,
  currentness public.official_source_currentness NOT NULL DEFAULT 'UNKNOWN',
  verified_at timestamptz,
  verified_by uuid REFERENCES public.users(id) ON DELETE RESTRICT ON UPDATE NO ACTION,
  production_approved boolean NOT NULL DEFAULT false,
  approved_at timestamptz,
  approved_by uuid REFERENCES public.users(id) ON DELETE RESTRICT ON UPDATE NO ACTION,
  next_review_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT official_source_governance_verification_metadata_ck CHECK (
    (official_source_verified AND identity_verified AND verified_at IS NOT NULL AND verified_by IS NOT NULL)
    OR
    (NOT official_source_verified AND verified_at IS NULL AND verified_by IS NULL)
  ),
  CONSTRAINT official_source_governance_approval_metadata_ck CHECK (
    (production_approved AND identity_verified AND official_source_verified AND approved_at IS NOT NULL AND approved_by IS NOT NULL)
    OR
    (NOT production_approved AND approved_at IS NULL AND approved_by IS NULL)
  )
);

CREATE TABLE public.official_source_evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid NOT NULL REFERENCES public.official_sources(id) ON DELETE RESTRICT ON UPDATE NO ACTION,
  evidence_url text NOT NULL,
  evidence_type text NOT NULL,
  checked_at timestamptz NOT NULL,
  reviewed_by uuid REFERENCES public.users(id) ON DELETE RESTRICT ON UPDATE NO ACTION,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT official_source_evidence_source_url_uq UNIQUE (source_id, evidence_url)
);

ALTER TABLE public.official_source_governance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_source_evidence ENABLE ROW LEVEL SECURITY;

-- The legacy duta_app policy remains intact, but table-level INSERT/UPDATE
-- would otherwise also authorize the new source_purpose column. Preserve only
-- the demonstrated legacy source-management columns; purpose governance stays
-- owner-controlled until a later governed reviewer workflow exists.
REVOKE INSERT, UPDATE ON TABLE public.official_sources FROM duta_app;
GRANT INSERT (institution, channel, url, category, priority, trust_level, last_checked, checksum, active)
  ON TABLE public.official_sources TO duta_app;
GRANT UPDATE (active, priority, trust_level)
  ON TABLE public.official_sources TO duta_app;

COMMIT;
