import { and, desc, eq, gt, isNull, or } from 'drizzle-orm';
import { NextResponse } from 'next/server';
import { externalJobListings } from '@/db/schema';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

export async function GET() {
  try {
    const now = new Date();
    const current = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const data = await withPublicTransaction((tx) => tx.select().from(externalJobListings).where(and(
      eq(externalJobListings.sourceType, 'OFFICIAL'),
      eq(externalJobListings.sourceName, 'SISKOP2MI / KP2MI'),
      eq(externalJobListings.destinationCountry, 'MALAYSIA'),
      eq(externalJobListings.sourceStatus, 'active'),
      gt(externalJobListings.lastCheckedAt, current),
      or(isNull(externalJobListings.expiresAt), gt(externalJobListings.expiresAt, now)),
    )).orderBy(desc(externalJobListings.lastCheckedAt)));
    return NextResponse.json({ data, source: 'SISKOP2MI / KP2MI', application: 'external_official_source' });
  } catch {
    return NextResponse.json({ error: 'Lowongan sumber rasmi belum tersedia.' }, { status: 503 });
  }
}
