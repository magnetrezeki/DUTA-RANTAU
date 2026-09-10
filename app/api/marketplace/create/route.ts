import { NextResponse } from "next/server";

// Listing creation is intentionally unavailable here. The authenticated server
// boundary is /api/admin/marketplace, which performs entity and eligibility checks.
export async function POST() {
  return NextResponse.json(
    { error: "Gunakan alur penjual yang sah untuk membuat listing." },
    { status: 410 },
  );
}