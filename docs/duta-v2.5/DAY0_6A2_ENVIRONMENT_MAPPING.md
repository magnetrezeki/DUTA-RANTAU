# Day 0.6A-2 — ownership, environment and consumer mapping

Date: 2026-09-08. Workspace D:\DUTA-RANTAU, branch duta-v2.5. Read-only investigation except creation of this document. No credential execution/replay, network validity check, rotation, revocation, password change, environment change, hosted-service query, application edit or Git history change. Neither prohibited workspace was accessed. Historical paths refer only to Git objects from this repository.

## Auth account mapping

AUTH ACCOUNT CLASS: UNKNOWN

ACCOUNT OWNERSHIP: UNKNOWN

PASSWORD CURRENTLY REFERENCED BY CODE: NO (application runtime).

PASSWORD CURRENTLY REFERENCED BY TESTS: YES (operational test script scripts/autotest.ps1; not the Vitest suite).

PASSWORD CURRENTLY REFERENCED BY FIXTURES: YES (login-test.json diagnostic input artifact; not proven synthetic).

The nonempty password is stored in login-test.json. Its account identifier matches the three inspected cookie session versions by in-memory comparison. No personal email address or account ID is printed. The identifier does not establish a synthetic/seed account. No account-owner declaration, production/staging label, matching account seed, or fixture generation establishes exclusive test use.

scripts/autotest.ps1:90–102 checks for login-test.json and passes that file to the login request. It targets a loopback application address, but loopback Next.js can authenticate against a hosted Supabase project. Therefore diagnostic use is confirmed; TEST account class is not. scripts/autotest-full.ps1:17 declares a reference to the same file; that alone does not establish another active login consumer. No direct password value/reference was found in app runtime or tests/ Vitest files. The exact password/account value search found only login-test.json among inspected current tracked text.

The locally configured Supabase endpoint has hosted endpoint structure and matches the recorded session issuer. That maps the sessions to the locally configured project target, not to its lifecycle classification or owner. A personal-looking email, test filename, or locally executed script is insufficient to classify USER-OWNED versus PROJECT-OWNED. Ownership must be established privately through legitimate account/project access, not through leaked credentials.

## Cookie/session mapping

SESSION FINDINGS: DIFFERENT SESSIONS

SESSION STATE: UNKNOWN (overall refresh/session validity).

| Finding | Artifact | Safe metadata | State |
|---|---|---|---|
| C1 | cookies.txt:5, current and historical | One inspected session ID; same account/issuer as C2 | Recorded access JWT EXPIRED; live refresh/session UNKNOWN |
| C2 | autotest-cookies.txt:5, two historical versions | Two distinct session IDs; both differ from C1; all three share one account/issuer | Artifacts HISTORICAL; recorded access JWTs EXPIRED; live refresh/session UNKNOWN |

Session ID comparison was performed in memory; identifiers and decoded payloads are not included here. Three distinct session IDs show different sessions, not merely a refreshed access token from one session. No server call validated whether any session remains accepted.

Global session revocation would affect this one identified account's sessions/devices, potentially including additional sessions not represented in the artifacts. Whether those devices are production, staging, development or test use remains UNKNOWN. Do not describe it as project-wide logout or as test-only impact.

Current consumers of cookie artifacts:

- scripts/autotest-full.ps1 — cookies.txt reference; DUTA_BASE_URL controls target, loopback fallback.
- scripts/diagnose-server.ps1:218–224 — reads cookies.txt for an authenticated diagnostic request; DUTA_BASE_URL controls target, loopback fallback.
- scripts/autotest.ps1 — autotest-cookies.txt used in the login/authenticated test flow; loopback target.

These scripts were inspected, not executed. They can access real accounts; their diagnostic naming is not a safety guarantee.

## Historical local key mapping

KEY SCOPE: LOCAL_ONLY (observed issuing-artifact provenance; reuse outside the repository remains UNKNOWN).

SUPABASE KEY CLASS: SERVICE_ROLE_LIKE.

C3 is SUPABASE_INTERNAL_SECRET_KEY, an opaque internal secret API credential from the historical generated Docker/local Supabase runtime file:

phase3-package/supabase/.temp/start-secrets/supabase_edge_runtime_phase3-package/env/docker.env:6

Its provenance is a Supabase CLI/local Docker stack: generated start-secrets directory, local database endpoint, demo/local JWT material, internal host/runtime configuration, and Supabase internal secret/publishable variable pair. It is not the adjacent public/anon key, not a database password, and not itself the legacy service-role JWT. SERVICE_ROLE_LIKE describes its elevated internal-secret role; exact accepted privileges were not tested. It should not be substituted for a hosted application credential merely because the names resemble each other.

There is no evidence mapping C3 to a hosted development, staging or production project. LOCAL_ONLY describes the supported origin classification, not proof of no external reuse or proof that an old local runtime has stopped.

## Current key consumers

CURRENT KEY CONSUMERS: 0 found in repository-visible executable/configuration paths.

A current text scan compared the historical value in memory and searched SUPABASE_INTERNAL_SECRET_KEY without printing the value. Tracked files and repository-visible configuration including .env.local/.env.example were inspected. Exclusions included .git internals, dependency/build outputs and audit documentation (mentions in reports are not consumers). No direct value/variable consumer was found. No diagnostic script was left behind.

| Consumer category | Relevant current paths / variable names | C3 relationship |
|---|---|---|
| Next.js server | lib/supabase/admin.ts — SUPABASE_SECRET_KEY; lib/supabase/server.ts — NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | Different names; no C3 value reference found |
| Browser | lib/supabase/client.ts — NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | Public configuration; no C3 reference |
| Proxy | proxy.ts — NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | No C3 reference |
| Database runtime | db/client.ts — APP_DATABASE_URL, SYSTEM_DATABASE_URL | Database credentials, not C3 |
| Tests | tests/setup.ts — .env.local | No C3 reference; environment loading alone does not prove a consumer |
| Diagnostics | scripts/autotest.ps1, scripts/autotest-full.ps1, scripts/diagnose-server.ps1 — DUTA_BASE_URL where present | Account/session consumers, no C3 reference |
| Migration tooling | drizzle.config.ts — DATABASE_URL | Different credential class |
| Seed tooling | scripts/seed-official-sources.ts | No C3 reference |
| Supabase CLI / Docker | No current generated key file, Docker/compose or Supabase config.toml consumer found in inspected repository-visible configuration | Historical consumer context only |
| CI / GitHub Actions | No current workflow consumer found | External secret configuration not queried |
| Vercel | vercel.json | Framework declaration only; external deployment values not queried |

Zero observed consumers is not proof of zero running consumers. An already-running Docker container, external environment, another clone or external secret store is outside this inspection. No machine-wide runtime or prohibited workspace inspection was attempted.

## Environment map

| Environment | Supabase target | Env files/naming | Credential classes | Known consumers / limits |
|---|---|---|---|---|
| LOCAL DEVELOPMENT | Current .env.local points to a hosted-shaped endpoint matching sessions; hosted project's lifecycle UNKNOWN. Separate historical CLI/Docker stack is local | .env.local loaded by tests/Next; .env.example template; DUTA_BASE_URL diagnostics | Public Supabase config; account/session credentials used by diagnostics; database URLs; historical local internal API key | Next server/browser/proxy, tests and diagnostics. A local app is not proof of a local database/Auth target |
| PREVIEW/STAGING | UNKNOWN | No inspected staging-specific env file or deployment-to-project map | UNKNOWN actual configured classes; app expects same variable names | Preview text/UI labels do not establish a separate environment or Supabase project; no external settings queried |
| PRODUCTION | UNKNOWN | vercel.json only identifies framework; no repository-visible production secret bindings | UNKNOWN actual values/keys; same server/public variable contracts would apply | Hosted runtime consumers/deployment mapping UNKNOWN; no Vercel/GitHub/Supabase settings queried |

PRODUCTION CREDENTIAL IMPACT: UNKNOWN. Matching session issuer to .env.local does not identify production. No evidence justifies rotating hosted project-wide API keys or database credentials in response to these account sessions.

