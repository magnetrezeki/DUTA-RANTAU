import { beforeEach, describe, expect, it, vi } from "vitest";
import { readFileSync } from "node:fs";

const state = vi.hoisted(() => ({ authenticated: true }));
vi.mock('@/lib/auth/api-guard', () => ({ authorizeApi: async () => state.authenticated
  ? { user: { id: '00000000-0000-4000-8000-000000000001' }, response: null }
  : { user: null, response: new Response(JSON.stringify({ error: 'auth' }), { status: 401 }) } }));

const { POST } = await import("../app/api/ai/transcribe/route");

const request = (audio?: File) => { const form = new FormData(); if (audio) form.set("audio", audio); return new Request("http://localhost/api/ai/transcribe", { method: "POST", body: form }); };

describe("voice transcription API", () => {
  beforeEach(() => { state.authenticated = true; });
  it("requires an authenticated member before audio reaches the provider", async () => { state.authenticated = false; const response = await POST(request(new File(["voice"], "voice.webm", { type: "audio/webm" })) as never); expect(response.status).toBe(401); await expect(response.json()).resolves.toMatchObject({ code: 'AUTH_REQUIRED' }); });
  it("rejects a non-multipart request", async () => expect((await POST(new Request("http://localhost/api/ai/transcribe", { method: "POST" }) as never)).status).toBe(415));
  it("rejects empty audio", async () => expect((await POST(request(new File([], "empty.webm", { type: "audio/webm" })) as never)).status).toBe(400));
  it("rejects unsupported audio types", async () => expect((await POST(request(new File(["x"], "bad.txt", { type: "text/plain" })) as never)).status).toBe(415));
  it.each(["audio/webm;codecs=opus", "audio/mp4", "audio/mpeg", "audio/wav", "audio/ogg"])("accepts supported browser audio type %s", async type => expect((await POST(request(new File(["voice"], "voice-input", { type })) as never)).status).toBe(503));
  it("rejects oversized audio", async () => expect((await POST(request(new File([new Uint8Array(10 * 1024 * 1024 + 1)], "large.webm", { type: "audio/webm" })) as never)).status).toBe(413));
  it("keeps the valid path safe when ASR is unavailable", async () => { const response = await POST(request(new File(["voice"], "voice.webm", { type: "audio/webm" })) as never); expect(response.status).toBe(503); await expect(response.json()).resolves.toMatchObject({ code: "TRANSCRIPTION_PROVIDER_UNAVAILABLE", errorCategory: "UNAVAILABLE" }); });
  it("keeps audio transient without filesystem persistence", () => { const source = readFileSync("lib/services/asr-provider.ts", "utf8"); expect(source).not.toMatch(/writeFile|createWriteStream|appendFile/); });
});
