import { afterEach, describe, expect, it, vi } from "vitest";
import { getAIProvider } from "../lib/services/ai-provider";

const originalEnv = { ...process.env };

afterEach(() => {
  process.env = { ...originalEnv };
  vi.unstubAllGlobals();
});

function enableNvidia() {
  process.env.NVIDIA_API_KEY = "test-only-not-a-real-key";
  process.env.NVIDIA_BASE_URL = "https://nvidia.test/v1";
  process.env.NVIDIA_MODEL = "test-model";
}

function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

describe("AI provider foundation", () => {
  it("uses a deterministic safe fallback without an NVIDIA key", async () => {
    delete process.env.NVIDIA_API_KEY;
    const result = await getAIProvider().generate({ message: "hello", channel: "text" });
    expect(result).toMatchObject({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE", latencyMs: 0 });
  });

  it("normalizes a valid NVIDIA response with safe metadata", async () => {
    enableNvidia();
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response({ choices: [{ message: { content: "  Halo!  " } }] })));
    const result = await getAIProvider().generate({ message: "hello", channel: "text" });
    expect(result).toMatchObject({ success: true, provider: "nvidia", model: "test-model", text: "Halo!" });
    expect(JSON.stringify(result)).not.toContain(process.env.NVIDIA_API_KEY);
  });

  it("uses an Indonesian request instruction", async () => {
    enableNvidia();
    const fetchMock = vi.fn().mockResolvedValue(response({ choices: [{ message: { content: "Baik" } }] }));
    vi.stubGlobal("fetch", fetchMock);
    await getAIProvider().generate({ message: "Bagaimana cara mencari pekerjaan?", channel: "text" });
    expect(JSON.parse(fetchMock.mock.calls[0][1].body).messages[0].content).toContain("Bahasa Indonesia");
  });

  it("uses a Bahasa Melayu request instruction", async () => {
    enableNvidia();
    const fetchMock = vi.fn().mockResolvedValue(response({ choices: [{ message: { content: "Baik" } }] }));
    vi.stubGlobal("fetch", fetchMock);
    await getAIProvider().generate({ message: "Bagaimana saya boleh mencari kerja?", channel: "text" });
    expect(JSON.parse(fetchMock.mock.calls[0][1].body).messages[0].content).toContain("Bahasa Melayu");
  });

  it("fails safely for HTTP errors without exposing upstream details", async () => {
    enableNvidia();
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response({ error: { message: "private upstream detail" } }, 500)));
    const result = await getAIProvider().generate({ message: "Halo", channel: "text" });
    expect(result).toMatchObject({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE" });
    expect(JSON.stringify(result)).not.toContain("private upstream detail");
  });

  it("fails safely after a timeout", async () => {
    enableNvidia();
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new DOMException("Aborted", "AbortError")));
    await expect(getAIProvider().generate({ message: "Halo", channel: "text" })).resolves.toMatchObject({ success: false, errorCategory: "TIMEOUT" });
  });

  it("fails safely for malformed or empty output", async () => {
    enableNvidia();
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response({ choices: [{}] })));
    await expect(getAIProvider().generate({ message: "Halo", channel: "text" })).resolves.toMatchObject({ success: false, errorCategory: "INVALID_RESPONSE" });
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response({ choices: [{ message: { content: "   " } }] })));
    await expect(getAIProvider().generate({ message: "Halo", channel: "text" })).resolves.toMatchObject({ success: false, errorCategory: "INVALID_RESPONSE" });
  });

  it("includes latency metadata", async () => {
    enableNvidia();
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(response({ choices: [{ message: { content: "Halo" } }] })));
    expect((await getAIProvider().generate({ message: "Halo", channel: "text" })).latencyMs).toBeGreaterThanOrEqual(0);
  });

  it("does not claim voice processing", async () => {
    enableNvidia();
    const fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
    const result = await getAIProvider().generate({ message: "audio", channel: "voice" });
    expect(result.success).toBe(false);
    expect(result.errorCategory).toBe("UNAVAILABLE");
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
