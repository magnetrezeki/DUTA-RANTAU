-- DUTA RANTAU emergency directory — safe idempotent deployment
-- May be run repeatedly. Does not drop tables, types, policies, or existing records.
BEGIN;

CREATE TABLE IF NOT EXISTS public.official_offices (
 id text PRIMARY KEY,
 institution text NOT NULL,
 city text NOT NULL,
 region text NOT NULL,
 latitude numeric(9,6) NOT NULL,
 longitude numeric(9,6) NOT NULL,
 official_url text NOT NULL,
 source_channel text NOT NULL,
 last_checked timestamptz NOT NULL,
 active boolean DEFAULT true NOT NULL,
 created_at timestamptz DEFAULT now() NOT NULL,
 updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.official_contacts (
 id text PRIMARY KEY,
 office_id text NOT NULL REFERENCES public.official_offices(id) ON DELETE CASCADE,
 label text NOT NULL,
 display_number text NOT NULL,
 e164 text NOT NULL,
 channel text NOT NULL,
 purpose text NOT NULL,
 warning text,
 whatsapp_confirmed boolean DEFAULT false NOT NULL,
 active boolean DEFAULT true NOT NULL,
 last_checked timestamptz NOT NULL,
 created_at timestamptz DEFAULT now() NOT NULL,
 updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.official_evidence (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 office_id text REFERENCES public.official_offices(id) ON DELETE SET NULL,
 institution text NOT NULL,
 evidence_type text NOT NULL,
 file_path text NOT NULL,
 captured_at timestamptz NOT NULL,
 effective_date timestamptz,
 verification_status text DEFAULT 'SUPPLIED_OFFICIAL_SCREENSHOT' NOT NULL,
 extracted_data jsonb DEFAULT '{}'::jsonb NOT NULL,
 created_at timestamptz DEFAULT now() NOT NULL,
 updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS official_contact_office_idx ON public.official_contacts(office_id,active);
CREATE UNIQUE INDEX IF NOT EXISTS official_evidence_path_uq ON public.official_evidence(file_path);
CREATE INDEX IF NOT EXISTS official_evidence_office_idx ON public.official_evidence(office_id,evidence_type);

ALTER TABLE public.official_offices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_evidence ENABLE ROW LEVEL SECURITY;

DO $policies$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_offices' AND policyname='official_offices_public') THEN
  CREATE POLICY official_offices_public ON public.official_offices FOR SELECT TO anon,authenticated USING (active=true);
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_contacts' AND policyname='official_contacts_public') THEN
  CREATE POLICY official_contacts_public ON public.official_contacts FOR SELECT TO anon,authenticated USING (active=true);
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_evidence' AND policyname='official_evidence_read') THEN
  CREATE POLICY official_evidence_read ON public.official_evidence FOR SELECT TO authenticated USING (true);
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_offices' AND policyname='official_offices_editor') THEN
  CREATE POLICY official_offices_editor ON public.official_offices FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_contacts' AND policyname='official_contacts_editor') THEN
  CREATE POLICY official_contacts_editor ON public.official_contacts FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
 END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='official_evidence' AND policyname='official_evidence_editor') THEN
  CREATE POLICY official_evidence_editor ON public.official_evidence FOR ALL TO authenticated USING (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[])) WITH CHECK (public.has_system_role(ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]));
 END IF;
END
$policies$;

