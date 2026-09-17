# DUTA RANTAU v2.5 — Staging Release Readiness

| Field | Value |
| --- | --- |
| Assessment date | `2026-09-18` |
| Baseline | `58c706034a8c9f76f955e7e644b7527e2eb12fa6` (`DAY0_FINAL_DEVELOPMENT_SIGNOFF`) |
| Candidate branch | `duta-v2.5` |
| Candidate classification | `STAGING_READY_FOR_HUMAN_GATE` |
| Remote actions | `NONE` |
| Staging actions | `NONE` |
| Production actions | `NONE` |

## Local release evidence

- Migration guard: `PASS (historical=35, forward=1)`.
- Migration 0039: `AUTHORITY_ACCEPTED`; Commit A
  `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5`; Commit B
  `de03e6abcb4b5c14c1cf20dd4a7f7940dfbddd84`; accepted SHA-256
  `5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30`.
- Clean isolated migration/structural/security validation: `PASS` on PostgreSQL
  16.15 using the existing local `postgres:16-alpine` image.
- Lint: `PASS`. TypeScript: `PASS`.
- Production build: `PASS`, including 40/40 static pages.
- MA-05 repository enforcement: `13/13 PASS` under the threads pool.
- Database-backed source and AI-router tests: `16/16 PASS` against a fresh
  disposable local database with synthetic data and restricted `duta_app`.
- The whole suite without its required APP database produced six expected
  environment failures; those cases pass with the refreshed local harness.
  One MA-05 case timed out only under whole-suite contention and passed in the
  dedicated MA-05 run.

## Release delta from the last development signoff

The candidate was 58 commits ahead of the Day 0 development signoff before
this readiness work. The inspected delta contained 167 changed paths, about
7,285 insertions and 270 deletions.

- Application: password recovery, safer public/admin routes, source-aware AI,
  official-job discovery, and fail-closed unavailable states.
- Database: additive migrations 0023–0039; 0039 is the first governed forward
  migration. Historical 0000–0038 remain frozen evidence.
- Security: runtime identity helpers, core RLS, admin RBAC, eligibility,
  moderation, and source-governance least privilege.
- Governance/regulatory: privacy records, free consumer access, jobs
  discovery-only, finance referral-only, marketplace containment, private
  moderator-first reports, 18+ launch, and deferred regulated modules.
- AI: quota, telemetry, routing/adapters, source ranking, tools, ASR/TTS
  foundations, and source-required fail-closed behavior.
- Testing/infrastructure: migration authority and validation enforcement,
  local database harnesses, security regressions, and build checks.
- Documentation: operational, migration, privacy, activation, and readiness
  records; these do not prove external environment state.

## Application staging smoke plan

Use approved staging configuration and synthetic accounts/data only.

1. Verify the release identity matches the authorized candidate.
2. Confirm browser configuration contains only staging-safe publishable values;
   database, admin, and provider credentials remain server-only.
3. Confirm authentication, registration, password recovery, logout, and
   suspended-user behavior.
4. Confirm active official-source reads, hidden inactive sources, denied
   duta_app purpose writes, and inaccessible governance/evidence tables.
5. Keep DUTA AI disabled unless separately activated. If authorized, confirm
   source-required fail-closed behavior, the 30-unit UTC quota, and that AI
   cannot grant roles, badges, eligibility, or regulated authority.
6. Confirm jobs remain discovery-only and finance remains
   `DUTA INFORM → DUTA CONNECT → AUTHORISED PARTY EXECUTES`.
7. Confirm Pasar execution remains contained, Citizen Report remains private
   and moderator-first, precise location is private/off by default, and Health,
   E-Undi, CCTV, and MyDigital ID remain deferred.
8. Confirm consumer registration is free and the retired RM9.90 consumer
   paywall does not appear.
9. Exercise responsive navigation, critical APIs, safe-unavailable behavior,
   and metadata-only logging without recording secrets or PII.

## Security and regulatory gate

Local repository evidence passes the locked controls above. Staging remains
fail-closed on target identity, prestate, secret scope, restricted roles, RLS,
synthetic-account isolation, and non-activation of deferred features.
Historical credential ownership and live provider availability remain external
questions; they are not evidence of staging readiness or production safety.

## Remaining human/external gates

- Authorize the exact candidate commit for remote publication.
- Identify and authorize the exact staging application and database targets.
- Provide `STAGING_EXECUTION_AUTHORIZED` for 0039 only after target prestate and
  recovery readiness pass.
- Configure approved staging credentials through the secret store by role name;
  never place values in Git or evidence.
- Execute migration/deployment only under separate authorization, then create
  attempt-specific applied-state and staging smoke evidence.

This package does not authorize push, merge, deployment, remote database or
Supabase mutation, secret changes, production action, or regulated activation.
