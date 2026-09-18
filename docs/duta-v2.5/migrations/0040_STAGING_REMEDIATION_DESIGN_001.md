# Migration 0040 — Staging Security Remediation Design 001

## Forensic finding

Read-only staging inspection found both 0039 tables owned by `postgres` with
direct full-table ACL entries for `anon`, `authenticated`, and `service_role`.
The `postgres` role has matching default table ACLs scoped to schema `public`.
There is no membership path making `duta_app` or `duta_system` inherit these
grants; both roles remain ungranted on the sensitive tables.

Root cause is `PROVIDER_DEFAULT_ACL`: table creation by `postgres` materialized
the schema-`public` default table ACL on each new object. Remediation therefore
requires both existing-object ACL correction and future default-ACL
correction.

## Service-role classification

`SERVICE_ROLE_GRANT = ACCEPTED_PROVIDER_PRIVILEGE` for this proposal. The
accepted 0039 verifier expressly checks `duta_app`, `duta_system`, `anon`, and
`authenticated`; it does not prohibit `service_role`. Staging also identifies
`service_role` as `BYPASSRLS`, consistent with its provider administrative
role. This proposal does not broaden its access and does not remove a
provider-required privilege without separate evidence and authority.

## Proposed deterministic correction

Migration 0040 performs only these changes in one transaction:

1. revoke all table privileges from `anon` and `authenticated` on
   `public.official_source_governance` and
   `public.official_source_evidence`;
2. alter table default privileges for owner `postgres`, schema `public`, to
   revoke all future table privileges from `anon` and `authenticated`.

It does not change data, ownership, RLS, FORCE RLS, policies, sequences,
functions, other schemas, other owners, unrelated existing tables,
`service_role`, `duta_app`, or `duta_system`.

Future migrations creating intentionally public tables under this boundary
must include explicit least-privilege grants. This consequence is deliberate
and must be reviewed before authority acceptance.

## Required staging execution prerequisites

- independent review and local validation complete;
- Commit A provenance established;
- separate Commit B promotes 0040 to `AUTHORITY_ACCEPTED` with its exact-byte
  checksum and completed validation evidence;
- staging identity positively reverified as `bftdfvihtewjwotrzwwe`;
- current ACL/default-ACL prestate reverified without mutation;
- recovery readiness and explicit `0040 STAGING_EXECUTION_AUTHORIZED` evidence;
- no production access and no rerun of migration 0039.

## Required post-remediation verification

- no effective or direct table/column grants to `anon`, `authenticated`,
  `duta_app`, or `duta_system` on either sensitive table;
- preserved `service_role` provider ACLs;
- a transaction-scoped future table probe proves corrected `postgres`/public
  defaults, then rolls back;
- RLS enabled, FORCE off, zero policies;
- exact 0039 structure and narrowed `duta_app` source privileges unchanged;
- governance/evidence/classified-source counts remain zero;
- safe negative behavior checks for restricted roles;
- no unrelated existing-object ACL change.

Only after all required 0039 and 0040 poststate checks pass may a separate
attempt record classify the remediation `APPLIED_CONFIRMED` and close the 0039
security failure.
