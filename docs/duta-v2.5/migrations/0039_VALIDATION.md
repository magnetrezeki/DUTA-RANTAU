# 0039 Source Registry Governance Foundation — Validation Record

| Field | Value |
| --- | --- |
| Migration | `0039_source_registry_governance_foundation.sql` |
| Repository lifecycle | `AUTHORITY_ACCEPTED` |
| Validation status | `COMPLETE_MA03` |
| Data effect | `NONE` |
| Schema effect | `ADDITIVE` |
| Security effects | `RLS`, `AUTHORIZATION` |
| Rollback classification | `REVERSIBLE` |

## Purpose

Add source-purpose classification, restricted source verification and approval
governance, currentness metadata, and source-specific evidence without source
ingestion, publication, booking, AI execution, runtime reviewer workflow, or
mission-data insertion.

## Declared pre-state

`public.official_sources` and `public.users` exist with UUID source/user
identifiers. The source table retains `sources_url_uq`, `source_institution_idx`,
RLS, `official_sources_public`, `official_sources_admin_all`, and the declared
legacy duta_app table privileges. The 0039 enums, tables, column, and narrowed
column privileges are absent.

## Declared post-state

The migration adds nullable `official_sources.source_purpose`; restricted
`official_source_governance` and `official_source_evidence` tables; exact
verification and approval checks; restrictive source/user foreign keys; RLS on
both new tables; and narrowed duta_app INSERT/UPDATE column privileges. It does
not classify or mutate existing source rows.

## Local validation contract

Use only the isolated `duta_local_test` database and synthetic fixtures:

- `tests/db/migrations/0039/prestate.sql`
- `tests/db/migrations/0039/verify.sql`
- `tests/db/migrations/0039/security-verify.sql`

Verify enum values, nullable legacy purpose, no automatic governance/evidence
rows, keys/constraints/defaults, restricted-table RLS, preserved legacy active
read and write behavior, and denied duta_app purpose/governance/evidence writes.

## Rollback boundary

Reverse the column privileges, RLS tables, constraints, tables, column, and
enums in dependency-safe order. This is reversible only before future
governance or evidence data becomes operationally authoritative.

## Local validation evidence

Validation completed at `2026-09-17T14:38:48.1149558Z` using the committed
runner at HEAD `d854fb92084d2b84b10a6a9c71bfc05930aef3d1`.

- Runner SHA-256: `42c05e7162105c84df59dcee2345cd1ab87872134b7e057ed08d0169c86ad74a`
- Container: `duta-local-test-db-clean`
- Loopback target: `127.0.0.1:55434`
- Database/bootstrap user: `duta_local_test` / `postgres`
- PostgreSQL server: `16.15` (`server_version_num=160015`)
- Image tag: `postgres:16-alpine`
- Image identity: `sha256:cf78e76683b9ca8c5733cbbdce6c9262b45b6767934dd0a95e671f9a0fc20685`
- Image repository digest: `postgres@sha256:cf78e76683b9ca8c5733cbbdce6c9262b45b6767934dd0a95e671f9a0fc20685`
- Synthetic data only: `YES`
- Remote, staging, or production connection: `NO`
- Image pull during validation: `NO`

The earlier partial container `duta-local-test-db` on loopback port `55433`
was preserved and was not reused as evidence. The successful run used a new
tmpfs-backed disposable container and clean database state.

| Phase | Result |
| --- | --- |
| Environment guard | `PASS` |
| Bootstrap | `PASS` |
| Prestate | `PASS` |
| Migration 0039 | `PASS` |
| Structural verification | `PASS` |
| Security verification | `PASS` |
| Final evidence | `PASS` |

Structural verification covered enums, columns, defaults, nullability,
constraints, foreign-key actions, indexes, RLS state, policy preservation,
legacy-row compatibility, absence of automatic governance/evidence rows, and
the exact duta_app column-level privilege boundary.

Security verification covered allowed active reads, allowed legacy priority
updates and unclassified inserts, denied purpose assignment/change/clear,
denied governance/evidence access for application and public roles, and
rejection of invalid verification and approval metadata combinations.

## Provenance and acceptance evidence

- Canonical SQL SHA-256: `5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30`
- Commit A / introducedCommit: `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5`
- Commit A is the unique earliest non-merge path-add for the canonical SQL.
- Prestate SHA-256: `467027a30647438637335c1a406e4cf4d89c7bb991c8632215aa1bebb8f0dff2`
- Verify SHA-256: `a93e06c32585e13def8b3e97381566af2abc3e711032a464bcefed988d072698`
- Security verify SHA-256: `f42252761080f429bd7b0a187a2bc63190da975e116e3276511e71082bab9341`
- Application schema representation was reviewed and updated before acceptance.
- Migration authority guard passed before acceptance with `historical=35, forward=1`.

## Environment-state disclaimer

This evidence establishes isolated local validation and repository authority
acceptance only. It does not establish staging application, production
application, deployment, full historical replay, or fresh-database authority.

Staging: not authorized and not executed.
Production: not authorized and not executed.
Deployment: not authorized and not executed.
Target environment applied state: unknown.
