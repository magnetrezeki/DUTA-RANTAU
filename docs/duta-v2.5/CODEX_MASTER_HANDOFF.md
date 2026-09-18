# DUTA RANTAU v2.5 — Codex master handoff

> PRODUCT AUTHORITY UPDATE — 2026-09-18: KPP-01A founder decisions FD-01
> through FD-05 supersede earlier active product assumptions in this handoff
> about Auth/onboarding, public-vs-auth value, primary navigation, organization
> commercialization and 18+ enforcement. See
> `killer-product/KPP01_FOUNDER_DECISIONS.md` and
> `killer-product/KPP02_UX_ARCHITECTURE_ENTRY_CONTRACT.md`. Historical
> implementation evidence below remains evidence, not current product authority.

> CURRENT-STATE UPDATE — 2026-09-18: This document is retained as historical
> takeover context. Its SR-01 current-state and permission statements are
> superseded by repository evidence at and after Commit B
> `de03e6abcb4b5c14c1cf20dd4a7f7940dfbddd84`. Migration 0039 is now
> `AUTHORITY_ACCEPTED`; clean isolated PostgreSQL 16.15 validation passed; the
> migration authority guard passes; staging, production, deployment, push and
> merge remain unexecuted and require their respective external authorization.
> See `migrations/0039_VALIDATION.md` and `STAGING_RELEASE_READINESS.md`.

Prepared 2026-09-17 from local repository inspection. This document is self-contained: no account memory or prior conversation is required. Paths below are repository-relative unless explicitly absolute. This is a current-state development handoff, not migration acceptance, applied-state evidence, legal advice, or release approval.

## Evidence language and precedence

- **VERIFIED FACT**: directly inspected repository content, Git evidence, or a check performed during handoff preparation. Recorded historical results are identified separately and are not fresh execution results.
- **LOCKED DECISION**: product/governance constraints in the repository or explicit owner instructions carried into this handoff.
- **SUPERSEDED/HISTORICAL**: prior state retained for context, not current authority.
- **OPEN ISSUE**: absent evidence, contradiction, untested risk, or unfinished work. Do not silently resolve it.
- **NEXT ACTION**: the next permissible preparation/review step, not automatic execution permission.
- **HARD GATE**: a condition requiring stop or specific human authorization.

Repository bytes and reachable history take priority over previous reports. Current execution evidence supersedes older evidence only for the same scope. Code existence, a passing static guard, and commit messages do not establish live behavior. Never translate missing evidence into PASS.

## 1. Current checkpoint

**VERIFIED FACT** — authoritative repository workspace: `D:\DUTA-RANTAU`. The handoff-writing agent's projectless scratch workspace is `C:\Users\User\Documents\Codex\2026-09-12\duta-rantau-v2-5-post-8l`; it is not the application repository. `D:\DUTA-AI` is not the target.

| Item | Verified before writing this document |
| --- | --- |
| Branch | `duta-v2.5` |
| HEAD | `eb529f7c9d92902e262ae15d78cb7849262af073` |
| HEAD tree | `3aea80757a804ea93ed8a23ecebd2e0b86daeaed` |
| Worktree | CLEAN |
| Index | No staged changes |
| HEAD parent | `ee795c9c57936498ec6ccb7050addbdbe66da473` |
| HEAD subject | `SR-01 fix 0039 verifier catalog array types` |
| HEAD scope | `tests/db/migrations/0039/verify.sql` only |

**VERIFIED FACT** — `ee795c9` is a direct ancestor of HEAD, with exactly one commit in `ee795c9..HEAD`, no divergence. Its tree was `e40436c04ce00eee24047060e964ddc4dae69286`. HEAD author and committer metadata: `Perdana01 <seraiwangi.emas@gmail.com>`, both dated `2026-09-17T16:02:46+08:00`. Metadata does not identify the application/session that invoked Git.

Relevant exact local HEAD reflog evidence (branch reflog agrees):

```text
eb529f7c9d92902e262ae15d78cb7849262af073 HEAD@{2026-09-17T16:02:46+08:00} commit: SR-01 fix 0039 verifier catalog array types
ee795c9c57936498ec6ccb7050addbdbe66da473 HEAD@{2026-09-17T15:58:01+08:00} commit: MA-05 use threads for repository enforcement
```

**VERIFIED FACT** — reconciliation classification: `A — EXPECTED_VERIFY_REMEDIATION_ALREADY_COMMITTED`. No new remediation commit is needed. This handoff is intentionally uncommitted; its addition means the worktree is no longer clean after writing, while HEAD/tree/index remain unchanged. Do not mistake that intentional documentation change for a new code checkpoint.

## 2. Product and application architecture

**LOCKED DECISION** — DUTA RANTAU serves the Indonesian diaspora in Malaysia. Preserve the existing application, Supabase identities/data, services, and official directory. Develop on `duta-v2.5`; keep `main` stable. AI is optional assistance over existing services. Do not rebuild from another workspace.

**VERIFIED FACT** — Next.js App Router / React / TypeScript; `app/` contains pages and HTTP routes, `components/` UI, `lib/domain/` policy, `lib/services/` services, `lib/auth/` and `lib/db/` authorization/identity, `db/schema.ts` Drizzle application types, and direct SQL migration artifacts. Package declarations include Next `^16.3.1`, React `^19.1.0`, Drizzle ORM `^0.45.2`, Supabase SSR `^0.8.0`, Supabase JS `^2.100.0`, PostgreSQL clients, Zod, Argon2 and jose. Declarations are not proof of installed or deployed versions.

**VERIFIED FACT** — `/` is now the public landing page; `/beranda` is the app home. Other current page families include `/tanya`, `/masuk`, `/daftar`, `/profil`, `/kerja`, `/komunitas`, `/pasar`, `/organisasi` (plans, detail, secretary), `/layanan`, `/jaga-diri`, `/info` (including tourism), and admin/content/source pages. Password recovery now exists at `/auth/lupa-password`, `/auth/reset-password`, `/auth/reset-password/form` with `/api/auth/password-recovery`. Consumer membership page and checkout route were deleted. Route presence alone does not prove authorization or production activation.

