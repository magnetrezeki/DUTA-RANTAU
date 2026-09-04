import { officialSources as officialSourcesTable } from "../db/schema";
import { appDb } from "../db/client";
import { eq } from "drizzle-orm";

type SeedSource = {
  institution: string;
  channel: string;
  url: string;
  category: string;
  priority: string;
  trustLevel: "OFFICIAL_VERIFIED";
  lastChecked: Date;
  checksum?: string;
  active: boolean;
};

const officialSources: SeedSource[] = [];

async function main() {
  if (!appDb) {
    throw new Error("APP_DATABASE_URL is not configured");
  }

  if (officialSources.length === 0) {
    console.log(
      "No static official-source dataset is configured. Database seed skipped safely.",
    );
    return;
  }

  for (const source of officialSources) {
    const existing = await appDb
      .select({ id: officialSourcesTable.id })
      .from(officialSourcesTable)
      .where(eq(officialSourcesTable.url, source.url))
      .limit(1);

    if (existing.length > 0) {
      continue;
    }

    await appDb.insert(officialSourcesTable).values(source);
  }

  console.log(`Seeded ${officialSources.length} official sources.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
