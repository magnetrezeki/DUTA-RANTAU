# Migration 0040 — Staging Attempt 001

| Field | Value |
| --- | --- |
| DOCUMENT_STATUS | `FINAL_ATTEMPT_EVIDENCE` |
| RECORD_TYPE | `STAGING_APPLIED_STATE_EVIDENCE` |
| AUTHORITY_MODEL | `FORWARD_ONLY_DIRECT_SQL` |
| Environment | `STAGING` |
| Project ref | `bftdfvihtewjwotrzwwe` |
| Database | `postgres` |
| PostgreSQL | `17.6` |
| Final classification | `APPLIED_CONFIRMED` |
| Production action | `NONE` |

## Migration identity and repository authority

- Migration: `0040_restrict_sensitive_table_default_acl.sql`.
- Attempt: `ATTEMPT_001`.
- Commit A / introducedCommit:
  `0b2f0e97007ba5647e9888a2d286a06b57c70f60`.
- Commit B / execution source:
  `d11d6a2ff3aec0b629489cfaae3ddda2e98f9a48`.
- Authority lifecycle: `AUTHORITY_ACCEPTED`.
- Authority guard: `PASS (historical=35, forward=2)`.
- Canonical exact-byte SHA-256:
  `b59dcfea09b1ebbc023783eff4e280e3e74bfe04bfe34a6d741a21839bbc4697`.
- Execution source: no working-tree content diff and empty index.

## Recovery readiness

- Recovery classification: `REVERSIBLE`.
- Recovery owner: `DUTA RANTAU PROJECT OWNER`.
- Historical logical recovery reference:
  `pre0039-20260917T210413Z/staging-pre0039.dump`.
- Recovery archive SHA-256:
  `4fd84716c3ad02fa354c58008c1ea99d98d5d38c2d172663556606ad4f335906`.
- Recovery archive size: `545194` bytes.
- 0040 reverse procedure: documented and locally verified in
  `docs/duta-v2.5/migrations/0040_AUTHORITY_REVIEW.md`.
- Result: `PASS`.

## Fresh target prestate

The approved staging credential was positively bound to project
`bftdfvihtewjwotrzwwe`; production ref `uokljxqqvpujwmubildy` was absent. The
database session reported database `postgres`, current user `postgres`, and
PostgreSQL `17.6`.

The accepted 0039 structure, enums, foreign-key actions, RLS enabled/FORCE off,
zero policies, and narrowed `duta_app` privileges all passed. Governance rows,
evidence rows, and classified legacy source rows were each zero.

Both sensitive tables were owned by `postgres` and had exactly the expected
provider ACL grantees: `postgres`, `anon`, `authenticated`, and `service_role`.
The `postgres`/schema-`public` table default ACL had exactly the same grantee
set. `duta_app` and `duta_system` had no effective sensitive-table privileges;
there were no unexpected current or default grantees.

- Pre-execution 0040 state: `KNOWN_NOT_APPLIED`.
- Target prestate result: `PASS`.

## Execution result

- Authorization: explicit user authorization for this project, Commit B, and
  checksum in the controlling session.
- authorized_by: `DUTA RANTAU PROJECT OWNER`.
- executed_by: `CODEX OPERATOR`.
- Method: PostgreSQL 17.6 client, startup files disabled, stop-on-error,
  canonical file mounted read-only, no image pull.
- Transaction classification: `TRANSACTIONAL`.
- started_at_utc: `2026-09-18T01:08:16.6818381Z`.
- completed_at_utc: `2026-09-18T01:08:19.6294818Z`.
- Server result: `BEGIN`, `REVOKE`, `ALTER DEFAULT PRIVILEGES`, `COMMIT`.
- Client exit: `0`.
- Execution count: `1`.
- Retry: `NONE`.

## Poststate verification

Both sensitive tables retain owner `postgres` and direct ACLs only for
`postgres` and `service_role`. `anon`, `authenticated`, `duta_app`, and
`duta_system` have no direct or effective table privileges. There are no
unexpected grantees.

The owner-`postgres`, schema-`public`, table default ACL retains only `postgres`
and `service_role`; `anon` and `authenticated` are absent. PostgreSQL 17's
`MAINTAIN` privilege was included in the ACL expansion. Sequence and function
defaults remain unchanged.

- `service_role` provider privileges: `PRESERVED`.
- RLS enabled / FORCE off: `PASS`.
- Policies: `0` on both tables.
- Governance/evidence/classified-source counts: `0 / 0 / 0`.
- 0039 enum and foreign-key invariants: `PASS`.
- Accepted `duta_app` official-source table/column privileges: `PASS`.
- `anon` and `authenticated` read-only behavior checks: denied.
- Staging `duta_app` official-source read: allowed.
- Staging `duta_app` sensitive-table reads: denied.
- `duta_system` effective sensitive-table privilege check: denied.

The unrelated existing-table ACL fingerprint remained
`df5e48a7eea428bc26edfc6ed450176e`. The unrelated default-ACL fingerprint
remained `08c5ac20983e2892492b9b18de961962`. Result: no unrelated ACL regression.

## Applied-state classification

- Schema/security/data poststate: `PASS`.
- Final classification: `APPLIED_CONFIRMED`.
- Staging migration execution state: committed exactly once.
- 0039 rerun: `NO`.
- Preview redeployment: `NOT PERFORMED`.
- Push/deployment/production action: `NONE`.

## Secret / PII disclaimer

No password, token, connection string, session cookie, raw authentication
record, PII, or secret-bearing output is present in this evidence.