**LOCKED DECISION** — Supabase authenticates users. Server-verified identity and database profile/role checks govern access; browser role metadata cannot grant authority. The restricted transaction identity bridge sets transaction-local identity for RLS. App/system database connections are distinct; generic `DATABASE_URL` is not a permitted fallback. Preserve server-only secrets, same-origin mutation protections, least privilege, tenant isolation and append-only audit boundaries.

**VERIFIED FACT** — AI implementation entry points include `app/api/ai/chat/route.ts`, `lib/services/ai-router.ts`, `ai-execution-plan.ts`, `authorized-ai-generation.ts`, `ai-provider-execution.ts`, `ai-provider-adapters.ts`, `ai-quota-repository.ts`, `ai-telemetry*.ts`, `ai-source-ranking.ts`, `duta-tools.ts`, and `lib/domain/ai-routing.ts` / `duta-ai-policy.ts`. Voice routes are `/api/ai/transcribe` and `/api/ai/speak`; route existence is not a live-provider guarantee.

**VERIFIED FACT** — current model routing uses L0 deterministic/DUTA weight 0, L1 Gemini weight 1, L2 Groq weight 2, L3 OpenAI weight 4. Groq is locked to `openai/gpt-oss-20b`; OpenAI to `gpt-5.6-luna`; Gemini requires configured model. Current adapter sends OpenAI POST to `https://api.openai.com/v1/chat/completions`, with `max_completion_tokens` and a `developer` instruction role. Generation cap is 300 tokens and planned-provider timeout is 15 seconds. NVIDIA adapter also exists but the old NVIDIA-centric design document is not a complete account of current routing.

**LOCKED DECISION** — authoritative quota is 30 weighted AI units per authenticated user per UTC calendar day, enforced by `public.consume_ai_usage`. Server derives identity and weight; authorization precedes external generation. `duta-ai-fair-use.ts` is a deprecated compatibility meter, not production quota authority. Source-required responses must cite acceptable evidence or fail safely. Retrieved/model text cannot authorize actions, assign badges/roles, or override policy. AI failure must preserve navigation and usable text/source fallbacks.

**OPEN ISSUE** — current live provider availability, credentials, deployment flags, remote database state and voice readiness were not tested. Historical reports of Gemini/Groq locked passes and controlled OpenAI unavailability are not current live certification. Sensitive-data routing needs privacy review before activation; route selection alone is not permission to transmit restricted data.

## 3. Completed work and exact provenance

**VERIFIED FACT** — the exact chronological commit/file inventory is in Appendix A. Important milestones:

| Commit | Purpose / scope |
| --- | --- |
| `8e348f0847910a914b918ce518f00e07a35dc4c8` | Safe internal provider diagnostic categories and deterministic tests |
| `b7fce3a7b9fbc98abc6e38f0e4c1dfd190cdb1d5` | OpenAI Chat Completions request contract correction |
| `d1763bdc1d332182da9885af88c71bc103478db0` | 0037 runtime identity helper SQL and tests |
| `2d83b43943a4f40d207909b78d6efbd8bcd6241c` | 0038 core runtime RLS plus pre-authority historical edits |
| `427cfa3959172c2acf300b5cabcfe86f8487470b` | Persistent AI quota/telemetry migration gate |
| `c26fa221b508e59bca95efbf371fad667f93a79c` | Password recovery hardening |
| `b7b3c56b796921f4e805ad5bc7475042bef3b710` | Landing page and app home |
| `b9834b7ff2a7c16a216182655157b255bd0ad28a` | Retire consumer membership/payment workflow |
| `e78ba12a640981c558439d83ec8a48895c116f3c` | Deny employer/seller submission; withhold marketplace |
| `3602a09a3b85161eae45101eb8339c68591612ea` | Privacy governance frameworks; authority baseline |
| `fbe268f0e1799e35a2c3dd5dcb3c8b5007e04cc3` | MA-01 forward migration authority |
| `e1acf0a176f8b430172c889ca5645b6fab0638f5` | MA-02 manifest and validation tests |
| `6f53640c35694926e03cfa80bd696b99f83b9011` | MA-02 validator hardening |
| `67312b8de35f40983ebfdf394a0130ee1d20c84b` | MA-03 validation contract/template/tests |
| `cce8876016ac01ee4b19224b5145ef54e4bede3a` | MA-04 execution/applied-state protocol |
| `f35d04e5cbd36a05bf18c1840bd2df9d25bc49bc` | MA-05 global guard and repository enforcement tests |
| `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5` | SR-01 Commit A: proposed 0039 SQL, manifest and harness |
| `e88d1d6080c4753c511502fdf5ba8922eee236c5` | Strengthen structural and security harness |
| `fd90130fb07922ee083d0fe8bb5949118ee4eaaf` | Complete structural verifier |
| `2e180c11496e5053c5b1f72cb37492c8d09ab47e` | Harden structural assertions |
| `253517110c2488bfcb86616a3d36e9746f846670` | Isolated 0039 PowerShell runner |
| `ee795c9c57936498ec6ccb7050addbdbe66da473` | Package-only MA-05 threads invocation |
| `eb529f7c9d92902e262ae15d78cb7849262af073` | Four verifier catalog-array text casts |

**HARD GATE** — earlier edits to 0023/0027/0034–0036 occurred before the frozen authority baseline; they are not precedent authorizing edits to historical SQL now.

## 4. Migration authority and acceptance

**LOCKED DECISION** — `FORWARD_ONLY_DIRECT_SQL`, authority version 1, manifest schema version 1. Baseline commit `3602a09a3b85161eae45101eb8339c68591612ea`, tree `6676178a4a8c7131c2f95679303e33c8ed7a2305`. Governing files: `MIGRATION_AUTHORITY.md`, `MIGRATION_VALIDATION_CONTRACT.md`, `MIGRATION_EXECUTION_PROTOCOL.md`, `MIGRATION_TEMPLATE.md`, `MIGRATION_APPLIED_STATE_TEMPLATE.md`, `db/migrations/forward-authority-baseline.json`, `forward-manifest.json`, and `scripts/check-migration-authority.mjs`.

