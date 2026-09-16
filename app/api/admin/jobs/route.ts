import { NextResponse } from 'next/server';

// Direct employer submissions remain unavailable while their regulatory
// classification is under review. Public job discovery is provided through
// separate read-only routes.
export async function POST() {
  return NextResponse.json(
    { error: 'Pengajuan lowongan langsung saat ini belum tersedia.' },
    { status: 410 },
  );
}
