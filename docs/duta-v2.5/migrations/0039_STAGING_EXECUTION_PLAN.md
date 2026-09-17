# Migration 0039 — Staging Execution Plan

| Field | Value |
| --- | --- |
| Plan status | `READY_FOR_STAGING_EXECUTION_AUTHORIZATION` |
| Environment | `STAGING` |
| Execution performed | `NO` |
| Authority model | `FORWARD_ONLY_DIRECT_SQL` |
| Migration | `0039_source_registry_governance_foundation.sql` |
| Commit A | `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5` |
| Commit B | `de03e6abcb4b5c14c1cf20dd4a7f7940dfbddd84` |
| Accepted checksum | `sha256:5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30` |
| Validation reference | `docs/duta-v2.5/migrations/0039_VALIDATION.md` |

This plan prepares a future authorized staging attempt. It is not staging
authorization and records no environment applied state.

## Required identities and roles

- The target must be explicitly identified as the approved DUTA RANTAU v2.5
  staging PostgreSQL database. Host/project/database identifiers must be
  checked out of band without recording connection strings or secrets.
- `authorized_by`, `executed_by`, and `verified_by` must be named in the future
  applied-state record.
- The execution role must be the approved staging migration owner or equivalent
  DDL role. It must not be `duta_app`, `duta_system`, `anon`, or `authenticated`.
- Runtime verification role names are `duta_app`, `duta_system`, `anon`, and
  `authenticated`. No credential values belong in repository evidence.

## Pre-execution gates

1. Check out the exact approved execution source commit and require a clean
   tracked worktree and empty index.
2. Run `node scripts/check-migration-authority.mjs`; require
   `PASS (historical=35, forward=1)`.
3. Recompute the canonical file's exact-byte SHA-256 and require equality with
   the accepted checksum above.
4. Verify target identity is staging and explicitly prove it is not production.
5. Obtain migration-specific `STAGING_EXECUTION_AUTHORIZED` evidence.
6. Record a current recoverable snapshot/backup and named recovery owner.
7. Verify the declared target prestate without mutation: `pgcrypto`; roles
   `duta_app` and `duta_system`; `public.users(id uuid)`; the accepted
   `public.official_sources` columns, indexes, RLS, policies, and grants; and
   absence of both new enums, both new tables, and `source_purpose`.

Any identity, checksum, authorization, backup, or prestate mismatch is
`PRESTATE_BLOCKED`. Stop without execution or target auto-repair. The local
synthetic `prestate.sql` must never be run against staging.

## Controlled execution

Use an approved PostgreSQL client session bound to the verified staging target.
Execute the locked canonical artifact directly with client startup files
disabled and stop-on-error enabled. Do not use `drizzle-kit migrate`, automatic
build/startup migration, copy/paste, numeric historical replay, or an
unverified generic `DATABASE_URL`.

Record sanitized UTC timestamps and the transaction result. The artifact is
transactional (`BEGIN`/`COMMIT`). An error before confirmed commit is not proof
of zero effects; inspect the target and classify the attempt under MA-04.

## Required poststate verification

- Verify exact enums, column nullability/default, tables, defaults, checks,
  uniqueness, and foreign-key actions in the accepted validation contract.
- Verify RLS is enabled on both new tables, FORCE RLS remains off, and no policy
  or application grant exposes either table.
- Verify duta_app has INSERT only on the nine approved legacy columns, UPDATE
  only on `active`, `priority`, and `trust_level`, and no purpose write.
- Verify existing source rows remain unclassified and no governance/evidence
  rows were automatically created, using non-sensitive counts only.
- Run approved behavior checks with dedicated synthetic staging identities:
  allowed legacy behavior and denied purpose/governance/evidence behavior.
- Run the application smoke plan in `STAGING_RELEASE_READINESS.md`.

The repository's local `verify.sql` and `security-verify.sql` contain synthetic
fixture identifiers. They are local evidence, not staging scripts.

## Evidence and outcomes

Create `docs/duta-v2.5/migrations/applied-state/0039_STAGING_ATTEMPT_NNN.md`
from `MIGRATION_APPLIED_STATE_TEMPLATE.md`. Record only sanitized identities,
hashes, role names, timestamps, safe counts, outcomes, and references.

Allowed outcomes are `PRESTATE_BLOCKED`, `EXECUTION_FAILED`, `STATE_UNCERTAIN`,
`POSTSTATE_FAILED`, or `APPLIED_CONFIRMED`. Preserve failed attempts.
`STATE_UNCERTAIN` and any failed gate prohibit production eligibility.

No production action is permitted. Production requires staging
`APPLIED_CONFIRMED` for the same checksum plus separate prestate, recovery, and
`PRODUCTION_EXECUTION_AUTHORIZED` evidence.
