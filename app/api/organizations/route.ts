import { NextRequest, NextResponse } from "next/server";
import { z } from 'zod';
import { auditLogs, entities, entityResponsiblePersons, notifications, organizationMembers, organizations } from "@/db/schema";
import { withPublicTransaction, withUserTransaction } from "@/lib/db/identity-bridge";
import { authorizeApi } from '@/lib/auth/api-guard';
const input=z.object({name:z.string().trim().min(3).max(160),type:z.string().trim().min(2).max(100),description:z.string().trim().min(20).max(5000),state:z.string().trim().max(100).optional(),city:z.string().trim().max(100).optional(),contact:z.string().trim().min(5).max(300)});

export async function GET() {
  try {
    const data = await withPublicTransaction(async (tx) => {
      return await tx.select().from(organizations);
    });

    return NextResponse.json({ data });
  } catch {
    return NextResponse.json(
      { error: "Data organisasi belum tersedia" },
      { status: 503 }
    );
  }
}

export async function POST(req:NextRequest){const auth=await authorizeApi(req);if(auth.response)return auth.response;const parsed=input.safeParse(await req.json());if(!parsed.success)return NextResponse.json({error:'Data organisasi tidak valid.'},{status:400});return withUserTransaction(auth.user!,async(tx,actor)=>{const slug=`${parsed.data.name.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'')}-${crypto.randomUUID().slice(0,8)}`;const [entity]=await tx.insert(entities).values({entityType:'organisation',displayName:parsed.data.name,slug,ownerUserId:actor.id,recordStatus:'PENDING',legalStatus:'unknown'}).returning();const [row]=await tx.insert(organizations).values({...parsed.data,entityId:entity.id,verification:'USER_GENERATED',recordStatus:'PENDING'}).returning();await tx.insert(organizationMembers).values({organizationId:row.id,userId:actor.id,role:'OWNER'});await tx.insert(entityResponsiblePersons).values({entityId:entity.id,userId:actor.id,role:'OWNER_REPRESENTATIVE',status:'active',isPrimary:true,appointedAt:new Date()});await tx.insert(notifications).values({userId:actor.id,type:'ORGANIZATION_SUBMITTED',priority:'NORMAL',title:'Profil organisasi dikirim untuk moderasi',body:`${row.name} belum terverifikasi atau dipublikasikan.`});await tx.insert(auditLogs).values({actorId:actor.id,organizationId:row.id,action:'organization.create',entityType:'organization',entityId:row.id,metadata:{status:'PENDING',verification:'USER_GENERATED'}});return NextResponse.json({data:row},{status:201})}).catch(()=>NextResponse.json({error:'Organisasi belum dapat disimpan.'},{status:503}))}
