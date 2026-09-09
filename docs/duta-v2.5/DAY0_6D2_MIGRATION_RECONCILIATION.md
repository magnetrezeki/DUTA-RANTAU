# Day 0.6D-2 — migration reconciliation and minimal local bootstrap design

Date: 2026-09-08. Static inspection/documentation only. No Docker/container/database/Supabase process was created or started; no migration, schema, role, grant, RLS policy, environment variable, application file, package manifest, commit or push was changed.

## Inventory

### Current migration chain and metadata

| Path/group | Type | Sequence/identifier | Tracked | Journal reference | Purpose | Status |
|---|---|---|---|---|---|---|
| db/migrations/0000_next_marrow.sql through 0003_stiff_sunspot.sql | Drizzle SQL migrations | 0000–0003 | Yes | Yes | Initial/evolving application schema | ACTIVE |
| db/migrations/0008_phase4_real_content_rls.sql | SQL migration | 0008 | Yes | Yes | Runtime content grants, admin policies, moderation protections | ACTIVE but out-of-order dependency concern |
| db/migrations/0009_organization_archival_workflow.sql | SQL migration | 0009 | Yes | Yes | Organization archival workflow/privileges/policies | ACTIVE |
| db/migrations/0010_runtime_database_roles.sql through 0022_account_deletion_function.sql | SQL migrations | 0010–0022 | Yes | No | Runtime roles, identity, RLS/grants, account-deletion hardening | ACTIVE in source, UNJOURNALED |
| db/migrations/meta/_journal.json | Drizzle journal | entries 0000–0009 | Yes | N/A | Declared migration chronology | ACTIVE but inconsistent |
| db/migrations/meta/0000_snapshot.json through 0003_snapshot.json | Drizzle schema snapshots | 0000–0003 | Yes | Correspond to 0000–0003 only | Generated schema metadata | LEGACY/INCOMPLETE for current state |
| db/schema.ts | Drizzle schema definition | current source schema | Yes | No | TypeScript application schema | ACTIVE |
| db/client.ts and drizzle.config.ts | Runtime/migration configuration | APP/SYSTEM/DATABASE_URL handling | Yes | No | Runtime connections and Drizzle migrate configuration | ACTIVE |

### Other database artifacts

| Path/group | Type | Identifier | Tracked | Journal reference | Purpose | Status |
|---|---|---|---|---|---|---|
| db/supabase-bootstrap.sql | Full bootstrap SQL | Fresh Supabase-oriented schema/RLS/seed | Yes | No | Alternate fresh database setup | LEGACY/UNKNOWN as canonical path |
| db/supabase-auth.sql | Auth trigger SQL | handle_new_auth_user | Yes | No | Maps Supabase Auth users to public users | ACTIVE reference, Supabase-specific |
| db/rls.sql | RLS policy SQL | auth.uid()-oriented policy set | Yes | No | Supabase-native RLS reference | LEGACY/MIXED with runtime-role model |
| db/supabase-phase4-organization-archival.sql | Workflow SQL | organization archival protection | Yes | No | Supabase variant of archival workflow | UNKNOWN alongside 0009 |
| db/organization-packages.sql | Setup SQL | organization package data | Yes | No | Add-on data/configuration | ACTIVE reference; not six-test required |
| db/official-emergency-records.sql and official-emergency-upsert.sql | Seed/upsert SQL | emergency directory | Yes | No | Official emergency data | ACTIVE reference; not six-test required |
| scripts/seed-official-sources.ts | Seed script | official sources | Yes | No | Runtime database source seeding | ACTIVE; not suitable for this plan until DB exists |
| scripts/security/phase3_attack_matrix.sql and phase3_verify_local.sql | Local security verification SQL | Phase 3 | Yes | No | RLS/role verification evidence | LEGACY/REFERENCE, useful for later local RLS work |
| phase3_apply_local.ps1 and Phase 3/4 runbooks | Local operation guidance | duta_rantau_staging / local Docker | Yes | No | Historical local role/RLS deployment process | REFERENCE; currently blocked by absent migration files |

