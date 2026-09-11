import { NextResponse } from "next/server";
import { eq } from "drizzle-orm";
import { jobs } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => {
      return await tx.select().from(jobs).where(eq(jobs.recordStatus, "ACTIVE"));
    });

    return NextResponse.json({ data });
  } catch {
    return NextResponse.json(
      { error: "Data lowongan belum tersedia" },
      { status: 503 }
    );
  }
}
