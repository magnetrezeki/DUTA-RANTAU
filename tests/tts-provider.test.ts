import { describe, expect, it } from "vitest";
import { getTTSProvider } from "../lib/services/tts-provider";
import { toSpeakableResponse } from "../lib/speakable-response";
describe("TTS foundation", () => {
  it("has a provider-independent safe fallback", async () => await expect(getTTSProvider().synthesize({ text: "Halo", language: "id" })).resolves.toMatchObject({ success: false, provider: "fallback", errorCategory: "UNAVAILABLE" }));
  it("removes long URLs from speakable text", () => expect(toSpeakableResponse("Lihat https://example.com/very/long/path")).not.toContain("https://"));
  it("keeps Indonesian and Malay paths text-safe", () => { expect(toSpeakableResponse("Jawaban ringkas", "id")).toContain("Jawaban"); expect(toSpeakableResponse("Jawapan ringkas", "ms")).toContain("Jawapan"); });
  it("does not alter trust wording", () => expect(toSpeakableResponse("Sumber komuniti belum rasmi.")).toContain("belum rasmi"));
});
