import { NextRequest, NextResponse } from "next/server";
import { and, eq } from "drizzle-orm";
import { z } from "zod";
import { entities, entityEligibilities, organizationMembers, products, sellers } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";
import { evaluateMarketplaceListingPermission } from "@/lib/domain/marketplace-compliance";

const input = z.object({
  sellerId: z.string().uuid(),
  name: z.string().trim().min(2).max(200),
  description: z.string().trim().min(2).max(10000),
  category: z.string().trim().min(2).max(100),
  priceMyr: z.string().trim().max(50).optional(),
  images: z.array(z.string().url()).max(10).optional(),
  state: z.string().trim().max(100).optional(),
  city: z.string().trim().max(100).optional(),
  recordStatus: z.enum(["DRAFT", "PENDING", "ACTIVE", "SUSPENDED", "ARCHIVED"]).optional(),
});

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req, "USER");
  if (auth.response) return auth.response;

  try {
    const parsed = input.safeParse(await req.json());
    if (!parsed.success) return NextResponse.json({ error: "Data marketplace tidak valid." }, { status: 400 });
    const data = parsed.data;

    const result = await withUserTransaction(auth.user!, async (tx, actor) => {
      const seller = (await tx.select().from(sellers).where(eq(sellers.id, data.sellerId)).limit(1))[0];
      if (!seller?.entityId) return null;
      const entity = (await tx.select().from(entities).where(eq(entities.id, seller.entityId)).limit(1))[0];
      if (!entity) return null;
      const organizationAuthority = seller.organizationId
        ? (await tx.select().from(organizationMembers).where(and(eq(organizationMembers.organizationId, seller.organizationId), eq(organizationMembers.userId, actor.id))).limit(1))[0]
        : undefined;
      const actorAuthorized = entity.ownerUserId === actor.id || (organizationAuthority?.memberStatus === "ACTIVE" && (organizationAuthority.role === "OWNER" || organizationAuthority.role === "ADMIN"));
      const commercialEligibility = (await tx.select().from(entityEligibilities).where(and(eq(entityEligibilities.entityId, entity.id), eq(entityEligibilities.eligibilityType, "commercial"))).limit(1))[0];
      const decision = evaluateMarketplaceListingPermission({
        entityType: entity.entityType,
        entityActive: entity.recordStatus === "ACTIVE",
        actorAuthorized,
        commercialEligibility: commercialEligibility ? { type: "commercial", status: commercialEligibility.status, expiresAt: commercialEligibility.expiresAt } : undefined,
        category: data.category,
      });
      if (!decision.allowed) return { denied: true };
      const [row] = await tx.insert(products).values({
        sellerId: seller.id,
        sellerEntityId: entity.id,
        name: data.name,
        description: data.description,
        category: data.category,
        riskTier: decision.riskTier,
        commercialEligibilitySnapshot: "approved",
        complianceReviewStatus: decision.riskTier === "GREEN" ? "not_required" : "pending",
        priceMyr: data.priceMyr,
        images: data.images ?? [],
        state: data.state,
        city: data.city,
        recordStatus: data.recordStatus ?? "PENDING",
        publishedAt: data.recordStatus === "ACTIVE" ? new Date() : undefined,
      }).returning();
      return { row };
    });

    if (!result || "denied" in result) return NextResponse.json({ error: "Listing belum memenuhi syarat penerbitan." }, { status: 403 });
    return NextResponse.json({ data: result.row }, { status: 201 });
  } catch {
    return NextResponse.json({ error: "Data marketplace belum dapat diproses." }, { status: 503 });
  }
}