import { NextResponse } from "next/server";
import { products } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

const publicListingFields = {
  id: products.id,
  name: products.name,
  description: products.description,
  category: products.category,
  priceMyr: products.priceMyr,
  images: products.images,
  state: products.state,
  city: products.city,
  publishedAt: products.publishedAt,
};

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => tx.select(publicListingFields).from(products));
    return NextResponse.json({ data });
  } catch {
    return NextResponse.json({ error: "Data marketplace belum tersedia" }, { status: 503 });
  }
}