The repository has 19 current migration SQL files. The journal expects 10 entries; all four snapshots stop at 0003. No duplicate journal tag exists.

## Chronology reconstruction

| Expected sequence | Classification | Evidence |
|---|---|---|
| 0000–0003 | PRESENT | Files, journal entries and matching snapshots exist |
| 0004_phase1a_identity_bridge_rls | MISSING | Journal and phase3_apply_local.ps1 reference it; no current file or reachable path history was established in earlier audit |
| 0005_membership_organization_registration | MISSING | Journal/runbook reference it; earlier reachable-history inspection found a path history, but no current file |
| 0006_membership_organization_registration_rls | MISSING | Journal/runbook reference it; earlier reachable-history inspection found a path history, but no current file |
| 0007_member_face_verification | MISSING | Journal and phase3_apply_local.ps1 reference it; no current file or reachable path history was established in earlier audit |
| 0008–0009 | PRESENT | Files and journal entries exist, but 0008 calls helpers introduced by visible later migrations |
| 0010–0022 | UNJOURNALED | Files are present but none appear in _journal.json |

MIGRATIONS EXPECTED: 23 by the visible numeric range 0000–0022; 19 present; 4 missing; 13 unjournaled.

MISSING 0004–0007 ROOT CAUSE: MIXED. Evidence supports historical removal/absence for 0005/0006 and no established source-path history for 0004/0007. The journal is also stale because it references all four absent files while omitting 0010–0022. There is insufficient evidence to label all four as one event such as squash or rename. Do not reconstruct or rename them from inference.

FULL MIGRATION REPLAY: UNSAFE. A journal-driven replay stops at absent files; a file-order replay has ordering uncertainty because 0008 depends on helpers visibly introduced in 0010/0011. The runbook itself requires the absent 0004–0007 artifacts. Replaying the large bootstrap SQL is not a substitute: it mixes Supabase auth/RLS assumptions and does not resolve authoritative chronology.

## Unjournaled migrations

| File | Objects affected | Dependencies | Current application relevance | Six-test relevance | Supabase-specific | Local PostgreSQL fit | Classification |
|---|---|---|---|---|---|---|---|
| 0010_runtime_database_roles.sql | duta_app, duta_system roles; public usage/revokes | PostgreSQL role administration, existing public tables | Required for restricted runtime model | REQUIRED_FOR_TEST_BOOTSTRAP for duta_app attributes, although minimal bootstrap may implement equivalent reviewed role setup | No | Yes | REQUIRED_FOR_TEST_BOOTSTRAP |
| 0011_runtime_identity_bridge.sql | current_app_* SECURITY DEFINER helpers | users, organization_members, enums, roles | Required by user/system transactions and policies | NOT_REQUIRED_FOR_TEST_BOOTSTRAP; six reads do not call helpers | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0012_runtime_role_grants.sql | duta_app SELECT on official_sources | official_sources, duta_app | Required for source reads | REQUIRED_FOR_TEST_BOOTSTRAP | No | Yes | REQUIRED_FOR_TEST_BOOTSTRAP |
| 0013_runtime_official_sources_rls.sql | official_sources SELECT policy for duta_app | official_sources, RLS, duta_app | Required for restricted source reads | REQUIRED_FOR_TEST_BOOTSTRAP | No | Yes | REQUIRED_FOR_TEST_BOOTSTRAP |
| 0014_runtime_users_select.sql | duta_app SELECT users | users, duta_app | Required by current-user runtime path | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0015_runtime_users_rls.sql | users_runtime_select policy | users, current_app_user_id | Required by current-user runtime path | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0016_runtime_content_select.sql | duta_app content discovery grants/policies | jobs/products/communities and legacy helper policy | Required by discovery modules | Not needed | Partly references auth.uid semantics | Yes with review | REQUIRES_REVIEW |
| 0017_runtime_sellers_select.sql | duta_app seller SELECT grant | sellers | Potential marketplace support | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0018_runtime_users_self_update.sql | limited user-column UPDATE grant/policy | users, current_app_user_id, duta_app | Required by profile PATCH | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0019_runtime_audit_self_insert.sql | audit self-insert policy | audit_logs, current_app_user_id | Superseded by 0021 | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0020_account_deletion_audit_hardening.sql | audit FK and constrained insert policy | audit_logs/users/current_app_user_id | Required for hardened deletion/audit path | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0021_remove_broad_audit_self_insert.sql | drops 0019 policy | audit_logs | Required to remove superseded broad policy | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |
| 0022_account_deletion_function.sql | delete_current_app_user RPC/function grants | users/current_app_user_id/duta_app | Required by account deletion endpoint | Not needed | No | Yes | NOT_REQUIRED_FOR_TEST_BOOTSTRAP |

