# Day 0.6E-1.6 Vercel Preview and Staging Environment Mapping

## Target Mapping

`duta-v2.5` Preview must use the separately confirmed staging project `bftdfvihtewjwotrzwwe` at `bftdfvihtewjwotrzwwe.supabase.co`. Vercel Production remains isolated on `uokljxqqvpujwmubildy`; Preview-scoped Vercel values do not alter Production-scoped values. The primary database branch named `main` in the staging project is still staging, not the V1 production project.

The repository has no Vercel mapping file that could force Preview to production. The material risk is operational: mistakenly assigning the production URL or publishable key to the Preview scope. Require an exact staging-hostname check before saving Preview variables.

## Environment Variable Inventory

| Name | Referenced by | Purpose | Class | Preview guidance |
| --- | --- | --- | --- | --- |
| `NEXT_PUBLIC_SUPABASE_URL` | browser, server, proxy, admin client | Supabase project endpoint | Public | MUST_SET, Preview only with staging URL |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | browser, server, proxy | Ordinary Auth and browser client key | Public | MUST_SET, Preview only with staging project key |
| `NEXT_PUBLIC_APP_URL` | admin source page | Server-side application base URL | Public | SHOULD_SET, Preview only to the intended Preview URL |
| `APP_DATABASE_URL` | `db/client.ts`, identity bridge, database-backed routes | restricted application database connection | Server secret | DO_NOT_SET until a staging schema and restricted runtime role exist |
| `SYSTEM_DATABASE_URL` | identity bridge, audit fallback | restricted system/audit database connection | Server secret | DO_NOT_SET for normal Preview |
| `SUPABASE_SECRET_KEY` | `lib/supabase/admin.ts`, security audit | optional server-only admin audit path | Server secret | DO_NOT_SET for normal Preview |
| `AI_PROVIDER` | health route and AI services | AI-provider selection | Server configuration | OPTIONAL; use disabled/default-safe behavior |
| `AI_API_KEY` | example configuration | AI provider credential | Server secret | DO_NOT_SET unless a separately approved provider is configured |
| `AUDIT_HASH_SALT` | security audit | stable audit identifier hash salt | Server secret | OPTIONAL; set only through a separate secret-management decision |
| `NODE_ENV` | framework/runtime | runtime mode | Framework-managed | DO_NOT_SET manually |
| `DATABASE_URL`, `DIRECT_URL` | tooling/example and legacy scripts | tooling or legacy connection names | Server secret | DO_NOT_SET for runtime Preview |
| `DEMO_MODE`, `GEMINI_API_KEY`, `GEMINI_MODEL`, `VERCEL_OIDC_TOKEN` | local/example configuration only | no current application runtime requirement found | Mixed | DO_NOT_SET |

The application expects the new **publishable key** format through `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. It does not reference `NEXT_PUBLIC_SUPABASE_ANON_KEY`. It does not reference `SUPABASE_SERVICE_ROLE_KEY`; the only admin key name is `SUPABASE_SECRET_KEY`.

## Supabase Client Paths

1. Browser client: `lib/supabase/client.ts` requires `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
2. Server cookie client: `lib/supabase/server.ts` requires the same two public values.
3. Proxy session-refresh client: `proxy.ts` requires the same two public values.
4. Admin audit client: `lib/supabase/admin.ts` additionally requires `SUPABASE_SECRET_KEY`; it is not required for ordinary authentication.

## Preview and Auth Requirements

Vercel Preview needs the staging URL and staging publishable key to boot, render, initialize Supabase, and perform ordinary authentication. `NEXT_PUBLIC_APP_URL` should be the intended Preview deployment URL because an admin server component constructs an API URL from it. Registration derives `emailRedirectTo` from the incoming request origin and sends users to `/auth/konfirmasi`; the staging Supabase Auth dashboard must later permit the Preview origin and `/auth/konfirmasi` redirect. The callback exchanges a code or verifies an OTP and returns to `/profil`.

No OAuth callback or password-reset route was found in the repository. Eventual staging Auth configuration therefore requires a staging site URL and allowed redirect URLs for the Vercel Preview origin and `/auth/konfirmasi` only.

## Empty Staging Database

The application can boot only **partially** against an empty staging project: public UI and ordinary Supabase initialization can load, while database-backed routes and identity-bridge flows fail when `APP_DATABASE_URL` is absent or when their required tables, functions, roles, and policies are absent. Likely affected modules include profiles, organisations, jobs, marketplace, sources, admin health/database reporting, audit, and organisation feature routes.

Because full replay is unsafe, the recommended staging strategy is **MINIMAL_SECURITY_TEST_SCHEMA**: create a separately reviewed, reversible staging-only schema that contains only the roles, tables, functions, and RLS policies necessary to test the identified authorization risks. Do not copy production data or credentials.

## Human Configuration Checklist

| Variable | Value source | Vercel scope | Secret | Browser safe |
| --- | --- | --- | --- | --- |
| `NEXT_PUBLIC_SUPABASE_URL` | staging project URL `bftdfvihtewjwotrzwwe.supabase.co` | Preview only | No | Yes |
| `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` | staging project API settings | Preview only | No | Yes |
| `NEXT_PUBLIC_APP_URL` | approved Vercel Preview URL | Preview only | No | Yes |
| `SUPABASE_SECRET_KEY` | none for normal Preview | DO_NOT_SET | Yes | No |
| `APP_DATABASE_URL` | none until reviewed test schema and restricted role exist | DO_NOT_SET | Yes | No |
| `SYSTEM_DATABASE_URL` | none for normal Preview | DO_NOT_SET | Yes | No |

Before configuration, confirm the Preview scope, exact staging hostname, and that no Production-scoped setting is changed. Do not set a production URL, production key, historical credential, service role, or database credential in Preview.
