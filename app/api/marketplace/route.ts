import { NextResponse } from 'next/server';

// Public marketplace discovery is withheld until P0 marketplace controls
// have been implemented and validated.
export async function GET() {
  return NextResponse.json(
    { error: 'Data marketplace belum tersedia. Pasar Rantau sedang dipersiapkan.' },
    { status: 503 },
  );
}
