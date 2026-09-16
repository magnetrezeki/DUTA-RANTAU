import { NextResponse } from 'next/server';

// Seller listing creation remains unavailable while marketplace onboarding
// and operator controls are under review.
export async function POST() {
  return NextResponse.json(
    { error: 'Pembuatan listing penjual saat ini belum tersedia.' },
    { status: 410 },
  );
}
