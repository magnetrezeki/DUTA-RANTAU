# DUTA RANTAU v2.5 — Migration Applied-State Evidence Template

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | TEMPLATE_ONLY |
| RECORD_TYPE | NOT_APPLIED_STATE_EVIDENCE |
| AUTHORITY_MODEL | FORWARD_ONLY_DIRECT_SQL |

This generic template records one future environment execution attempt. It does not claim that `0039` or any other migration has executed. Use the approved future path `docs/duta-v2.5/migrations/applied-state/NNNN_<ENVIRONMENT>_ATTEMPT_NNN.md`.

## Migration Identity

- Migration number: `NNNN`
- Canonical filename:
- Environment: `STAGING | PRODUCTION`
- Attempt identity: `ATTEMPT_NNN`

## Repository Authority

- AUTHORITY_ACCEPTED commit:
- introducedCommit:
- Execution source/release commit:
- authorityVersion:
- manifestSchemaVersion:

Git identity is audit metadata only. It does not prove environment execution.

## Accepted Checksum

- Manifest accepted checksum: `sha256:<64 lowercase hex>`
- Exact-byte SHA-256 recomputed before execution:
- Checksum match: `PASS | FAIL`

If this check fails, classify PRESTATE_BLOCKED or EXECUTION_FAILED as applicable and do not execute the artifact.

## Validation Reference

- Migration-specific validation result: `docs/duta-v2.5/migrations/NNNN_VALIDATION.md`
- Local validation evidence reviewed:

## Target Pre-State

- Required objects, columns/types, constraints, functions, roles, extensions:
- RLS, policies, grants, ownership/security properties:
- Non-sensitive data invariants:
- Verification summary/reference:
- Result: `PASS | PRESTATE_BLOCKED`

Repository state does not prove target state. PRESTATE_BLOCKED stops execution; do not auto-repair or use conditional DDL to bypass drift.

## Dependency Verification

- Governed dependencies and same-environment APPLIED_CONFIRMED evidence:
- Historical object/security preconditions:
- Result:

## Execution Authorization

- Authorization concept: `STAGING_EXECUTION_AUTHORIZED | PRODUCTION_EXECUTION_AUTHORIZED`
- authorized_by:
- Authorization reference:
- Consequence acknowledgement for IRREVERSIBLE, if applicable:

## Rollback / Recovery Readiness

- MA-03 classification: `REVERSIBLE | FORWARD_FIX_ONLY | DATA_BACKUP_REQUIRED | MANUAL_RECOVERY | IRREVERSIBLE`
- Reverse/corrective/recovery approach:
- Recovery owner:
- Safe backup reference, completion, and recovery-verification status when DATA_BACKUP_REQUIRED:

## Execution Method

- Tool/method:
- Sanitized operation identifier:
- Locked artifact/direct-SQL integrity confirmation:
- Transaction classification: `TRANSACTIONAL | NON_TRANSACTIONAL_WITH_JUSTIFICATION`
- Step-level evidence reference when non-transactional:

Do not record a raw command, connection string, password, token, session cookie, or secret-bearing output.

## Execution Result

- started_at_utc: ISO-8601 UTC
- completed_at_utc: ISO-8601 UTC
- Commit/rollback or result evidence:
- Safe result classification:
- Sanitized error summary/reference, if applicable:

## Post-State Verification

- Schema verification:
- Constraint/index/function verification:
- Result: `PASS | POSTSTATE_FAILED | STATE_UNCERTAIN`

## Security Verification

- RLS/policy/grant/owner/FORCE RLS checks where applicable:
- Authorized and unauthorized safe verification where applicable:
- ROLE_GRANT / SECURITY_FUNCTION checks where applicable:
- Result:

Do not use real-user credentials as test fixtures.

## Data Verification

- Non-sensitive counts, aggregates, or schema-safe invariants:
- Backfill/transform/delete checks where applicable:
- Result:

Do not include raw PII, raw auth records, credentials, or sensitive dumps.

## Applied-State Classification

- Final classification: `PRESTATE_BLOCKED | EXECUTION_FAILED | STATE_UNCERTAIN | POSTSTATE_FAILED | APPLIED_CONFIRMED`
- Rationale:

STATE_UNCERTAIN blocks dependent migrations, staging-to-production eligibility, and APPLIED_CONFIRMED claims. APPLIED_CONFIRMED requires identity, checksum, authorization, execution, post-state, security/data, and evidence gates to pass.

## Evidence References

- Safe pre-state reference:
- Safe execution reference:
- Safe post-state reference:
- Safe security/data reference:

## Operator / Reviewer

- authorized_by:
- executed_by:
- verified_by:

Role separation is recommended. A small team may use the same person in more than one role, but every role remains explicit.

## Chronology

- Repository chronology reference:
- Environment event timestamps: UTC ISO-8601

Git timestamps do not substitute for environment execution timestamps.

## Secret / PII Disclaimer

This evidence must not contain passwords, API keys, access tokens, database connection strings, session cookies, raw PII, raw authentication records, secret-bearing command lines, or unsanitized errors. Preserve prior failed attempts; do not overwrite an APPLIED_CONFIRMED attempt. Corrections require a new auditable evidence record.