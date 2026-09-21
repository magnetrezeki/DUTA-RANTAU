import { NextRequest, NextResponse } from 'next/server';
import { and, eq, inArray } from 'drizzle-orm';
import { z } from 'zod';
import { jobs } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { withUserTransaction } from '@/lib/db/identity-bridge';

const input = z.object({ title: z.string().min(3).max(160), description: z.string().min(20).max(5000), state: z.string().min(2).max(80), city: z.string().min(2).max(80), salaryText: z.string().max(120).optional(), applicationMethod: z.string().min(3).max(300) });

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await authorizeApi(req); if (auth.response) return auth.response;
  const parsed = input.safeParse(await req.json()); if (!parsed.success) return NextResponse.json({ error: 'Data info kerja tidak valid.' }, { status: 400 });
  const { id } = await params;
  return withUserTransaction(auth.user!, async (tx, actor) => {
    const [row] = await tx.update(jobs).set({ ...parsed.data, recordStatus: 'PENDING', updatedAt: new Date() }).where(and(eq(jobs.id, id), eq(jobs.ownerId, actor.id), inArray(jobs.recordStatus, ['DRAFT', 'PENDING', 'REJECTED']))).returning();
    return row ? NextResponse.json({ data: row }) : NextResponse.json({ error: 'Pengajuan tidak ditemukan atau tidak dapat diedit.' }, { status: 404 });
  }).catch(() => NextResponse.json({ error: 'Pengajuan belum dapat diperbarui.' }, { status: 503 }));
}
