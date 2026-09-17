# Migration 0039 — Staging Attempt 001

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | `FINAL_ATTEMPT_EVIDENCE` |
| RECORD_TYPE | `STAGING_APPLIED_STATE_EVIDENCE` |
| AUTHORITY_MODEL | `FORWARD_ONLY_DIRECT_SQL` |
| Environment | `STAGING` |
| Project ref | `bftdfvihtewjwotrzwwe` |
| Database | `postgres` |
| PostgreSQL | `17.6` |
| Final classification | `POSTSTATE_FAILED` |
| Production action | `NONE` |

## Migration identity and repository authority

- Migration: `0039_source_registry_governance_foundation.sql`.
- Attempt: `ATTEMPT_001`.
- AUTHORITY_ACCEPTED commit: `de03e6abcb4b5c14c1cf20dd4a7f7940dfbddd84`.
- introducedCommit: `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5`.
- Authorized execution source commit: `cccb6a95eafbafda12165e160f8a38a064380847`.
- Execution tree: `97486f2515e78ecb81286d60c365528653b6cc78`.
- Execution source had no working-tree content diff and an empty index.
- Authority guard: `PASS (historical=35, forward=1)`.
- Validation reference: `docs/duta-v2.5/migrations/0039_VALIDATION.md`.

The disposable Windows checkout required the repository's already verified
mixed historical byte representations for the authority guard. Git reported
EOL conversion warnings, but both working-tree content diff and staged diff
were empty. The canonical 0039 file was mounted read-only for execution.

## Accepted checksum

- Manifest checksum: `sha256:5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30`.
- Exact-byte SHA-256 immediately before execution: `5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30`.
- Checksum match: `PASS`.

## Target pre-state and dependencies

The final read-only precheck verified staging identity, PostgreSQL `17.6`,
execution role `postgres`, schema-create and owner capability, `pgcrypto`, the
four required application roles, `users(id uuid)`, all legacy
`official_sources` columns, the two declared secondary indexes plus the primary
key index, RLS, two legacy policies, legacy `duta_app` privileges, and the
runtime identity function. Both new enums, both new tables, and
`official_sources.source_purpose` were absent. Result: `PASS`.

The initial index-count predicate counted the primary-key index and therefore
returned three rather than two. Read-only enumeration confirmed the two
required secondary indexes and the primary-key index; this was a verifier
predicate issue, not target drift.

## Execution authorization and recovery

- Authorization: explicit `STAGING_EXECUTION_AUTHORIZED` for this project,
  candidate, and checksum in the controlling session.
- authorized_by: `DUTA RANTAU PROJECT OWNER`.
- executed_by: `CODEX OPERATOR`.
- Recovery classification: `REVERSIBLE`, bounded to before authoritative
  governance/evidence data exists.
- Recovery owner: `DUTA RANTAU PROJECT OWNER`.
- Backup reference: `pre0039-20260917T210413Z/staging-pre0039.dump`.
- Backup SHA-256: `4fd84716c3ad02fa354c58008c1ea99d98d5d38c2d172663556606ad4f335906`.
- Recovery readiness reference:
  `docs/duta-v2.5/migrations/0039_STAGING_LOGICAL_RECOVERY_001.md`.

## Execution result

- Method: PostgreSQL 17.6 client, startup files disabled, stop-on-error,
  canonical file execution from a read-only mount.
- Transaction classification: `TRANSACTIONAL`.
- started_at_utc: `2026-09-17T22:46:12.9151323Z`.
- completed_at_utc: `2026-09-17T22:46:24.4347822Z`.
- Client exit: `0`.
- Server result: one `BEGIN`, both enum creations, table alteration, both table
  creations, both RLS alterations, privilege narrowing/grants, and one
  `COMMIT` completed.
- Execution count: `1`.
- Migration retry: `NONE`.

## Post-state verification

Read-only catalog verification passed for the exact enum values; nullable
default-null `source_purpose`; both accepted table column sets and defaults;
primary keys; five foreign keys with `ON DELETE RESTRICT` and `ON UPDATE NO
ACTION`; governance checks; evidence uniqueness; RLS enabled with FORCE off;
zero policies; and the required `duta_app` privilege narrowing. The data
invariants also passed: governance rows `0`, evidence rows `0`, and classified
legacy source rows `0`.

## Security verification failure

The locked security postcondition requiring no application grants on the two
new tables failed. Effective and direct catalog inspection found all table
privileges on both new tables granted to `anon` and `authenticated`. The
provider also granted them to `service_role`. Staging default ACLs for objects
created by `postgres` in schema `public` contain these grants.

RLS remains enabled, FORCE remains off, and both new tables have zero policies,
but the direct grants still violate the accepted validation contract. No grant
repair, schema repair, migration retry, redeployment, or behavior-test mutation
was attempted after this fail-closed result.

- Schema/constraint verification: `PASS`.
- Data verification: `PASS`.
- RLS/policy verification: `PASS`.
- Application-grant verification: `FAIL`.
- Security result: `POSTSTATE_FAILED`.

## Applied-state classification

- Final classification: `POSTSTATE_FAILED`.
- Database execution state: migration transaction `COMMITTED` exactly once.
- `APPLIED_CONFIRMED`: `NO`.
- Rationale: the canonical artifact committed and structural/data invariants
  passed, but Supabase staging default ACLs introduced prohibited direct grants
  on both new tables. A separately authorized governed remediation and new
  verification attempt are required. Production eligibility remains blocked.

## Operator / reviewer and chronology

- authorized_by: `DUTA RANTAU PROJECT OWNER`.
- executed_by: `CODEX OPERATOR`.
- verified_by: `CODEX OPERATOR`.
- Prestate/recovery reference:
  `docs/duta-v2.5/migrations/0039_STAGING_LOGICAL_RECOVERY_001.md`.
- Environment event timestamps: UTC values recorded above.

## Secret / PII disclaimer

This record contains no password, token, connection string, session cookie,
secret value, raw authentication record, or PII. Production project
`uokljxqqvpujwmubildy` was not connected, selected, or modified. No push,
deployment, Preview redeployment, or production action occurred.
