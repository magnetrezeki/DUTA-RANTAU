import { describe, expect, it } from "vitest";
import { POST } from "../app/api/ai/speak/route";
const request = (body: unknown) => new Request("http://localhost/api/ai/speak", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
describe("TTS API", () => {
  it("rejects empty text", async () => expect((await POST(request({ text: "" }) as never)).status).toBe(400));
  it("rejects oversized text", async () => expect((await POST(request({ text: "x".repeat(501) }) as never)).status).toBe(400));
  it("returns a controlled unavailable result without provider details", async () => { const response = await POST(request({ text: "Halo", language: "id" }) as never); expect(response.status).toBe(503); await expect(response.json()).resolves.toMatchObject({ errorCategory: "UNAVAILABLE" }); });
});
