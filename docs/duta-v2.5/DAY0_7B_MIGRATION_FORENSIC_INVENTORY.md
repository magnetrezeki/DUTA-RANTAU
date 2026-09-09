# Day 0.7B-1 — Migration Forensic Inventory

Date: 2026-09-09. Repository and Git-history evidence only; no SQL was executed and no hosted database was accessed.

## Current inventory

Only `db/migrations` exists. Current HEAD has 19 SQL files: `0000`–`0003`, `0008`–`0022`. The journal records ten tags: `0000`–`0009`; six of those tags have current files (`0000`–`0003`, `0008`, `0009`). Therefore current classification is **6 JOURNALED, 13 UNJOURNALED, 0 UNKNOWN**. The earlier finding of 13 unjournaled current files is confirmed.

| Range | Files | Primary category | Major objects / dependency | Replay risk |
|---|---:|---|---|---|
| 0000 | 1 | SCHEMA, TABLE, TYPE, INDEX | Base enums; users, organisations, memberships, content, jobs, audit, sources and related FKs | HIGH: foundational non-idempotent DDL |
| 0001 | 1 | TABLE, INDEX | Communities, notifications, organisation documents/letters/meetings, payments; depends on 0000 | HIGH: non-idempotent DDL |
| 0002 | 1 | TABLE, INDEX | Meeting, attendance, branches, subscription/payment/task/publication objects; depends on 0000/0001 | HIGH: non-idempotent DDL |
| 0003 | 1 | TABLE, INDEX | Official offices, contacts, evidence; depends on 0000 | HIGH: non-idempotent DDL |
| 0008–0009 | 2 | RLS, POLICY, GRANT, FUNCTION, TRIGGER | Phase 4 content, audit and organisation-archival policies; depends on base tables, roles and identity functions | HIGH: policy replacement, grants, trigger/function changes |
| 0010–0011 | 2 | GRANT, FUNCTION | Restricted roles and identity bridge functions; must precede runtime grants/policies | HIGH: role ownership/privilege assumptions |
| 0012–0017 | 6 | GRANT, POLICY | Least-privilege runtime reads for sources, users, jobs/products/communities/sellers; depends on 0010/0011 and respective tables | MEDIUM/HIGH: duplicate policy/grant state |
| 0018–0022 | 5 | GRANT, POLICY, FUNCTION | User self-update, audit insert hardening/removal, account deletion function; depends on 0010/0011, users and audit tables | HIGH: security-policy supersession and auth assumptions |

## Missing-number analysis

| Identifier | Classification | Evidence | Relationship / ambiguity |
|---|---|---|---|
| 0004 | NEVER_FOUND | Journal tag `0004_phase1a_identity_bridge_rls` exists; no file appeared in any reachable Git tree or path history. | Purpose is suggested by its tag only. SQL and exact objects are unavailable. |
| 0005 | BRANCH_ONLY | `0005_membership_organization_registration.sql` first appeared in reachable commit `bc09aaf` on 2026-08-29; absent at current HEAD. | Defines member-registration enums/tables and adds organisation application fields. No deletion event is present in current branch path history; current branch does not prove it was deployed or replaced. |
| 0006 | BRANCH_ONLY | `0006_membership_organization_registration_rls.sql` first appeared with 0005 in `bc09aaf`; absent at current HEAD. | Adds grants/RLS/policies for those membership-registration objects and references identity helpers. It depends on 0005 and likely the unavailable 0004 functionality. |
| 0007 | NEVER_FOUND | Journal tag `0007_member_face_verification` exists; no file appeared in any reachable Git tree or path history. | Tag suggests a member-verification feature, but SQL and supersession cannot be established. |

The expected count of 23 derives from the numeric range `0000` through `0022`, not from 23 extant files. It is not evidence that all 23 migrations were applied anywhere.

## Journal and history evidence

- `0000`/`0001` first appeared in `f46d91f` (2026-08-16); `0002`/`0003` in `de2f1e1` (2026-08-17).
- Historical `0005`/`0006` and snapshot/journal updates appeared in `bc09aaf` (2026-08-29).
- `0008`–`0013` plus journal changes appeared in `474179b` (2026-09-04); `0014`–`0022` then appeared as successive runtime-security changes through `235911a` (2026-09-05).
- No reachable historical migration SQL exists for `0004` or `0007`.

## Dependencies and supersession

Physical numeric order does not fully demonstrate logical order. `0010` role lockdown must precede `0012`–`0018` grants/policies; `0011` identity functions must precede policies that call them. `0019` adds `audit_logs_self_insert`, `0020` replaces `audit_user_insert` with hardened conditions, and `0021` removes the broad `0019` policy: this is a **SUPERSEDES** chain. `0008`/`0009` also drop/recreate named policies and functions, creating replay collision risk.

`0005`/`0006` are not proven copied into current files. Their objects overlap the broader membership/organisation domain, but repository evidence is insufficient to call them replaced or squashed.

## Repair options

| Option | Production risk | Staging risk | Local replay safety | Auditability | Maintainability |
|---|---|---|---|---|---|
| Restore missing historical files | HIGH | HIGH | LOW | Medium | Low |
| New-environment baseline/squash migration | Medium | Medium | Medium after proof | High | High |
| Preserve files and add a migration ledger | LOW | LOW | HIGH | High | Medium |
| Renumber current migrations | HIGH | HIGH | LOW | Low | Low |
| Rebuild history from canonical schema | HIGH | HIGH | LOW | Medium | Medium |

Recommended direction: preserve current files, create a non-destructive migration ledger, then design a new-environment baseline only after a local disposable replay experiment proves the intended canonical schema. Do not renumber or restore unknown SQL.

## Next safe validation

Create a separately authorized local-only experiment that replays a selected, documented chronology into a fresh disposable PostgreSQL target, with stop conditions for missing 0004/0007 dependencies, duplicate policy/function errors, privilege/RLS weakening, data assumptions, or any mismatch with the minimal tested schema. Do not involve hosted databases.
