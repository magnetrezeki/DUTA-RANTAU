-- POST-8L-A1: persistent per-user fair-use accounting; no client write policy.
BEGIN;

CREATE TABLE IF NOT EXISTS public.ai_usage_buckets (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  period_start timestamptz NOT NULL,
  usage_units integer NOT NULL DEFAULT 0,
  request_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, period_start)
);
CREATE INDEX IF NOT EXISTS ai_usage_buckets_period_idx ON public.ai_usage_buckets(period_start);

CREATE TABLE IF NOT EXISTS public.ai_usage_requests (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  period_start timestamptz NOT NULL,
  request_id text NOT NULL CHECK (length(btrim(request_id)) BETWEEN 1 AND 128),
  units integer NOT NULL CHECK (units > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, period_start, request_id)
);

ALTER TABLE public.ai_usage_buckets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_usage_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.ai_usage_buckets FROM PUBLIC, anon, authenticated;
REVOKE ALL ON public.ai_usage_requests FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.ai_usage_buckets TO duta_app;

DROP POLICY IF EXISTS ai_usage_self_only ON public.ai_usage_buckets;
CREATE POLICY ai_usage_self_only ON public.ai_usage_buckets
FOR SELECT TO duta_app
USING (user_id = public.current_app_user_id());

CREATE OR REPLACE FUNCTION public.consume_ai_usage(
  p_user uuid,
  p_units integer,
  p_limit integer,
  p_request_id text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  quota_period_start timestamptz := date_trunc('day', now() AT TIME ZONE 'UTC') AT TIME ZONE 'UTC';
  actor_id uuid;
  request_inserted boolean;
BEGIN
  actor_id := public.current_app_user_id();
  IF actor_id IS NULL OR p_user IS NULL OR p_user IS DISTINCT FROM actor_id THEN
    RAISE EXCEPTION 'verified application identity is required';
  END IF;

  -- 30 is the current server-owned fair-use ceiling passed by the runtime.
  -- Lower limits remain valid; callers cannot raise the ceiling above 30.
  IF p_units IS NULL OR p_limit IS NULL OR p_units <= 0 OR p_limit <= 0
     OR p_units > p_limit OR p_limit > 30 THEN
    RAISE EXCEPTION 'invalid ai quota';
  END IF;

  IF p_request_id IS NULL OR length(btrim(p_request_id)) NOT BETWEEN 1 AND 128 THEN
    RAISE EXCEPTION 'valid ai quota request identifier is required';
  END IF;

  INSERT INTO public.ai_usage_requests(user_id, period_start, request_id, units)
  VALUES (actor_id, quota_period_start, p_request_id, p_units)
  ON CONFLICT (user_id, period_start, request_id) DO NOTHING
  RETURNING true INTO request_inserted;

  IF NOT COALESCE(request_inserted, false) THEN
    RETURN true;
  END IF;

  INSERT INTO public.ai_usage_buckets(user_id, period_start, usage_units, request_count)
  VALUES (actor_id, quota_period_start, p_units, 1)
  ON CONFLICT (user_id, period_start) DO UPDATE
  SET usage_units = public.ai_usage_buckets.usage_units + excluded.usage_units,
      request_count = public.ai_usage_buckets.request_count + 1,
      updated_at = now()
  WHERE public.ai_usage_buckets.usage_units + excluded.usage_units <= p_limit;

  IF FOUND THEN
    RETURN true;
  END IF;

  DELETE FROM public.ai_usage_requests
  WHERE user_id = actor_id
    AND period_start = quota_period_start
    AND request_id = p_request_id;
  RETURN false;
END
$$;

REVOKE ALL ON FUNCTION public.consume_ai_usage(uuid, integer, integer, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.consume_ai_usage(uuid, integer, integer, text) TO duta_app;

COMMIT;
