import "server-only";

import { and, desc, eq } from "drizzle-orm";
import { officialSources } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export type OfficialSource = typeof officialSources.$inferSelect;

export type OfficialSourceView = Omit<OfficialSource, "lastChecked"> & {
  lastChecked: string;
};

function toOfficialSourceView(row: OfficialSource): OfficialSourceView {
  return {
    ...row,
    lastChecked: row.lastChecked.toISOString().slice(0, 10),
  };
}

export async function getSources(): Promise<OfficialSource[]> {
  return withPublicTransaction(async (tx) => {
    const rows = await tx
      .select()
      .from(officialSources)
      .where(eq(officialSources.active, true))
      .orderBy(desc(officialSources.lastChecked));

    return rows as OfficialSource[];
  });
}

export async function getOfficialSourcesForInstitution(
  institution: string,
): Promise<OfficialSourceView[]> {
  return withPublicTransaction(async (tx) => {
    const rows = await tx
      .select()
      .from(officialSources)
      .where(
        and(
          eq(officialSources.institution, institution),
          eq(officialSources.priority, "P0"),
          eq(officialSources.active, true),
        ),
      )
      .orderBy(desc(officialSources.lastChecked))
      .limit(2);

    return rows.map(toOfficialSourceView);
  });
}
