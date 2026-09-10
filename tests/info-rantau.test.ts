import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

describe("Info Rantau categories", () => {
  it("routes Tempat Wisata to the established Info Rantau route", () => {
    const infoPage = readFileSync(resolve("app/info/page.tsx"), "utf8");

    expect(infoPage).toContain('href="/info/tempat-wisata"');
    expect(existsSync(resolve("app/info/tempat-wisata/page.tsx"))).toBe(true);
  });

  it("keeps unavailable categories controlled until verified content exists", () => {
    const infoPage = readFileSync(resolve("app/info/page.tsx"), "utf8");

    expect(infoPage).toContain('disabled aria-label={`${label}: belum tersedia`}');
  });
});
