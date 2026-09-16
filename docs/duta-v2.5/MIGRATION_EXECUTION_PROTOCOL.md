# DUTA RANTAU v2.5 — MA-04 Migration Execution Protocol

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | ACTIVE_EXECUTION_PROTOCOL |
| AUTHORITY_MODEL | FORWARD_ONLY_DIRECT_SQL |
| SCOPE | Governed forward migrations `0039+` |

## Purpose and authority boundary

MA-04 governs target environment pre-state verification, environment-specific execution authorization, controlled staging execution, staging applied-state evidence, production eligibility, controlled production execution, production applied-state evidence, rollback/recovery readiness, and environment evidence integrity.

MA-01 owns the authority model and historical boundary. MA-02 owns the manifest and repository historical integrity. MA-03 owns migration authoring, dependency declarations, local validation, and authority acceptance. MA-04 owns environment execution and applied-state evidence. MA-05 will own repository-wide static/global enforcement. These responsibilities do not overlap.

`AUTHORITY_ACCEPTED != APPLIED_CONFIRMED`. Repository authority and Git history do not prove environment execution, staging application, production application, or deployment. MA-04 applied-state environments are STAGING and PRODUCTION; LOCAL validation remains an MA-03 responsibility.

Current environment state is always `UNKNOWN / EXTERNAL_STATE_REQUIRED` until a migration-specific environment attempt has complete evidence. This protocol does not establish current state for either staging or production.

## Target pre-state and checksum gates

Before environment execution, verify the migration-specific TARGET_PRESTATE against the MA-03 declared pre-state. Applicable checks include tables, columns/types, constraints, functions, roles, extensions, RLS, policies, grants, ownership/security properties, and non-sensitive data invariants. Repository state never proves target environment state.

If any prerequisite differs, classify the attempt `PRESTATE_BLOCKED`, STOP, and do not execute or auto-repair. Conditional DDL must not bypass target drift.

Before execution, recompute SHA-256 over the exact SQL artifact bytes. The result must equal the AUTHORITY_ACCEPTED manifest checksum. A mismatch stops execution. Record the verified accepted checksum in the attempt evidence.

Each attempt records migration number, canonical filename, AUTHORITY_ACCEPTED commit, introducedCommit, execution source/release commit, accepted checksum, migration-specific validation reference, authorityVersion, and manifestSchemaVersion. These Git identities are audit metadata only; they do not prove execution.

## Staging protocol

The required sequence is:

`AUTHORITY_ACCEPTED` → staging target pre-state verified → explicit `STAGING_EXECUTION_AUTHORIZED` evidence → controlled direct-SQL execution of the locked artifact → staging post-state verification → applicable security verification → applicable safe data verification → complete evidence record → `APPLIED_CONFIRMED`.

Every required gate must pass before APPLIED_CONFIRMED. A failed gate preserves attempt evidence and prevents production eligibility.

## Production protocol

Production execution eligibility requires AUTHORITY_ACCEPTED, STAGING APPLIED_CONFIRMED for the same accepted SQL checksum, passing staging post-state verification, passing production TARGET_PRESTATE verification, rollback/recovery readiness, and explicit `PRODUCTION_EXECUTION_AUTHORIZED` evidence.

Only then may controlled direct-SQL execution occur, followed by production post-state and applicable security/data verification and a complete evidence record. Staging success never automatically executes production; production always needs separate explicit authorization.

## Controlled outcome classifications

- `PRESTATE_BLOCKED`: target prerequisites do not match and execution did not proceed.
- `EXECUTION_FAILED`: execution failed and evidence sufficiently establishes its resulting state classification.
- `STATE_UNCERTAIN`: partial effect may have occurred or target state cannot be reliably established.
- `POSTSTATE_FAILED`: execution reported success but a required post-state verification did not pass.
- `APPLIED_CONFIRMED`: identity, checksum, authorization, execution, post-state, security/data, and evidence gates all passed.

While STATE_UNCERTAIN, dependent migration execution, staging-to-production eligibility, and APPLIED_CONFIRMED claims are prohibited. A failed command does not by itself prove zero database effects.

