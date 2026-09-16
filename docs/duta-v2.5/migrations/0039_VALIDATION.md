# 0039 Source Registry Governance Foundation — Validation Record

| Field | Value |
| --- | --- |
| Migration | `0039_source_registry_governance_foundation.sql` |
| Repository lifecycle | `PROPOSED` |
| Validation status | `PENDING_MA03` |
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

## Pending evidence

Checksum: pending Commit B acceptance.
Introduced commit: pending Commit B acceptance.
Local execution: not performed.
Staging: not authorized.
Production: not authorized.
Environment applied state: unknown.
