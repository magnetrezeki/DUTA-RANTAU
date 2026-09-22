import { afterEach, describe, expect, it, vi } from "vitest";
import { ASR_TIMEOUT_MS, AUTHORIZED_OPENAI_TRANSCRIBE_MODEL, getASRProvider } from "../lib/services/asr-provider";

const originalEnv = { ...process.env };
const audio = (type = "audio/webm") => new File(["audio"], "founder-recording-name.webm", { type });
afterEach(() => { process.env = { ...originalEnv }; vi.unstubAllGlobals(); });
function enable() { process.env.OPENAI_API_KEY = "test-only-not-a-real-key"; process.env.OPENAI_TRANSCRIBE_MODEL = AUTHORIZED_OPENAI_TRANSCRIBE_MODEL; process.env.OPENAI_MODEL = "independent-text-model"; }
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

describe("OpenAI ASR provider", () => {
  it("fails closed without the exact independent transcription configuration", async () => {
    delete process.env.OPENAI_API_KEY; delete process.env.OPENAI_TRANSCRIBE_MODEL; process.env.OPENAI_MODEL = AUTHORIZED_OPENAI_TRANSCRIBE_MODEL;
    const fetchMock = vi.fn(); vi.stubGlobal("fetch", fetchMock);
    await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE" });
    process.env.OPENAI_API_KEY = "test"; process.env.OPENAI_TRANSCRIBE_MODEL = "whisper-1";
    await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ success: false, errorCategory: "UNAVAILABLE" });
    expect(fetchMock).not.toHaveBeenCalled();
  });
  it.each(["id", "ms"] as const)("uses one server-authenticated multipart request for language=%s", async language => {
    enable(); let captured: { url: string; init: RequestInit } | undefined;
    const fetchMock = vi.fn(async (url: string, init: RequestInit) => { captured = { url, init }; return json({ text: "  Halo DUTA  " }); }); vi.stubGlobal("fetch", fetchMock);
    await expect(getASRProvider().transcribe({ audio: audio(), language })).resolves.toMatchObject({ success: true, provider: "openai", model: AUTHORIZED_OPENAI_TRANSCRIBE_MODEL, language, transcript: "Halo DUTA" });
    expect(fetchMock).toHaveBeenCalledTimes(1); expect(captured?.url).toBe("https://api.openai.com/v1/audio/transcriptions"); expect(captured?.init.method).toBe("POST"); expect(captured?.init.headers).toEqual({ Authorization: "Bearer test-only-not-a-real-key" }); expect(captured?.init.signal).toBeInstanceOf(AbortSignal);
    const form = captured?.init.body as FormData; expect(form.get("model")).toBe(AUTHORIZED_OPENAI_TRANSCRIBE_MODEL); expect(form.get("language")).toBe(language); const file = form.get("file") as File; expect(file).toBeInstanceOf(File); expect(file.type).toBe("audio/webm"); expect(file.name).toBe("voice-input.webm");
  });
  it("preserves the 15 second timeout contract", () => expect(ASR_TIMEOUT_MS).toBe(15_000));
  it("preserves safe HTTP diagnostics without raw response, credentials, or input names", async () => {
    enable(); vi.stubGlobal("fetch", vi.fn(async () => json({ error: { code: "invalid_api_key", message: "PRIVATE_PROVIDER_MESSAGE" }, secret: "test-only-not-a-real-key" }, 401)));
    const result = await getASRProvider().transcribe({ audio: audio() }); const serialized = JSON.stringify(result);
    expect(result).toMatchObject({ success: false, errorCategory: "UNAVAILABLE", diagnostics: { httpStatus: 401, providerErrorCode: "invalid_api_key", normalizedFailureClass: "AUTHENTICATION_FAILURE", requestAttempted: true, providerResponded: true } });
    expect(serialized).not.toContain("PRIVATE_PROVIDER_MESSAGE"); expect(serialized).not.toContain("test-only-not-a-real-key"); expect(serialized).not.toContain("founder-recording-name");
  });
  it("handles timeout, malformed JSON, and empty transcripts safely", async () => {
    enable(); vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError"))); await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ errorCategory: "TIMEOUT", diagnostics: { normalizedFailureClass: "TIMEOUT_FAILURE" } });
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(new Response("not-json", { status: 200 }))); await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ errorCategory: "INVALID_RESPONSE", diagnostics: { normalizedFailureClass: "RESPONSE_FAILURE" } });
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(json({ text: "  " }))); await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ errorCategory: "INVALID_RESPONSE" });
  });
});
