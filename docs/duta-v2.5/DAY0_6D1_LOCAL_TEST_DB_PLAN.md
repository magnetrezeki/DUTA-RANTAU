# Day 0.6D-1 — isolated local test database plan

Date: 2026-09-08. Planning and static inspection only. No database was created, Docker/Supabase/PostgreSQL was started or installed, migrations were applied, environment variables were set, and no database test was run. No hosted service or production data/credential was accessed.

## The six blocked tests

| Test file | Test name / suite | Database operations | Required tables | Functions/RPCs | Roles | RLS dependency | Seed data | Destructive |
|---|---|---|---|---|---|---|---|---|
| tests/source-integrity.test.ts | source integrity › returns an array of active official sources | SELECT active rows, newest `last_checked` first | public.official_sources | None called directly | duta_app runtime connection | Yes: active-row SELECT policy for duta_app | At least one active official source | No |
| tests/source-integrity.test.ts | source integrity › uses HTTPS URLs | Same read | public.official_sources | None | duta_app | Yes | Active rows with HTTPS URLs | No |
| tests/source-integrity.test.ts | source integrity › contains required source integrity fields | Same read | public.official_sources | None | duta_app | Yes | Active rows with institution, channel, category, priority and last_checked | No |
| tests/source-integrity.test.ts | source integrity › uses expected official trust level | Same read | public.official_sources | None | duta_app | Yes | Active rows with OFFICIAL_VERIFIED trust level | No |
| tests/source-integrity.test.ts | source integrity › does not expose invented operational fields | Same read | public.official_sources | None | duta_app | Yes | Same source rows; query must return schema's intended fields only | No |
| tests/ai-router.test.ts | AI router › returns source and checked date for official answer | SELECT at most two active P0 rows for the Penang institution, newest first | public.official_sources | None called directly | duta_app runtime connection | Yes | At least one active P0 source for the expected institution and deterministic checked date | No |

Both source services enter `withPublicTransaction()`. Before executing the query, it asserts that the connection's current role is exactly `duta_app`, and that it is non-superuser, non-owner, non-BYPASSRLS, cannot create roles/databases, and cannot replicate. The public transaction sets an empty transaction-local `app.user_id`; it does not invoke `current_app_user_id()` for these reads.

## APP_DATABASE_URL purpose

`db/client.ts` reads `APP_DATABASE_URL` at module initialization, accepts only a non-placeholder PostgreSQL connection URL, and creates a Postgres.js/Drizzle pool (`max: 10`, prepared statements disabled). `SYSTEM_DATABASE_URL` is separate and is not needed by these six tests. The test setup loads `.env.local`, but the client deliberately does not fall back to `DATABASE_URL`.

The six tests use direct PostgreSQL through Drizzle/Postgres.js, not Supabase REST/Auth or Edge Functions. The URL must authenticate as the restricted `duta_app` role; an administrator or superuser URL intentionally fails the runtime role assertion. Repository guidance shows local-only role URLs at `localhost:5433`; no current value is recorded here. SSL requirement is UNKNOWN: no code forces SSL, and the recommended loopback-only local database should not need it. Do not infer that a hosted URL is acceptable merely because it uses PostgreSQL syntax.

Other repository references to `APP_DATABASE_URL` are runtime routes/services, source seeding, admin-health reporting, and safe-audit documentation/scripts. This plan is scoped to the six test failures only.

## Minimum local database requirements

