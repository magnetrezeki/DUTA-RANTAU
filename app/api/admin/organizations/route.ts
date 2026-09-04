import { NextRequest, NextResponse } from "next/server";
import { desc, eq } from "drizzle-orm";
import { z } from "zod";

import { auditLogs, organizations } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";

const createInput = z.object({
  name: z.string().min(3).max(160),
  type: z.string().min(2).max(100),
  description: z.string().max(5000).optional(),
  state: z.string().max(120).optional(),
  city: z.string().max(120).optional(),
  logoUrl: z.string().url().max(1000).optional(),
  contact: z.string().max(500).optional(),
});

const updateInput = createInput.partial().extend({
  organizationId: z.string().uuid(),
  verification: z.enum([
    "USER_GENERATED",
    "OFFICIAL_VERIFIED",
    "INSTITUTION_VERIFIED",
    "DUTA_VERIFIED",
    "COMMUNITY_VERIFIED",
  ]).optional(),
  recordStatus: z.enum([
    "DRAFT",
    "PENDING",
    "ACTIVE",
    "SUSPENDED",
    "ARCHIVED",
  ]).optional(),
});

export async function GET(req: NextRequest) {
  const auth = await authorizeApi(req, "SUPER_ADMIN");
  if (auth.response) return auth.response;

  return withUserTransaction(auth.user!, async (tx) => {
    const rows = await tx
      .select()
      .from(organizations)
      .orderBy(desc(organizations.updatedAt));

    return NextResponse.json({ organizations: rows });
  });
}

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req, "SUPER_ADMIN");
  if (auth.response) return auth.response;

  const body = createInput.parse(await req.json());

  return withUserTransaction(auth.user!, async (tx, actor) => {
    const [organization] = await tx
      .insert(organizations)
      .values({
        ...body,
        verification: "USER_GENERATED",
        recordStatus: "PENDING",
      })
      .returning();

    await tx.insert(auditLogs).values({
      actorId: actor.id,
      organizationId: organization.id,
      action: "content_admin_create",
      entityType: "organization",
      entityId: organization.id,
      metadata: {
        status: organization.recordStatus,
        verification: organization.verification,
      },
    });

    return NextResponse.json({ organization }, { status: 201 });
  });
}

export async function PATCH(req: NextRequest) {
  const auth = await authorizeApi(req, "SUPER_ADMIN");
  if (auth.response) return auth.response;

  const body = updateInput.parse(await req.json());
  const { organizationId, ...changes } = body;

  return withUserTransaction(auth.user!, async (tx, actor) => {
    const existing = await tx
      .select()
      .from(organizations)
      .where(eq(organizations.id, organizationId))
      .limit(1);

    if (!existing[0]) {
      return NextResponse.json(
        { error: "Organisasi tidak ditemukan." },
        { status: 404 },
      );
    }

    if (
      changes.recordStatus === "ACTIVE" &&
      changes.verification !== "DUTA_VERIFIED" &&
      existing[0].verification !== "DUTA_VERIFIED"
    ) {
      return NextResponse.json(
        { error: "Organisasi harus DUTA_VERIFIED sebelum diaktifkan." },
        { status: 400 },
      );
    }

    const [organization] = await tx
      .update(organizations)
      .set(changes)
      .where(eq(organizations.id, organizationId))
      .returning();

    await tx.insert(auditLogs).values({
      actorId: actor.id,
      organizationId,
      action:
        changes.recordStatus === "ARCHIVED"
          ? "content_admin_archive"
          : "content_admin_update",
      entityType: "organization",
      entityId: organizationId,
      metadata: changes,
    });

    return NextResponse.json({ organization });
  });
}

export async function DELETE(req: NextRequest) {
  const auth = await authorizeApi(req, "SUPER_ADMIN");
  if (auth.response) return auth.response;

  const organizationId = new URL(req.url).searchParams.get("organizationId");

  if (!organizationId || !z.string().uuid().safeParse(organizationId).success) {
    return NextResponse.json(
      { error: "organizationId tidak valid." },
      { status: 400 },
    );
  }

  return withUserTransaction(auth.user!, async (tx, actor) => {
    const [organization] = await tx
      .update(organizations)
      .set({ recordStatus: 'ARCHIVED' })
      .where(eq(organizations.id, organizationId))
      .returning();

    if (!organization) {
      return NextResponse.json(
        { error: "Organisasi tidak ditemukan." },
        { status: 404 },
      );
    }

    await tx.insert(auditLogs).values({
      actorId: actor.id,
      organizationId,
      action: "content_admin_archive",
      entityType: "organization",
      entityId: organizationId,
      metadata: {
        previousStatus: "ACTIVE",
        newStatus: "ARCHIVED",
      },
    });

    return NextResponse.json({ organization });
  });
}
