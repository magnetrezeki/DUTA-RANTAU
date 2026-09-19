import { NextResponse } from "next/server";

const unavailable = () => NextResponse.json(
  {
    error: "Detail Pasar Rantau belum tersedia untuk beta publik.",
    code: "MARKETPLACE_DETAIL_UNAVAILABLE",
  },
  { status: 503, headers: { "Cache-Control": "no-store" } },
);

// No endpoint may report successful Marketplace actions until the approved
// discovery/evaluate/connect data contract and authorization boundary exist.
export async function GET() { return unavailable(); }
export async function PATCH() { return unavailable(); }
export async function DELETE() { return unavailable(); }
