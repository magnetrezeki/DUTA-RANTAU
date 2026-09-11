import { NextRequest, NextResponse } from 'next/server';
import type { AIProviderResult } from '@/lib/services/ai-provider';
import { z } from 'zod';
import { answerQuestion } from '@/lib/services/ai-router';
import { rateLimit } from '@/lib/rate-limit';
import { consumePersistentAiQuota } from '@/lib/services/ai-quota-repository';
import { executePlannedProvider } from '@/lib/services/ai-provider-execution';
import { isDutaAiEnabled } from '@/lib/domain/duta-ai-policy';
import { authorizeApi } from '@/lib/auth/api-guard';
import { aiEnabled } from '@/lib/domain/ai-routing';
import { planAiExecution } from '@/lib/services/ai-execution-plan';
import { runAuthorizedGeneration } from '@/lib/services/authorized-ai-generation';
const input=z.object({message:z.string().trim().min(2).max(1000),location:z.string().max(100).optional(),channel:z.enum(['text','voice']).optional()});
export async function POST(req:NextRequest){
 const auth=await authorizeApi(req);if(auth.response)return auth.response;
 if(!isDutaAiEnabled()||!aiEnabled())return NextResponse.json({error:'DUTA AI belum diaktifkan.',code:'AI_DISABLED'},{status:503});
 try{const body=input.parse(await req.json());if(body.channel==='voice')return NextResponse.json({error:'Input suara belum tersedia.'},{status:422});const ip=req.headers.get('x-forwarded-for')?.split(',')[0]??'local';if(!rateLimit(`ai:${ip}`,15).ok)return NextResponse.json({error:'Terlalu banyak permintaan. Coba lagi sebentar.',code:'RATE_LIMITED'},{status:429});const plan=planAiExecution(body.message);const execution=await runAuthorizedGeneration({modelClass:plan.modelClass,deterministic:()=>answerQuestion(body.message,body.location),consume:async()=>{const quota=await consumePersistentAiQuota(auth.user!,plan.weight);return quota.status},generate:()=>executePlannedProvider(plan.modelClass,body.message)});if(execution.status==='quota_denied')return NextResponse.json({error:'Kuota penggunaan wajar DUTA AI telah dicapai. Sila cuba semula selepas tetapan semula.',code:'QUOTA_EXCEEDED'},{status:429});if(execution.status==='quota_error')return NextResponse.json({error:'DUTA AI belum tersedia.',code:'PROVIDER_UNAVAILABLE'},{status:503});if(execution.status==='deterministic')return NextResponse.json({...execution.value as object,quota:{units:0,source:'deterministic'}});const generated=execution.value as AIProviderResult|undefined;if(!generated?.success)return NextResponse.json({error:'DUTA AI belum tersedia.',code:'PROVIDER_UNAVAILABLE'},{status:503});return NextResponse.json({answer:generated.text,intent:plan.intent,quota:{units:plan.weight}});}
 catch(error){return NextResponse.json({error:error instanceof z.ZodError?'Pertanyaan tidak valid.':'DUTA belum dapat memeriksa sumber saat ini. Silakan coba lagi atau gunakan pertanyaan lain.'},{status:error instanceof z.ZodError?400:503});}
}
