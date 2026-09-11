# POST-8L-E controlled activation readiness

## Environment contract

| Variable | Purpose | Required for | Server/client | Current validation | Missing behavior | Security risk | Action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `DUTA_AI_ENABLED` | Activation kill switch | Any AI route use | Server | Explicit `true` only | Disabled | Low | Set only for approved staging activation |
| `GEMINI_API_KEY`, `GEMINI_MODEL` | L1 provider selection | L1 smoke test | Server | Missing key fails closed | `PROVIDER_UNAVAILABLE` | Secret exposure if public | Configure only in staging secret store after transport is implemented |
| `GROQ_API_KEY`, `GROQ_MODEL` | L2 provider selection | L2 smoke test | Server | Missing key fails closed | `PROVIDER_UNAVAILABLE` | Secret exposure if public | Configure only in staging secret store after transport is implemented |
| `OPENAI_API_KEY`, `OPENAI_MODEL` | L3 provider selection | L3 smoke test | Server | Luna-only model policy | `PROVIDER_UNAVAILABLE` | Secret/model-policy bypass | Use `gpt-5.6-luna` only after transport is implemented |
| `NVIDIA_API_KEY` and model settings | Benchmark/voice support | Optional non-chat work | Server | Not in chat execution path | Safe provider fallback | Secret exposure | Do not configure for chat activation |
| `APP_DATABASE_URL` | Restricted application database role | Quota and telemetry | Server | Missing DB fails closed at repository boundary | Quota error | Database credential exposure | Use staging-only restricted role |
| `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | Browser authentication client | Authenticated application | Client-safe publishable values | Required by Supabase clients | Auth unavailable | RLS must protect data | Use staging project values only |
| `SUPABASE_SECRET_KEY` | Optional administrative path | Not needed for normal AI activation | Server | Optional | Admin helper unavailable | High if exposed | Leave unset unless separately authorized |

No provider credential uses a `NEXT_PUBLIC_` name. Provider configuration is server-only and is not imported by client components.

## Migration deployment checklist

Prerequisites: authorization for the isolated staging database; confirmed snapshot/backup; a restricted `duta_app` role; `public.users` and `public.current_app_user_id()` already compatible with the migrations.

1. Confirm the target is the authorized staging database, its pre-state is recorded, and no production connection string is in the execution session.
2. Apply `0034_ai_fair_use_foundation.sql`. Verify `ai_usage_buckets`, its index, RLS, self-only policy, and `consume_ai_usage(uuid, integer, integer)` grants.
3. Apply `0035_ai_telemetry_foundation.sql`. Verify `ai_telemetry_events`, its foreign key to `public.users`, RLS, self-only insert policy, and `duta_app` insert-only contract.
4. Apply `0036_ai_telemetry_correlation.sql`. Verify nullable `correlation_id` and its partial unique index.
5. Reconfirm `duta_app` cannot create DDL, `anon`/`authenticated` cannot write telemetry or quota data, and no policy/grant has broadened.
6. Preserve additive schema state on rollback: set `DUTA_AI_ENABLED=false`, roll back the application release if required, and do not destructively remove telemetry/quota tables during an incident.

All three migrations are additive. Remote execution remains deferred.

## Controlled staging smoke plan

Run only after real server-side transports, staging credentials, and migrations are authorized. Use synthetic authenticated accounts and metadata-only telemetry review.

| Case | Expected result |
| --- | --- |
| L0 authoritative deterministic request | 200; zero quota units; no provider call |
| L1 public/non-sensitive request | Gemini selected after quota success |
| L2 general/economy request | Groq selected after quota success |
| L3 sensitive/escalated request | OpenAI Luna selected after quota success |
| Anonymous request | `AUTH_REQUIRED`; no quota/provider |
| Flag disabled | `AI_DISABLED`; no quota/provider |
| Exhausted quota | `QUOTA_EXCEEDED`; no provider |
| Message over 1000 characters | `INPUT_TOO_LARGE`; no quota/provider |
| Selected provider unavailable | `PROVIDER_UNAVAILABLE`; no fallback |
| Official source absent | `AUTHORITATIVE_SOURCE_REQUIRED`; no provider |

## Error contract

| Code | Status | Quota | Provider | Safe for display |
| --- | --- | --- | --- | --- |
| `AI_DISABLED` | 503 | No | No | Yes |
| `AUTH_REQUIRED` | 401 | No | No | Yes |
| `QUOTA_EXCEEDED` | 429 | Attempted | No | Yes |
| `RATE_LIMITED` | 429 | No | No | Yes |
| `INPUT_TOO_LARGE` | 400 | No | No | Yes |
| `PROVIDER_UNAVAILABLE` | 503 | Depends on provider attempt | Selected provider only | Yes |
| `AUTHORITATIVE_SOURCE_REQUIRED` | 422 | No | No | Yes |

`FORBIDDEN_CONTEXT` and `UNSUPPORTED_INTENT` are not current route error codes and must not be claimed as implemented.

## Readiness classification

| Area | Classification | Reason |
| --- | --- | --- |
| Application, authentication, feature flag, quota, source enforcement, privacy | Ready with control | Existing tests cover fail-closed route boundaries |
| Migrations | Ready with control | Additive and locally validated; remote authorization remains required |
| Provider routing | Blocker | Gemini, Groq, and OpenAI adapters deliberately return controlled unavailable results rather than invoke configured transports |
| Provider credentials | Blocker | Must not be configured before corresponding server transports are implemented and reviewed |
| Telemetry and observability | Ready with control | Metadata-only telemetry has correlation, total latency, quota outcome, source outcome, and estimated cost |
| Local burst rate limit | Ready with control | Suitable for a small controlled environment only |
| Distributed rate limit | Deferred non-blocker for small staging; public-launch blocker | No shared cross-instance enforcement |
| Duplicate request protection | Deferred non-blocker for small staging; public-launch blocker | No full idempotency mechanism |
| Rollback | Ready with control | Feature flag first, application rollback second, additive schema retained |

Staging activation is currently **NO-GO** because the authorized live provider transports are not implemented. Public launch is also **NO-GO** because provider transport, distributed rate limiting, and duplicate-request protection remain unresolved.