**LOCKED DECISION** — 0000–0038 are `FROZEN_HISTORICAL_EVIDENCE`: 35 physical files, missing numbers 0004–0007. Journal ends at 0009; 0010–0038 are unjournaled. Journal is `LEGACY_FROZEN_METADATA`, not current replay authority. Do not reconstruct, renumber, rename, squash, delete or rewrite historical SQL/journal; do not add 0039+ journal entries. `FULL_HISTORICAL_REPLAY=UNSUPPORTED`; `FRESH_DATABASE_AUTHORITY=NOT_ESTABLISHED`. Ordinary build/start/deploy must never auto-run migrations.

**LOCKED DECISION** — repository authority, schema/security validation, and environment applied state are three separate authorities. Repository statuses: `PROPOSED`, `REVIEWED`, `AUTHORITY_ACCEPTED`, `SUPERSEDED`. Local validation and staging/production execution are separate gates, not manifest statuses.

**LOCKED DECISION** — required two-commit provenance:

1. Commit A adds canonical SQL plus PROPOSED metadata and validation plan/scaffold. For 0039 it is `9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5`.
2. Commit B is a later, separately authorized acceptance commit after completed required validation. It records accepted exact-byte checksum, completed validation reference, complete metadata, and `introducedCommit` pointing to the earliest unique non-merge addition of canonical SQL (Commit A). A later containing commit, merge, rename or delete/re-add is not valid provenance.

**VERIFIED FACT** — no Commit B appears in the reviewed lineage. 0039 manifest is still PROPOSED with `checksum: null`, `introducedCommit: null`, `validationContract: {status: PENDING_MA03, reference: null}`. `AUTHORITY_ACCEPTED` is the immutability boundary; accepted corrections normally require a new governed migration. Exact UTF-8 file bytes are hashed without newline normalization.

**HARD GATE** — acceptance requires exact SQL, dependencies, actual schema/security/data validation, positive and adversarial tests, RLS/FORCE/bypass decisions, rollback/recovery readiness and evidence. A global guard only checks structural rules; it cannot certify SQL behavior or truth of evidence. Staging requires explicit migration-specific authorization and verified target pre-state/checksum. Production additionally requires same-checksum staging `APPLIED_CONFIRMED`, production pre-state/recovery and separate authorization. `STATE_UNCERTAIN` blocks dependent execution and success claims. Failed attempts remain preserved.

## 5. SR-01 / 0039 exact design and integrity

**VERIFIED FACT** — canonical SQL: `db/migrations/0039_source_registry_governance_foundation.sql`. Schema effect ADDITIVE; security RLS + AUTHORIZATION; data effect NONE; requires RLS validation; no backfill; rollback classification REVERSIBLE (bounded to before authoritative governance/evidence data exists).

**VERIFIED FACT** — manifest dependencies: migrations 0000, 0008, 0010, 0011, 0012, 0013, 0038; tables `public.official_sources`, `public.users`; columns `official_sources.id`, `.active`, `.last_checked`, `users.id`; roles `duta_app`, `duta_system`; extension `pgcrypto`; no declared function dependency entries. Security prerequisites: official_sources RLS, policies `official_sources_public` / `official_sources_admin_all`, and legacy duta_app SELECT/INSERT/UPDATE/DELETE grants. Historical numbers supplement actual object checks; they never prove state.

**VERIFIED FACT** — SQL adds:

- `public.source_purpose`: NEWS / CONSULAR_SERVICE / CONTACT; nullable `official_sources.source_purpose`, default NULL. Legacy rows stay unclassified.
- `public.official_source_currentness`: UNKNOWN / CURRENT / STALE / REVIEW_REQUIRED.
- `official_source_governance`: source_id PK/FK; identity_verified and official_source_verified false; currentness UNKNOWN; verification timestamp/reviewer; production_approved false with approval timestamp/reviewer; next_review_at; created_at/updated_at default now(). Verification requires identity plus timestamp/reviewer; false verification prohibits verification metadata. Approval requires identity and official verification plus timestamp/reviewer; false approval prohibits approval metadata.
- `official_source_evidence`: UUID id default gen_random_uuid(), source_id, evidence_url/type, checked_at, optional reviewed_by, timestamps; UNIQUE(source_id,evidence_url). Evidence may exist without a governance row.
- All source/user FKs use DELETE RESTRICT / UPDATE NO ACTION. Both new tables enable RLS without FORCE; no application policies/grants are added. Owner-only setup is not runtime reviewer authorization.
- Revoke duta_app table INSERT/UPDATE on official_sources. Allow INSERT only institution, channel, url, category, priority, trust_level, last_checked, checksum, active; UPDATE only active, priority, trust_level. Existing SELECT/DELETE and policies remain. No purpose writes are authorized for duta_app.

**VERIFIED FACT** — protected exact-byte SHA256 values recomputed during preparation:

| Artifact | SHA256 |
| --- | --- |
| `db/migrations/0039_source_registry_governance_foundation.sql` | `5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30` |
| `tests/db/migrations/0039/prestate.sql` | `467027a30647438637335c1a406e4cf4d89c7bb991c8632215aa1bebb8f0dff2` |
| `tests/db/migrations/0039/verify.sql` | `a93e06c32585e13def8b3e97381566af2abc3e711032a464bcefed988d072698` |
| `tests/db/migrations/0039/security-verify.sql` | `a4d394f0b6f0f9bb4f6d98aa8db4463c1444ef2075e29b95d6f5101d307dc26a` |
| `scripts/run-0039-local-validation.ps1` | `3e36c66f8cefa7b0e2a4587e8f3b56a45788225f889b19df3632d494737f5ebc` |

