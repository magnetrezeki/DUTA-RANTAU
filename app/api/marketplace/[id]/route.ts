import { NextRequest, NextResponse } from 'next/server';
import { and, eq, inArray } from 'drizzle-orm';
import { z } from 'zod';
import { products, sellers } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { withUserTransaction } from '@/lib/db/identity-bridge';

const input = z.object({ name: z.string().min(2).max(160), description: z.string().min(10).max(4000), category: z.enum(['ordinary_goods', 'food_and_beverage']), priceMyr: z.number().nonnegative().max(999999).optional(), state: z.string().min(2).max(80), city: z.string().min(2).max(80), contact: z.string().min(3).max(200) });

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await authorizeApi(req); if (auth.response) return auth.response;
  const parsed = input.safeParse(await req.json()); if (!parsed.success) return NextResponse.json({ error: 'Data produk tidak valid.' }, { status: 400 });
  const { id } = await params;
  return withUserTransaction(auth.user!, async (tx, actor) => {
    const owned = await tx.select({ id: products.id }).from(products).innerJoin(sellers, eq(sellers.id, products.sellerId)).where(and(eq(products.id, id), eq(sellers.userId, actor.id), inArray(products.recordStatus, ['DRAFT', 'PENDING', 'REJECTED']))).limit(1);
    if (!owned[0]) return NextResponse.json({ error: 'Listing tidak ditemukan atau tidak dapat diedit.' }, { status: 404 });
    const { contact, priceMyr, ...values } = parsed.data;
    const [row] = await tx.update(products).set({ ...values, description: `${values.description}\n\nKontak/handoff: ${contact}`, priceMyr: priceMyr?.toFixed(2), recordStatus: 'PENDING', updatedAt: new Date() }).where(eq(products.id, id)).returning();
    return NextResponse.json({ data: row });
  }).catch(() => NextResponse.json({ error: 'Listing belum dapat diperbarui.' }, { status: 503 }));
}
