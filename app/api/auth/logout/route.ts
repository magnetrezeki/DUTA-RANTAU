import { NextResponse } from 'next/server';import { createSupabaseServerClient } from '@/lib/supabase/server';export async function POST(){try{const supabase=await createSupabaseServerClient();await supabase.auth.signOut();return NextResponse.json({ok:true})}catch{return NextResponse.json({error:'Gagal keluar.'},{status:500})}}

