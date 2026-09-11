CREATE TABLE IF NOT EXISTS public.ai_telemetry_events (id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_ref uuid REFERENCES public.users(id) ON DELETE SET NULL,intent text NOT NULL,risk text NOT NULL,sensitivity text NOT NULL,model_class text NOT NULL,provider text,model text,source_requirement text NOT NULL,source_tier text,quota_outcome text NOT NULL,weighted_units integer NOT NULL,input_tokens integer NOT NULL,output_tokens integer NOT NULL,estimated_cost numeric(14,8) NOT NULL DEFAULT 0,latency_ms integer NOT NULL DEFAULT 0,success boolean NOT NULL,error_code text,fallback_used boolean NOT NULL DEFAULT false,created_at timestamptz NOT NULL DEFAULT now());
ALTER TABLE public.ai_telemetry_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.ai_telemetry_events FROM PUBLIC,anon,authenticated;
GRANT INSERT ON public.ai_telemetry_events TO duta_app;
CREATE POLICY ai_telemetry_insert_self ON public.ai_telemetry_events FOR INSERT TO duta_app WITH CHECK (user_ref=public.current_app_user_id());
CREATE INDEX IF NOT EXISTS ai_telemetry_events_user_created_idx ON public.ai_telemetry_events(user_ref,created_at);
