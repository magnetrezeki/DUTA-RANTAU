import { describe, expect, it } from "vitest";
import { POST } from "../app/api/ai/transcribe/route";

const request = (audio?: File) => { const form = new FormData(); if (audio) form.set("audio", audio); return new Request("http://localhost/api/ai/transcribe", { method: "POST", body: form }); };

describe("voice transcription API", () => {
  it("rejects a non-multipart request", async () => expect((await POST(new Request("http://localhost/api/ai/transcribe", { method: "POST" }) as never)).status).toBe(415));
  it("rejects empty audio", async () => expect((await POST(request(new File([], "empty.webm", { type: "audio/webm" })) as never)).status).toBe(400));
  it("rejects unsupported audio types", async () => expect((await POST(request(new File(["x"], "bad.txt", { type: "text/plain" })) as never)).status).toBe(415));
  it("accepts the browser WebM MIME parameter instead of rejecting it as unsupported", async () => expect((await POST(request(new File(["voice"], "voice.webm", { type: "audio/webm;codecs=opus" })) as never)).status).toBe(503));
  it("rejects oversized audio", async () => expect((await POST(request(new File([new Uint8Array(10 * 1024 * 1024 + 1)], "large.webm", { type: "audio/webm" })) as never)).status).toBe(413));
  it("keeps the valid path safe when ASR is unavailable", async () => { const response = await POST(request(new File(["voice"], "voice.webm", { type: "audio/webm" })) as never); expect(response.status).toBe(503); await expect(response.json()).resolves.toMatchObject({ errorCategory: "UNAVAILABLE" }); });
});
