import { afterEach, describe, expect, it, vi } from "vitest";
import { getASRProvider } from "../lib/services/asr-provider";

const originalEnv = { ...process.env };
const audio = () => new File(["audio"], "voice.webm", { type: "audio/webm" });
afterEach(() => { process.env = { ...originalEnv }; vi.unstubAllGlobals(); });
function enable() { process.env.NVIDIA_API_KEY = "test-only-not-a-real-key"; process.env.NVIDIA_ASR_MODEL = "test-asr"; process.env.NVIDIA_ASR_BASE_URL = "https://asr.test/v1"; }
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

describe("ASR provider", () => {
  it("uses a safe fallback without configuration", async () => { delete process.env.NVIDIA_API_KEY; await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE" }); });
  it("normalizes transcript metadata", async () => { enable(); vi.stubGlobal("fetch", vi.fn().mockResolvedValue(json({ text: "  Halo DUTA  " }))); await expect(getASRProvider().transcribe({ audio: audio(), language: "id" })).resolves.toMatchObject({ success: true, provider: "nvidia", model: "test-asr", language: "id", transcript: "Halo DUTA" }); });
  it("supports Bahasa Melayu request metadata", async () => { enable(); const fetchMock = vi.fn().mockResolvedValue(json({ text: "Apa khabar" })); vi.stubGlobal("fetch", fetchMock); await getASRProvider().transcribe({ audio: audio(), language: "ms" }); expect(fetchMock.mock.calls[0][1].body.get("language")).toBe("ms"); });
  it("does not expose raw provider errors", async () => { enable(); vi.stubGlobal("fetch", vi.fn().mockResolvedValue(json({ error: "private provider detail" }, 500))); const result = await getASRProvider().transcribe({ audio: audio() }); expect(JSON.stringify(result)).not.toContain("private provider detail"); });
  it("handles timeout and malformed output safely", async () => { enable(); vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError"))); await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ errorCategory: "TIMEOUT" }); vi.stubGlobal("fetch", vi.fn().mockResolvedValue(json({ unexpected: true }))); await expect(getASRProvider().transcribe({ audio: audio() })).resolves.toMatchObject({ errorCategory: "INVALID_RESPONSE" }); });
});
