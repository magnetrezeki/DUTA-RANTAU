# DUTA RANTAU 2.5 — Day 0 baseline audit

## Day 0.5 factual update

See DAY0_5_BASELINE_RECOVERY.md for current evidence. The roaming npm entry exists but is unreadable in this execution context; Day 0's missing-file diagnosis was incomplete. A process-only NPM_CONFIG_PREFIX override selects the functioning installed npm 11.11.0 on Node v24.14.1. No installation or persistent configuration change was needed. Validation now ran: tests FAIL (24 passed, 6 failed because APP_DATABASE_URL is absent), lint PASS, typecheck PASS, production build PASS. Original Day 0 results below remain a historical record. Lint concerns were not observed as validation failures. The fresh build does not verify dynamic database routes.

History assessment confirms additional session/internal local-runtime secret material; rotation/remediation is required. A scanner parser error accidentally emitted a sensitive test-artifact line; see the incident disclosure in the Day 0.5 report. No sensitive value is included in documentation. SAFE TO BEGIN DAY 1 remains NO due to failing tests and unresolved credential remediation.

Audit date: 2026-09-08. Scope: repository inspection and documentation only. No live database inspection, exploitation, deployment, installation, or application changes. Only D:\DUTA-RANTAU was used as project evidence. Audit completion is not a production security certification.

## Repository baseline

