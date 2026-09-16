# DUTA RANTAU v2.5 — MA-03 Migration Validation Contract

| Field | Value |
| --- | --- |
| DOCUMENT | MA-03 Migration Validation Contract |
| DOCUMENT_STATUS | ACTIVE_VALIDATION_CONTRACT |
| AUTHORITY_MODEL | FORWARD_ONLY_DIRECT_SQL |
| SCOPE | Governed forward migrations `0039+` |
| HISTORICAL_MIGRATIONS | `0000`–`0038` are FROZEN_HISTORICAL_EVIDENCE |

## Authority boundary

This is the normative repository validation and authoring contract for
governed direct-SQL migrations beginning with `0039`. It does not establish
historical replay authority, fresh database authority, environment applied
state, staging execution, production execution, or deployment authority.

MA-01 defines the authority model and historical boundary. MA-02 defines the
manifest schema, historical mutation detection, and basic forward-entry
validation. MA-03 defines migration-specific authoring, dependencies,
pre-state and post-state, validation, and authority acceptance. MA-04 owns
environment execution and applied-state evidence. MA-05 will own
repository-wide static/global enforcement. These responsibilities do not
create competing sources of truth.

`0038` is the historical ceiling; `0039` is reserved as the first governed
forward migration number. Reserving `0039` does not assert that it has been
authored, proposed, reviewed, accepted, locally tested, applied, or deployed.
`LEGACY_FROZEN_METADATA` remains the policy for the legacy journal.

## Repository lifecycle

The only repository-authority statuses are `PROPOSED`, `REVIEWED`,
`AUTHORITY_ACCEPTED`, and `SUPERSEDED`. They never state local, staging, or
production application.

`PROPOSED` → `REVIEWED` requires an SQL/proposed artifact, purpose,
dependency declaration, declared pre-state, impact classifications,
rollback/recovery plan, validation plan, and review evidence.

`REVIEWED` → `AUTHORITY_ACCEPTED` requires the exact SQL artifact, its
exact-byte checksum, a valid `introducedCommit`, complete dependency metadata,
schema/security/data classifications, an RLS decision, rollback classification,
completed migration-specific validation evidence, a non-pending validation
reference, and complete manifest metadata.

`AUTHORITY_ACCEPTED` → `SUPERSEDED` requires a reason and, where applicable,
successor or corrective evidence. SUPERSEDED preserves accepted SQL and all
acceptance-grade metadata.

AUTHORITY_ACCEPTED is the immutability point. Do not silently alter number,
filename, SQL bytes, purpose, dependencies, checksum, introducedCommit,
schemaEffect, securityEffects, requiresRlsValidation, requiresDataBackfill,
dataEffect, rollback classification, or validation reference. Schema,
security, or data corrections require a new governed forward migration.
Documentation-only corrections may use an auditable evidence revision without
changing SQL authority semantics.

## Required two-commit provenance model

The two-commit model is REQUIRED for governed migrations.

Commit A introduces the canonical SQL artifact, PROPOSED manifest metadata,
and applicable migration-specific validation plan or evidence scaffold. It
MUST NOT mark the migration AUTHORITY_ACCEPTED. Commit B occurs only after
required validation and records AUTHORITY_ACCEPTED, the exact checksum, a
completed validation reference, complete acceptance metadata, and
introducedCommit pointing to Commit A.

For `0039+`, introducedCommit means the earliest non-merge commit reachable
from the authority-acceptance lineage that adds the canonical governed SQL
path. It is SQL artifact provenance only, not an authority-acceptance,
deployment, staging-execution, or production-execution commit. The referenced
commit must exist locally, be non-merge, add the canonical path, and be the
unique introduction event for that path. A later commit that merely contains
the file is insufficient. Rename-based provenance is rejected and path reuse
is prohibited. Historical `0000`–`0038` files are exempt from retrospective
introducedCommit reconstruction.

MA-03 defines these semantics; MA-05 will enforce them repository-wide. A
future implementation may use `git log --follow --diff-filter=A -- <path>`
and parent/root-diff verification, but command output is not authority.

## Dependencies and declared pre-state

The locked manifest structure is `dependsOn.migrations`, `.tables`, `.columns`,
`.functions`, `.roles`, `.extensions`, and `.security`. Every value is a
non-empty declaration relevant to the migration.

Governed migration numbers can be supplementary dependency evidence, but a
migration number never replaces actual object or security preconditions. For
historical `0000`–`0038`, a number alone is insufficient evidence and target
state must never be inferred from numbering.

Use schema-qualified tables (`schema.table`) and columns
(`schema.table.column`) where applicable. Functions use a schema-qualified
name and include a signature when overload ambiguity exists. Roles and
extensions use their exact PostgreSQL names. Security declarations state
required RLS state, policy, grant/revoke posture, role, security function, or
ownership/security property; they are declared preconditions, not environment
applied-state evidence.

Three concepts remain separate:

- DECLARED_PRESTATE is this repository contract of required conditions.
- LOCAL_PRESTATE is a synthetic isolated fixture used for local validation.
- TARGET_PRESTATE is actual staging or production evidence, owned by MA-04.

