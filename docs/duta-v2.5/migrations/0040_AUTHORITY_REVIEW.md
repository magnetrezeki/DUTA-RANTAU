# Migration 0040 — Independent Authority Review

| Field | Value |
| --- | --- |
| Migration | `0040_restrict_sensitive_table_default_acl.sql` |
| Review result | `PASS` |
| Authority decision | `AUTHORITY_ACCEPTED` |
| Commit A | `0b2f0e97007ba5647e9888a2d286a06b57c70f60` |
| Canonical SHA-256 | `b59dcfea09b1ebbc023783eff4e280e3e74bfe04bfe34a6d741a21839bbc4697` |
| Environment execution | `NOT AUTHORIZED / NOT PERFORMED` |

## Independent findings

The canonical SQL contains one transaction. It revokes privileges only from
`anon` and `authenticated` on the two named 0039 tables, then changes only
table defaults for owner `postgres` in schema `public` for those two roles.
It does not revoke from `service_role`, modify another existing object, or
touch data, schema structure, RLS, policies, functions, sequences, types,
schemas, another owner, or another schema.

Staging evidence showed both named tables owned by `postgres` with direct ACLs
materialized from matching `postgres`/`public` table defaults. `duta_app` and
`duta_system` have no sensitive-table privileges or membership path that
explains the provider grants. `service_role` is a provider administrative
`BYPASSRLS` role and is outside the prohibited role set in the accepted 0039
verifier. Preserving it is therefore intentional and does not weaken the
accepted contract.

## Failure and idempotence analysis

`BEGIN`/`COMMIT` makes the migration transactional. PostgreSQL `REVOKE` and
`ALTER DEFAULT PRIVILEGES ... REVOKE` are deterministic and succeed when an
expected privilege is already absent. This makes repeated local application a
safe no-op, but it does not authorize rerunning an environment migration or
permit target drift to be ignored.

A later staging precheck must fail closed unless it verifies all of the
following immediately before execution:

- target identity is project `bftdfvihtewjwotrzwwe`, database `postgres`;
- execution role is `postgres`, owns both tables, and owns the relevant
  schema-`public` table default ACL;
- both tables exist with the accepted 0039 structure, RLS enabled, FORCE off,
  zero policies, and zero governance/evidence rows;
- direct table ACLs are exactly the captured provider state for `postgres`,
  `anon`, `authenticated`, and `service_role`, with no additional grantee;
- `postgres`/`public` table defaults contain the corresponding grants, with no
  unexpected grantee;
- `duta_app` and `duta_system` remain ungranted on both tables;
- accepted 0039 `duta_app` source privileges and zero classified-source count
  remain unchanged;
- canonical 0040 bytes, authority metadata, and recovery evidence match.

Any mismatch is `PRESTATE_BLOCKED`; 0040 must not be used as an unconditional
repair for unknown drift.

## Secure-by-default rule

Future `postgres`-owned tables created in schema `public` do not receive
implicit `anon` or `authenticated` privileges after 0040. A public/API-facing
table must receive explicit least-privilege grants in its own governed
migration when access is intended. Provider defaults are not application
authorization. This is consistent with the repository's explicit RLS and
grant migrations and applies only within the exact owner/schema/object-class
boundary.

## Independent local verification

A clean disposable PostgreSQL 16.15 reproduction passed the committed 0040
fixtures and additional falsification checks. The review verified current
object correction, future-object behavior, `service_role` preservation,
restricted-role denial, RLS and zero-policy invariants, exact `duta_app`
source privileges, no data mutation, unrelated existing-table ACL
preservation, other-owner and other-schema default preservation, sequence and
function default preservation, successful repeat application, and a complete
reverse procedure. The disposable environments were removed.

## Recovery determination

`PRE_0040_RECOVERY_REQUIREMENT = EXISTING_RECOVERY_SUFFICIENT` under the MA-03
`REVERSIBLE` classification. 0040 changes ACL metadata only and the exact
reverse grants/default grants were verified locally. The historical pre-0039
logical archive remains available as broader recovery evidence, but it is not
the primary 0040 reverse mechanism. A fresh logical backup is not required by
the current protocol for this data-effect `NONE`, reversible correction.

A later execution gate must still capture fresh read-only post-0039/pre-0040
ACL evidence and name the recovery owner and reverse procedure. This authority
review neither creates a new backup nor authorizes recovery or execution.

## Authority boundary

This review accepts repository authority only. It does not authorize staging
execution, any remote `REVOKE`, any remote `ALTER DEFAULT PRIVILEGES`, migration
0039 rerun, deployment, Preview redeployment, push, merge, production access,
or production inspection.
