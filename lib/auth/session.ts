import { eq } from 'drizzle-orm';import { appDb } from '@/db/client';import { users } from '@/db/schema';import { createSupabaseServerClient } from '@/lib/supabase/server';import type { UserRole } from '@/types';
const roles:UserRole[]=['USER','MEMBER','VERIFIED_MEMBER','SELLER','ORG_ADMIN','ORG_STAFF','MODERATOR','EDITOR','SUPER_ADMIN'];
export async function destroySession(){const supabase=await createSupabaseServerClient();await supabase.auth.signOut()}
export async function getCurrentUser(){try{const supabase=await createSupabaseServerClient();const {data:{user},error}=await supabase.auth.getUser();if(error||!user)return null;if(appDb){const profile=(await appDb.select({id:users.id,name:users.name,email:users.email,role:users.role,city:users.city,state:users.state}).from(users).where(eq(users.id,user.id)).limit(1))[0];if(profile)return profile}const rawRole=user.user_metadata?.role;const role:UserRole=roles.includes(rawRole)?rawRole:'USER';return {id:user.id,name:String(user.user_metadata?.name??user.email?.split('@')[0]??'Kawan Rantau'),email:user.email??'',role,city:user.user_metadata?.city??null,state:null}}catch{return null}}