`REQUIRED_FOR_TEST_BOOTSTRAP` means the test behavior must be reproduced, not that the unjournaled source file may be executed blindly. The minimal test bootstrap should create the equivalent reviewed role/grant/policy surface directly after it is separately approved.

## Minimal schema for six tests

| Object | Classification | Required detail |
|---|---|---|
| public.official_sources | TEST_REQUIRED | Table queried by both source services |
| trust_level enum | TEST_REQUIRED | Must contain OFFICIAL_VERIFIED |
| official_sources id, institution, channel, url, category, priority, trust_level, last_checked, checksum, active, created_at, updated_at | TEST_REQUIRED | Exact service/test row shape |
| unique URL and institution indexes | APPLICATION_REQUIRED_BUT_NOT_TEST_REQUIRED | Present in schema; useful for fidelity/performance but assertions do not require them |
| `duta_app` LOGIN role with restricted attributes/no ownership | TEST_REQUIRED | Enforced by assertRestrictedRole() before every query |
| bootstrap administrator | TEST_REQUIRED for future setup only | Must not be APP_DATABASE_URL connection |
| SELECT grant on official_sources to duta_app | TEST_REQUIRED | Required by PostgreSQL privileges |
| RLS enabled on official_sources | TEST_REQUIRED | Avoids a permissive false-positive test environment |
| one duta_app active-source SELECT policy (`active = true`) | TEST_REQUIRED | Mirrors 0013 behavior required by source service |
| duta_system, users, auth schema, `auth.uid()`, JWT claims, service role | NOT_REQUIRED | Six tests neither authenticate nor use user data |
| current_app_* helpers and application triggers | NOT_REQUIRED | Six tests use withPublicTransaction, not user/system transactions |
| pgcrypto / gen_random_uuid | NOT_REQUIRED for minimal bootstrap with explicit deterministic UUID fixture IDs; REQUIRED for full schema replay | Existing full migrations use gen_random_uuid |
| official source fixture rows | TEST_REQUIRED | Synthetic, deterministic active rows, including expected Penang P0 result/date |
| inactive synthetic source row | APPLICATION_REQUIRED_BUT_NOT_TEST_REQUIRED | Recommended negative RLS/row-filter assertion |

TEST-REQUIRED TABLES: 1. TEST-REQUIRED FUNCTIONS: 0. TEST-REQUIRED RLS POLICIES: 1. TEST-REQUIRED ROLES: 1 (`duta_app`; bootstrap administrator is a setup concern, not test connection role).

## Strategy comparison

| Strategy | Fidelity / RLS fidelity | Reproducibility and complexity | Risk / ability to run all six |
|---|---|---|---|
| A. Full migration replay | Nominally highest, currently untrustworthy | Low reproducibility because journal/files/order disagree | High risk; cannot safely run |
| B. Reviewed migration subset | Can be high if canonical missing history is recovered | Medium/high complexity; must resolve sequence/dependencies first | Risk of silently omitting needed objects; not ready |
| C. Minimal test bootstrap | High for the exact source-read/role/RLS behavior, intentionally narrow outside it | Small deterministic local surface; disposable | Low risk when guarded; runs all six, but does not prove full application migration fidelity |
| D. Schema snapshot plus test RLS | Snapshot covers only through 0003 and lacks current role policy state | Hidden generated-schema assumptions and manual reconciliation | Medium/high risk; no advantage over explicit minimal bootstrap |
| E. Existing supabase-bootstrap.sql | Broad data/auth/RLS coverage, but mixed/legacy Supabase assumptions | Large and non-canonical relative to current journal | High risk for narrow tests; do not use as shortcut |