## Transaction and recovery requirements

For a `TRANSACTIONAL` migration, record commit or rollback evidence; post-state verification remains mandatory. For `NON_TRANSACTIONAL_WITH_JUSTIFICATION`, require a pre-execution recovery plan, step-level evidence, partial-failure analysis, and heightened post-state verification. Failure may require STATE_UNCERTAIN.

MA-04 consumes, without redefining, MA-03 rollback classifications:

- `REVERSIBLE`: verified reverse procedure readiness.
- `FORWARD_FIX_ONLY`: documented corrective-forward recovery approach.
- `DATA_BACKUP_REQUIRED`: safe backup reference, completion evidence, and recovery-verification readiness before execution.
- `MANUAL_RECOVERY`: human-controlled recovery owner and procedure before execution.
- `IRREVERSIBLE`: explicit environment execution authorization acknowledging consequences.

Universal down migrations are not required.

## Target verification and evidence safety

Security-impacting migrations require applicable target verification. RLS may require enabled state, policies, policy expressions, grants, safe authorized and unauthorized behavior, owner/bypass posture, and FORCE RLS review. AUTHORIZATION requires positive and negative safe verification. ROLE_GRANT requires exact least-privilege grant/revoke verification. SECURITY_FUNCTION requires applicable owner, security mode, search_path, grants, behavior, and authorization checks. Never use real-user credentials as fixtures.

Data evidence may use non-sensitive counts, aggregates, schema-safe invariants, and sanitized verification summaries. Do not commit raw production PII, raw auth records, user credentials, or sensitive record dumps.

Repository evidence must never contain passwords, API keys, access tokens, database connection strings, session cookies, raw production PII, raw authentication records, secret-bearing command lines, or unsanitized errors. Record sanitized operation/method identifiers, status, safe error classification/summaries, hashes, non-sensitive counts/aggregates, and external non-secret evidence references only.

Execution evidence uses UTC ISO-8601 timestamps for actual environment events. Git timestamps do not replace execution timestamps. Record role-based `authorized_by`, `executed_by`, and `verified_by` fields. Separation of duties is recommended; the same person may hold multiple roles when staffing requires it, but accountability remains explicit.

## Evidence storage and attempt history

Applied-state evidence is stored under `docs/duta-v2.5/migrations/applied-state/` using `NNNN_<ENVIRONMENT>_ATTEMPT_NNN.md`. It is migration-specific, environment-specific, and attempt-specific. No evidence record is created by this protocol alone.

Failed attempts remain historical evidence. A later success must not overwrite or delete an earlier failure. Corrections create subsequent auditable evidence. For APPLIED_CONFIRMED attempts, migration identity, environment, attempt identity, checksum, execution result, and post-state result must not be silently rewritten.

## Multiple migrations and execution method

Forward migrations execute in governed dependency order. Required governed dependencies must be APPLIED_CONFIRMED in the same target where applicable; historical migration numbers alone never prove target state. Batch execution is only operationally possible if each migration retains independent evidence, dependency boundaries are checked, and processing fails closed between migrations.

Execution authority remains FORWARD_ONLY_DIRECT_SQL. Prefer execution of the locked SQL artifact directly. Copy/paste is discouraged because it can introduce artifact drift; any alternative must preserve verified exact accepted SQL intent and artifact integrity. `drizzle-kit migrate` is not historical replay authority. Automatic migrations during ordinary build, deploy, or application startup are prohibited. MA-04 establishes no CI/CD migration executor.

Do not use numeric `0000 → current` replay as an existing target execution procedure. Fresh-database historical authority remains NOT ESTABLISHED. Only specifically authorized forward migration(s) may execute after target pre-state verification.

MA-04 uses repository evidence only. It does not create `duta_migration_history` or any database-side applied-state table; such a ledger needs separate future migration/schema authorization.

## Sequencing boundary

MA-04 lock does not authorize access to staging or production. Every environment execution requires future explicit authorization for a specific migration. MA-04 also does not authorize `0039`. The locked sequence is MA-04 implementation and independent review/lock, then MA-05 preparation, implementation, and independent review/lock, then SR-01 / `0039` authoring.