**VERIFIED FACT** — verifier remediation adds four `::text` casts across three changed lines: governance PK and evidence PK use `array_agg(a.attname::text ORDER BY a.attnum)`; INSERT and UPDATE allowed-column assertions use `array_agg(attname::text ORDER BY attnum)`. Removing those four casts produces the exact parent file content. Expected arrays, ordering, predicates and assertion behavior are unchanged: no assertion weakening or security-policy change. Zero remaining known mismatches in these four targets; this is not a full SQL execution pass.

**VERIFIED FACT** — infrastructure remediation adds only package script `test:migration:enforcement = vitest run tests/migration-repository-enforcement.test.ts --pool threads`. It remains exact at HEAD. No SQL/runtime code changed in that commit.

**OPEN ISSUE — runner pin**: runner still expects old verifier SHA256 `8a48b8ff1bd426554c82bf7326f6456d926b37dff5120fff0938c71917257ca1`. Current verifier is `a93e06...`. After tool-presence checks, `Assert-Artifacts` will block even dry-run before Docker/SQL execution. Do not silently update this protected runner; review and authorize a precise remediation, then re-lock its hash.

**OPEN ISSUE — security fixture**: `security-verify.sql` switches to duta_app then attempts an explicit `id` INSERT for UUID ending 0103. The migration's column INSERT grant excludes `id`. Static inspection identifies a likely permission failure before later negative cases; no live confirmation was performed. Resolve fixture intent against least privilege; do not broaden grants to make tests pass.

**OPEN ISSUE — schema representation**: `db/schema.ts` currently defines legacy officialSources but does not represent the new source_purpose/governance/evidence structures. MA-03 requires schema review/update where applicable; this remains an explicit review item, not authority to edit schema now.

## 6. Testing: evidence and limits

**VERIFIED FACT** — fresh command during handoff preparation:

```text
node scripts/check-migration-authority.mjs
MIGRATION_AUTHORITY_CHECK: PASS (historical=35, forward=1)
```

**VERIFIED FACT** — test artifacts inspected, not freshly executed for this documentation task:

| Area | File / evidence boundary |
| --- | --- |
| MA-02 | `tests/migration-manifest.test.ts`: baseline, frozen hashes/files, pending proposal, malformed paths, applied-state exclusion, dependency identifiers and metadata |
| MA-03 | `tests/migration-authority.test.ts`: contract/template markers, two-commit rules, proposal scaffold and validation obligations; not live SQL |
| MA-05 | `tests/migration-repository-enforcement.test.ts`: temporary Git fixture repos, provenance, immutability, checksums, renames/re-adds/merges, dependency errors and automatic-migration prohibition |
| Infrastructure | Threads script exists; original failure transcript/root cause and a fresh threads test result are not established by this handoff |
| Lint/typecheck/build | Scripts exist; NOT rerun at current HEAD for this documentation task |
| 0039 local SQL | NO fresh execution; NO LOCAL_VALIDATION_PASS |

**SUPERSEDED/HISTORICAL** — `DAY0_5_BASELINE_RECOVERY.md` records 24/30 tests passing, six failing because APP_DATABASE_URL was absent; lint/typecheck/build passed. npm failure was prefix selection of an inaccessible roaming npm copy, not conclusively a missing installation. Process-only `NPM_CONFIG_PREFIX='C:\Program Files\nodejs'` enabled installed npm; do not change persistent config or install dependencies as a shortcut. These are older results, not current-HEAD certification.

**SUPERSEDED/HISTORICAL** — `DAY0_FINAL_DEVELOPMENT_SIGNOFF.md` later records local tests/lint/typecheck/build passing and dependency-correct replay through 0015, with deferred preproduction gates. That supersedes the older Day 0 development block within its scope; it does not prove current 0039, production, or hosted readiness. `DAY0_6E_FINAL_SECURITY_SIGNOFF.md` records isolated staging 17/17 authorization subchecks (5 ALLOW, 8 RLS_DENY, 4 GRANT_DENY), 12 behavioral cases, 4 escalation subchecks and fixture restoration. This is historical minimal-fixture evidence only.

**SUPERSEDED/HISTORICAL** — physical numeric replay passed 0000–0003 then failed 0008 because duta_app was not yet created (0010); identity helpers are in 0011. Logical order 0000,0001,0002,0003,0010,0011,0008,0009 passed. Extension passed 0012 then failed 0013 on missing Supabase anon/authenticated roles in plain PostgreSQL. Do not rewrite historical SQL to suppress those dependency failures. Later development signoff records progress through 0015; 0016 auth.uid()/policy behavior remains a deferred native-environment gate.

**OPEN ISSUE** — the 0039 validation record still says `Local execution: not performed`; owner context refers to a failed local attempt and forensic container. No durable attempt transcript proving precise phase outcomes was available in the inspected current validation record. The name[]/text[] comparator defect explains the cast remediation statically; actual previous runtime error text, phase progression and database effects must not be invented. Preserve that documentation/evidence gap. A committed fix does not retroactively turn the attempt into PASS.

**HARD GATE** — `tests/setup.ts` loads `.env.local`. Do not run the full suite blind: some tests connect to databases. No environment values should be printed or copied. Safe static test selection still requires inspecting test/setup behavior; MA-05 tests create and delete temporary repositories and make fixture commits, not application commits. No test execution in this task was used to infer DB acceptance.

## 7. Docker / PostgreSQL local validation architecture

**VERIFIED FACT** — runner is `scripts/run-0039-local-validation.ps1`, parameter `[switch]$Execute`. Fixed target: container `duta-local-test-db`, database `duta_local_test`, external host `127.0.0.1`, external port `55433`, internal PostgreSQL `5432`, bootstrap user postgres. Script image is `postgres:16-alpine`. Uses existing local image only (`--pull never`), `--rm`, tmpfs `/var/lib/postgresql/data:rw,noexec,nosuid,size=256m`, synthetic runtime-generated password, and host `psql` (no container-internal SQL substitution). It refuses an existing same-name container or occupied port; it does not reuse/reset the forensic instance.

