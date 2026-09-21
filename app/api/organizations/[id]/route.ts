import { NextRequest, NextResponse } from 'next/server';
import { and, eq, inArray } from 'drizzle-orm';
import { z } from 'zod';
import { entities, organizations } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { withUserTransaction } from '@/lib/db/identity-bridge';

const input = z.object({ name: z.string().min(3).max(160), type: z.string().min(2).max(80), description: z.string().min(10).max(3000), state: z.string().min(2).max(80), city: z.string().min(2).max(80), contact: z.string().min(3).max(200) });

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await authorizeApi(req); if (auth.response) return auth.response;
  const parsed = input.safeParse(await req.json()); if (!parsed.success) return NextResponse.json({ error: 'Data organisasi tidak valid.' }, { status: 400 });
  const { id } = await params;
  return withUserTransaction(auth.user!, async (tx, actor) => {
    const owned = await tx.select({ id: organizations.id }).from(organizations).innerJoin(entities, eq(entities.id, organizations.entityId)).where(and(eq(organizations.id, id), eq(entities.ownerUserId, actor.id), inArray(organizations.recordStatus, ['PENDING', 'REJECTED']))).limit(1);
    if (!owned[0]) return NextResponse.json({ error: 'Organisasi tidak ditemukan atau tidak dapat diedit.' }, { status: 404 });
    const [row] = await tx.update(organizations).set({ ...parsed.data, recordStatus: 'PENDING', verification: 'USER_GENERATED', updatedAt: new Date() }).where(eq(organizations.id, id)).returning();
    return NextResponse.json({ data: row });
  }).catch(() => NextResponse.json({ error: 'Organisasi belum dapat diperbarui.' }, { status: 503 }));
}
