import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { answerQuestion } from '@/lib/services/ai-router';
import { rateLimit } from '@/lib/rate-limit';
const input=z.object({message:z.string().trim().min(2).max(1000),location:z.string().max(100).optional()});
export async function POST(req:NextRequest){
 const ip=req.headers.get('x-forwarded-for')?.split(',')[0]??'local';
 if(!rateLimit(`ai:${ip}`,15).ok)return NextResponse.json({error:'Terlalu banyak permintaan. Coba lagi sebentar.'},{status:429});
 try{const body=input.parse(await req.json());return NextResponse.json(answerQuestion(body.message,body.location));}
 catch{return NextResponse.json({error:'Pertanyaan tidak valid.'},{status:400});}
}
