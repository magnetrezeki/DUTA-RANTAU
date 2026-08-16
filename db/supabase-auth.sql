-- Run after Drizzle migrations in the Supabase SQL Editor.
-- Keeps authorization roles in public.users; never trusts role from signup metadata.
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id,email,name,city,role,profile_visibility,location_visibility,created_at,updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email,''),
    COALESCE(NULLIF(NEW.raw_user_meta_data ->> 'name',''), split_part(COALESCE(NEW.email,''),'@',1), 'Kawan Rantau'),
    NULLIF(NEW.raw_user_meta_data ->> 'city',''),
    'USER',
    'PRIVATE',
    'PRIVATE',
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_auth_user();
