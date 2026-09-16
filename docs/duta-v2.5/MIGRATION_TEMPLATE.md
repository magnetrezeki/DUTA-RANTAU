# DUTA RANTAU v2.5 — Governed Forward Migration Template

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | TEMPLATE_ONLY |
| RECORD_TYPE | NOT_A_MIGRATION_RECORD |
| AUTHORITY_MODEL | FORWARD_ONLY_DIRECT_SQL |

Use this checklist for a future governed migration. Replace `NNNN` only when
that migration is actually authored. This template does not create, propose,
review, accept, test, apply, or deploy `0039`.

## Identity

- Migration number: `NNNN`
- Canonical filename: `NNNN_lowercase_slug.sql`
- Purpose:
- Authoring status: `PROPOSED | REVIEWED | AUTHORITY_ACCEPTED | SUPERSEDED`

## Authority status and dependencies

Record the two-commit provenance model: Commit A introduces SQL plus PROPOSED
metadata; Commit B records AUTHORITY_ACCEPTED after validation. introducedCommit
must be the earlier non-merge SQL-add commit, not the acceptance commit.

| Category | Declared dependencies |
| --- | --- |
| migrations | |
| tables | schema-qualified `schema.table` |
| columns | `schema.table.column` |
| functions | schema-qualified; signature when overloaded |
| roles | exact PostgreSQL role name |
| extensions | exact extension name |
| security | RLS, policy, grant/revoke, role, function, ownership property |

Historical migration number alone is insufficient evidence. Declare the actual
database and security preconditions.

## Pre-state

### DECLARED_PRESTATE

List applicable tables, columns, types, nullability/defaults, constraints,
functions/signatures, roles, extensions, RLS, policies, grants/revokes, data
invariants, and absence of conflicting objects.

### LOCAL_PRESTATE

Synthetic isolated fixture: `tests/db/migrations/NNNN/prestate.sql`.

### TARGET_PRESTATE

Owned by MA-04. Do not fill this template as staging/production execution
evidence.

## SQL design

- Canonical direct-SQL artifact:
- Schema effect: `NONE | ADDITIVE | ALTERING | DESTRUCTIVE | MIXED`
- Security effects: `NONE | AUTHORIZATION | RLS | ROLE_GRANT | SECURITY_FUNCTION | AUTHENTICATION | MULTIPLE`
- RLS decision / requiresRlsValidation:
- Data effect: `NONE | BACKFILL | TRANSFORM | DELETE | MIXED`
- requiresDataBackfill:
- IDEMPOTENCY_DECISION:
- Conditional DDL justification, if any:
- Transaction policy: `TRANSACTIONAL | NON_TRANSACTIONAL_WITH_JUSTIFICATION`
- Operational risk: locks, rewrite, indexes, transaction duration, large-table
  impact, batching, and blocking behavior where applicable.

### Idempotency decision

Record the explicit IDEMPOTENCY_DECISION and justify any conditional DDL.

Unexpected pre-state fails closed unless conditional behavior is deliberately
justified. Do not use IF EXISTS or IF NOT EXISTS merely to hide drift.

## Expected post-state

List applicable objects, columns/types/defaults/nullability, constraints,
indexes, functions/security properties, RLS, policies and behavior,
roles/grants, and data invariants.

## Validation artifacts

- Prestate fixture: `tests/db/migrations/NNNN/prestate.sql`
- Post-state verifier: `tests/db/migrations/NNNN/verify.sql`
- Security verifier, when applicable: `tests/db/migrations/NNNN/security-verify.sql`
- Synthetic seed, when applicable: `tests/db/migrations/NNNN/seed.sql`
- Validation result: `docs/duta-v2.5/migrations/NNNN_VALIDATION.md`

Schema-only work requires prestate plus verify. Security work additionally
requires adversarial negative validation. Data work requires representative
synthetic data and invariant checks. Mixed work combines the applicable proofs.

## Security and data validation

For RLS, record policies, expressions, authorized allow, unauthorized denial,
owner/bypass considerations, role behavior, and FORCE RLS decision. For
AUTHORIZATION, ROLE_GRANT, SECURITY_FUNCTION, AUTHENTICATION, or MULTIPLE,
record the relevant positive and negative evidence. Security-impacting work
must include negative/adversarial validation.

For BACKFILL, TRANSFORM, DELETE, or MIXED, record representative data,
edge/null cases, invariants, partial-failure consideration, and explicit
idempotency decision. DELETE also records destructive acknowledgement and
affected-data definition.

## Rollback/recovery

- Classification: `REVERSIBLE | FORWARD_FIX_ONLY | DATA_BACKUP_REQUIRED | MANUAL_RECOVERY | IRREVERSIBLE`
- Verified recovery or corrective plan:
- Ownership:

`DOWN_MIGRATION_REQUIRED: NO`. Do not fabricate reverse SQL.

## Provenance and acceptance evidence

- Commit A / introducedCommit:
- Commit B / acceptance commit:
- Exact-byte checksum: `sha256:<64 lowercase hex>`
- Dependency review:
- Local isolated validation evidence:
- Manifest `validationContract.reference`:
- Authority acceptance review:

## Environment-state disclaimer

AUTHORITY_ACCEPTED is repository authority only. It does not prove local
execution, staging execution, production execution, or deployment. MA-04 owns
target pre-state and environment applied-state evidence.
