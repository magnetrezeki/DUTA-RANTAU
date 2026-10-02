import { NextRequest, NextResponse } from 'next/server';
import { and, eq } from 'drizzle-orm';
import { notifications } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { withUserTransaction } from '@/lib/db/identity-bridge';

export async function POST(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const auth = await authorizeApi(_req);
  if (auth.response) return auth.response;
  const { id } = await params;
  return withUserTransaction(auth.user!, async tx => {
    const [row] = await tx.update(notifications).set({ readAt: new Date() }).where(and(eq(notifications.id, id), eq(notifications.userId, auth.user!.id))).returning({ id: notifications.id, readAt: notifications.readAt });
    if (!row) return NextResponse.json({ error: 'Notifikasi tidak tersedia.' }, { status: 404 });
    return NextResponse.json({ data: row });
  }).catch(() => NextResponse.json({ error: 'Notifikasi belum dapat ditandai.' }, { status: 503 }));
}
