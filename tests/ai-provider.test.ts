import { afterEach, describe, expect, it } from "vitest";
import { getAIProvider } from "../lib/services/ai-provider";

const originalKey = process.env.NVIDIA_API_KEY;
const originalModel = process.env.NVIDIA_MODEL;

afterEach(() => {
  if (originalKey === undefined) delete process.env.NVIDIA_API_KEY;
  else process.env.NVIDIA_API_KEY = originalKey;
  if (originalModel === undefined) delete process.env.NVIDIA_MODEL;
  else process.env.NVIDIA_MODEL = originalModel;
});

describe("AI provider foundation", () => {
  it("uses a deterministic safe fallback without an NVIDIA key", async () => {
    delete process.env.NVIDIA_API_KEY;
    const result = await getAIProvider().generate({ message: "hello", channel: "text" });
    expect(result).toEqual({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE" });
  });

  it("selects NVIDIA server-side and returns only safe metadata", async () => {
    process.env.NVIDIA_API_KEY = "test-only-not-a-real-key";
    process.env.NVIDIA_MODEL = "test-model";
    const result = await getAIProvider().generate({ message: "hello", channel: "text" });
    expect(result).toEqual({ success: false, provider: "nvidia", model: "test-model", errorCategory: "UNAVAILABLE" });
    expect(JSON.stringify(result)).not.toContain(process.env.NVIDIA_API_KEY);
  });

  it("does not claim voice processing", async () => {
    delete process.env.NVIDIA_API_KEY;
    const result = await getAIProvider().generate({ message: "audio", channel: "voice" });
    expect(result.success).toBe(false);
    expect(result.errorCategory).toBe("UNAVAILABLE");
  });
});
