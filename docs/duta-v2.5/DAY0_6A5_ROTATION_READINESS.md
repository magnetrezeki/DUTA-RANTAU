# Day 0.6A-5 — credential rotation readiness

Date: 2026-09-08. Repository-only, read-only readiness verification. The already-authorized Day 0.6A-4 working-tree containment changes are preserved but were not changed in this phase. No credential was replayed, changed, rotated or revoked; no hosted system, environment, application code, database, Supabase, Git history, commit or push was modified.

## Rotation inventory

| ID | Type | Owner | Environment | System | Present in working-tree containment snapshot | Present in Git history | Likely still valid | Rotation required | Can be done locally | Hosted action required |
|---|---|---|---|---|---|---|---|---|---|---|
| L1 | TEST_PASSWORD artifact paired with the affected account | UNKNOWN | Hosted target, lifecycle UNKNOWN | Supabase Auth account | NO | YES | UNKNOWN | YES | NO | YES |
| C1/C2 | SESSION_TOKEN containers for the same account, across three different session IDs | UNKNOWN | Hosted target, lifecycle UNKNOWN | Supabase Auth sessions/refresh tokens | NO | YES | UNKNOWN; recorded access JWTs expired, refresh/session state unverified | YES | NO | YES |
| C3 | SERVICE_ROLE_LIKE internal secret API key | UNKNOWN | LOCAL_ONLY observed provenance; external reuse UNKNOWN | Historical local Supabase CLI/Docker runtime | NO | YES | UNKNOWN | CONDITIONAL: yes if issuer/runtime remains active or reuse is confirmed; otherwise record retirement/non-reuse evidence | NO from this repository evidence | NO for the observed local-only case; YES only if later evidence establishes hosted reuse |

The Day 0.6A count of three rotation families remains: password replacement, affected-account session revocation, and C3 replacement/invalidation or verified retirement. C1/C2 are one session-revocation family, not two separate account rotations. No evidence requires rotating public Supabase publishable/anonymous configuration, hosted database credentials, Vercel/GitHub credentials, a hosted JWT signing key, or unrelated provider keys.

## Auth account and session readiness

AUTH ACCOUNT ENVIRONMENT: UNKNOWN.

AUTH ACCOUNT OWNERSHIP: UNKNOWN.

Repository evidence establishes that the three inspected session artifacts identify one account and three different session IDs. Their issuers match the hosted-shaped Supabase endpoint configured in .env.local. The account/password fixture names and local diagnostic scripts do not prove a test, development, staging or production account; no test/seed declaration identifies it as project-owned. Do not use the disclosed material or network calls to establish identity.

SESSION REVOCATION: REQUIRED once the legitimate account/project owner is verified. Recorded access tokens are expired, but that does not establish that refresh-token-backed sessions are invalid. Revocation must occur through authorized hosted Supabase/Auth account controls. It will affect that account's current sessions/devices, not necessarily all project users. Preserve a legitimate recovery path before ending sessions.

## Local Supabase runtime key readiness

LOCAL SUPABASE KEY CURRENTLY USED: NO current repository-visible consumer found.

LOCAL SUPABASE KEY ROTATION REQUIRED: UNKNOWN.

The historical C3 artifact is generated local Docker/Supabase runtime material. The current repository contains no Supabase CLI config, Docker/Compose configuration, local-stack script, package command, test setup reference or environment-variable reference to SUPABASE_INTERNAL_SECRET_KEY. Current application server code uses a differently named SUPABASE_SECRET_KEY; database code uses APP_DATABASE_URL/SYSTEM_DATABASE_URL; browser/proxy use public configuration names. No direct historical C3 value match was found in current executable/configuration paths.

This supports the observed LOCAL_ONLY classification and zero visible current consumers. It does not prove that an old local container, another clone, a shell environment or an external secret store has stopped accepting the key. Do not declare C3 rotated or retired until its issuer/runtime lifecycle is established. No hosted project rotation is indicated by current evidence.

## Hosted project map

