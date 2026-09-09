# Day 0.7B-2 — Local Migration Replay Report

Date: 2026-09-09. A fresh disposable `postgres:16-alpine` container named `duta-local-test-db` was bound only to `127.0.0.1:55433`, used a generated runtime-only password, no volume, and was removed in `finally`. No hosted database, Supabase, or Vercel service was accessed.

## Physical-order manifest and result

| Order | Migration | Result | Observation |
|---:|---|---|---|
| 1 | 0000_next_marrow.sql | PASS | Base types, tables, FKs and indexes created. |
| 2 | 0001_glorious_scarlet_witch.sql | PASS | Community and organisation operations objects created. |
| 3 | 0002_reflective_magdalene.sql | PASS | Organisation operations/publication objects created. |
| 4 | 0003_stiff_sunspot.sql | PASS | Official-office/contact/evidence objects created. |
| 5 | 0008_phase4_real_content_rls.sql | FAIL | `duta_app` role does not exist. Replay stopped immediately. |

The first failure is **GRANT_ROLE_ASSUMPTION**. Its missing prerequisite is the restricted runtime role `duta_app`, whose creator is current migration `0010_runtime_database_roles.sql`. Policy expressions in the same migration also depend on identity helpers created by `0011_runtime_identity_bridge.sql`. The failure is non-secret and occurred before any later migration was attempted.

## Empirical dependency findings

- `0000` through `0003` are clean-baseline compatible in physical order.
- `0008` is **REQUIRES_PREDECESSOR**: at minimum `0010`, and logically `0011`, must precede its grants/policies.
- The physical order is not valid for a clean baseline. Full current replay is unsafe.
- No independent probes were run. The first-failure evidence was sufficient, and probes would not safely establish a canonical baseline without selectively constructing prerequisites.

## Historical gap relevance

Historical `0005` is **PARTIALLY_REQUIRED** only for the historical membership-registration domain: it adds member-specific tables/types and organisation application columns, but it does not create `duta_app` and does not resolve the observed first failure.

Historical `0006` is **PARTIALLY_REQUIRED** for its own historical registration RLS layer. It assumes `duta_app` and identity helpers, so it cannot resolve the first failure and would introduce additional prerequisite requirements. Neither historical file was executed.

`0004` is classified **LIKELY_MISSING_SCHEMA_CHANGE** because its journal tag names identity bridge/RLS work and current policy migrations depend on later equivalents in `0010`/`0011`; its exact SQL remains unavailable. `0007` remains **UNKNOWN**: its member-face-verification journal tag has no reachable SQL and no observed role in the initial failure.

Objects with no creator earlier in physical order at the first failure: `duta_app`, `duta_system` (not yet needed by the failing statement), and identity functions `current_app_user_id`, `current_app_has_role`, and `current_app_has_org_role`. Current creators exist later in `0010`/`0011`; no claim is made about hosted state.

## Strategy decision

Recommend **Strategy B**: preserve legacy migrations unchanged and create a new canonical baseline for fresh V2.5 environments only after a separately authorized local experiment proves a dependency-correct order. It has the best auditability and maintainability without renumbering or guessing absent SQL. Strategy A has low replay safety because 0004/0007 are unavailable; Strategy C remains useful only for future incremental change after a proven baseline, not as a cure for physical-order replay.

## Next safe experiment

On a new disposable local PostgreSQL database, run a separately authorized logical-order probe that applies `0000`–`0003`, then `0010` and `0011`, then evaluates `0008`/`0009` one at a time. Stop on any duplicate policy/function, missing object, privilege/RLS weakening, auth-schema assumption, or destructive/data-dependent operation. Do not apply historical 0005/0006 or unknown replacements without separate authorization.

## Day 0.7B-3 logical-order probe

Static precheck found no execution-critical circular dependency from `0010`/`0011` back to `0008`/`0009`. A fresh disposable local database then passed all eight files in this exact order: `0000`, `0001`, `0002`, `0003`, `0010`, `0011`, `0008`, `0009`. This empirically validates `0010` after `0003`, `0011` after `0010`, `0008` after `0010`/`0011`, and `0009` after `0008`.

The result does not validate remaining migrations, historical 0005/0006, missing 0004/0007, or any hosted state. The next logical current files are `0012` and `0013`, which depend on the proven role/function/table foundation. Strategy B confidence is now MEDIUM.

## Day 0.7B-4 extension

`0012_runtime_role_grants.sql` is READY after the proven foundation and passed. It grants only schema usage and `official_sources` SELECT to `duta_app`. `0013_runtime_official_sources_rls.sql` is structurally dependent on `official_sources` but failed on plain PostgreSQL because the Supabase roles `anon` and `authenticated` do not exist. This is a **SUPABASE_SPECIFIC_DEPENDENCY**, not evidence that the migration SQL should be changed. The ten-step probe stopped at 0013. No public privilege, RLS, audit privilege, or cross-organisation post-replay inspection was performed after the failed tenth step.
