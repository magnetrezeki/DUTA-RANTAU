import { getOfficialSourcesForInstitution } from "@/lib/services/sources";

import { runDutaTool } from "@/lib/services/duta-tools";
import type { DutaToolItem } from "@/lib/services/duta-tools";
import { officialEmergencyOffices } from "@/lib/official-emergency-data";
import { blockedDutaAiAnswer, routeDutaAiIntent } from '@/lib/domain/duta-ai-policy';

function hasPurpose(contact: { label: string; purpose: string }, pattern: RegExp) {
  return pattern.test(`${contact.label} ${contact.purpose}`);
}

export function formatOfficialAnswer(
  office: (typeof officialEmergencyOffices)[number],
  message: string,
) {
  const protection = office.contacts.find((contact) => hasPurpose(contact, /perlindungan|pengaduan|wni|ksatria/i));
  const main = office.contacts.find((contact) => contact !== protection && hasPurpose(contact, /kantor|umum|informasi|pertanyaan/i));
  const location = `${office.institution} berada di ${office.city}, ${office.region}. Alamat lengkap belum tersedia dalam data DUTA yang telah diverifikasi.`;
  const mainContact = main ? ` Kontak utama: ${main.label}: ${main.number}.` : ' Kontak utama belum tersedia dalam data DUTA yang telah diverifikasi.';
  const protectionContact = protection ? ` Perlindungan WNI: ${protection.label}: ${protection.number}.` : ' Kontak perlindungan WNI belum tersedia dalam data DUTA yang telah diverifikasi.';

  if (/biaya|tarif|fee/.test(message.toLowerCase())) {
    return `Biaya layanan yang terkini belum tersedia dalam data DUTA yang telah diverifikasi. ${location}${mainContact}${protectionContact}`;
  }

  return `${location}${mainContact}${protectionContact}`;
}

export function formatJobAnswer(items: DutaToolItem[]) {
  return items.map((item) => {
    const details = item.details;
    const fields = [
      details?.location ? `Lokasi: ${details.location}.` : undefined,
      details?.salary ? `Gaji: ${details.salary}.` : undefined,
      details?.employmentType ? `Jenis kerja: ${details.employmentType}.` : undefined,
      details?.requirements ? `Syarat: ${details.requirements}.` : undefined,
      details?.applicationMethod ? `Cara melamar: ${details.applicationMethod}.` : undefined,
      `Status sumber: ${item.sourceType} (kepercayaan ${item.trustLevel}).`,
    ].filter(Boolean).join(" ");
    return `${item.title}. ${fields}`;
  }).join(" ");
}

export type Intent =
  | "OFFICIAL_SERVICE"
  | "JOB_SEARCH"
  | "COMMUNITY_SEARCH"
  | "MARKETPLACE_SEARCH"
  | "ORGANIZATION"
  | "SAFETY"
  | "GENERAL";

export function detectIntent(message: string): Intent {
  const q = message.toLowerCase();

  if (/darurat|kekerasan|kecelakaan|hilang|ditipu|bantuan sekarang/.test(q)) {
    return "SAFETY";
  }

  if (/paspor|konsuler|imigrasi|kjri|kbri|kri|dokumen|legalisasi|atase/.test(q)) {
    return "OFFICIAL_SERVICE";
  }

  if (/kerja|lowongan|freelance|part.?time/.test(q)) {
    return "JOB_SEARCH";
  }

  if (/komunitas|kawan|paguyuban|orang indonesia/.test(q)) {
    return "COMMUNITY_SEARCH";
  }

  if (/produk|pasar|beli|penjual|jasa/.test(q)) {
    return "MARKETPLACE_SEARCH";
  }

  if (/organisasi|rapat|anggota|surat undangan|kas/.test(q)) {
    return "ORGANIZATION";
  }

  return "GENERAL";
}

