import { NextResponse } from 'next/server';import { demoCommunities } from '@/lib/demo-data';export async function GET(){return NextResponse.json({data:demoCommunities,demo:true});}
