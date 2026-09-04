import "server-only";

import { eq } from "drizzle-orm";
import { organizations } from "@/db/schema";
import { withPublicTransaction } from "@/lib/db/identity-bridge";

export async function getOrganizations() {
  return withPublicTransaction(async (tx) => {
    return tx
      .select()
      .from(organizations)
      .where(eq(organizations.recordStatus, "ACTIVE"));
  });
}

export async function getOrganization(id: string) {
  return withPublicTransaction(async (tx) => {
    const rows = await tx
      .select()
      .from(organizations)
      .where(eq(organizations.id, id))
      .limit(1);

    return rows[0] ?? null;
  });
}
