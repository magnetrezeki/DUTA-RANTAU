-- Synthetic, deterministic data for the isolated local-test database only.
\set ON_ERROR_STOP on

BEGIN;

TRUNCATE TABLE public.official_sources;

INSERT INTO public.official_sources (
  id, institution, channel, url, category, priority, trust_level,
  last_checked, checksum, active, created_at, updated_at
) VALUES
  (
    '00000000-0000-4000-8000-000000000101',
    'KJRI Penang',
    'website',
    'https://source-penang.example.invalid/official',
    'consular',
    'P0',
    'OFFICIAL_VERIFIED',
    '2026-08-16T00:00:00Z',
    'synthetic-checksum-penang-v1',
    true,
    '2026-08-16T00:00:00Z',
    '2026-08-16T00:00:00Z'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    'Synthetic Inactive Source',
    'website',
    'https://inactive-source.example.invalid/official',
    'general',
    'P0',
    'OFFICIAL_VERIFIED',
    '2026-08-15T00:00:00Z',
    'synthetic-checksum-inactive-v1',
    false,
    '2026-08-15T00:00:00Z',
    '2026-08-15T00:00:00Z'
  );

COMMIT;
