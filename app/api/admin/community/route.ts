import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { communities } from "@/db/schema";
import { authorizeApi, authorizePlatformApi } from "@/lib/auth/api-guard";
import { withUserTransaction } from "@/lib/db/identity-bridge";
import { eq } from 'drizzle-orm';

const input = z.object({
  name: z.string().trim().min(2).max(200),
  description: z.string().trim().max(10000).optional(),
  category: z.string().trim().min(2).max(100),
  state: z.string().trim().max(100).optional(),
  city: z.string().trim().max(100).optional(),
  visibility: z.string().trim().max(50).optional(),
  trustLevel: z.enum([
    "OFFICIAL_VERIFIED",
    "INSTITUTION_VERIFIED",
    "DUTA_VERIFIED",
    "COMMUNITY_VERIFIED",
    "USER_GENERATED"
  ]).optional(),
  recordStatus: z.enum(["PENDING","ACTIVE","SUSPENDED","ARCHIVED"]).optional()
});

export async function POST(req: NextRequest) {
  const auth = await authorizeApi(req, "EDITOR");
  if (auth.response) return auth.response;

  try {
    const parsed = input.safeParse(await req.json());

    if (!parsed.success) {
      return NextResponse.json(
        { error: "Data komunitas tidak valid." },
        { status: 400 }
      );
    }

    const data = parsed.data;

    const result = await withUserTransaction(auth.user!, async (tx, actor) => {
      const [row] = await tx.insert(communities).values({
        ownerId: actor.id,
        name: data.name,
        description: data.description,
        category: data.category,
        state: data.state,
        city: data.city,
        visibility: data.visibility ?? "PUBLIC",
        trustLevel: data.trustLevel ?? "USER_GENERATED",
        recordStatus: data.recordStatus ?? "PENDING"
      }).returning();

      return row;
    });

    return NextResponse.json({ data: result }, { status: 201 });
  } catch {
    return NextResponse.json(
      { error: "Data komunitas belum dapat diproses." },
      { status: 503 }
    );
  }
}

const decisionInput=z.object({id:z.string().uuid(),decision:z.enum(['APPROVE','REJECT','ARCHIVE'])});
export async function PATCH(req:NextRequest){const auth=await authorizePlatformApi(req,'moderation.manage');if(auth.response)return auth.response;const parsed=decisionInput.safeParse(await req.json());if(!parsed.success)return NextResponse.json({error:'Keputusan tidak valid.'},{status:400});return withUserTransaction(auth.user!,async tx=>{const status=parsed.data.decision==='APPROVE'?'ACTIVE':parsed.data.decision==='REJECT'?'REJECTED':'ARCHIVED';const [row]=await tx.update(communities).set({recordStatus:status}).where(eq(communities.id,parsed.data.id)).returning();return row?NextResponse.json({data:row}):NextResponse.json({error:'Komuniti tidak ditemukan.'},{status:404})})}
