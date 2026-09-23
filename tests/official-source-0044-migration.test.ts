import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const migration = readFileSync("db/migrations/0044_malaysia_official_source_registry.sql", "utf8");

describe("0044 governed source population", () => {
  it("is forward-only, transactional, idempotent, and non-destructive", () => {
    expect(migration.trimStart()).toMatch(/^--[^\n]*\n/); expect(migration).toContain("BEGIN;"); expect(migration.trimEnd()).toMatch(/COMMIT;$/);
    expect(migration).toContain("ON CONFLICT (url) DO UPDATE"); expect(migration).not.toMatch(/\b(TRUNCATE|DROP TABLE|DELETE FROM)\b/i);
  });

  it("does not manufacture governance approval or reviewer evidence", () => {
    expect(migration).toContain("official_source_governance (source_id)");
    expect(migration).not.toMatch(/production_approved\s*=\s*true/i); expect(migration).not.toMatch(/official_source_verified\s*=\s*true/i); expect(migration).not.toMatch(/verified_by\s*=/i);
  });

  it.each(["KBRI Kuala Lumpur", "KJRI Johor Bahru", "KJRI Penang", "KJRI Kuching", "KJRI Kota Kinabalu", "KRI Tawau"])("provides a P0 consular website for %s", institution => {
    expect(migration).toContain(`('${institution}','WEBSITE'`); expect(migration).toContain("'P0','CONSULAR_SERVICE'::public.source_purpose");
  });

  it("does not register appointment endpoints as news", () => {
    for (const value of ["antrean.kbrikl.id", "daftaronline.indonesiainjb.my", "layananonline.kjripenang.my", "imigrasi.synergize.co", "teman-baik.kjrikk.com", "temujanjiantrianpelayanankritawau.org"]) expect(migration).not.toContain(value);
  });

  it("keeps DUTA retrieval purpose-bound", () => {
    const sourceService = readFileSync("lib/services/sources.ts", "utf8");
    expect(sourceService).toContain('eq(officialSources.sourcePurpose, "CONSULAR_SERVICE")');
  });
});
