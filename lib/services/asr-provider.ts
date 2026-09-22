import "server-only";

export type ASRErrorCategory = "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE";
export type ASRFailureClass = "AUTHENTICATION_FAILURE" | "PERMISSION_FAILURE" | "REQUEST_FAILURE" | "RATE_LIMIT_FAILURE" | "PROVIDER_FAILURE" | "TIMEOUT_FAILURE" | "NETWORK_FAILURE" | "RESPONSE_FAILURE";
export type ASRDiagnostics = { httpStatus?: number; providerErrorCode?: string; normalizedFailureClass?: ASRFailureClass; requestAttempted: boolean; requestLeftApplication: boolean | null; providerResponded: boolean };
export type ASRResult = { success: boolean; provider: "fallback" | "openai"; transcript?: string; model?: string; language?: string; latencyMs: number; errorCategory?: ASRErrorCategory; diagnostics?: ASRDiagnostics };
export type ASRInput = { audio: File; language?: "id" | "ms" };
export interface ASRProvider { transcribe(input: ASRInput): Promise<ASRResult>; }

export const ASR_TIMEOUT_MS = 15_000;
export const AUTHORIZED_OPENAI_TRANSCRIBE_MODEL = "gpt-4o-mini-transcribe";
const OPENAI_TRANSCRIPTIONS_URL = "https://api.openai.com/v1/audio/transcriptions";
const diagnostics = (values: Partial<ASRDiagnostics> = {}): ASRDiagnostics => ({ requestAttempted: false, requestLeftApplication: false, providerResponded: false, ...values });
const fallback = (errorCategory: ASRErrorCategory, latencyMs = 0, detail = diagnostics()): ASRResult => ({ success: false, provider: "fallback", latencyMs, errorCategory, diagnostics: detail });

function failureClass(status: number): ASRFailureClass {
  if (status === 401) return "AUTHENTICATION_FAILURE";
  if (status === 403) return "PERMISSION_FAILURE";
  if (status === 400 || status === 404 || status === 422) return "REQUEST_FAILURE";
  if (status === 429) return "RATE_LIMIT_FAILURE";
  return "PROVIDER_FAILURE";
}

function safeErrorCode(payload: unknown): string | undefined {
  if (typeof payload !== "object" || payload === null || !("error" in payload) || typeof payload.error !== "object" || payload.error === null || !("code" in payload.error)) return undefined;
  const code = (payload.error as { code?: unknown }).code;
  return typeof code === "string" && /^[A-Za-z0-9_.-]{1,80}$/.test(code) ? code : undefined;
}

function providerFilename(audio: File) {
  const type = audio.type.toLowerCase().split(";", 1)[0];
  const extension: Record<string, string> = { "audio/webm": "webm", "audio/mp4": "mp4", "audio/mpeg": "mp3", "audio/wav": "wav", "audio/ogg": "ogg" };
  return `voice-input.${extension[type] ?? "webm"}`;
}

export function getASRProvider(): ASRProvider {
  const apiKey = process.env.OPENAI_API_KEY;
  const model = process.env.OPENAI_TRANSCRIBE_MODEL;
  if (!apiKey?.trim() || model !== AUTHORIZED_OPENAI_TRANSCRIBE_MODEL) return { transcribe: async () => fallback("UNAVAILABLE") };
  return {
    async transcribe({ audio, language = "id" }) {
      const startedAt = Date.now(); const controller = new AbortController(); const timeout = setTimeout(() => controller.abort(), ASR_TIMEOUT_MS);
      try {
        const form = new FormData(); form.set("file", audio, providerFilename(audio)); form.set("model", model); form.set("language", language);
        const response = await fetch(OPENAI_TRANSCRIPTIONS_URL, { method: "POST", headers: { Authorization: `Bearer ${apiKey}` }, body: form, signal: controller.signal });
        if (!response.ok) {
          let providerErrorCode: string | undefined;
          try { providerErrorCode = safeErrorCode(await response.json()); } catch { /* Raw response is intentionally discarded. */ }
          return fallback("UNAVAILABLE", Date.now() - startedAt, diagnostics({ httpStatus: response.status, providerErrorCode, normalizedFailureClass: failureClass(response.status), requestAttempted: true, requestLeftApplication: true, providerResponded: true }));
        }
        let body: unknown;
        try { body = await response.json(); }
        catch { return fallback("INVALID_RESPONSE", Date.now() - startedAt, diagnostics({ httpStatus: response.status, normalizedFailureClass: "RESPONSE_FAILURE", requestAttempted: true, requestLeftApplication: true, providerResponded: true })); }
        const transcript = typeof body === "object" && body !== null && "text" in body && typeof body.text === "string" ? body.text.trim() : "";
        if (!transcript) return fallback("INVALID_RESPONSE", Date.now() - startedAt, diagnostics({ httpStatus: response.status, normalizedFailureClass: "RESPONSE_FAILURE", requestAttempted: true, requestLeftApplication: true, providerResponded: true }));
        return { success: true, provider: "openai", model, language, transcript, latencyMs: Date.now() - startedAt, diagnostics: diagnostics({ httpStatus: response.status, requestAttempted: true, requestLeftApplication: true, providerResponded: true }) };
      } catch (error) {
        const timedOut = error instanceof DOMException && error.name === "AbortError";
        return fallback(timedOut ? "TIMEOUT" : "UNAVAILABLE", Date.now() - startedAt, diagnostics({ normalizedFailureClass: timedOut ? "TIMEOUT_FAILURE" : "NETWORK_FAILURE", requestAttempted: true, requestLeftApplication: null, providerResponded: false }));
      } finally { clearTimeout(timeout); }
    },
  };
}
