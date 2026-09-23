export type OfficialSourceChannel = "WEBSITE" | "INSTAGRAM" | "FACEBOOK" | "X" | "YOUTUBE";
export type OfficialSourcePurpose = "NEWS" | "CONSULAR_SERVICE" | "CONTACT";
export type OfficialSourceDomain = "MISSION" | "TENAGA_KERJA" | "HUKUM" | "PENDIDIKAN_KEBUDAYAAN" | "PERHUBUNGAN" | "PERDAGANGAN";
export type IngestionCapability = "EXTERNAL_ADAPTER_REQUIRED";

export type MalaysiaOfficialSource = {
  id: string;
  institution: string;
  channel: OfficialSourceChannel;
  url: string;
  evidenceScope: readonly string[];
  primaryPurpose: OfficialSourcePurpose;
  infoRantauEligible: true;
  domain: OfficialSourceDomain;
  ingestionCapability: IngestionCapability;
};

const source = (
  id: string,
  institution: string,
  channel: OfficialSourceChannel,
  url: string,
  evidenceScope: readonly string[],
  primaryPurpose: OfficialSourcePurpose,
  domain: OfficialSourceDomain = "MISSION",
): MalaysiaOfficialSource => ({ id, institution, channel, url, evidenceScope, primaryPurpose, infoRantauEligible: true, domain, ingestionCapability: "EXTERNAL_ADAPTER_REQUIRED" });