**VERIFIED FACT** — prestate creates duta_app/duta_system LOGIN roles without superuser, createdb, createrole, replication or BYPASSRLS; anon/authenticated are NOLOGIN stand-ins. Synthetic ORG_ADMIN and legacy source UUIDs use the `00000000-0000-4000-8000-...` namespace. This is a minimal test fixture, not a Supabase clone or production snapshot.

**VERIFIED FACT** — phases 0–7 below are an explanatory mapping. Script has seven named phase fields, not an official eight-item numbered enum; do not fabricate an exact earlier phase convention.

| Phase | Code operation |
| --- | --- |
| 0 | Locate Docker and host psql, fixed-target assertions, four artifact hashes; without Execute print DRY_RUN_ONLY and exit |
| 1 | ENVIRONMENT_GUARD: Docker daemon, local image, absent container/free port and eventual container identity/binding |
| 2 | BOOTSTRAP: create disposable PostgreSQL, readiness probe up to 30 attempts, local PG variables; guard/bootstrap marked PASS together |
| 3 | PRESTATE: host psql -X -v ON_ERROR_STOP=1 -f prestate.sql; query safe server identity |
| 4 | MIGRATION_0039: execute canonical SQL through host psql |
| 5 | VERIFY: structural SQL verifier |
| 6 | SECURITY_VERIFY: behavioral role/denial/check tests |
| 7 | FINAL_EVIDENCE: stdout JSON with UTC time, Git IDs, hashes, target, phases and classification |

**VERIFIED FACT** — prestate and migration each BEGIN/COMMIT in separate psql processes. Structural and security tests use BEGIN/ROLLBACK for test mutations. There is no whole-run transaction: a failure in verification does not roll back the previously committed migration. `ON_ERROR_STOP=1` fails closed; runner classifies nonzero external exits STATE_UNCERTAIN. Artifact/tool errors before the try block may lack structured phase evidence. Finally restores PGPASSWORD and removes PGHOST/PGPORT/PGUSER/PGDATABASE; it does not restore prior values for those four variables.

**HARD GATE** — preserve any existing forensic container. Runner has no container cleanup in finally, but `--rm` means stopping it can remove it and tmpfs data. Do not stop, delete, restart, recreate, rename or reuse it without explicit owner authorization. No Docker command was issued during this handoff; current existence/running/image/data state is unverified.

**OPEN ISSUE — postgres:16 vs postgres:16-alpine**: owner flags an unresolved image discrepancy. Repository runner and historical replay document specify alpine; current actual forensic image was not inspected. Container identity regex accepts PostgreSQL 16 tags generally, while creation pins alpine. These are different scopes and are not proof of identical images. Reconcile exact locally available/forensic image and authorized future image (ideally digest evidence) before any execution. Do not pull an image or silently change the target.

## 8. Security, regulatory and official-source locks

**LOCKED DECISION** — basic consumer registration/access is FREE, no consumer subscription/paywall. Initial public launch policy is 18+; technical age gate is not established by the privacy framework. Jobs are discovery-only: no placement, application capture, or direct-employer submission. Current `/api/admin/jobs` POST returns 410. Pasar Rantau remains withheld: `/api/marketplace` GET returns 503; admin seller listing POST returns 410. Payment execution disabled. Citizen Report is private/moderator-first; precise location private/default off. Health, E-Undi, CCTV, MyDigital ID and multi-country regulated expansion are deferred.

**LOCKED DECISION** — privacy frameworks are not final legal notices or legal compliance certification. Founder/Managing Director is interim accountable owner; DPO requirement and appointment remain undecided/LEGAL_REVIEW_REQUIRED. Vendor regions, contracts/DPAs, subprocessors, cross-border facts, retention, privacy request channel and incident process remain TO_VERIFY. Export is not implemented; account deletion is partial/API exists with cross-system evidence unresolved. High-risk feature activation requires DPIA/legal review. Preserve all six `R2A02_*.md` frameworks.

**LOCKED DECISION** — `DUTA INFORM → DUTA CONNECT → OFFICIAL GOVERNMENT SYSTEM EXECUTES`. DUTA does not initially book consular appointments, reserve slots, host official forms, collect passports, store appointment credentials/confirmations or proxy-submit applications. R2A-02B official URL registry runtime work is not proven complete by SR-01 SQL.

**VERIFIED FACT** — existing official_sources directory, official_offices, official_contacts, and legacy official_evidence are distinct from new `official_source_evidence`. `lib/services/sources.ts` reads active sources through public identity transactions; institution lookup filters P0, returns at most two, newest checked first. `lib/official-emergency-data.ts` and `ai-router.ts` support contact answers, explicitly abstaining from unavailable current fees/addresses. Read-only tools cover official information, consulates, jobs, communities and organizations; source provenance is not government endorsement. Trust A–E describes origin (government, verified organization, verified partner, community, general AI), never guaranteed safety.

**VERIFIED FACT** — `job-sources.ts` allowlists HTTPS `siskop2mi.bp2mi.go.id` list/detail paths, Malaysia destination, OFFICIAL SISKOP2MI/KP2MI source, active status, nonexpired listings and last check within seven days. This code is not evidence of a currently operational ingestion pipeline or current external URL availability.

**LOCKED DECISION** — no credentials, tokens, headers, complete connection strings, raw provider bodies, personal records, passport data or raw audio in handoffs/logs/evidence. Historical credential material is compromised/quarantined and must never be reused. Current-tree containment does not erase Git exposure or prove credential revocation. Owner/issuer identification and recovery remain prerequisites to rotation; no credential replay or automatic history rewrite.

## 9. Superseded approaches and contradictions

