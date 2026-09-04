import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { jobs } from "@/db/schema";
import { authorizeApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";

const input = z.object({
  id: z.string().uuid().optional(),
  title: z.string().trim().min(2).max(200),
  employer: z.string().trim().min(2).max(200),
  description: z.string().trim().min(2).max(10000),
  state: z.string().trim().max(100).optional(),
  city: z.string().trim().max(100).optional(),
  salaryText: z.string().trim().max(200).optional(),
  employmentType: z.string().trim().min(2).max(100),
  requirements: z.string().trim().max(5000).optional(),
  language: z.string().trim().max(50).optional(),
  applicationMethod: z.string().trim().max(500).optional(),
  recordStatus: z.enum(["PENDING","ACTIVE","SUSPENDED","ARCHIVED"]).optional()
});

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req, "EDITOR");
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
      const [row] = await tx.insert(jobs).values({
        ownerId: actor.id,
        title: data.title,
        employer: data.employer,
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

    return NextResponse.json({ data: result }, { status: 201 });
  } catch {
    return NextResponse.json(
      { error: "Data lowongan belum dapat diproses." },
      { status: 503 }
    );
  }
}
