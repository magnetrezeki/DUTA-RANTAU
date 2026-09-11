import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { answerQuestion } from '@/lib/services/ai-router';
import { rateLimit } from '@/lib/rate-limit';
import { consumeDutaAiQuota } from '@/lib/services/duta-ai-fair-use';
import { isDutaAiEnabled } from '@/lib/domain/duta-ai-policy';
import { authorizeApi } from '@/lib/auth/api-guard';
import { aiEnabled } from '@/lib/domain/ai-routing';
const input=z.object({message:z.string().trim().min(2).max(1000),location:z.string().max(100).optional(),channel:z.enum(['text','voice']).optional()});
export async function POST(req:NextRequest){
 const auth=await authorizeApi(req);if(auth.response)return auth.response;
 const ip=req.headers.get('x-forwarded-for')?.split(',')[0]??'local';
 if(!isDutaAiEnabled()||!aiEnabled())return NextResponse.json({error:'DUTA AI belum diaktifkan.',code:'AI_DISABLED'},{status:503});
 if(!rateLimit(`ai:${ip}`,15).ok)return NextResponse.json({error:'Terlalu banyak permintaan. Coba lagi sebentar.',code:'RATE_LIMITED'},{status:429});
 const quota=consumeDutaAiQuota(auth.user!.id);if(!quota.allowed)return NextResponse.json({error:'Kuota penggunaan wajar DUTA AI telah dicapai. Sila cuba semula selepas tetapan semula.',code:'QUOTA_EXCEEDED',quota},{status:429});
 try{const body=input.parse(await req.json());if(body.channel==='voice')return NextResponse.json({error:'Input suara belum tersedia.'},{status:422});return NextResponse.json({...await answerQuestion(body.message,body.location),quota});}
 catch(error){return NextResponse.json({error:error instanceof z.ZodError?'Pertanyaan tidak valid.':'DUTA belum dapat memeriksa sumber saat ini. Silakan coba lagi atau gunakan pertanyaan lain.'},{status:error instanceof z.ZodError?400:503});}
}