## Rotation blast radius

| SECRET ID | ENVIRONMENT | CONSUMERS | ROTATION IMPACT | POTENTIAL BREAKAGE | PRECONDITION BEFORE ROTATION |
|---|---|---|---|---|---|
| C1 | Hosted target, lifecycle UNKNOWN | One account's devices; cookie-based diagnostic scripts | UNKNOWN | Account sessions terminate; diagnostics using old cookie fail | Verify legitimate owner/project, account usage and required recovery access |
| C2 | Same target/account as C1, historical artifacts | Historical sessions and diagnostic workflow | UNKNOWN | Same account-global revocation includes other devices; historical existence does not prove inactivity | Handle jointly with C1 after owner/project confirmation; no token replay |
| C3 | LOCAL_ONLY provenance | 0 current repository consumers found; historical Docker/CLI runtime | UNKNOWN | A still-running local service could reject an old key; no breakage if already invalidated and unused | Verify issuer/runtime retirement or active consumer map and non-reuse; choose data-preserving local lifecycle procedure |

L1 password replacement also makes scripts/autotest.ps1's current fixture unusable. That dependency must be planned explicitly; do not keep a real password in Git for test convenience. No general application config change is implied by an account password reset.

Overall ROTATION BLAST RADIUS: UNKNOWN because account lifecycle/ownership and live local-runtime consumers remain unverified.

## Proposed sequence — no execution

1. Privately confirm the affected account/project owner and usage. Prepare a synthetic fixture or private test-credential input plan for scripts/autotest.ps1, then have the verified owner replace the exposed password through legitimate recovery/account management. Do not relabel the current artifact synthetic without evidence.
2. Revoke the affected account's sessions, covering all three recorded session IDs and other account sessions as appropriate. Coordinate device/test impact; preserve legitimate recovery access. A recorded expired access token does not settle refresh-token validity. Do not replay the exposed credentials to verify completion.
3. Verify the historical local key's runtime and consumers. If retired, document authoritative invalidation/non-reuse evidence. If active locally, coordinate a supported key replacement with affected local consumers without deleting database data. If hosted reuse is discovered, stop and prepare an explicit environment-specific rotation plan before acting.

Owner-authorized account containment need not wait for history rewriting, but this phase does not authorize it. No production key replacement is inferred.

## Exact current HEAD containment targets

| FILE | FINDING TYPE | SAFE REMEDIATION TYPE | Planning note |
|---|---|---|---|
| cookies.txt | C1 confirmed private session dump | REMOVE_ARTIFACT | Later owner-authorized removal; diagnostic users must obtain fresh sessions privately, not committed cookie replacements |
| login-test.json | L1 likely real password fixture | REPLACE_WITH_SYNTHETIC_FIXTURE | Existing operational test reads it; a clearly synthetic fixture will not authenticate. Plan REPLACE_WITH_ENV_REFERENCE for the test consumer in a separate authorized change if real integration login is needed |

CURRENT HEAD CONTAINMENT FILES: 2. C2/C3 historical files are not present in HEAD and need no current-file removal. A later ADD_TO_GITIGNORE prevention change may cover generated cookie/secret artifacts; ignoring files alone does not untrack existing secrets or invalidate them. No files were edited or removed here.

## Gate

SAFE TO PREPARE ROTATION: YES — repository mapping is sufficient to prepare the scoped owner-led plan and consumer changes.

SAFE TO EXECUTE ROTATION: NO — account/project ownership and lifecycle classification remain unverified; local runtime state/consumers and potential reuse are unverified. This is not a blanket prohibition on the verified account owner's legitimate recovery actions; execution needs correct targets and separate authorization.

Required preconditions: privately confirm owner/project/account usage; coordinate script and device impact; confirm local runtime/key issuer and active consumers or prior invalidation; resolve any hosted reuse before local-key replacement. No additional credential values are needed in this conversation.

Final safety check: application, Supabase, credentials, environment variables and Git history unchanged. Only this document was added; existing audit documents were not modified. No commit or push performed.
