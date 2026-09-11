ALTER TABLE public.ai_telemetry_events ADD COLUMN IF NOT EXISTS correlation_id text;
CREATE UNIQUE INDEX IF NOT EXISTS ai_telemetry_events_correlation_idx ON public.ai_telemetry_events(correlation_id) WHERE correlation_id IS NOT NULL;
