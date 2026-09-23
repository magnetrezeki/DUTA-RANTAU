import { describe, expect, it } from "vitest";
import { canonicalizeOfficialUrl, malaysiaAppointmentEndpoints, malaysiaMissionInstitutions, malaysiaOfficialSources } from "../lib/official-source-registry";

describe("Malaysia official-source registry", () => {
  it("represents all 27 approved sources without loss or canonical URL collision", () => {
    expect(malaysiaOfficialSources).toHaveLength(27);
    expect(new Set(malaysiaOfficialSources.map(source => source.id)).size).toBe(27);
    expect(new Set(malaysiaOfficialSources.map(source => canonicalizeOfficialUrl(source.url))).size).toBe(27);
    expect(malaysiaOfficialSources.every(source => source.infoRantauEligible)).toBe(true);
  });

  it("covers six missions and five Kuala Lumpur functions", () => {
    const institutions = new Set(malaysiaOfficialSources.map(source => source.institution));
    malaysiaMissionInstitutions.forEach(institution => expect(institutions.has(institution)).toBe(true));
    expect(new Set(malaysiaOfficialSources.filter(source => source.domain !== "MISSION").map(source => source.domain))).toEqual(new Set(["TENAGA_KERJA", "HUKUM", "PENDIDIKAN_KEBUDAYAAN", "PERHUBUNGAN", "PERDAGANGAN"]));
  });

  it("keeps news eligibility separate from universal consular authority", () => {
    expect(malaysiaOfficialSources.filter(source => source.primaryPurpose === "CONSULAR_SERVICE")).toHaveLength(6);
    expect(malaysiaOfficialSources.filter(source => source.primaryPurpose === "CONSULAR_SERVICE").every(source => source.channel === "WEBSITE")).toBe(true);
    expect(malaysiaOfficialSources.filter(source => source.channel !== "WEBSITE").every(source => source.primaryPurpose === "NEWS")).toBe(true);
  });

  it("keeps appointment endpoints outside the Info Rantau registry", () => {
    const sourceUrls = new Set(malaysiaOfficialSources.map(source => canonicalizeOfficialUrl(source.url)));
    expect(malaysiaAppointmentEndpoints).toHaveLength(6);
    malaysiaAppointmentEndpoints.forEach(([, url]) => expect(sourceUrls.has(canonicalizeOfficialUrl(url))).toBe(false));
  });
});
