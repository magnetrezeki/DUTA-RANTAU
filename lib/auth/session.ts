import { eq, sql } from 'drizzle-orm';
import { appDb } from '@/db/client';
import { users } from '@/db/schema';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export async function destroySession(){
  const supabase=await createSupabaseServerClient();
  await supabase.auth.signOut();
}

export async function getCurrentUser(){
  try{
    const supabase=await createSupabaseServerClient();
    const {data:{user},error}=await supabase.auth.getUser();

    if(error||!user)return null;
    if(!appDb)return null;

    const profile=(await appDb.transaction(async tx=>{
      await tx.execute(
        sql`select set_config('app.user_id', ${user.id}, true)`
      );

      const rows=await tx
        .select({
          id:users.id,
          name:users.name,
          email:users.email,
          role:users.role,
          city:users.city,
          state:users.state,
          suspendedAt:users.suspendedAt
        })
        .from(users)
        .where(eq(users.id,user.id))
        .limit(1);

      return rows[0]??null;
    }));

    if(!profile||profile.suspendedAt)return null;

    return {
      id:profile.id,
      name:profile.name,
      email:profile.email??user.email??'',
      role:profile.role,
      city:profile.city??null,
      state:profile.state??null
    };
  }catch{
    return null;
  }
}
