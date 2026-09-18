# Migrations 0039 + 0040 — Staging Security Reconciliation 001

## Preserved history

`docs/duta-v2.5/migrations/applied-state/0039_STAGING_ATTEMPT_001.md` remains
immutable evidence that migration 0039 committed once but initially failed its
security poststate because provider default ACLs granted the new sensitive
tables to `anon` and `authenticated`. That failed attempt is not rewritten or
reclassified.

## Corrective-forward result

Authority-accepted migration 0040 committed exactly once on staging project
`bftdfvihtewjwotrzwwe`. Its applied-state evidence is
`docs/duta-v2.5/migrations/applied-state/0040_STAGING_ATTEMPT_001.md`.

Fresh poststate verification established:

- the accepted 0039 structure, enum values, foreign keys, RLS enabled/FORCE
  off, and zero-policy state remain intact;
- governance rows, evidence rows, and classified legacy-source rows remain
  zero;
- `postgres` ownership and `service_role` provider privileges are preserved;
- `anon` and `authenticated` have no current sensitive-table privileges and no
  future owner-`postgres`/schema-`public` table defaults;
- `duta_app` and `duta_system` remain denied on both sensitive tables;
- accepted `duta_app` privileges on `official_sources` remain unchanged;
- unrelated current-table and default ACL fingerprints are unchanged;
- no application data, schema structure, RLS policy, enum, or foreign key was
  mutated by 0040.

## Reconciled classification

- 0039 structural contract: `PASS`.
- 0039 initial attempt record: `POSTSTATE_FAILED` and preserved.
- 0040 corrective migration: `APPLIED_CONFIRMED`.
- Combined staging security contract: `SATISFIED`.
- Production eligibility: not established by this record.
- Preview redeployment and application smoke validation: still required and
  separately authorized.
- Production action, push, merge, deployment, and 0039 rerun: `NONE`.