export async function answerQuestion(
  message: string,
  location = "Malaysia",
) {
  const policy = routeDutaAiIntent(message);
  const blocked = blockedDutaAiAnswer(policy.risk);
  if (blocked) return { intent: policy.intent, confidence: 'tinggi', answer: blocked, steps: [], sources: [], disclaimer: 'DUTA AI tidak memberikan nasihat pelaburan.' };
  const intent = detectIntent(message);

  if (intent === "OFFICIAL_SERVICE") {
    const q = message.toLowerCase();

    let institution = "KBRI Kuala Lumpur";

    if (q.includes("johor")) {
      institution = "KJRI Johor Bahru";
    } else if (q.includes("penang")) {
      institution = "KJRI Penang";
    } else if (q.includes("kuching")) {
      institution = "KJRI Kuching";
    } else if (q.includes("kinabalu") || q.includes("sabah")) {
      institution = "KJRI Kota Kinabalu";
    } else if (q.includes("tawau")) {
      institution = "KRI Tawau";
    }

    const sources = await getOfficialSourcesForInstitution(institution).catch(() => []);
    const office = officialEmergencyOffices.find((item) => item.institution === institution);
    const knownFacts = office ? formatOfficialAnswer(office, message) : "";

    return {
      intent,
      confidence: "sedang",
      answer: knownFacts || "Saya belum menemukan informasi resmi terverifikasi untuk pertanyaan ini.",
      steps: [...(office ? ["Jam layanan dan prosedur belum tervalidasi dalam data DUTA."] : []), ...(office ? ["Terakhir diverifikasi: " + office.lastChecked + "."] : []), ...(office ? ["Sumber resmi: " + office.officialUrl] : [])],
      sources,
      disclaimer:
        "DUTA RANTAU bukan institusi pemerintah dan tidak menggantikan keterangan resmi.",
    };
  }

  const responses: Record<
    Exclude<Intent, "OFFICIAL_SERVICE">,
    string
  > = {
    JOB_SEARCH: `Saya dapat membantu mencari lowongan di sekitar ${location}. Semua lowongan demo harus diperiksa langsung; DUTA RANTAU bukan agen pekerjaan.`,
    COMMUNITY_SEARCH:
      "Saya dapat membantu menemukan komunitas berdasarkan lokasi dan minat. Lokasi presisi anggota selalu disembunyikan secara default.",
    MARKETPLACE_SEARCH:
      "Saya dapat membantu menjelajahi produk dan jasa komunitas. Periksa status penjual sebelum bertransaksi.",
    ORGANIZATION:
      "Permintaan ini terkait Kantor Digital. Data organisasi hanya dapat diakses sesuai peran dan izin anggota.",
    SAFETY:
      "Jika Anda dalam bahaya langsung, utamakan keselamatan dan hubungi layanan darurat atau perwakilan resmi yang relevan melalui kanal resminya. DUTA tidak memberikan diagnosis hukum atau medis.",
    GENERAL:
      "Saya belum menemukan informasi yang cukup terpercaya untuk menjawab pertanyaan ini. Coba sebutkan topik dan lokasi dengan lebih spesifik.",
  };

  const fallbackAnswer = responses[intent];
  const toolResult = await runDutaTool(message);


  return {
    intent,
    confidence: intent === "GENERAL" ? "rendah" : "sedang",
    answer: toolResult.status === "SUCCESS" ? intent === "JOB_SEARCH" ? `Saya menemukan ${toolResult.resultCount} lowongan yang sesuai. ${formatJobAnswer(toolResult.items)}` : `Saya menemukan ${toolResult.resultCount} hasil ${toolResult.tool.replaceAll("_", " ")}. ${toolResult.items.map(item => item.title).join("; ")}` : fallbackAnswer,
    steps: [],
    sources: [],

    tool: toolResult.status === "SUCCESS" ? toolResult : undefined,
    disclaimer:
      intent === "SAFETY"
        ? "Panduan ini bukan keputusan medis atau hukum."
        : undefined,
  };
}
