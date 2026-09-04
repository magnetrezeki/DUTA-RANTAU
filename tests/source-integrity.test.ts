import { describe, expect, it } from "vitest";
import { getSources, type OfficialSource } from "../lib/services/sources";

describe("source integrity", () => {
  it("returns an array of active official sources", async () => {
    const sources: OfficialSource[] = await getSources();

    expect(Array.isArray(sources)).toBe(true);
  });

  it("uses HTTPS URLs", async () => {
    const sources: OfficialSource[] = await getSources();

    expect(
      sources.every((x: OfficialSource) =>
        x.url.startsWith("https://"),
      ),
    ).toBe(true);
  });

  it("contains required source integrity fields", async () => {
    const sources: OfficialSource[] = await getSources();

    expect(
      sources.every(
        (x: OfficialSource) =>
          Boolean(x.institution) &&
          Boolean(x.channel) &&
          Boolean(x.category) &&
          Boolean(x.priority) &&
          Boolean(x.lastChecked),
      ),
    ).toBe(true);
  });

  it("uses the expected official trust level", async () => {
    const sources: OfficialSource[] = await getSources();

    expect(
      sources.every(
        (x: OfficialSource) =>
          x.trustLevel === "OFFICIAL_VERIFIED",
      ),
    ).toBe(true);
  });

  it("does not expose invented operational fields", async () => {
    const sources: OfficialSource[] = await getSources();

    expect(
      sources.every(
        (x: OfficialSource) =>
          !("status" in x) &&
          !("openingHours" in x) &&
          !("fees" in x) &&
          !("requirements" in x),
      ),
    ).toBe(true);
  });
});
