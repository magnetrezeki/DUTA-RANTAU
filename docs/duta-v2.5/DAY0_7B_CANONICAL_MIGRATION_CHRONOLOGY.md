# Day 0.7B-1 — Proposed Canonical Migration Chronology

This is a logical proposal derived from current files, journal metadata, and reachable Git history. It is not a rename, replay, or deployment plan.

| Canonical step | Physical source | Logical purpose | Required predecessor | Confidence |
|---:|---|---|---|---|
| 1 | 0000 | Create base enums, core tables, foreign keys, and indexes | Empty compatible database | HIGH |
| 2 | 0001 | Add community and organisation operational tables | 0000 users/organisations/memberships | HIGH |
| 3 | 0002 | Add organisation operations and publication tables | 0000/0001 organisation and user objects | HIGH |
| 4 | 0003 | Add official office/contact/evidence tables | 0000 | HIGH |
| 5 | Historical 0004 | Identity-bridge/RLS predecessor indicated only by journal tag | Unknown SQL | LOW |
| 6 | Historical 0005 | Membership and organisation-registration domain | 0000 users/organisations; 0004 may be required by later policy layer | MEDIUM for historical existence, LOW for replay inclusion |
| 7 | Historical 0006 | Registration RLS and grants | 0005 plus identity functions | MEDIUM for historical existence, LOW for replay inclusion |
| 8 | Historical 0007 | Member face verification indicated only by journal tag | Unknown SQL | LOW |
| 9 | 0008 | Phase 4 content/audit RLS rollout | Base tables, restricted roles, identity functions | MEDIUM |
| 10 | 0009 | Organisation archival policy/function/trigger layer | Organisations, audit logs, roles | MEDIUM |
| 11 | 0010 | Create/restrict runtime database roles | Base schema | HIGH |
| 12 | 0011 | Create identity bridge functions and execution grants | 0010 and users/organisation members | HIGH |
| 13 | 0012–0017 | Apply least-privilege runtime grants and read policies | 0010/0011 and target tables | HIGH for dependency, MEDIUM for physical placement |
| 14 | 0018 | Add self-profile update boundary | 0010/0011/users | HIGH |
| 15 | 0019 | Historical audit self-insert policy | Audit logs and identity bridge | HIGH as historical step |
| 16 | 0020 | Harden audit constraints/policy | 0019 or equivalent audit policy state | HIGH |
| 17 | 0021 | Remove broad audit self-insert policy | 0019 | HIGH |
| 18 | 0022 | Account deletion function and execution grant | 0010/0011/users/audit logs | HIGH |

## Physical versus logical order

The physical sequence places `0008`/`0009` before `0010`/`0011`, although their policy expressions and grants rely on runtime-role and identity-function concepts. A future baseline must order prerequisites before consumers or explicitly prove existing deployment state. Missing `0004`/`0007` prevent a high-confidence complete chronology.

## Day 0.7B-2 empirical update

A fresh local physical-order replay passed `0000`–`0003` and failed first at `0008_phase4_real_content_rls.sql` because `duta_app` did not exist. The current creator is `0010_runtime_database_roles.sql`; identity functions used by the policy layer are created in `0011_runtime_identity_bridge.sql`. This upgrades the physical-order mismatch from static concern to observed evidence. Do not reorder files yet; use this evidence only to design a future isolated logical-order probe.

## Day 0.7B-3 logical-order evidence

The isolated order `0000 -> 0001 -> 0002 -> 0003 -> 0010 -> 0011 -> 0008 -> 0009` passed completely on a fresh disposable PostgreSQL database. This is evidence for a canonical baseline dependency order, not permission to rename legacy files or apply it to hosted systems. The candidate next logical files are `0012_runtime_role_grants.sql` and `0013_runtime_official_sources_rls.sql`.

`0012` passed after that foundation. `0013` requires Supabase-provided `anon` and `authenticated` roles in addition to its table dependency, so it cannot be validated unchanged on plain PostgreSQL without an explicitly modeled local role fixture. Treat it as a Supabase-environment-dependent step.

## Non-negotiable constraints for future repair

- Do not renumber current migrations or rewrite history.
- Do not restore 0004/0007 from guessed SQL.
- Do not replay the full current directory against hosted or non-empty databases.
- Treat policy drop/recreate and role/grant operations as high-risk until proved on a disposable local target.
- Record ledger status separately from deployed database state; repository history cannot prove hosted application order.