- **SUPERSEDED/HISTORICAL**: `CURRENT_ARCHITECTURE.md` explicitly reflects commit 1de693a. Its route counts, membership routes, lack of recovery, and narrower SQL inventory are stale. Inspect actual current files first.
- **SUPERSEDED/HISTORICAL**: `V25_TARGET_ARCHITECTURE.md` is design-only; RAG, realtime, caching, circuit breakers and complete privacy/deletion behavior must not be presented as implemented solely from that document.
- **SUPERSEDED/HISTORICAL**: older documents say MA-05 “will own” enforcement and 0039 is only reserved. Current guard/tests and PROPOSED SQL supersede those progress descriptions; underlying authority restrictions still apply.
- **SUPERSEDED/HISTORICAL**: old OpenAI transport collapsed failure outcomes. Diagnostic categories and request-contract fixes now exist. Older request max_tokens/system-role assumptions are not current OpenAI code.
- **OPEN ISSUE**: current adapter declares RESPONSE_PARSE_FAILURE but its catch classifies non-abort errors, including JSON parse exceptions, as NETWORK_FAILURE. Do not claim granular parse categorization is fully implemented.
- **SUPERSEDED/HISTORICAL**: “create the one remediation commit” is already satisfied by eb529f7. Do not duplicate it, reset to ee795c9, amend or replay it.
- **SUPERSEDED/HISTORICAL**: physical replay, Drizzle journal repair, guessed missing SQL, broad grants to pass tests, and direct numeric replay against an existing database are not authorized solutions.
- **OPEN ISSUE**: rollback is classified REVERSIBLE but the record describes a boundary/procedure, not completed reverse-execution evidence. Acceptance review must establish required readiness.

## 10. Exact next execution point, permissions and hard stops

**NEXT ACTION** — resume at `SR01_0039_VERIFY_REMEDIATION_POST_COMMIT_REVIEW`. Verify this handoff against local Git and hashes. Then prepare `SR01_0039_CLEAN_LOCAL_VALIDATION_PRECHECK`, explicitly addressing stale runner pin, security-fixture id privilege issue, image discrepancy, forensic-container preservation, schema representation and missing attempt evidence. This handoff does not authorize fixing those files or executing the runner.

**LOCKED DECISION — autonomous scope now**: local read-only repository/history inspection, static comparison, non-secret hashes, migration authority guard, and documentation review. The owner authorized writing this handoff only, uncommitted. Previous one-commit authorization was exact-parent/exact-file and is already satisfied; it is not reusable. Future ordinary coding/tests require scope from the new owner's task; no blanket execution authority transfers with this document.

**HARD GATE — explicit human authorization required**: changes to protected SQL/harness/runner or manifest; recording migration validation/acceptance evidence; Commit B; any new commit, staging for commit, history operation, merge or push; SQL/database connections or execution; local validation rerun; Docker lifecycle actions; image pull; staging/production access; provider live retest; credential rotation/revocation; external service operations; deployment; activation of deferred regulated features. “Staging authorized” in migration reports means staging-environment authority, distinct from Git index staging; neither is granted here.

**HARD GATE — stop conditions**:

1. Unexpected branch/HEAD/tree/index/worktree changes beyond this handoff; preserve others' work and reconcile, never reset it.
2. Hash mismatch, guard failure, changed dependency/manifest/provenance, absent evidence or disagreement between target and approved image/role/database/port.
3. Existing forensic container, occupied target port, missing host psql/local image, or stale runner pins; do not bypass safeguards.
4. Any non-loopback/hosted target, real-user data, remote credentials or secret-bearing output.
5. Failed SQL, incomplete rollback/commit evidence or STATE_UNCERTAIN; preserve evidence and stop downstream phases.
6. Required assertion fails; do not weaken checks, broaden grants, alter RLS, or mark acceptance to proceed.
7. A request would cross ungranted scope (DB, container, commit, network, acceptance, release). Obtain concrete authorization before action.

**OPEN ISSUE — known risks**: unvalidated 0039 security path; stale pin blocks execution; fixture/grant inconsistency; source schema/runtime integration unfinished; incomplete current lint/typecheck/build evidence; secret exposure in historical Git; absent full historical/fresh DB authority; minimal fixture tests do not prove deployed Supabase security; operational privacy facts and launch gates unresolved; static guard cannot prove semantic validation; temporary-container lifecycle can destroy forensic evidence.

## 11. First inspection commands and files

**NEXT ACTION** — use local commands only; no fetch/pull, npm install, provider request, SQL, Docker or runner execution:

```powershell
Set-Location -LiteralPath 'D:\DUTA-RANTAU'
git branch --show-current
git rev-parse HEAD 'HEAD^{tree}'
git --no-optional-locks status --short
git diff --name-status
git diff --cached --name-status
git merge-base --is-ancestor ee795c9c57936498ec6ccb7050addbdbe66da473 HEAD
git log --reverse --format='%H %P %T %s' ee795c9c57936498ec6ccb7050addbdbe66da473..HEAD
git show --format=fuller --stat eb529f7c9d92902e262ae15d78cb7849262af073
git show --format= eb529f7c9d92902e262ae15d78cb7849262af073 -- tests/db/migrations/0039/verify.sql
node scripts/check-migration-authority.mjs
Get-FileHash -Algorithm SHA256 db/migrations/0039_source_registry_governance_foundation.sql,tests/db/migrations/0039/prestate.sql,tests/db/migrations/0039/verify.sql,tests/db/migrations/0039/security-verify.sql,scripts/run-0039-local-validation.ps1
```

Inspect first: this file; all five migration authority/contract/template documents; baseline/manifest JSON; canonical 0039 SQL; `migrations/0039_VALIDATION.md`; three 0039 fixture/verifier SQL files; runner; `db/schema.ts`; three migration test files; `package.json`; `vitest.config.ts`; `tests/setup.ts`. Then inspect current route/service/policy files cited above and six privacy framework documents. Do not open secret env files to populate a handoff.

For a separately scoped static testing task, commands to review are `npm run test:migration:enforcement`, `vitest run tests/migration-manifest.test.ts tests/migration-authority.test.ts --pool threads`, `npm run lint`, `npm run typecheck`, `npm run build`. Installed local tools should be used without download. Build/typecheck can write generated caches; full tests can use DB credentials. These command references are not an instruction to run them during this handoff.

**VERIFIED FACT — preparation boundary**: no SQL, database connection, runner execution, Docker action, provider live call, remote operation, migration acceptance, commit, merge, push or deployment was performed to prepare this document. No code/SQL/manifest/runner was modified. Current local forensic-container state was not inspected.

