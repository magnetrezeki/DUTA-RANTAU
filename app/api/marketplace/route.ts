import { NextResponse } from "next/server";
import { products } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => {
      return await tx.select().from(products);
    });

    return NextResponse.json({ data });
  } catch {
    return NextResponse.json(
      { error: "Data marketplace belum tersedia" },
      { status: 503 }
    );
  }
}
