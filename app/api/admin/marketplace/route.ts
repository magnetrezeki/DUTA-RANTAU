import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { products } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";

const input = z.object({
  sellerId: z.string().uuid(),
  name: z.string().trim().min(2).max(200),
  description: z.string().trim().min(2).max(10000),
  category: z.string().trim().min(2).max(100),
  priceMyr: z.string().trim().max(50).optional(),
  images: z.array(z.string().url()).max(10).optional(),
  state: z.string().trim().max(100).optional(),
  city: z.string().trim().max(100).optional(),
  recordStatus: z.enum(["PENDING","ACTIVE","SUSPENDED","ARCHIVED"]).optional()
});

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req, "EDITOR");
  if (auth.response) return auth.response;

  try {
    const parsed = input.safeParse(await req.json());

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Data marketplace tidak valid." },
        { status: 400 }
      );
    }

    const data = parsed.data;

    const result = await withUserTransaction(auth.user!, async (tx) => {
      const [row] = await tx.insert(products).values({
        sellerId: data.sellerId,
        name: data.name,
        description: data.description,
        category: data.category,
        priceMyr: data.priceMyr,
        images: data.images ?? [],
        state: data.state,
        city: data.city,
        recordStatus: data.recordStatus ?? "PENDING"
      }).returning();

      return row;
    });

    return NextResponse.json({ data: result }, { status: 201 });
  } catch {
    return NextResponse.json(
      { error: "Data marketplace belum dapat diproses." },
      { status: 503 }
    );
  }
}