export const malaysiaOfficialSources = [
  source("MISSION_01_WEBSITE", "KBRI Kuala Lumpur", "WEBSITE", "https://kemlu.go.id/kualalumpur", ["office", "general information", "consular", "protection", "immigration"], "CONSULAR_SERVICE"),
  source("MISSION_01_INSTAGRAM", "KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/indonesiainkualalumpur/", ["official announcements", "consular", "protection", "immigration"], "NEWS"),
  source("MISSION_01_FACEBOOK", "KBRI Kuala Lumpur", "FACEBOOK", "https://www.facebook.com/IndonesianEmbassyKualaLumpur/", ["official announcements", "consular", "protection"], "NEWS"),
  source("MISSION_01_X", "KBRI Kuala Lumpur", "X", "https://x.com/kbrikualalumpur", ["official information", "consular"], "NEWS"),
  source("MISSION_01_YOUTUBE", "KBRI Kuala Lumpur", "YOUTUBE", "https://www.youtube.com/@kbrikualalumpur", ["official information", "consular"], "NEWS"),
  source("MISSION_02_WEBSITE", "KJRI Johor Bahru", "WEBSITE", "https://kemlu.go.id/johorbahru", ["office", "consular", "immigration", "protection", "community", "local warnings"], "CONSULAR_SERVICE"),
  source("MISSION_02_INSTAGRAM", "KJRI Johor Bahru", "INSTAGRAM", "https://www.instagram.com/indonesiainjb/", ["official services", "announcements"], "NEWS"),
  source("MISSION_02_FACEBOOK", "KJRI Johor Bahru", "FACEBOOK", "https://www.facebook.com/IndonesianInJohorBahru/", ["services", "protection", "community", "local warnings"], "NEWS"),
  source("MISSION_03_WEBSITE", "KJRI Penang", "WEBSITE", "https://kemlu.go.id/penang", ["office", "consular", "immigration", "protection", "community", "local warnings"], "CONSULAR_SERVICE"),
  source("MISSION_03_INSTAGRAM", "KJRI Penang", "INSTAGRAM", "https://www.instagram.com/indonesiainpenang/", ["official announcements", "services"], "NEWS"),
  source("MISSION_03_FACEBOOK", "KJRI Penang", "FACEBOOK", "https://www.facebook.com/indonesiainpenang/", ["services", "protection", "community information"], "NEWS"),
  source("MISSION_03_X", "KJRI Penang", "X", "https://x.com/IndonesiaPenang", ["consular information", "local warnings"], "NEWS"),
  source("MISSION_03_YOUTUBE", "KJRI Penang", "YOUTUBE", "https://www.youtube.com/channel/UCQ6aLdnF6UFNDjP-1_QqHpw", ["official service publications", "information"], "NEWS"),
  source("MISSION_04_WEBSITE", "KJRI Kota Kinabalu", "WEBSITE", "https://kemlu.go.id/kotakinabalu", ["office", "consular", "immigration", "protection", "community", "local warnings"], "CONSULAR_SERVICE"),
  source("MISSION_04_INSTAGRAM", "KJRI Kota Kinabalu", "INSTAGRAM", "https://www.instagram.com/indonesiainkotakinabalu/", ["official services", "announcements"], "NEWS"),
  source("MISSION_05_WEBSITE", "KJRI Kuching", "WEBSITE", "https://kemlu.go.id/kuching", ["office", "consular", "immigration", "protection", "community", "local warnings"], "CONSULAR_SERVICE"),
  source("MISSION_05_INSTAGRAM", "KJRI Kuching", "INSTAGRAM", "https://www.instagram.com/indonesiainkuching/", ["official services", "announcements"], "NEWS"),
  source("MISSION_05_FACEBOOK", "KJRI Kuching", "FACEBOOK", "https://www.facebook.com/kjrikuching/", ["services", "protection", "community", "local warnings"], "NEWS"),
  source("MISSION_06_WEBSITE", "KRI Tawau", "WEBSITE", "https://kemlu.go.id/tawau", ["office", "consular", "immigration", "protection", "community", "local warnings"], "CONSULAR_SERVICE"),
  source("MISSION_06_INSTAGRAM", "KRI Tawau", "INSTAGRAM", "https://www.instagram.com/indonesiaintawau/", ["official services", "announcements"], "NEWS"),
  source("MISSION_06_FACEBOOK", "KRI Tawau", "FACEBOOK", "https://www.facebook.com/konsulatritawau/", ["services", "protection", "community", "local warnings"], "NEWS"),
  source("MISSION_06_X", "KRI Tawau", "X", "https://x.com/indonesiaintwu", ["consular", "immigration", "protection", "community", "local warnings"], "NEWS"),
  source("FUNCTION_TENAGA_KERJA", "Atase/Fungsi Tenaga Kerja — KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/atnaker.kl/", ["migrant workers", "employment", "protection", "repatriation"], "NEWS", "TENAGA_KERJA"),
  source("FUNCTION_HUKUM", "Atase Hukum — KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/atkum.kualalumpur/", ["law", "protection", "legal assistance"], "NEWS", "HUKUM"),
  source("FUNCTION_PENDIDIKAN", "Atase Pendidikan dan Kebudayaan — KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/atdikbud_kualalumpur/", ["education", "students", "scholarships", "culture"], "NEWS", "PENDIDIKAN_KEBUDAYAAN"),
  source("FUNCTION_PERHUBUNGAN", "Atase Perhubungan — KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/ataseperhubungan.kl/", ["transportation", "seafarers", "travel"], "NEWS", "PERHUBUNGAN"),
  source("FUNCTION_PERDAGANGAN", "Atase Perdagangan — KBRI Kuala Lumpur", "INSTAGRAM", "https://www.instagram.com/atdag.kualalumpur/", ["trade", "business", "export", "economy"], "NEWS", "PERDAGANGAN"),
] as const satisfies readonly MalaysiaOfficialSource[];

export const malaysiaAppointmentEndpoints = [
  ["KBRI Kuala Lumpur", "https://antrean.kbrikl.id/"],
  ["KJRI Johor Bahru", "https://daftaronline.indonesiainjb.my/"],
  ["KJRI Penang", "https://layananonline.kjripenang.my/"],
  ["KJRI Kuching", "https://imigrasi.synergize.co/?i=1"],
  ["KJRI Kota Kinabalu", "https://teman-baik.kjrikk.com/"],
  ["KRI Tawau", "https://www.temujanjiantrianpelayanankritawau.org/dl/b1edeb"],
] as const;

export function canonicalizeOfficialUrl(value: string): string {
  const url = new URL(value);
  url.hash = "";
  url.hostname = url.hostname.toLowerCase();
  if (url.pathname !== "/") url.pathname = url.pathname.replace(/\/+$/, "");
  return url.toString();
}

export const malaysiaMissionInstitutions = ["KBRI Kuala Lumpur", "KJRI Johor Bahru", "KJRI Penang", "KJRI Kota Kinabalu", "KJRI Kuching", "KRI Tawau"] as const;
