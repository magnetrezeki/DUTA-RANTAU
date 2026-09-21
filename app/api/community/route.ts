import { NextRequest, NextResponse } from "next/server";
import { eq } from 'drizzle-orm';
import { z } from 'zod';
import { auditLogs, communities, communityMembers, notifications } from "@/db/schema";
import { withPublicTransaction, withUserTransaction } from "@/lib/db/identity-bridge";
import { authorizeApi } from '@/lib/auth/api-guard';
const input=z.object({name:z.string().trim().min(3).max(160),description:z.string().trim().min(20).max(5000),category:z.string().trim().min(2).max(80),state:z.string().trim().max(100).optional(),city:z.string().trim().max(100).optional(),visibility:z.enum(['PUBLIC','PRIVATE']).default('PUBLIC')});

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => {
      return await tx.select().from(communities).where(eq(communities.recordStatus,'ACTIVE'));
    });

    return NextResponse.json({ data });
  } catch {
    return NextResponse.json(
      { error: "Data komunitas belum tersedia" },
      { status: 503 }
    );
  }
}

export async function POST(req:NextRequest){const auth=await authorizeApi(req);if(auth.response)return auth.response;const parsed=input.safeParse(await req.json());if(!parsed.success)return NextResponse.json({error:'Data komuniti tidak valid.'},{status:400});return withUserTransaction(auth.user!,async(tx,actor)=>{const [row]=await tx.insert(communities).values({...parsed.data,ownerId:actor.id,trustLevel:'USER_GENERATED',recordStatus:'PENDING',communityAccessScope:'pre_arrival_allowed'}).returning();await tx.insert(communityMembers).values({communityId:row.id,userId:actor.id,role:'OWNER'});await tx.insert(notifications).values({userId:actor.id,type:'COMMUNITY_SUBMITTED',priority:'NORMAL',title:'Komuniti dikirim untuk moderasi',body:`${row.name} belum dipublikasikan sebelum disetujui.`});await tx.insert(auditLogs).values({actorId:actor.id,action:'community.submitted',entityType:'community',entityId:row.id,metadata:{status:'PENDING'}});return NextResponse.json({data:row},{status:201})}).catch(()=>NextResponse.json({error:'Komuniti belum dapat disimpan.'},{status:503}))}
