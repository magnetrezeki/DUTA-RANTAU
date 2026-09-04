import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { eq } from "drizzle-orm";
import { officialSources } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";

const input = z.object({
  active: z.boolean().optional(),
  priority: z.string().trim().min(1).max(20).optional(),
  trustLevel: z.string().trim().min(1).max(50).optional(),
});

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const auth = await authorizeApi(req, "EDITOR");

  if (auth.response) {
    return auth.response;
  }

  const { id } = await params;

  if (!z.string().uuid().safeParse(id).success) {
    return NextResponse.json(
      { error: "ID sumber tidak valid." },
      { status: 400 },
    );
  }

  try {
    const parsed = input.safeParse(await req.json());

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Data sumber tidak valid." },
        { status: 400 },
      );
    }

    const result = await withUserTransaction(auth.user!, async (tx) => {
      const [row] = await tx
        .update(officialSources)
        .set(parsed.data)
        .where(eq(officialSources.id, id))
        .returning();

      return row ?? null;
    });

    if (!result) {
      return NextResponse.json(
        { error: "Sumber tidak ditemukan." },
        { status: 404 },
      );
    }

    return NextResponse.json({ data: result });
  } catch {
    return NextResponse.json(
      { error: "Sumber belum dapat diperbarui." },
      { status: 503 },
    );
  }
}
