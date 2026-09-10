import "server-only";

export type ASRErrorCategory = "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE";
export type ASRResult = { success: boolean; provider: "fallback" | "nvidia"; transcript?: string; model?: string; language?: string; latencyMs: number; errorCategory?: ASRErrorCategory };
export type ASRInput = { audio: File; language?: "id" | "ms" };
export interface ASRProvider { transcribe(input: ASRInput): Promise<ASRResult>; }

const TIMEOUT_MS = 15_000;
const fallback = (errorCategory: ASRErrorCategory, latencyMs = 0): ASRResult => ({ success: false, provider: "fallback", latencyMs, errorCategory });

export function getASRProvider(): ASRProvider {
  const apiKey = process.env.NVIDIA_API_KEY;
  const model = process.env.NVIDIA_ASR_MODEL;
  if (!apiKey || !model) return { transcribe: async () => fallback("UNAVAILABLE") };
  const baseUrl = (process.env.NVIDIA_ASR_BASE_URL || "https://integrate.api.nvidia.com/v1").replace(/\/$/, "");
  return {
    async transcribe({ audio, language = "id" }) {
      const startedAt = Date.now(); const controller = new AbortController(); const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);
      try {
        const form = new FormData(); form.set("file", audio, "voice-input"); form.set("model", model); form.set("language", language);
        const response = await fetch(`${baseUrl}/audio/transcriptions`, { method: "POST", headers: { Authorization: `Bearer ${apiKey}` }, body: form, signal: controller.signal });
        if (!response.ok) return fallback("UNAVAILABLE", Date.now() - startedAt);
        const body: unknown = await response.json();
        const transcript = typeof body === "object" && body !== null && "text" in body && typeof body.text === "string" ? body.text.trim() : "";
        if (!transcript) return fallback("INVALID_RESPONSE", Date.now() - startedAt);
        return { success: true, provider: "nvidia", model, language, transcript, latencyMs: Date.now() - startedAt };
      } catch (error) { return fallback(error instanceof DOMException && error.name === "AbortError" ? "TIMEOUT" : "UNAVAILABLE", Date.now() - startedAt); }
      finally { clearTimeout(timeout); }
    },
  };
}