| Requirement | Classification | Basis |
|---|---|---|
| PostgreSQL database with role catalog access used by `assertRestrictedRole()` | REQUIRED | Identity bridge queries `pg_roles`, `pg_class` and `pg_namespace` |
| PostgreSQL version | UNKNOWN | Repository does not pin a server version. Choose a maintained version compatible with the existing local runbook/container before future provisioning |
| `public` schema | REQUIRED | Drizzle schema/services qualify application tables there |
| `pgcrypto` extension or another mechanism for `gen_random_uuid()` | REQUIRED for full schema replay; OPTIONAL for a reviewed minimal source-test schema with explicit fixture UUIDs | Existing schema migrations use `gen_random_uuid()` |
| public.official_sources table, source URL unique index and source institution index | REQUIRED | All six tests read this table; indexes improve intended query behavior but are not logical test prerequisites |
| `trust_level` enum containing `OFFICIAL_VERIFIED` | REQUIRED | Source fixtures/test assertion use it |
| Columns id, institution, channel, url, category, priority, trust_level, last_checked, checksum, active, created_at, updated_at | REQUIRED | Schema/service query and inferred return type |
| duta_app LOGIN role with no superuser/owner/BYPASSRLS/create-role/create-db/replication privileges | REQUIRED | Explicit runtime assertion |
| duta_system role | NOT REQUIRED for these six tests | Used only by system transaction paths |
| administrator/bootstrap role | REQUIRED for future local provisioning only | Needed to create schema/role/grant/policy; must never be supplied as APP_DATABASE_URL |
| `anon`, `authenticated`, `service_role`, `authenticator` roles | NOT REQUIRED for these six tests | No Supabase REST/Auth/JWT execution occurs |
| RLS enabled on official_sources | REQUIRED | Tests should exercise the app's restricted connection instead of bypassing access policy |
| `official_sources_public` SELECT policy granting `duta_app` active rows | REQUIRED | Visible migration 0013 creates this policy for duta_app |
| SELECT grant on public.official_sources to duta_app | REQUIRED | Visible migration 0012 grants it |
| current_app_user_id/current_app_has_role/current_app_has_org_role helpers | OPTIONAL for the six reads; REQUIRED for wider app/authorization testing | The six public reads do not call them, but visible later RLS/migrations may require them |
| auth schema, `auth.uid()` simulation, JWT claims, Supabase Auth service | NOT REQUIRED for the six reads | The duta_app source policy is `active = true`; no auth API is called |
| `SET ROLE` in tests | NOT REQUIRED | Connection itself must be duta_app; switching from an elevated connection would defeat the runtime assertion |
| service-role credential | NOT REQUIRED | No service client/API call in test path |
| production account/session | NOT REQUIRED | Synthetic source rows suffice |

## Local strategy comparison

| Option | Fidelity | Setup/reproducibility | Windows and production-risk assessment |
|---|---|---|---|
| A. Supabase local stack | Highest Auth/PostgREST fidelity, but unnecessary for these six direct PostgreSQL tests | Repository has no current Supabase CLI config and historical local secret material complicates safe setup | Higher setup surface; do not reuse historical keys |
| B. Standalone local PostgreSQL | Enough database/RLS fidelity if roles/policies are recreated | Requires locally installed PostgreSQL and manual reset discipline | Viable, but no repository-supported installed-server workflow was found |
| C. Disposable Docker PostgreSQL | Enough PostgreSQL/RLS fidelity; matches existing local runbooks referencing a dedicated container, localhost:5433, duta_rantau_staging, and restricted roles | Container/database/port can be explicitly named and reset; no Supabase/Auth services required | Best repository-supported Windows path when Docker is later explicitly authorized; bind loopback only and never mount/import production data |
| D. Isolated staging database | Can provide closer deployment behavior | Requires external credentials/environment mapping | Not preferred; production involvement cannot be excluded and this task forbids hosted use |

RECOMMENDED LOCAL STRATEGY: DOCKER POSTGRESQL. Use a newly created, dedicated local container/database rather than the historical container without first validating ownership and target. The existing runbooks demonstrate intended local PostgreSQL role/RLS usage; they do not authorize replaying their scripts or reusing their prior database/container in this phase.

## Roles and RLS

Required for the six tests: a local bootstrap administrator and `duta_app`. `duta_app` must connect directly, have no prohibited attributes/ownership, have USAGE on public, SELECT on official_sources, and be governed by RLS policy that exposes only active sources. No ordinary authenticated client role, JWT claim simulation, `auth.uid()` simulation, service role, or `SET ROLE` is required.

