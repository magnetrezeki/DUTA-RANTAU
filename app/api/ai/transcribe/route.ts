import { NextRequest, NextResponse } from "next/server";
import { getASRProvider } from "@/lib/services/asr-provider";

const acceptedTypes = new Set(["audio/webm", "audio/mp4", "audio/mpeg", "audio/wav", "audio/ogg"]);
const maxBytes = 10 * 1024 * 1024;

export async function POST(request: NextRequest) {
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("multipart/form-data")) return NextResponse.json({ error: "Audio harus dikirim sebagai formulir." }, { status: 415 });
  try {
    const form = await request.formData(); const audio = form.get("audio"); const language = form.get("language");
    if (!(audio instanceof File) || audio.size === 0) return NextResponse.json({ error: "Rekaman audio kosong atau tidak valid." }, { status: 400 });
    if (!acceptedTypes.has(audio.type)) return NextResponse.json({ error: "Format audio belum didukung." }, { status: 415 });
    if (audio.size > maxBytes) return NextResponse.json({ error: "Ukuran audio melebihi 10 MB." }, { status: 413 });
    const result = await getASRProvider().transcribe({ audio, language: language === "ms" ? "ms" : "id" });
    if (!result.success) return NextResponse.json({ error: "Transkripsi belum tersedia. Silakan ketik pertanyaan Anda.", errorCategory: result.errorCategory }, { status: 503 });
    return NextResponse.json({ transcript: result.transcript, provider: result.provider, model: result.model, language: result.language, latencyMs: result.latencyMs });
  } catch { return NextResponse.json({ error: "Rekaman audio tidak dapat diproses." }, { status: 400 }); }
}
