import "server-only";
import { desc, eq } from "drizzle-orm";
import { communities, jobs, organizations } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";
import { getSources } from "@/lib/services/sources";
import { officialEmergencyOffices } from "@/lib/official-emergency-data";

export type TrustLevel = "A" | "B" | "C" | "D" | "E" | "UNKNOWN";
export type DutaToolName = "search_official_information" | "find_consulate" | "search_jobs" | "find_community" | "find_organisation" | "search_duta_map" | "search_news";
export type DutaToolItem = { title: string; reference?: string; sourceType: string; trustLevel: TrustLevel; lastVerifiedAt?: string; details?: { employer?: string; location?: string; salary?: string; employmentType?: string; requirements?: string; applicationMethod?: string } };
export type DutaToolResult = { tool: DutaToolName; status: "SUCCESS" | "EMPTY" | "UNAVAILABLE"; items: DutaToolItem[]; resultCount: number; errorCategory?: "UNAVAILABLE" | "EMPTY" };
const trust = (value: string): TrustLevel => ({ OFFICIAL_VERIFIED: "A", INSTITUTION_VERIFIED: "B", DUTA_VERIFIED: "C", COMMUNITY_VERIFIED: "D", USER_GENERATED: "UNKNOWN" }[value] as TrustLevel ?? "UNKNOWN");
const unavailable = (tool: DutaToolName): DutaToolResult => ({ tool, status: "UNAVAILABLE", items: [], resultCount: 0, errorCategory: "UNAVAILABLE" });
const matches = (text: string, query: string) => text.toLowerCase().includes(query.toLowerCase());

export function routeDutaTool(message: string): DutaToolName | undefined {
  const q = message.toLowerCase();
  if (/berita|news|info rantau/.test(q)) return "search_news";
  if (/peta|map|dekat|terdekat|alamat|lokasi/.test(q)) return /kbri|kjri|kri|konsulat/.test(q) ? "find_consulate" : "search_duta_map";
  if (/kbri|kjri|kri|konsulat|paspor|kekonsuleran|imigrasi/.test(q)) return "find_consulate";
  if (/kerja|lowongan|jawatan|operator|kilang/.test(q)) return "search_jobs";
  if (/komunitas|komuniti|paguyuban/.test(q)) return "find_community";
  if (/organisasi|pertubuhan/.test(q)) return "find_organisation";
  if (/resmi|rasmi|kemlu|layanan pemerintah/.test(q)) return "search_official_information";
  return undefined;
}

export async function runDutaTool(message: string): Promise<DutaToolResult> {
  const tool = routeDutaTool(message); if (!tool) return unavailable("search_official_information");
  try {
    if (tool === "search_duta_map" || tool === "search_news") return unavailable(tool);
    if (tool === "find_consulate") { const items = officialEmergencyOffices.filter(x => matches(`${x.institution} ${x.city} ${x.region}`, message) || /kbri|kjri|kri|konsulat|terdekat|dekat/.test(message.toLowerCase())).map(x => ({ title: `${x.institution} — ${x.city}`, reference: x.officialUrl, sourceType: "Official Government", trustLevel: "A" as const, lastVerifiedAt: x.lastChecked })); return { tool, status: items.length ? "SUCCESS" : "EMPTY", items, resultCount: items.length, ...(items.length ? {} : { errorCategory: "EMPTY" as const }) }; }
    if (tool === "search_official_information") { const rows = (await getSources()).filter(x => matches(`${x.institution} ${x.category} ${x.channel}`, message)).slice(0, 5); const items = rows.map(x => ({ title: x.institution, reference: x.url, sourceType: "Official Government", trustLevel: trust(x.trustLevel), lastVerifiedAt: x.lastChecked.toISOString().slice(0, 10) })); return { tool, status: items.length ? "SUCCESS" : "EMPTY", items, resultCount: items.length, ...(items.length ? {} : { errorCategory: "EMPTY" as const }) }; }
    if (tool === "search_jobs") { const rows = await withPublicTransaction(tx => tx.select().from(jobs).where(eq(jobs.recordStatus, "ACTIVE")).orderBy(desc(jobs.createdAt)).limit(5)) as Array<typeof jobs.$inferSelect>; const items = rows.filter(x => matches(`${x.title} ${x.employer} ${x.city ?? ""} ${x.state ?? ""}`, message) || /kerja|lowongan|jawatan|operator|kilang/.test(message.toLowerCase())).map(x => ({ title: `${x.title} — ${x.employer}`, sourceType: "DUTA listing", trustLevel: trust(x.trustLevel), details: { employer: x.employer, location: [x.city, x.state].filter(Boolean).join(", ") || undefined, salary: x.salaryText ?? undefined, employmentType: x.employmentType, requirements: x.requirements ?? undefined, applicationMethod: x.applicationMethod ?? undefined } })); return { tool, status: items.length ? "SUCCESS" : "EMPTY", items, resultCount: items.length, ...(items.length ? {} : { errorCategory: "EMPTY" as const }) }; }
    if (tool === "find_community") { const rows = await withPublicTransaction(tx => tx.select().from(communities).where(eq(communities.recordStatus, "ACTIVE")).limit(5)) as Array<typeof communities.$inferSelect>; const items = rows.map(x => ({ title: x.name, sourceType: "Community", trustLevel: trust(x.trustLevel) })); return { tool, status: items.length ? "SUCCESS" : "EMPTY", items, resultCount: items.length, ...(items.length ? {} : { errorCategory: "EMPTY" as const }) }; }
    const rows = await withPublicTransaction(tx => tx.select().from(organizations).where(eq(organizations.recordStatus, "ACTIVE")).limit(5)) as Array<typeof organizations.$inferSelect>; const items = rows.map(x => ({ title: x.name, sourceType: "Organisation", trustLevel: trust(x.verification) })); return { tool, status: items.length ? "SUCCESS" : "EMPTY", items, resultCount: items.length, ...(items.length ? {} : { errorCategory: "EMPTY" as const }) };
  } catch { return unavailable(tool); }
}