INSERT INTO public.official_offices (id,institution,city,region,latitude,longitude,official_url,source_channel,last_checked,active) VALUES
('kbri-kl','KBRI Kuala Lumpur','Kuala Lumpur','Semenanjung Malaysia',3.139,101.687,'https://kemlu.go.id/kualalumpur','Halaman resmi KBRI Kuala Lumpur — Pelayanan Perlindungan WNI & BHI; lampiran tarif dari kanal resmi','2026-08-17T00:00:00Z',true),
('kjri-jb','KJRI Johor Bahru','Johor Bahru','Johor',1.4927,103.7414,'https://kemlu.go.id/johorbahru','Kanal resmi KJRI Johor Bahru pada poster tarif','2026-08-10T00:00:00Z',true),
('kjri-penang','KJRI Penang','George Town','Pulau Pinang',5.4141,100.3288,'https://kemlu.go.id/penang','Profil resmi KJRI Penang yang disertakan','2026-08-10T00:00:00Z',true),
('kjri-kuching','KJRI Kuching','Kuching','Sarawak',1.5533,110.3592,'https://kemlu.go.id/kuching','Poster dan akun resmi KJRI Kuching yang disertakan','2026-08-10T00:00:00Z',true),
('kjri-kk','KJRI Kota Kinabalu','Kota Kinabalu','Sabah',5.9804,116.0735,'https://kemlu.go.id/kotakinabalu','Pengumuman resmi TEMAN BAIK KJRI Kota Kinabalu yang disertakan','2026-08-10T00:00:00Z',true),
('kri-tawau','KRI Tawau','Tawau','Sabah Timur',4.2448,117.8912,'https://kemlu.go.id/tawau','Pengumuman dan profil resmi KRI Tawau yang disertakan','2026-08-10T00:00:00Z',true) ON CONFLICT (id) DO UPDATE SET institution=excluded.institution,city=excluded.city,region=excluded.region,latitude=excluded.latitude,longitude=excluded.longitude,official_url=excluded.official_url,source_channel=excluded.source_channel,last_checked=excluded.last_checked,active=true;
INSERT INTO public.official_contacts (id,office_id,label,display_number,e164,channel,purpose,warning,whatsapp_confirmed,active,last_checked) VALUES
('kl-protection-wa','kbri-kl','WhatsApp Perlindungan WNI','+60 17 500 7047','60175007047','WHATSAPP_CONFIRMED','Perlindungan WNI','Diverifikasi pada halaman resmi KBRI Kuala Lumpur; periksa kembali kanal resmi jika tidak tersambung.',true,true,'2026-08-17T00:00:00Z'),
('jb-pengaduan','kjri-jb','Pengaduan / Ksatria','+60 10 528 8040','60105288040','WHATSAPP_CONFIRMED','Pengaduan dan bantuan kasus',NULL,true,true,'2026-08-10T00:00:00Z'),
('penang-protection','kjri-penang','Pengaduan & Perlindungan WNI','+60 10 949 1859','60109491859','HOTLINE_MOBILE','Pengaduan dan perlindungan WNI','Sumber menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('penang-service','kjri-penang','Pelayanan KJRI Penang','+60 11 1246 0970','601112460970','HOTLINE_MOBILE','Informasi pelayanan','Sumber menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('kuching-general','kjri-kuching','Pengaduan Umum','+60 16 886 6734','60168866734','HOTLINE_MOBILE','Pengaduan umum','Poster menyebut hotline; ketersediaan WhatsApp belum dinyatakan secara eksplisit.',false,true,'2026-08-10T00:00:00Z'),
('kuching-death','kjri-kuching','Kematian WNI','+60 16 889 9734','60168899734','HOTLINE_MOBILE','Bantuan kematian WNI',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-labour','kjri-kuching','Ketenagakerjaan','+60 12 880 1288','60128801288','HOTLINE_MOBILE','Masalah ketenagakerjaan',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-immigration','kjri-kuching','Imigrasi','+60 10 595 4699','60105954699','HOTLINE_MOBILE','Informasi imigrasi',NULL,false,true,'2026-08-10T00:00:00Z'),
('kuching-apowakim','kjri-kuching','APOWAKIM Imigrasi','+60 10 954 6570','60109546570','WHATSAPP_CONFIRMED','Pendaftaran paspor/SPLP melalui WhatsApp resmi','Bukan nomor darurat umum; gunakan khusus layanan paspor/SPLP.',true,true,'2026-08-10T00:00:00Z'),
('kk-hotline','kjri-kk','Hotline KJRI Kota Kinabalu','+60 14 606 0067','60146060067','HOTLINE_MOBILE','Pertanyaan dan informasi lain',NULL,false,true,'2026-08-10T00:00:00Z'),
('kk-appointment','kjri-kk','TEMAN BAIK — Jadwal Temu Janji','+62 857 2030 5600','6285720305600','APPOINTMENT_ONLY','Hanya menyampaikan jadwal temu janji','Bukan hotline darurat dan bukan untuk pertanyaan umum.',false,true,'2026-08-10T00:00:00Z'),
('tawau-immigration','kri-tawau','Keimigrasian Mendesak','+60 11 1623 0800','601116230800','HOTLINE_MOBILE','Keperluan keimigrasian mendesak','Nomor dibaca dari poster resmi yang disertakan; verifikasi kembali pada kanal resmi.',false,true,'2026-08-10T00:00:00Z'),
('tawau-consular','kri-tawau','Kekonsuleran Mendesak','+60 19 822 6800','60198226800','HOTLINE_MOBILE','Keperluan kekonsuleran mendesak',NULL,false,true,'2026-08-10T00:00:00Z'),
('tawau-office','kri-tawau','Telepon Kantor','+60 89 772 052','6089772052','PHONE','Kontak kantor KRI Tawau',NULL,false,true,'2026-08-10T00:00:00Z') ON CONFLICT (id) DO UPDATE SET label=excluded.label,display_number=excluded.display_number,e164=excluded.e164,channel=excluded.channel,purpose=excluded.purpose,warning=excluded.warning,whatsapp_confirmed=excluded.whatsapp_confirmed,active=true,last_checked=excluded.last_checked;
INSERT INTO public.official_evidence (office_id,institution,evidence_type,file_path,captured_at,verification_status,extracted_data) VALUES
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.34.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.34.jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35 (1).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35 (3).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35 (3).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.35.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.35.jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.36 (2).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.36 (2).jpeg"}'::jsonb),
('kjri-kk','KJRI Kota Kinabalu','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.08.36.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.08.36.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.06.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.06.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.07 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.07 (1).jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.07.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.07.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.08 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.08 (1).jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.08.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.08.jpeg"}'::jsonb),
('kjri-kuching','KJRI Kuching','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 19.20.09.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 19.20.09.jpeg"}'::jsonb),
('kbri-kl','KBRI Kuala Lumpur','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.05.36.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.05.36.jpeg"}'::jsonb),
('kbri-kl','KBRI Kuala Lumpur','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.05.37.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.05.37.jpeg"}'::jsonb),
('kjri-jb','KJRI Johor Bahru','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.18.01.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.18.01.jpeg"}'::jsonb),
('kjri-jb','KJRI Johor Bahru','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.18.02.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.18.02.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.08.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.08.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.09.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.09.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.51.10.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.51.10.jpeg"}'::jsonb),
('kjri-penang','KJRI Penang','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 22.59.31.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 22.59.31.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.53 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.53 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.53.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.53.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54 (2).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54 (2).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','TARIFF','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.54.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.54.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.55.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.55.jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.56 (1).jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.56 (1).jpeg"}'::jsonb),
('kri-tawau','KRI Tawau','CONTACT_OR_SERVICE','/evidence/official-2026-08-10/WhatsApp Image 2026-08-10 at 23.12.56.jpeg','2026-08-10T00:00:00Z','SUPPLIED_OFFICIAL_SCREENSHOT','{"originalFilename": "WhatsApp Image 2026-08-10 at 23.12.56.jpeg"}'::jsonb) ON CONFLICT (file_path) DO UPDATE SET office_id=excluded.office_id,institution=excluded.institution,evidence_type=excluded.evidence_type,captured_at=excluded.captured_at,verification_status=excluded.verification_status,extracted_data=excluded.extracted_data,updated_at=now();

COMMIT;

SELECT
 (SELECT count(*) FROM public.official_offices) AS offices,
 (SELECT count(*) FROM public.official_contacts) AS contacts,
 (SELECT count(*) FROM public.official_evidence) AS evidence,
 (SELECT bool_and(c.relrowsecurity)
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname='public' AND c.relname IN ('official_offices','official_contacts','official_evidence')) AS all_rls_enabled;
