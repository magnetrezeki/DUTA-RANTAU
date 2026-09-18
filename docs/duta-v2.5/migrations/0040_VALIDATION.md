# 0040 Sensitive Table Default ACL Remediation — Validation Record

| Field | Value |
| --- | --- |
| Migration | `0040_restrict_sensitive_table_default_acl.sql` |
| Repository lifecycle | `PROPOSED` |
| Validation status | `PENDING_MA03` |
| Data effect | `NONE` |
| Schema effect | `NONE` |
| Security effects | `AUTHORIZATION` |
| Rollback classification | `REVERSIBLE` |

## Purpose

Correct the provider default-ACL inheritance observed after staging migration
0039. Remove privileges for `anon` and `authenticated` from the two sensitive
0039 tables and from future table defaults owned by `postgres` in schema
`public`. Preserve `service_role`, RLS, policies, data, and existing runtime
application grants.

## Declared pre-state

- Migration 0039 is structurally committed.
- Both sensitive tables are owned by `postgres`, have RLS enabled and FORCE
  disabled, and have zero policies.
- Direct full-table grants exist for `anon`, `authenticated`, and
  `service_role` because `postgres` has matching table defaults in schema
  `public`.
- `duta_app` and `duta_system` have no privileges on the sensitive tables.
- The narrowed 0039 `duta_app` privileges on `official_sources` are intact.

## Declared post-state

- `anon` and `authenticated` have no privileges on either sensitive table.
- Future tables created by `postgres` in schema `public` do not inherit table
  privileges for `anon` or `authenticated`.
- `service_role` provider privileges remain unchanged.
- RLS, FORCE, policy inventories, runtime-role restrictions, and data remain
  unchanged.

## Governance consequence

Changing `postgres` table defaults in schema `public` affects every future
table created in that exact owner/schema boundary. A future public-facing
migration must explicitly grant the minimum intended privileges to `anon` or
`authenticated`; implicit provider defaults are no longer accepted as
authorization. Defaults for sequences and functions, other owners, and other
schemas remain unchanged.

## Local validation contract

Use only a disposable PostgreSQL database with synthetic objects:

- `tests/db/migrations/0040/prestate.sql`
- `tests/db/migrations/0040/verify.sql`
- `tests/db/migrations/0040/security-verify.sql`

Verify current-object revokes, future default behavior, preserved
`service_role`, unchanged RLS/policies, unchanged `duta_app` source
privileges, negative access for restricted roles, zero data mutation, and no
unrelated ACL change.

## Authority and environment disclaimer

This is a Commit A proposal scaffold. Its manifest checksum and
`introducedCommit` remain null until independent validation and a separate
Commit B authority decision. It authorizes no staging or production SQL and
does not change the classification of staging attempt 0039.

## Proposal-stage local evidence

The synthetic provider-style default ACL was reproduced and the proposed
correction was applied in a disposable PostgreSQL 16.15 container at
`2026-09-17T23:35:02.8286969Z`. No host port, remote connection, staging data,
or production data was used. The container used tmpfs database storage and was
removed after validation.

- Image: `postgres:16-alpine`.
- Image identity:
  `sha256:cf78e76683b9ca8c5733cbbdce6c9262b45b6767934dd0a95e671f9a0fc20685`.
- Migration SHA-256:
  `b59dcfea09b1ebbc023783eff4e280e3e74bfe04bfe34a6d741a21839bbc4697`.
- Prestate SHA-256:
  `5cc08e664852f72eff16e99328b48942f45b282d6c85b6364809a0dc3b89ccfe`.
- Verify SHA-256:
  `7a1fba95a657367ce4e85e73e188d3c05e54ffda9bbbff47966516dc4afe64bd`.
- Security verify SHA-256:
  `1f3ba77d7f4e291818afb67bd3814a68690973c2d83dfc4f7790b60007f4e9c6`.

| Phase | Result |
| --- | --- |
| Provider-style default ACL reproduction | `PASS` |
| Existing sensitive-table revokes | `PASS` |
| Future table default-ACL probe | `PASS` |
| service_role preservation | `PASS` |
| RLS / FORCE / policy preservation | `PASS` |
| duta_app official_sources privilege preservation | `PASS` |
| Restricted-role negative behavior | `PASS` |
| Zero data mutation | `PASS` |
| Migration authority guard | `PASS (historical=35, forward=2)` |
| Repository enforcement tests | `PASS (13/13)` |

This is proposal-stage validation, not independent review or authority
acceptance. Provider-specific staging semantics still require post-apply
verification if a later gate authorizes execution.
