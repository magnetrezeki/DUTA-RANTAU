import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { and, eq } from "drizzle-orm";
import { entities, entityEligibilities, jobs, organizationMembers, organizations } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";
import { evaluateJobPostingPermission } from "@/lib/domain/job-posting-safety";

const input = z.object({
  employerEntityId: z.string().uuid(),
  title: z.string().trim().min(2).max(200),
  description: z.string().trim().min(2).max(10000),
  state: z.string().trim().max(100).optional(),
  city: z.string().trim().max(100).optional(),
  salaryText: z.string().trim().max(200).optional(),
  employmentType: z.string().trim().min(2).max(100),
  requirements: z.string().trim().max(5000).optional(),
  language: z.string().trim().max(50).optional(),
  applicationMethod: z.string().trim().max(500).optional(),
  recordStatus: z.enum(["PENDING","ACTIVE"]).optional()
});

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req);
  if (auth.response) return auth.response;

  try {
    const parsed = input.safeParse(await req.json());

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Data lowongan tidak valid." },
        { status: 400 }
      );
    }

    const data = parsed.data;

    const result = await withUserTransaction(auth.user!, async (tx, actor) => {
      const entity = (await tx.select().from(entities).where(eq(entities.id, data.employerEntityId)).limit(1))[0];
      if (!entity) return null;
      const organizationAuthority = (await tx.select().from(organizationMembers).innerJoin(organizations, eq(organizationMembers.organizationId, organizations.id)).where(and(eq(organizations.entityId, entity.id), eq(organizationMembers.userId, actor.id))).limit(1))[0];
      const actorAuthorized = entity.ownerUserId === actor.id || (organizationAuthority?.organization_members.memberStatus === "ACTIVE" && (organizationAuthority.organization_members.role === "OWNER" || organizationAuthority.organization_members.role === "ADMIN"));
      const employerEligibility = (await tx.select().from(entityEligibilities).where(and(eq(entityEligibilities.entityId, entity.id), eq(entityEligibilities.eligibilityType, "employer"))).limit(1))[0];
      const decision = evaluateJobPostingPermission({ entityType: entity.entityType, entityActive: entity.recordStatus === "ACTIVE", actorAuthorized, employerEligibility: employerEligibility ? { type: "employer", status: employerEligibility.status, expiresAt: employerEligibility.expiresAt } : undefined, postingKind: "direct_employer" });
      if (!decision.allowed) return { denied: true };
      const [row] = await tx.insert(jobs).values({
        ownerId: actor.id,
        employerEntityId: entity.id,
        postingKind: "direct_employer",
        employerEligibilitySnapshot: "approved",
        publishedAt: data.recordStatus === "ACTIVE" ? new Date() : undefined,
        title: data.title,
        employer: entity.displayName,
        description: data.description,
        state: data.state,
        city: data.city,
        salaryText: data.salaryText,
        employmentType: data.employmentType,
        requirements: data.requirements,
        language: data.language,
        applicationMethod: data.applicationMethod,
        recordStatus: data.recordStatus ?? "PENDING"
      }).returning();

      return row;
    });

    if (!result || "denied" in result) return NextResponse.json({ error: "Majikan belum memenuhi syarat penerbitan." }, { status: 403 });
    return NextResponse.json({ data: result }, { status: 201 });
  } catch {
    return NextResponse.json(
      { error: "Data lowongan belum dapat diproses." },
      { status: 503 }
    );
  }
}
