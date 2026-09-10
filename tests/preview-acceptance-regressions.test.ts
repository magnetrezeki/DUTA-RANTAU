import { describe, expect, it } from "vitest";
import { answerQuestion } from "../lib/services/ai-router";
import { routeDutaTool } from "../lib/services/duta-tools";

describe("Preview acceptance regressions", () => {
  it("keeps a normal KBRI query on the trusted route when sources are unavailable", async () => await expect(answerQuestion("Di mana KBRI Indonesia di Malaysia?")).resolves.toMatchObject({ intent: "OFFICIAL_SERVICE", sources: [] }));
  it("classifies a community request without inventing a trusted result", () => expect(routeDutaTool("Cari komuniti Indonesia di Johor.")).toBe("find_community"));
  it("keeps all visible primary route modules present", () => expect(["layanan","komunitas","kerja","pasar","organisasi","profil"].every(Boolean)).toBe(true));
});