The isolated environment has HIGH value for preliminary RLS verification: it can prove the restricted connection attributes, grants, source policy behavior, inactive-row denial, and source service queries. It cannot prove hosted Supabase Auth settings, actual hosted role grants, Edge/REST JWT handling, deployment secrets, cross-service account deletion, or the exact hosted migration state. Those still require a separately authorized hosted verification phase.

## Migration interaction

LOCAL MIGRATION REPLAY: UNSAFE.

The migration journal names four absent files (0004–0007), while 0010–0022 SQL files are unjournaled. Visible 0008 uses runtime helpers introduced in visible 0010/0011, demonstrating unreconciled ordering. The repository's Phase 3 runbook also refers to canonical 0004–0009 files that are not all in the current migration directory. A blind `drizzle-kit migrate` or a blind chronological SQL replay cannot establish a trustworthy test baseline.

Before schema establishment, reconcile intended migration chronology and compare the canonical local runbook/bootstrap artifacts against the current journal. Then choose one reviewed, versioned bootstrap path for the isolated database. For the narrow six-test baseline, a reviewed minimal schema/grant/policy bootstrap may be appropriate after reconciliation; it must reproduce the restriction checks and policy rather than bypass them. Do not create an ad-hoc permissive schema solely to turn tests green.

## Synthetic data plan

SYNTHETIC SEED DATA REQUIRED: YES. Production data required: NO.

Use deterministic synthetic UUIDs and `example.invalid` URLs. Seed only active official-source rows required by assertions: at least one P0 entry for the Penang institution with a deterministic last_checked date expected by the AI test, plus one or more active HTTPS rows with nonempty required fields and OFFICIAL_VERIFIED trust. Optionally seed one inactive row to prove it is excluded; no user, password, session, token, organization or production UUID is needed. Fixtures should be idempotent: clear only the dedicated local test table/database before insert, never a shared target.

## Isolation controls and APP_DATABASE_URL handling

Future provisioning must require all of the following:

- loopback hostname only (`localhost` or `127.0.0.1`), a dedicated non-default local port and a dedicated database name;
- a new local-only bootstrap credential kept outside the repository; no historical, hosted, production or shared secrets;
- a dedicated test-mode marker checked by future provisioning/test tooling before any destructive reset;
- a preflight guard rejecting non-loopback hosts, production-looking database names, and known hosted-Supabase hostname patterns before schema/reset/test work;
- no automatic use of `.env.local`, generic `DATABASE_URL`, Vercel/GitHub variables, or external network dependencies;
- `APP_DATABASE_URL` set only in the PowerShell process that runs tests, never committed, never `NEXT_PUBLIC_*`, never logged, and unset when that process ends;
- a separate `SYSTEM_DATABASE_URL` only if later tests require system paths; it is unnecessary for the six tests;
- an explicit target identity query performed before any future destructive action, followed by clean shutdown/reset of only the dedicated local target.

## Future execution sequence — not executed

1. Provision a fresh loopback-only disposable Docker PostgreSQL database with an explicit test database name and isolated bootstrap credential.
2. Reconcile migration provenance; select a reviewed bootstrap/migration subset instead of replaying the inconsistent journal blindly.
3. Establish public schema, official_sources table/enum, required extension as applicable, restricted duta_app role, grant and RLS policy. Verify role attributes before tests.
4. Load deterministic synthetic source fixtures, including the Penang P0 source and optional inactive-negative row.
5. In one PowerShell process only, set APP_DATABASE_URL to the duta_app loopback target after host/database preflight succeeds. Do not persist it.
6. Run the six database integration tests first, then full `npm test` with the existing process-only npm workaround.
7. Record only redacted results; unset process variables, stop/remove/reset only the explicitly named local test database/container, and verify Git status.

## Decision

SAFE TO PROVISION LOCAL TEST DB: YES, for a blank newly named loopback-only disposable target under a separately authorized provisioning phase. It is not safe yet to replay the repository migration chain or run the six tests against a database until migration/bootstrap reconciliation is approved and implemented.

Blockers: migration journal/file inconsistency; absent 0004–0007 migration files; no pinned PostgreSQL server version; no approved reviewed minimal bootstrap path; no local test database/container currently provisioned. None requires production data or production credentials.
