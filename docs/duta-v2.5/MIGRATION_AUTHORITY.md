# DUTA RANTAU v2.5 — Migration Authority

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | ACTIVE_FORWARD_AUTHORITY |
| AUTHORITY_VERSION | 1 |
| REPOSITORY_BASELINE_HEAD | `3602a09a3b85161eae45101eb8339c68591612ea` |
| REPOSITORY_BASELINE_TREE | `6676178a4a8c7131c2f95679303e33c8ed7a2305` |
| HISTORICAL_MIGRATION_CEILING | 0038 |
| FIRST_GOVERNED_FORWARD_MIGRATION | 0039 |
| AUTHORITY_MODEL | FORWARD_ONLY_DIRECT_SQL |
| LAST_REVIEW | 2026-09-16 |
| OWNER | Founder / Managing Director — interim repository governance owner |

## Purpose and scope

This document establishes the forward-only repository authority for database
migrations created after the declared repository baseline. It does not repair,
reconstruct, renumber, or validate the historical migration era.

The historical migration set is `0000` through `0038`. The first governed
forward migration number is `0039`. Reserving `0039` means only that it is the
next governed number: it does not mean that a `0039` file exists, has been
accepted, has been applied, or is production-approved.

## Three separate authorities

### Repository migration authority

Repository migration authority defines which future migration artifacts are
valid. It governs numbering, dependency declarations, checksums, immutability,
and validation requirements for governed direct-SQL migrations.

### Environment applied-state authority

Environment applied-state authority records what was actually executed in a
local, staging, or production environment. Repository presence and Git history
do not prove execution in any environment.

### Schema and security validation authority

Schema and security validation authority defines how resulting database
behavior is tested. It covers schema, constraints, functions, roles, grants,
RLS, policies, and security invariants.

These authorities are separate and must not be conflated.

## Historical migration policy

Migrations `0000` through `0038` are **FROZEN_HISTORICAL_EVIDENCE**. They are
not a complete replay authority.

Known forensic limitations include:

- The Drizzle journal ends at `0009`.
- Current physical migration files extend through `0038`.
- Historical physical files `0004` through `0007` are absent.
- Current files `0010` through `0038` are unjournaled.
- Full physical numeric replay is dependency-unsafe.
- Security and RLS behavior depends on unjournaled direct-SQL migrations.
- Historical fresh-database replay is not currently authoritative.

`FULL_HISTORICAL_REPLAY` is therefore `UNSUPPORTED`, and
`FRESH_DATABASE_AUTHORITY` is `NOT_ESTABLISHED`.

## Historical integrity and rewrite prohibition

Do not retroactively reconstruct the journal, renumber, rename, squash,
delete, or rewrite historical migration SQL. Do not claim journal completeness
or numeric replay completeness.

After a governed forward migration receives authority acceptance, its SQL is
immutable. A correction normally requires a new governed forward migration.

## Legacy journal policy

`db/migrations/meta/_journal.json` is **LEGACY_FROZEN_METADATA**. It remains
historical evidence, but is not complete current migration authority and is
not authoritative for migrations `0010` onward.

The legacy journal must not be modified, repaired, reconstructed, renumbered,
or receive `0039+` entries under this authority model. A separately authorized
migration-system redesign is required before that policy can change.

## Governed forward migration policy

Future governed direct-SQL migrations use monotonically increasing, unique
numbers: `0039`, `0040`, `0041`, and so on.

Each future migration must declare explicit prerequisites. They may include
migration prerequisites, tables, columns, functions, roles, extensions, and
security prerequisites. A future migration must not assume successful replay
of every historical migration.

Every future migration will receive a SHA-256 checksum over exact UTF-8 file
bytes, without newline normalization. Checksum implementation belongs to MA-02
and MA-05; MA-01 does not create or store future migration checksums.

Migrations affecting authorization, RLS, roles, grants, security functions, or
authentication-related database behavior require targeted security validation
before environment execution.

Every governed migration must declare one rollback or recovery classification:
`REVERSIBLE`, `FORWARD_FIX_ONLY`, `DATA_BACKUP_REQUIRED`, `MANUAL_RECOVERY`,
or `IRREVERSIBLE`. Generic DOWN migrations are not required.

## Acceptance lifecycle

The conceptual lifecycle is:

`PROPOSED` → `REVIEWED` → `AUTHORITY_ACCEPTED` → `LOCALLY_VALIDATED` →
`STAGING_AUTHORIZED` → `STAGING_APPLIED` → `STAGING_VERIFIED` →
`PRODUCTION_AUTHORIZED` → `PRODUCTION_APPLIED` → `PRODUCTION_VERIFIED`.

These states are separate. MA-01 does not implement a lifecycle ledger.
MA-02 and MA-04 will govern machine-readable manifest and environment
applied-state evidence.

## Local validation policy

Future migration validation uses isolated PostgreSQL only:

| Boundary | Requirement |
| --- | --- |
| Database | `duta_local_test` |
| Network | Loopback only |
| Credentials | Synthetic/local only |
| Remote database | Prohibited during local validation |
| Staging | Prohibited during local validation |
| Production | Prohibited during local validation |

Because full historical replay is unsupported, a target migration may use a
documented minimum pre-state fixture. A **TEST PRE-STATE FIXTURE** is not a
production schema snapshot. The detailed validation contract belongs to MA-03.

## Applied-state and environment execution policy

Repository migration presence does not prove local, staging, or production
application. Historical staging and production applied state remain
`UNKNOWN / EXTERNAL_STATE_REQUIRED`.

Staging execution requires explicit authorization, target-environment
verification, pre-state and dependency verification, checksum verification,
rollback or recovery preparation, post-state verification, and applied-state
evidence.

Production execution additionally requires successful staging validation,
separate production authorization, verified production pre-state, a locked
release commit and checksum, and rollback or backup approval. The detailed
execution protocol belongs to MA-04.

## Drizzle and TypeScript schema policy

`drizzle-kit migrate` must not be used to reconstruct the complete current
historical database under this authority model. `drizzle-kit generate` may
later be used only as schema-diff inspection assistance; generated SQL is not
automatically an accepted governed migration.

`db/schema.ts` is the application's TypeScript schema representation. It is
not the authoritative historical migration ledger. For a future governed
migration, `db/schema.ts` must be reviewed or updated where applicable, while
the governed direct-SQL migration is the authorized database delta. Detailed
drift controls belong to MA-03 and MA-05.

## Fresh database policy

Do not use `drizzle-kit migrate` or numeric replay of `0000` through `0038`
as a current fresh-database reconstruction method. Establishing fresh-database
authority is a separate future gate.
