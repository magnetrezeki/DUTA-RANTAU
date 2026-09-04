# Phase 3A Security Review — Generate Only

## Architecture

Supabase Auth remains identity source. `public.users` remains role/profile source. User-scoped Drizzle routes receive a branded verified identity and run inside `withUserTransaction`, which connects only as `duta_app`, sets transaction-local `app.user_id`, reads it back, revalidates the active profile/role, then performs RLS-protected work.

## Restricted roles

- `duta_app`: LOGIN, NOINHERIT, non-owner, non-superuser, non-BYPASSRLS; ordinary request runtime.
- `duta_system`: separate restricted LOGIN for explicit system/audit/provider work.
- `duta_rantau`: owner/migration only; forbidden for RLS proof and request runtime.

## Identity safety

- No `auth.uid()` dependency.
- No NULL-identity privilege.
- No client actor ID.
- Transaction-local only; no session/global identity.
- Startup role inspection rejects dangerous attributes or ownership.
- Missing restricted URL fails closed; no owner fallback.

## RLS/grants

36 tables classified; 85 policies prepared after archival policy hardening. Sensitive jobs, sessions, memberships, payments, subscriptions, and audit operations have narrower SQL grants than ordinary content tables. System `USING(true)` policies are scoped only to explicit `duta_system` and selected tables; they are not NULL-user bypasses.

## Application compatibility

Converted direct user Drizzle routes:

- source mutation;
- organization creation;
- secretary/publication generation;
- meeting transcription;
- organization access service.

`/api/jobs` remains feature-policy blocked and has no user DB mutation. Profile/Auth/Storage remain Supabase paths; full browser-local Auth compatibility is not proven by plain PostgreSQL staging.

## Rollback safety

Rollback checks for unexpected non-Phase3 policies before removal, drops only named Phase3/Phase4 policies/triggers/functions, revokes their grants, restores RLS/policy/helper baseline, and removes only the known local migration ledger timestamps. Roles remain inert for inspection.

## Artifact-only evidence

- 41 unit/API/security tests passed.
- TypeScript and Next.js build passed.
- Canonical migration, rollback, verification, and attack SQL parsed successfully.
- 86 local policies prepared; zero `auth.uid()` references in local migrations; zero raw app-API imports of `db/client`. Supabase-specific policies are isolated in companion deployment SQL.

## Not verified

No role, grant, migration, RLS, fixture, attack, pool, rollback, or application database test has run. Phase 3 remains BLOCKED until Windows LOCAL_STAGING returns every required PASS marker.
