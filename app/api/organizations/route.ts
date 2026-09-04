import { NextResponse } from "next/server";
import { organizations } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => {
      return await tx.select().from(organizations);
    });

    return NextResponse.json({ data });
  } catch {
    return NextResponse.json(
      { error: "Data organisasi belum tersedia" },
      { status: 503 }
    );
  }
}
