-- 0044: populate the Founder-approved Malaysia official-source registry.
-- The fixed last_checked value records the dated 2026-09-23 registry decision;
-- it is not a governance verification, reviewer action, or production approval.
BEGIN;

WITH registry(institution, channel, url, category, priority, source_purpose) AS (
  VALUES
    ('KBRI Kuala Lumpur','WEBSITE','https://kemlu.go.id/kualalumpur','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/indonesiainkualalumpur/','official_news','P1','NEWS'::public.source_purpose),
    ('KBRI Kuala Lumpur','FACEBOOK','https://www.facebook.com/IndonesianEmbassyKualaLumpur/','official_news','P1','NEWS'::public.source_purpose),
    ('KBRI Kuala Lumpur','X','https://x.com/kbrikualalumpur','official_news','P1','NEWS'::public.source_purpose),
    ('KBRI Kuala Lumpur','YOUTUBE','https://www.youtube.com/@kbrikualalumpur','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Johor Bahru','WEBSITE','https://kemlu.go.id/johorbahru','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KJRI Johor Bahru','INSTAGRAM','https://www.instagram.com/indonesiainjb/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Johor Bahru','FACEBOOK','https://www.facebook.com/IndonesianInJohorBahru/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Penang','WEBSITE','https://kemlu.go.id/penang','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KJRI Penang','INSTAGRAM','https://www.instagram.com/indonesiainpenang/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Penang','FACEBOOK','https://www.facebook.com/indonesiainpenang/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Penang','X','https://x.com/IndonesiaPenang','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Penang','YOUTUBE','https://www.youtube.com/channel/UCQ6aLdnF6UFNDjP-1_QqHpw','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Kota Kinabalu','WEBSITE','https://kemlu.go.id/kotakinabalu','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KJRI Kota Kinabalu','INSTAGRAM','https://www.instagram.com/indonesiainkotakinabalu/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Kuching','WEBSITE','https://kemlu.go.id/kuching','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KJRI Kuching','INSTAGRAM','https://www.instagram.com/indonesiainkuching/','official_news','P1','NEWS'::public.source_purpose),
    ('KJRI Kuching','FACEBOOK','https://www.facebook.com/kjrikuching/','official_news','P1','NEWS'::public.source_purpose),
    ('KRI Tawau','WEBSITE','https://kemlu.go.id/tawau','consular','P0','CONSULAR_SERVICE'::public.source_purpose),
    ('KRI Tawau','INSTAGRAM','https://www.instagram.com/indonesiaintawau/','official_news','P1','NEWS'::public.source_purpose),
    ('KRI Tawau','FACEBOOK','https://www.facebook.com/konsulatritawau/','official_news','P1','NEWS'::public.source_purpose),
    ('KRI Tawau','X','https://x.com/indonesiaintwu','official_news','P1','NEWS'::public.source_purpose),
    ('Atase/Fungsi Tenaga Kerja — KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/atnaker.kl/','official_news','P1','NEWS'::public.source_purpose),
    ('Atase Hukum — KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/atkum.kualalumpur/','official_news','P1','NEWS'::public.source_purpose),
    ('Atase Pendidikan dan Kebudayaan — KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/atdikbud_kualalumpur/','official_news','P1','NEWS'::public.source_purpose),
    ('Atase Perhubungan — KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/ataseperhubungan.kl/','official_news','P1','NEWS'::public.source_purpose),
    ('Atase Perdagangan — KBRI Kuala Lumpur','INSTAGRAM','https://www.instagram.com/atdag.kualalumpur/','official_news','P1','NEWS'::public.source_purpose)
)
INSERT INTO public.official_sources (
  institution, channel, url, category, priority, trust_level, last_checked,
  checksum, active, source_purpose
)
SELECT institution, channel, url, category, priority, 'OFFICIAL_VERIFIED',
  TIMESTAMPTZ '2026-09-23 00:00:00+08',
  'p5c-0044-founder-approved-registry-v1', true, source_purpose
FROM registry
ON CONFLICT (url) DO UPDATE SET
  institution = EXCLUDED.institution,
  channel = EXCLUDED.channel,
  category = EXCLUDED.category,
  priority = EXCLUDED.priority,
  trust_level = EXCLUDED.trust_level,
  last_checked = EXCLUDED.last_checked,
  checksum = EXCLUDED.checksum,
  active = true,
  source_purpose = EXCLUDED.source_purpose,
  updated_at = now();

-- Preserve the 0039 truth boundary: registry inclusion does not manufacture
-- reviewer identity, evidence, currentness, or production approval.
INSERT INTO public.official_source_governance (source_id)
SELECT source.id
FROM public.official_sources source
WHERE source.checksum = 'p5c-0044-founder-approved-registry-v1'
ON CONFLICT (source_id) DO NOTHING;

COMMIT;