## Appendix A — exact relevant commit and changed-file inventory

**VERIFIED FACT** — generated from local Git, chronological range `dda5d0e1c2ce45e38f793342bdcae85a8fd55f61..eb529f7c9d92902e262ae15d78cb7849262af073`. The excluded starting commit is the historical Groq model-authority lock. A/M/D below are Git file status codes; each entry includes full commit, parent, tree, subject and exact changed paths. No intermediate commit in this range is omitted.

```text
COMMIT 8e348f0847910a914b918ce518f00e07a35dc4c8
PARENT dda5d0e1c2ce45e38f793342bdcae85a8fd55f61
TREE 2b7cd31ddb69244666e7e6516cfcb20634d73697
SUBJECT feat: OpenAI safe internal diagnostic categorization and deterministic tests

M	lib/services/ai-provider-adapters.ts
M	lib/services/ai-provider.ts
M	tests/ai-provider-adapters.test.ts
COMMIT b7fce3a7b9fbc98abc6e38f0e4c1dfd190cdb1d5
PARENT 8e348f0847910a914b918ce518f00e07a35dc4c8
TREE 2fe7160478811fffec23ad7360a67dae5ba9ddf4
SUBJECT fix: OpenAI Chat Completions contract uses max_completion_tokens and developer instruction role

M	lib/services/ai-provider-adapters.ts
M	tests/ai-provider-adapters.test.ts
COMMIT d1763bdc1d332182da9885af88c71bc103478db0
PARENT b7fce3a7b9fbc98abc6e38f0e4c1dfd190cdb1d5
TREE ded144549504b212417a73a61e40057c865d193b
SUBJECT fix: isolate runtime identity helpers for fresh staging bootstrap

A	db/migrations/0037_runtime_identity_helpers.sql
A	tests/identity-helper-migration.test.ts
COMMIT 2d83b43943a4f40d207909b78d6efbd8bcd6241c
PARENT d1763bdc1d332182da9885af88c71bc103478db0
TREE ef55d20e73b4a03775c830beacaa5b26b0a5f2f5
SUBJECT security: enforce core-runtime RLS on fresh bootstrap (POST-8L-H2B)

M	db/migrations/0023_entity_legal_status_foundation.sql
M	db/migrations/0027_community_membership_growth_foundation.sql
A	db/migrations/0038_core_runtime_rls_enforcement.sql
A	tests/core-runtime-rls-migration.test.ts
COMMIT 427cfa3959172c2acf300b5cabcfe86f8487470b
PARENT 2d83b43943a4f40d207909b78d6efbd8bcd6241c
TREE 6626d2377ede546a1d2de44efa8c4b2c61ebd62a
SUBJECT Harden AI quota and telemetry migration gate

M	app/api/ai/chat/route.ts
M	db/migrations/0034_ai_fair_use_foundation.sql
M	db/migrations/0035_ai_telemetry_foundation.sql
M	db/migrations/0036_ai_telemetry_correlation.sql
A	docs/duta-v2.5/POST8LH3D_R3_QUOTA_POLICY.md
A	lib/services/ai-quota-policy.ts
M	lib/services/ai-quota-repository.ts
M	lib/services/duta-ai-fair-use.ts
M	package.json
A	scripts/test-ai-quota-db.mjs
M	tests/ai-chat-route.test.ts
A	tests/ai-fair-use-migration.test.ts
M	tests/duta-ai-policy.test.ts
COMMIT c26fa221b508e59bca95efbf371fad667f93a79c
PARENT 427cfa3959172c2acf300b5cabcfe86f8487470b
TREE 786cf8145ef75fe1d1d555d30aa00580faa62bbc
SUBJECT fix: harden password recovery flow

A	app/api/auth/password-recovery/route.ts
A	app/auth/lupa-password/page.tsx
A	app/auth/reset-password/form/page.tsx
A	app/auth/reset-password/form/reset-password-form.tsx
A	app/auth/reset-password/route.ts
M	app/masuk/page.tsx
A	lib/auth/password-recovery.ts
A	tests/password-recovery.test.ts
COMMIT b7b3c56b796921f4e805ad5bc7475042bef3b710
PARENT c26fa221b508e59bca95efbf371fad667f93a79c
TREE 49908b938d785b903cfc07298426674d307dbaa2
SUBJECT feat: add public landing page and app home

A	app/beranda/page.tsx
A	app/landing.module.css
M	app/page.tsx
M	components/app-shell.tsx
A	components/landing-cta.tsx
A	tests/landing-page.test.tsx
COMMIT b9834b7ff2a7c16a216182655157b255bd0ad28a
PARENT b7b3c56b796921f4e805ad5bc7475042bef3b710
TREE d0288d8f88d5b644b186cb94f6af91b683785419
SUBJECT fix: retire consumer membership workflow

D	app/api/membership/checkout/route.ts
M	app/beranda/page.tsx
D	app/membership/page.tsx
M	app/profil/page.tsx
M	components/auth-form.tsx
D	lib/services/payment-provider.ts
A	tests/consumer-membership-retirement.test.ts
M	tests/landing-page.test.tsx
COMMIT e78ba12a640981c558439d83ec8a48895c116f3c
PARENT b9834b7ff2a7c16a216182655157b255bd0ad28a
TREE a5697035a28435bdd2a111afddeae412cc76d15f
SUBJECT R2A-01 contain regulated launch boundaries

M	app/api/admin/jobs/route.ts
M	app/api/admin/marketplace/route.ts
M	app/api/marketplace/route.ts
M	app/pasar/page.tsx
M	tests/job-posting-safety.test.ts
M	tests/marketplace-compliance.test.ts
M	tests/phase4-production.test.ts
COMMIT 3602a09a3b85161eae45101eb8339c68591612ea
PARENT e78ba12a640981c558439d83ec8a48895c116f3c
TREE 6676178a4a8c7131c2f95679303e33c8ed7a2305
SUBJECT R2A-02A establish privacy governance foundation

A	docs/duta-v2.5/R2A02_CROSS_BORDER_PROCESSING_REGISTER.md
A	docs/duta-v2.5/R2A02_DATA_PROCESSING_INVENTORY.md
A	docs/duta-v2.5/R2A02_DPIA_FRAMEWORK.md
A	docs/duta-v2.5/R2A02_DPO_REQUIREMENT_ASSESSMENT.md
A	docs/duta-v2.5/R2A02_PRIVACY_NOTICE_FRAMEWORK.md
A	docs/duta-v2.5/R2A02_VENDOR_PROCESSOR_REGISTER.md
A	tests/r2a02-governance.test.ts
COMMIT fbe268f0e1799e35a2c3dd5dcb3c8b5007e04cc3
PARENT 3602a09a3b85161eae45101eb8339c68591612ea
TREE 921fa4b052a0445f8435c91eab244c091ee58435
SUBJECT MA-01 establish forward migration authority

A	db/migrations/forward-authority-baseline.json
A	docs/duta-v2.5/MIGRATION_AUTHORITY.md
COMMIT e1acf0a176f8b430172c889ca5645b6fab0638f5
PARENT fbe268f0e1799e35a2c3dd5dcb3c8b5007e04cc3
TREE 2d0060034dd31addcef5fb10a2483e80093056b2
SUBJECT MA-02 add forward migration manifest

A	db/migrations/forward-manifest.json
A	tests/migration-manifest.test.ts
COMMIT 6f53640c35694926e03cfa80bd696b99f83b9011
PARENT e1acf0a176f8b430172c889ca5645b6fab0638f5
TREE 463622717d79db0e7e5459089ef2eb268de1d6f6
SUBJECT MA-02 harden migration manifest validator

M	tests/migration-manifest.test.ts
COMMIT 67312b8de35f40983ebfdf394a0130ee1d20c84b
PARENT 6f53640c35694926e03cfa80bd696b99f83b9011
TREE 6d56b64281c59466cda0d77dde81cd9bf988545d
SUBJECT MA-03 establish migration validation contract

A	docs/duta-v2.5/MIGRATION_TEMPLATE.md
A	docs/duta-v2.5/MIGRATION_VALIDATION_CONTRACT.md
A	tests/migration-authority.test.ts
COMMIT cce8876016ac01ee4b19224b5145ef54e4bede3a
PARENT 67312b8de35f40983ebfdf394a0130ee1d20c84b
TREE 4b1bf7d906fde3b82de7b98912e19b98af7fdee3
SUBJECT MA-04 establish migration execution protocol

A	docs/duta-v2.5/MIGRATION_APPLIED_STATE_TEMPLATE.md
A	docs/duta-v2.5/MIGRATION_EXECUTION_PROTOCOL.md
COMMIT f35d04e5cbd36a05bf18c1840bd2df9d25bc49bc
PARENT cce8876016ac01ee4b19224b5145ef54e4bede3a
TREE f47247857d8520072191b777e14fe20569721aad
SUBJECT MA-05 establish repository migration enforcement

M	package.json
A	scripts/check-migration-authority.mjs
M	tests/migration-authority.test.ts
A	tests/migration-repository-enforcement.test.ts
COMMIT 9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5
PARENT f35d04e5cbd36a05bf18c1840bd2df9d25bc49bc
TREE 7c9f94039e8708c3ed3da584cf9918f1ce708e49
SUBJECT SR-01 author proposed migration 0039

A	db/migrations/0039_source_registry_governance_foundation.sql
M	db/migrations/forward-manifest.json
A	docs/duta-v2.5/migrations/0039_VALIDATION.md
A	tests/db/migrations/0039/prestate.sql
A	tests/db/migrations/0039/security-verify.sql
A	tests/db/migrations/0039/verify.sql
M	tests/migration-authority.test.ts
M	tests/migration-manifest.test.ts
M	tests/migration-repository-enforcement.test.ts
COMMIT e88d1d6080c4753c511502fdf5ba8922eee236c5
PARENT 9865917b6c8a6da4d5cf90df5a82d90dc6c07cd5
TREE 89a8ea8a5521282b8b305ce899f655aa10bdcdb6
SUBJECT SR-01 strengthen 0039 validation harness

M	tests/db/migrations/0039/security-verify.sql
M	tests/db/migrations/0039/verify.sql
COMMIT fd90130fb07922ee083d0fe8bb5949118ee4eaaf
PARENT e88d1d6080c4753c511502fdf5ba8922eee236c5
TREE 4623cf4cf88ab497eddd081885cc3a47aee98ad2
SUBJECT SR-01 complete 0039 structural verification

M	tests/db/migrations/0039/verify.sql
COMMIT 2e180c11496e5053c5b1f72cb37492c8d09ab47e
PARENT fd90130fb07922ee083d0fe8bb5949118ee4eaaf
TREE 7066e6ed6294539a8e605b6e055c302330d15f46
SUBJECT SR-01 harden 0039 structural assertions

M	tests/db/migrations/0039/verify.sql
COMMIT 253517110c2488bfcb86616a3d36e9746f846670
PARENT 2e180c11496e5053c5b1f72cb37492c8d09ab47e
TREE a4bd53d5af614f22e6bdf390ceb406c4a5aad902
SUBJECT SR-01 prepare isolated 0039 local validation runner

A	scripts/run-0039-local-validation.ps1
COMMIT ee795c9c57936498ec6ccb7050addbdbe66da473
PARENT 253517110c2488bfcb86616a3d36e9746f846670
TREE e40436c04ce00eee24047060e964ddc4dae69286
SUBJECT MA-05 use threads for repository enforcement

M	package.json
COMMIT eb529f7c9d92902e262ae15d78cb7849262af073
PARENT ee795c9c57936498ec6ccb7050addbdbe66da473
TREE 3aea80757a804ea93ed8a23ecebd2e0b86daeaed
SUBJECT SR-01 fix 0039 verifier catalog array types

M	tests/db/migrations/0039/verify.sql
```
