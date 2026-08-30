import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    ok: true,
    message: "Marketplace detail placeholder"
  });
}

export async function PATCH() {
  return NextResponse.json({
    ok: true,
    message: "Marketplace update placeholder"
  });
}

export async function DELETE() {
  return NextResponse.json({
    ok: true,
    message: "Marketplace delete placeholder"
  });
}
