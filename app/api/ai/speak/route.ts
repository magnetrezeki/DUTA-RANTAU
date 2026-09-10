import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { getTTSProvider } from "@/lib/services/tts-provider";

const input = z.object({ text: z.string().trim().min(1).max(500), language: z.enum(["id", "ms"]).optional() });
export async function POST(request: NextRequest) {
  try {
    const body = input.parse(await request.json());
    const result = await getTTSProvider().synthesize({ text: body.text, language: body.language ?? "id" });
    return NextResponse.json({ error: "Suara server belum tersedia. Anda masih dapat membaca jawaban di layar.", errorCategory: result.errorCategory }, { status: 503 });
  } catch { return NextResponse.json({ error: "Teks untuk dibacakan tidak valid." }, { status: 400 }); }
}
