import { NextResponse } from 'next/server';import { demoProducts } from '@/lib/demo-data';export async function GET(){return NextResponse.json({data:demoProducts,demo:true});}
