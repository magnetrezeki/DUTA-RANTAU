import { NextResponse } from 'next/server';import { getCurrentUser } from '@/lib/auth/session';export async function GET(){const user=await getCurrentUser();return user?NextResponse.json({user}):NextResponse.json({user:null},{status:401});}

