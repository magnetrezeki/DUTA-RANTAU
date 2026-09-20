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

    expect(infoPage).toContain('Belum ada artikel terverifikasi untuk diterbitkan.');
    expect(infoPage).toContain('tidak membuat suapan berita atau rekomendasi tanpa provenance');
    const tourismPage = readFileSync(resolve('app/info/tempat-wisata/page.tsx'), 'utf8');
    expect(tourismPage).toContain('Belum ada tempat wisata terverifikasi.');
    expect(tourismPage).toContain('Tidak ada rekomendasi dianggap official, fresh, atau verified');
  });
});