- Workspace and Git root: D:\DUTA-RANTAU; branch: duta-v2.5.
- Remote: origin, https://github.com/magnetrezeki/DUTA-RANTAU.git.
- Initial working tree: clean, including no untracked files.
- Latest five commits: 1de693a Replace greeting emoji with DUTA icon; 2b77231 fix: handle Supabase signup email rate limit; 235911a feat: finalize auth account deletion and deploy readiness; 4a634aa fix: harden audit log account deletion flow; 236d006 fix: allow self audit logs for profile updates.
- Exact installed and lockfile versions: Next.js 16.3.1; React/react-dom 19.2.8. Package declarations are ranges (^16.3.1 and ^19.1.0 respectively), not exact locks. TypeScript lock: 5.9.3.
- npm, package-lock.json. Local Node: v24.14.1. Locked Next engine requires Node >=20.9.0. No project engines pin; deployed runtime is unverified. Native Argon2, Node crypto and PostgreSQL clients imply Node server execution rather than an all-Edge architecture.
- TypeScript: strict, ES2022, bundler resolution, noEmit, incremental, React JSX, @/* alias; includes broad **/*.ts and **/*.tsx and generated Next types. AppTransaction is any and several page rows are any, weakening protection against schema/UI drift.
- Styling: handwritten app/globals.css; no Tailwind dependency or configuration found. Responsive breakpoints and safe-area padding exist.
- Important dependencies: Supabase SSR and JS clients, Drizzle ORM/Postgres.js, pg, Zod, Argon2, jose, lucide-react, server-only. ESLint config uses JS/Next rules without an explicit TypeScript parser configuration; validation is unavailable, so lint behavior is not certified. eslint-config-next declaration is on 15.x while Next is 16.x.
- Scripts: dev=next dev --hostname 0.0.0.0; start=next start --hostname 0.0.0.0 --port 3000; test=vitest run; lint=eslint .; typecheck=tsc --noEmit; build=next build. Database generation, migration and seeding scripts exist but were not executed.
- Structure: app/ pages and route handlers; components/ UI; lib/auth, lib/db, lib/services, lib/supabase, lib/domain and lib/audit; db/ schema, SQL and migrations; tests/ Vitest; public/ manifest, logo and official evidence; scripts/ operational helpers; types/ application interfaces. Existing backup-home-* and phase3-package directories are inside this repository, but are not additional authoritative applications.
- app/layout.tsx wraps all routes in AppShell. proxy.ts refreshes Supabase cookies with getUser; it does not enforce page authorization. vercel.json declares only framework=nextjs. next.config.ts optimizes lucide imports and image formats; no AI gateway or runtime duration configuration.
- PWA manifest exists; no service worker/registration found. See voice report for precise capability limits.

## Validation results

All four requested commands were attempted without altering environment variables:

| Command | Result | Evidence |
|---|---|---|
| npm test | NOT AVAILABLE | npm launcher failed before Vitest started |
| npm run lint | NOT AVAILABLE | npm launcher failed before ESLint started |
| npm run typecheck | NOT AVAILABLE | npm launcher failed before TypeScript started |
| npm run build | NOT AVAILABLE | npm launcher failed before Next build started |

Common error: MODULE_NOT_FOUND for C:\Users\User\AppData\Roaming\npm\node_modules\npm\bin\npm-cli.js. Local npm launcher was not repaired and dependencies were not installed. These are infrastructure failures, not evidence of failing application assertions. No pass counts are available.

tests/setup.ts loads .env.local. AI official-source and source-integrity tests perform database reads; they are not a fully isolated unit suite and require appropriate APP_DATABASE_URL and migrated role/policy state. Other tests cover intent precedence, permission helpers, organization plans, template review markers, audio-buffer clearing and source-code boundary assertions. They do not establish live RLS, end-to-end authentication, account-deletion recovery, or browser voice compatibility. A successful build alone would not establish working database-backed pages.

## Environment names only

Inventory combines runtime source, scripts/documentation, .env.example and names from .env.local. Presence in a file does not imply active integration or deployment configuration. No values are recorded.

| Variable | Classification | Usage/evidence |
|---|---|---|
| NEXT_PUBLIC_SUPABASE_URL | PUBLIC_BROWSER_SAFE | Browser/server/proxy Supabase endpoint |
| NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | PUBLIC_BROWSER_SAFE | Intended publishable client key; security depends on RLS and grants |
| NEXT_PUBLIC_APP_URL | PUBLIC_BROWSER_SAFE | Admin sources self-fetch origin; validate trusted deployment URL |
| APP_DATABASE_URL | SERVER_ONLY | db/client.ts dynamic lookup; restricted duta_app credential |
| SYSTEM_DATABASE_URL | SERVER_ONLY | db/client.ts dynamic lookup; restricted system operations |
| DATABASE_URL | SERVER_ONLY | Drizzle/legacy operational scripts; deliberately not runtime fallback |
| DIRECT_URL | SERVER_ONLY | Local env name; active runtime use not found |
| PHASE3_ADMIN_DATABASE_URL | SERVER_ONLY | Runbook administrative database access |
| SUPABASE_SECRET_KEY | SERVER_ONLY | Admin deletion/audit helper |
| AUDIT_HASH_SALT | SERVER_ONLY | Audit identifier hashing |
| AI_API_KEY | SERVER_ONLY | Example env only; no connected chat provider |
| GEMINI_API_KEY | SERVER_ONLY | Local env name; no runtime provider call found |
| AI_PROVIDER | SERVER_ONLY | Health endpoint reports configured selector; no adapter selection |
| GEMINI_MODEL | SERVER_ONLY | Local env name; no active model use found |
| VERCEL_OIDC_TOKEN | SERVER_ONLY | Local environment token name |
| EMAIL_PROVIDER_TOKEN | SERVER_ONLY | Historical documentation reference |
| SMS_PROVIDER_TOKEN | SERVER_ONLY | Historical documentation reference |
| FACE_VERIFICATION_TOKEN | SERVER_ONLY | Historical documentation reference |
| DUTA_BASE_URL | UNKNOWN_REQUIRES_REVIEW | Operational test target; must never point tests at production accidentally |
| DEMO_MODE | UNKNOWN_REQUIRES_REVIEW | Example setting, no runtime feature flag implementation found |
| ALLOW_RLS_SECURITY_TESTS | SERVER_ONLY | Runbook test opt-in; not enabled in this audit |
| NODE_ENV | SERVER_ONLY | Missing-origin behavior in API guard |
| PORT | SERVER_ONLY | Runtime/script convention; start script uses fixed port |

No NEXT_PUBLIC_* secret variable name was found. This does not prove arbitrary supplied values or historical commits are secret-free. The restricted runtime database variable names do not occur as assignments in .env.local; inherited shell/deployment values were not printed or assumed. Existing local AI names are not evidence of a working Gemini integration.

Future proposed names only: NVIDIA_API_KEY, NVIDIA_BASE_URL, NVIDIA_MODEL, AI_FALLBACK_PROVIDER, AI_FALLBACK_API_KEY, AI_FALLBACK_MODEL, ASR_PROVIDER, ASR_API_KEY, ASR_MODEL, TTS_PROVIDER, TTS_API_KEY, TTS_MODEL, DUTA_AI_ENABLED, DUTA_TOOLS_ENABLED, DUTA_VOICE_INPUT_ENABLED, DUTA_VOICE_OUTPUT_ENABLED. All server controlled; expose only a derived capability response to browsers. No variable added.

## Baseline assessment and gate

Strengths: existing modular routes, database schema, verified user abstraction, transaction-local identity checks, source provenance fields, conservative official answers, and optional provider stubs. Preserve these investments.

Weaknesses: preview UI mixed with live queries, inconsistent authorization layers, migration history gaps, tracked credential artifacts, non-distributed rate limits, source dates hard-coded in chat UI, no genuine LLM/voice implementation, and unavailable validation. Detailed risks are in V25_SECURITY_RISK_REGISTER.md.

Current app baseline cannot be marked PASS because execution checks did not run and multiple end-to-end modules are partial. Repository, AI, Supabase, voice and NVIDIA audit PASS means inspection/design completed, not that the subsystem is production ready.

SAFE TO BEGIN DAY 1: NO. Resolve the unavailable validation and assess/contain tracked credentials and high-severity policy risks before ordinary feature development. Remediation itself requires a subsequent authorized task; nothing was fixed on Day 0. No database, Supabase, application, environment, Vercel or main changes were made. Expected final changes are exactly the eight requested Markdown files under docs/duta-v2.5/.