RECOMMENDED BOOTSTRAP STRATEGY: MINIMAL_TEST_BOOTSTRAP.

## Minimal isolated bootstrap design — future work only

1. Prerequisites: a newly named, loopback-only disposable Docker PostgreSQL target and a local bootstrap administrator outside repository files.
2. Extensions: none for the minimal explicit-ID table; evaluate pgcrypto only if a later approved bootstrap uses full-schema UUID defaults.
3. Schema/types: public schema and minimal `trust_level` enum with required values.
4. Tables: create only `public.official_sources` with exact source-service columns.
5. Indexes: create the schema indexes for consistency; they are not assertion prerequisites.
6. Functions/triggers: none. Built-in `set_config` is sufficient for the public transaction path.
7. Roles/grants: create restricted `duta_app`; assert no superuser/BYPASSRLS/ownership/create-role/create-db/replication attributes; grant only required schema usage and table SELECT.
8. RLS: enable RLS and create one duta_app policy allowing `active = true`. Add a future verification assertion that inactive rows are unavailable.
9. Synthetic fixtures: deterministic IDs and source metadata only, with expected active P0 Penang row/date and optional inactive negative row.
10. Verification assertions: current role is duta_app, restricted attributes are true, RLS is enabled, policy/grant exist, active row is returned, inactive row is denied, query ordering/limit matches service.

MINIMAL BOOTSTRAP RLS FIDELITY: HIGH for these six tests. It faithfully tests the restricted `duta_app` direct connection, grant and active-row filter. It has no fidelity claim for Supabase Auth/JWT roles, cross-user access, other tables, triggers, or hosted deployment state.

## Production access abort guard

PRODUCTION ACCESS ABORT GUARD: YES.

The future runner must require a process-only APP_DATABASE_URL and abort before any schema/reset/test action unless all conditions hold: hostname exactly localhost or 127.0.0.1; a dedicated test database name and port; no hosted Supabase domain; no nonlocal host; no production-like target/project marker; no use of .env.local/generic DATABASE_URL; no external network fetch; and the connection confirms the expected local database name/current role. It must refuse administrator URLs for test execution and use an independent local bootstrap credential only during provisioning. It must never use committed, production, historical or shared credentials/data.

## Separate workstreams

WORKSTREAM A — LOCAL TEST BOOTSTRAP may proceed before production migration repair: YES, because it is explicitly narrow, disposable, synthetic, guarded and does not alter/replay production chronology.

WORKSTREAM B — PRODUCTION MIGRATION RECONCILIATION remains required: YES. It must recover/establish authoritative 0004–0007 provenance, journal 0010–0022 or create an approved replacement history, resolve 0008/0010/0011 order, and validate a full schema/RLS state in a separately authorized environment. The minimal bootstrap must not be represented as a production migration fix.

## Proposed future implementation files — not created

PROPOSED NEW FILE COUNT: 4.

- tests/db/bootstrap-local-test.sql — narrow schema/type/role/grant/RLS setup; contains no credentials.
- tests/db/seed-local-test.sql — deterministic synthetic official-source rows only.
- tests/db/verify-local-test.sql — local target/role/RLS/fixture assertions.
- scripts/run-local-db-tests.ps1 — strict preflight guard, process-only APP_DATABASE_URL handling, ordered test/reset invocation and refusal of nonlocal targets.

SAFE TO IMPLEMENT MINIMAL LOCAL BOOTSTRAP: YES, only when the future implementation is constrained to these reviewed files, runs against a newly provisioned loopback-only disposable database, and implements the abort guard before bootstrap/reset actions. It is not safe to execute the existing migration chain or use this plan against any hosted/production target.

## Final safety decision

No source/application/migration file was modified. The unresolved production migration work, absent canonical migrations, server-version selection, and unprovisioned local database remain blockers to execution, not blockers to writing the narrow implementation under the stated guard. Do not provision or run it without a new explicit authorization.