Applicable declared pre-state covers tables, columns, types, nullability and
defaults, constraints, functions/signatures, roles, extensions, RLS state,
policies, grants/revokes, data invariants, and conflicting-object absence.
The migration-specific validation record makes each category explicitly
applicable or not applicable.

## Post-state and local validation

Local post-state validation checks applicable objects, columns, types,
defaults, nullability, constraints, indexes, functions and security
properties, RLS state, policies and behavior, roles/grants, and data
invariants. Object existence alone is insufficient for security-impacting
migrations.

Local validation uses isolated PostgreSQL database `duta_local_test` with
synthetic data only. Production dumps, staging dumps, real user data,
production auth users, and remote credentials are prohibited. Full historical
replay is UNSUPPORTED. Successful migration-specific local validation does not
establish `0000`–`0038` replayability, complete historical chronology, fresh
database bootstrap authority, staging applied state, or production applied
state.

The existing `tests/db/bootstrap-local-test.sql`, `tests/db/seed-local-test.sql`,
`tests/db/verify-local-test.sql`, and `scripts/run-local-db-tests.ps1` harness
is REUSABLE_WITH_MIGRATION_SPECIFIC_PRESTATE, not full historical bootstrap
authority. Future artifacts use:

- `tests/db/migrations/NNNN/prestate.sql`
- `tests/db/migrations/NNNN/verify.sql`
- `tests/db/migrations/NNNN/security-verify.sql` when security validation applies
- `tests/db/migrations/NNNN/seed.sql` when representative data is needed
- `docs/duta-v2.5/migrations/NNNN_VALIDATION.md` for validation result evidence

Schema-only work needs prestate plus verify. Security-impacting work additionally
needs security-verify with negative/adversarial behavior. Data effects need
synthetic seed data where needed and data-invariant verification. Mixed work
combines each applicable evidence category.

## Security validation

For RLS effects, validate applicable RLS enabled/disabled state, policy
inventory and expressions, authorized access, unauthorized denial,
owner/bypass considerations, role behavior, and FORCE RLS decision. Negative
or adversarial validation is mandatory.

AUTHORIZATION requires positive authorized and negative unauthorized cases.
ROLE_GRANT requires exact grant/revoke delta, intended role/object, least
privilege, and a negative privilege assertion where relevant. SECURITY_FUNCTION
requires relevant owner, SECURITY DEFINER/SECURITY INVOKER expectation,
search_path safety, execute grants, input/output, and authorization checks.
AUTHENTICATION validation is limited to database-facing behavior; external
provider/runtime authentication is not proven by this contract. MULTIPLE
requires every relevant category-specific validation and cannot reduce depth.

## Data, schema, and operational validation

Data effects are `NONE`, `BACKFILL`, `TRANSFORM`, `DELETE`, or `MIXED`.
NONE expects no data mutation and detects unexpected mutation where practical.
BACKFILL requires representative synthetic rows, completeness, null/edge cases,
post-state invariants, an explicit idempotency decision, and partial-failure
consideration. TRANSFORM requires representative before/after states,
invariants, and partial-failure consideration. DELETE requires explicit
destructive acknowledgement, affected-data definition, recovery/backup
classification, and partial-failure consideration. MIXED combines evidence
for each actual effect.

Schema effects are `NONE`, `ADDITIVE`, `ALTERING`, `DESTRUCTIVE`, or `MIXED`.
ADDITIVE requires collision, compatibility, default/nullability, constraint,
and index review where applicable. ALTERING requires compatibility, lock or
rewrite risk, dependent-object, and data-preservation review. DESTRUCTIVE
requires heightened recovery, compatibility, and rollback review. Migration
design explicitly considers table locking, rewrites, index construction,
long-running transactions, large-table effects, batching, and blocking where
applicable; this is not target-execution approval.

Every migration declares an IDEMPOTENCY_DECISION. Conditional DDL such as
IF EXISTS or IF NOT EXISTS must not hide unexpected pre-state; use it only
with a deliberate documented justification. Every migration also declares
TRANSACTIONAL or NON_TRANSACTIONAL_WITH_JUSTIFICATION.

## Rollback and validation evidence

Rollback classifications are `REVERSIBLE` (a verified reverse procedure),
`FORWARD_FIX_ONLY` (later governed correction), `DATA_BACKUP_REQUIRED`
(verified recovery evidence before target execution), `MANUAL_RECOVERY`
(human-controlled steps and ownership), and `IRREVERSIBLE` (explicitly
acknowledged consequences). `DOWN_MIGRATION_REQUIRED: NO`; recovery reflects
actual risk rather than fabricated reverse SQL.

The validation contract defines what must be tested. A validation result is the
migration-specific evidence that it passed. The global contract is this file;
the result record is `docs/duta-v2.5/migrations/NNNN_VALIDATION.md`. For a
future AUTHORITY_ACCEPTED entry, `validationContract.reference` must point to
that migration-specific record. This does not change the MA-02 manifest schema.

AUTHORITY_ACCEPTED is repository authority only. It does not mean local
execution, staging execution, production execution, or deployment. MA-04
governs target pre-state and environment execution evidence.
