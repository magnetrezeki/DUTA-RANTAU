import { describe, expect, it } from "vitest";
import { adapterFor, ingestOfficialStories, type OfficialStoryCandidate } from "../lib/services/info-rantau-ingestion";
import { malaysiaOfficialSources } from "../lib/official-source-registry";

const at = "2026-09-23T08:00:00Z";
const story = (sourceId: string, overrides: Partial<OfficialStoryCandidate> = {}): OfficialStoryCandidate => ({ sourceId, externalId: sourceId, title: "Pelayanan paspor keliling dibuka", body: "Pelayanan paspor keliling dibuka untuk masyarakat pada hari Sabtu.", publishedAt: "2026-09-23T01:00:00Z", ...overrides });

describe("Info Rantau deterministic ingestion foundation", () => {
  it("merges one cross-platform story into one card with four references", () => {
    const result = ingestOfficialStories([], [story("MISSION_01_WEBSITE", { canonicalUrl: "https://kemlu.go.id/kualalumpur/berita/paspor-keliling" }), story("MISSION_01_INSTAGRAM"), story("MISSION_01_FACEBOOK"), story("MISSION_01_X")], at);
    expect(result).toHaveLength(1); expect(result[0].sourceReferences).toHaveLength(4); expect(result[0].canonicalSourceId).toBe("MISSION_01_WEBSITE");
  });

  it("does not merge two distinct same-day stories", () => {
    const result = ingestOfficialStories([], [story("MISSION_01_INSTAGRAM"), story("MISSION_01_FACEBOOK", { title: "Peringatan cuaca untuk warga", body: "Peringatan hujan lebat bagi warga di wilayah lain.", externalId: "weather" })], at);
    expect(result).toHaveLength(2);
  });

  it("upgrades a social-first canonical story when a richer Kemlu publication arrives", () => {
    const first = ingestOfficialStories([], [story("MISSION_01_INSTAGRAM")], "2026-09-23T02:00:00Z");
    const merged = ingestOfficialStories(first, [story("MISSION_01_WEBSITE", { canonicalUrl: "https://kemlu.go.id/kualalumpur/berita/paspor-keliling", body: "Pelayanan paspor keliling dibuka untuk masyarakat pada hari Sabtu. Informasi lengkap tersedia di situs resmi." })], "2026-09-23T03:00:00Z");
    expect(merged).toHaveLength(1); expect(merged[0].canonicalSourceId).toBe("MISSION_01_WEBSITE"); expect(merged[0].firstSeenAt).toBe("2026-09-23T02:00:00Z"); expect(merged[0].sourceReferences).toHaveLength(2);
  });

  it("protects against similar cross-institution false positives", () => {
    const result = ingestOfficialStories([], [story("MISSION_01_INSTAGRAM"), story("MISSION_03_INSTAGRAM", { externalId: "penang", body: "Pelayanan paspor keliling dibuka di Penang untuk jadwal yang berbeda." })], at);
    expect(result).toHaveLength(2);
  });

  it("is idempotent for the same canonical source item", () => {
    const candidate = story("MISSION_01_WEBSITE", { canonicalUrl: "https://kemlu.go.id/kualalumpur/berita/paspor-keliling" });
    const result = ingestOfficialStories(ingestOfficialStories([], [candidate], at), [candidate], at);
    expect(result).toHaveLength(1); expect(result[0].sourceReferences).toHaveLength(1);
  });

  it("exposes controlled unavailable adapters instead of fake collection", async () => {
    const adapters = malaysiaOfficialSources.map(adapterFor);
    expect(adapters.every(adapter => !adapter.available && adapter.dependency.length > 0)).toBe(true);
    await expect(adapters[0].collect()).resolves.toEqual([]);
  });
});
