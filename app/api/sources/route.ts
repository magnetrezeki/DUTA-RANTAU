import { NextResponse } from "next/server";
import { eq } from "drizzle-orm";
import { officialSources } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) =>
      tx
        .select()
        .from(officialSources)
        .where(eq(officialSources.active, true))
        .orderBy(officialSources.lastChecked),
    );

    return NextResponse.json({
      data,
      meta: {
        count: data.length,
      },
    });
  } catch {
    return NextResponse.json(
      { error: "Data sumber belum tersedia" },
      { status: 503 },
    );
  }
}
