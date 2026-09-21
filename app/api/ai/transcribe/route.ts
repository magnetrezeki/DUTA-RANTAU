import { NextRequest, NextResponse } from "next/server";
import { getASRProvider } from "@/lib/services/asr-provider";
import { authorizeApi } from "@/lib/auth/api-guard";

const acceptedTypes = new Set(["audio/webm", "audio/mp4", "audio/mpeg", "audio/wav", "audio/ogg"]);
const maxBytes = 10 * 1024 * 1024;

export async function POST(request: NextRequest) {
  const auth = await authorizeApi(request);
  if (auth.response) {
    if (auth.response.status === 401) return NextResponse.json({ error: "Silakan masuk untuk melanjutkan.", code: "AUTH_REQUIRED" }, { status: 401 });
    return auth.response;
  }
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("multipart/form-data")) return NextResponse.json({ error: "Audio harus dikirim sebagai formulir." }, { status: 415 });
  try {
    const form = await request.formData(); const audio = form.get("audio"); const language = form.get("language");
    if (!(audio instanceof File) || audio.size === 0) return NextResponse.json({ error: "Rekaman audio kosong atau tidak valid." }, { status: 400 });
    const mimeType = audio.type.toLowerCase().split(";", 1)[0];
    if (!acceptedTypes.has(mimeType)) return NextResponse.json({ error: "Format audio belum didukung." }, { status: 415 });
    if (audio.size > maxBytes) return NextResponse.json({ error: "Ukuran audio melebihi 10 MB." }, { status: 413 });
    const result = await getASRProvider().transcribe({ audio, language: language === "ms" ? "ms" : "id" });
    if (!result.success) return NextResponse.json({ error: "Transkripsi belum tersedia. Silakan ketik pertanyaan Anda.", code: "TRANSCRIPTION_PROVIDER_UNAVAILABLE", errorCategory: result.errorCategory }, { status: 503 });
    return NextResponse.json({ transcript: result.transcript, provider: result.provider, model: result.model, language: result.language, latencyMs: result.latencyMs });
  } catch { return NextResponse.json({ error: "Rekaman audio tidak dapat diproses." }, { status: 400 }); }
}