| Environment | Status | Evidence and limit |
|---|---|---|
| Local | PARTIAL | Application can run locally; .env.local points to a hosted-shaped Supabase endpoint. Historical CLI/Docker artifacts are local provenance only. |
| Preview/staging | UNKNOWN | No staging-specific environment file, deployment mapping, or repository-visible separate Supabase target. |
| Production | UNKNOWN | vercel.json identifies Next.js only. No repository-visible hosted secret binding/project map was inspected. |

HOSTED PRODUCTION CREDENTIAL INVOLVEMENT: UNKNOWN. The affected session issuer may belong to any lifecycle category. Hosted production involvement cannot be excluded; do not rotate project-wide hosted credentials based on this evidence alone.

## Rotation blast radius

| Action | Impact | Reason |
|---|---|---|
| Replace L1 account password | UNKNOWN | May affect an unknown-owner hosted account and the diagnostic script that formerly used the fixture; account environment/usage is unverified. |
| Revoke C1/C2 sessions | UNKNOWN | Ends active sessions for the same unknown-lifecycle account; refresh status and connected devices unknown. |
| Replace/invalidate C3 local key | UNKNOWN | No visible consumers, but active local containers/external reuse remain unknown. |
| Rotate hosted project credentials | UNKNOWN and NOT YET SAFE | Hosted project identity/reuse is not mapped; no evidence currently requires it. |

Overall ROTATION BLAST RADIUS: UNKNOWN.

## Action ownership

### USER/DASHBOARD ACTIONS REQUIRED

- Privately verify the affected Auth account and the Supabase project/environment through legitimate owner access.
- Replace the affected account password and revoke its sessions through supported account/project controls after verifying recovery access.
- Establish whether the historical local runtime is retired. If it remains active, use its supported local lifecycle/key procedure with the owner; if C3 was reused in any hosted target, prepare that target's separate approved rotation plan.
- Record non-secret completion evidence: finding ID, operator, time, outcome and service health.

### LOCAL CODEX ACTIONS REQUIRED

- None before owner/environment confirmation.
- Later, only under explicit authorization: update a private local test-input mechanism so diagnostics can run without committed account credentials; prove C3 consumer/non-reuse state from authorized local runtime evidence; run isolated test database validations.

### NOT YET SAFE

- Resetting the password or revoking sessions before confirming account/project ownership.
- Replacing C3 before identifying its issuer/runtime consumers or retirement state.
- Rotating Supabase project, Vercel, GitHub, database or provider credentials based solely on the historical findings.
- Rewriting history before rotation, baseline stabilization, owner coordination and authorization verification.

## APP_DATABASE_URL test blocker

The six failures are DATABASE INTEGRATION tests: five source-integrity tests call getSources(), and one AI-router official-source test calls getOfficialSourcesForInstitution(). Both use withPublicTransaction() and intentionally fail before connection when APP_DATABASE_URL is absent. They exercise database role/transaction/query assumptions, not a pure unit mock. They are not hosted-RLS proof because no database was reached, and they are not diagnostic artifact tests.

Safest recommended target: LOCAL TEST DB with isolated test data and the restricted duta_app runtime role/RLS/migration state needed by the identity bridge. If a true local representation cannot provide that role/policy behavior, use an ISOLATED STAGING DB, never production. Do not fabricate APP_DATABASE_URL or point tests at a production database. The final classification requested is LOCAL TEST DB.

## History cleanup readiness

HISTORY CLEANUP READY: NO.

History cleanup remains deferred until credential containment/rotation is complete, baseline database tests are reproducible against an isolated target, and authorization/migration verification is complete. It also needs owner coordination for origin references, main, backup branches, collaborators and clone recovery. History rewrite reduces accidental redisclosure but cannot invalidate a credential.

## Gate

SAFE TO EXECUTE ROTATION: NO.

SAFE TO PREPARE ISOLATED DB TESTING: YES, provided it uses a newly provisioned local test database or an explicitly isolated staging target, never production, and remains a separately authorized setup task. Existing missing migration/journal and authorization questions must be resolved as part of proving that target.

Blockers: account/project ownership and lifecycle unknown; refresh-session validity/reuse unknown; C3 runtime issuer/consumer/retirement unverified; hosted production involvement cannot be excluded; database test target not yet provisioned; migration/authorization baseline remains inconsistent.
