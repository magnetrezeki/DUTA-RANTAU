-- POST-8L-A1: persistent per-user fair-use accounting; no client write policy.
CREATE TABLE IF NOT EXISTS public.ai_usage_buckets (user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,period_start timestamptz NOT NULL,usage_units integer NOT NULL DEFAULT 0,request_count integer NOT NULL DEFAULT 0,created_at timestamptz NOT NULL DEFAULT now(),updated_at timestamptz NOT NULL DEFAULT now(),PRIMARY KEY(user_id,period_start));
CREATE INDEX IF NOT EXISTS ai_usage_buckets_period_idx ON public.ai_usage_buckets(period_start);
ALTER TABLE public.ai_usage_buckets ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.ai_usage_buckets FROM anon,authenticated;
GRANT SELECT,INSERT,UPDATE ON public.ai_usage_buckets TO duta_app;
CREATE POLICY ai_usage_self_only ON public.ai_usage_buckets FOR SELECT TO duta_app USING (user_id=public.current_app_user_id());
CREATE OR REPLACE FUNCTION public.consume_ai_usage(p_user uuid,p_units integer,p_limit integer) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ DECLARE period_start timestamptz:=date_trunc('day',now()); BEGIN IF p_units<0 OR p_limit<0 THEN RAISE EXCEPTION 'invalid ai quota'; END IF; INSERT INTO public.ai_usage_buckets(user_id,period_start,usage_units,request_count) VALUES(p_user,period_start,p_units,1) ON CONFLICT(user_id,period_start) DO UPDATE SET usage_units=public.ai_usage_buckets.usage_units+excluded.usage_units,request_count=public.ai_usage_buckets.request_count+1,updated_at=now() WHERE public.ai_usage_buckets.usage_units+excluded.usage_units<=p_limit; RETURN FOUND; END $$;
REVOKE ALL ON FUNCTION public.consume_ai_usage(uuid,integer,integer) FROM PUBLIC; GRANT EXECUTE ON FUNCTION public.consume_ai_usage(uuid,integer,integer) TO duta_app;
