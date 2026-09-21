import { NextRequest, NextResponse } from 'next/server';
import { and, eq, inArray } from 'drizzle-orm';
import { z } from 'zod';
import { communities } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { withUserTransaction } from '@/lib/db/identity-bridge';

const input = z.object({ name: z.string().min(3).max(160), description: z.string().min(10).max(3000), category: z.string().min(2).max(80), state: z.string().min(2).max(80), city: z.string().min(2).max(80) });

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await authorizeApi(req); if (auth.response) return auth.response;
  const parsed = input.safeParse(await req.json()); if (!parsed.success) return NextResponse.json({ error: 'Data komuniti tidak valid.' }, { status: 400 });
  const { id } = await params;
  return withUserTransaction(auth.user!, async (tx, actor) => {
    const [row] = await tx.update(communities).set({ ...parsed.data, recordStatus: 'PENDING', updatedAt: new Date() }).where(and(eq(communities.id, id), eq(communities.ownerId, actor.id), inArray(communities.recordStatus, ['PENDING', 'REJECTED']))).returning();
    return row ? NextResponse.json({ data: row }) : NextResponse.json({ error: 'Komuniti tidak ditemukan atau tidak dapat diedit.' }, { status: 404 });
  }).catch(() => NextResponse.json({ error: 'Komuniti belum dapat diperbarui.' }, { status: 503 }));
}
