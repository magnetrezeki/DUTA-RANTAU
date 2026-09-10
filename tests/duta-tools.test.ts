import { describe, expect, it } from "vitest";
import { routeDutaTool, runDutaTool } from "../lib/services/duta-tools";

describe("DUTA read-only tool routing", () => {
  it("routes official information", () => expect(routeDutaTool("layanan resmi Kemlu")).toBe("search_official_information"));
  it("routes consulates", () => expect(routeDutaTool("Di mana KJRI terdekat?")).toBe("find_consulate"));
  it("routes jobs", () => expect(routeDutaTool("Ada kerja operator kilang?")).toBe("search_jobs"));
  it("routes communities", () => expect(routeDutaTool("Cari komuniti Indonesia")).toBe("find_community"));
  it("routes organisations", () => expect(routeDutaTool("organisasi di Johor")).toBe("find_organisation"));
  it("routes maps and news to their controlled registry entries", () => { expect(routeDutaTool("peta tempat dekat saya")).toBe("search_duta_map"); expect(routeDutaTool("berita terbaru KBRI")).toBe("search_news"); });
  it("preserves official provenance without trust upgrades", async () => { const result = await runDutaTool("KJRI terdekat"); expect(result).toMatchObject({ tool: "find_consulate", status: "SUCCESS" }); expect(result.items[0]).toMatchObject({ sourceType: "Official Government", trustLevel: "A" }); });
  it("handles unavailable, empty, and unknown paths safely", async () => { await expect(runDutaTool("peta dekat saya")).resolves.toMatchObject({ status: "UNAVAILABLE" }); await expect(runDutaTool("kalimat yang tidak dikenal")).resolves.toMatchObject({ status: "UNAVAILABLE" }); });
});
