import { createServerClient } from '@supabase/ssr';import { cookies } from 'next/headers';
export async function createSupabaseServerClient(){const jar=await cookies();const url=process.env.NEXT_PUBLIC_SUPABASE_URL;const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;if(!url||!key)throw new Error('SUPABASE_NOT_CONFIGURED');return createServerClient(url,key,{cookies:{getAll(){return jar.getAll()},setAll(items){try{items.forEach(({name,value,options})=>jar.set(name,value,options))}catch{/* Server Components cannot write; proxy refreshes cookies. */}}}})}

