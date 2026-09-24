# DUTA RANTAU v2.5 — Codex Handover Checkpoint

## Checkpoint identity

- Generated: 2026-09-24T18:15:04+08:00
- Workspace: `D:\DUTA-RANTAU`
- Branch: `duta-v2.5`
- Authoritative HEAD: `46fd72ed1771335583db3e5858a069cc064a2a4e`
- HEAD subject: `feat(sources): govern Malaysia official source registry`
- `origin/duta-v2.5`: `46fd72ed1771335583db3e5858a069cc064a2a4e`
- Relationship: local and remote are identical (`ahead 0`, `behind 0`; merge base is the authoritative HEAD).
- Index: clean; no staged files.
- Worktree: dirty and intentionally preserved. See the complete inventory below.
- H0 activity boundary: documentation only. No test, build, database connection, migration, deployment, environment change, commit, or push was performed.

## How to use this checkpoint

Treat the repository and this file as the continuation source. Preserve all dirty work. Do not reset, clean, stash, checkout over, stage wholesale, or reapply completed database work. Capability labels mean:

- `CLOSED_PASS`: accepted evidence exists and the gate must not be restarted without a new defect.
- `ACTIVE`: current uncommitted work or the immediate open checkpoint.
- `IMPLEMENTED`: code exists; runtime or product completion may still need a bounded proof.
- `PARTIAL`: useful implementation exists with a named remaining gap.
- `DISCONNECTED`: implementation exists but a required runtime connector is absent.
- `HIDDEN_BY_DESIGN`: intentionally not shown to users.
- `GOVERNED_OFF`: deliberately unavailable because policy, verification, or execution authority is absent.
- `DEFERRED`: intentionally postponed.
- `RECOVERY_UNRESOLVED`: prior implementation is reported but historical provenance was not recovered conclusively.
- `GENUINELY_MISSING`: no current implementation evidence.
- `OPEN`: known work remains.

## Authoritative checkpoint ledger

### Authentication — `CLOSED_PASS`

Evidence: commits `16a7de1` (honest Preview auth availability), `e6b214b` (runtime auth dependency remediation), password recovery commit `c26fa22`, auth routes and focused auth tests. Founder-observed acceptance established successful password signup, confirmation email, activation callback, login to `/beranda`, and authenticated `/api/auth/me` profile/session/role resolution. The signup HTTP 500 was caused by a Supabase Custom SMTP credential misconfiguration and was corrected outside application code. Password recovery/reset routes and tests are present.

Current user-facing state: signup, confirmation, login, session recognition, `/api/auth/me`, and password recovery/reset are implemented.

Remaining gap: email deliverability hardening because confirmation mail may land in Spam.

DO NOT REPEAT: do not reopen the SMTP incident as a database, callback, migration, or application-code defect without new evidence. Never record Founder PII, cookies, tokens, UUIDs, or SMTP/API credentials.

### DUTA AI — `IMPLEMENTED`

Evidence: deterministic routing, provider adapters, execution plan, quota/fair-use, telemetry, source ranking, injection resistance, provider smoke observability (`bed0530`), and authoritative source retrieval tests. Gemini/Groq/OpenAI text provider architecture and controlled provider fallback exist. Authoritative source fallback remains a separate decision from provider fallback.

Current user-facing state: Tanya DUTA accepts text and voice-derived text, routes through governed tools/providers, and returns controlled failure when provider or authoritative evidence is unavailable.

Remaining gap: one representative post-0044 staging E2E authoritative-source proof (`P5-R3`).

DO NOT REPEAT: do not weaken `AUTHORITATIVE_SOURCE_REQUIRED`, fabricate an answer, or treat a provider fallback as a source fallback.

### Voice / ASR — `ACTIVE`

Evidence: browser voice flow (`ad85875`); OpenAI transcription alignment (`dbb648b`); Groq primary with OpenAI fallback (`704b3a1`); safe fallback diagnostics (`a838298`); focused ASR/voice tests and prior successful Founder runtime evidence. Internal provider results preserve diagnostics and a fallback diagnostic chain.

Current user-facing state: authenticated browser capture posts multipart audio to `/api/ai/transcribe`; Groq is primary and OpenAI is fallback; controlled failure permits typing.

Remaining gap: `P5-R2` public diagnostic containment is present as an uncommitted route diff and must be reviewed/validated before commit. Do not rerun broad provider acceptance during H0 continuation.

DO NOT REPEAT: do not revert R6/R6D, remove internal diagnostics, expose provider bodies/secrets, or rebuild ASR architecture.

### Official sources / migration 0044 — `CLOSED_PASS`

Evidence: authoritative commit `46fd72e`; `db/migrations/0044_malaysia_official_source_registry.sql`; typed registry; Info Rantau normalization/dedupe foundation; local PostgreSQL migration/RLS verification evidence; source retrieval tests; Commit-A and origin push. Founder handover evidence records the shared-staging apply and post-apply verification.

Verified shared-staging state:

- migration 0044 has already been applied to shared staging;
- 27 official-source rows exist;
- 27 governance rows exist;
- all six Malaysia RI missions have a P0 `CONSULAR_SERVICE` website record;
- restricted `duta_app` can see active official sources through the governed read path.

Production state: migration 0044 has **not** been executed in Production.

DO NOT REPEAT: **do not reapply migration 0044 to shared staging**. Do not apply it to Production without a separate Founder authorization and release gate. Do not weaken RLS, grant `BYPASSRLS`, or elevate `duta_app`.

## Feature Recovery Ledger

| Capability | Status | Evidence | Current user-facing state | Remaining gap / next action | Do not repeat |
|---|---|---|---|---|---|
| Landing / R2.1 UX | IMPLEMENTED | `aa7fa2b`, `d0c8f8a`, R2/R2.1/R2.1-F proof artifacts | Public landing and responsive visual system exist | Preserve active CSS polish; review separately | Do not restart visual port |
| Hari Ini | IMPLEMENTED | `aba1fa4`, member/public components and proof states | Public/member states with truthful empty states | Connect more real account data only in later CONNECT phase | Do not invent activity |
| Tanya DUTA | ACTIVE | `88c4cd9`, `ad85875`, AI route/provider tests | Text, answer, source display, voice entry, controlled failures | Finish P5-R2 containment review, then P5-R3 source journey | Do not replace routing architecture |
| Voice | ACTIVE | R4/R5/R6/R6D commits and current route diff | Groq primary, OpenAI fallback, typed browser flow | Validate minimal public response containment | Do not expose diagnostics publicly |
| Keperluan | IMPLEMENTED | `4d319ec`, `/layanan`, mission registry | Six RI mission discovery and governed service links | Periodic endpoint verification | Do not claim DUTA performs appointments |
| Info Rantau / News | RECOVERY_UNRESOLVED | `search_news`; 27-source registry; `info-rantau-ingestion`; mission registry; `/info` containment | Curated official links and ingestion/dedupe foundation; UI does not claim a live feed | Recover historical connector provenance before deciding to reconnect or rebuild | Do not say News was never implemented; do not build a new engine during handover |
| RI mission discovery | IMPLEMENTED | mission registry, official emergency data, six P0 source records | Six Malaysia missions discoverable by region/service | P5-R3 representative staging proof | Do not repeat six-mission governance gate |
| Appointment/service routing | IMPLEMENTED / GOVERNED_OFF per endpoint | mission registry separates appointment URLs from NEWS | Verified endpoints may open; uncertain endpoints remain disabled | Reverify only endpoints marked pending/unclear | Do not ingest appointment URLs as news |
| Jaga Diri | IMPLEMENTED | `4cb805a`, `1601cef`, emergency contact tests | Persistent safety access and official contact paths | Routine evidence freshness | Do not hide behind account/paywall |
| Community | IMPLEMENTED | moderated submission/membership routes, migration 0042, tests | Discovery, submission, membership under moderation | Connect richer real content after technical gate | Do not auto-publish user claims |
| Organizations | IMPLEMENTED | organization routes, ownership/membership, 0042/0043 | Creation and owner-scoped management foundations | Continue capability connection under permissions | Do not collapse org representative into verified person |
| Secretary / organization tools | PARTIAL | secretary generation, publication draft, meeting transcription routes | Permission/plan-gated draft generation exists | Runtime/provider and product acceptance for each tool | Do not imply publication without review |
| Jobs | IMPLEMENTED / PARTIAL | job routes, moderated submission, official job source foundation | Information, discovery, connection, moderated contributions | Connect approved official/employer sources | DUTA must not act as placement agency |
| Pasar Rantau | IMPLEMENTED / PARTIAL | marketplace routes, seller/compliance models | DISCOVER → EVALUATE → CONNECT; moderated listings | Improve verified supply and handoff | No checkout, wallet, escrow, payment, refund, or delivery execution |
| Notification Inbox | IMPLEMENTED | bounded inbox/supporting-surface commit `562e767`, notification policies | Account notifications when real records exist | Connect real events progressively | Do not add a sixth bottom-nav item |
| DUTA Belajar | IMPLEMENTED / PARTIAL | `/belajar`, bounded-learning tests | Honest discovery surface with no invented catalogue/progress | Connect real curriculum/catalogue later | Do not fabricate progress/certificates |
| Saya / Profile | IMPLEMENTED | `a93cdc0`, profile/user routes | Profile and account world exists | Connect additional verified data carefully | Do not equate membership with verification |
| DUTA Map / Sekitar | PARTIAL / GOVERNED_OFF | `/sekitar`, deterministic unavailable tool path | Manual area selection; no precise GPS | Connect privacy-safe location sources later | Precise device location remains disabled |
| E-Undi | DEFERRED | No accepted current execution evidence | Not an active voting execution product | Separate legal/security/product design gate | Do not invent or expose voting execution |
| MyDigital ID | DEFERRED | No accepted connector evidence | No live identity-provider integration | Provider/legal/security agreement first | Do not equate DUTA profile with government identity |
| CCTV / family monitoring | GOVERNED_OFF | Product/privacy boundary; no accepted surveillance connector | Not offered | Separate consent, privacy, child-safety, and legal gate | Do not invent a new minor/age rule |
| Photo | GENUINELY_MISSING beyond profile/avatar basics | No accepted standalone photo capability evidence | No standalone product | Define product need after recovery/connect phase | Do not infer from visual assets |
| Points | GENUINELY_MISSING | No accepted points ledger/reward evidence | No points program | Founder product decision and abuse/economics design | Do not fabricate balances |
| Wallet/payment/escrow | GOVERNED_OFF | Marketplace/finance governance | Inform and connect only | Authorized-party integration and regulatory gate | DUTA executes no payment, refund, wallet, escrow, or delivery |

## News / Info Rantau recovery detail

Founder reports that official News / Info Rantau was previously live-connected and tested. Available Git refs did not conclusively recover that historical live connector. Its correct status is `RECOVERY_UNRESOLVED`, not “never implemented.”

Current evidence:

- `search_news` exists as a deterministic tool route but may return controlled unavailable state.
- `lib/official-source-registry.ts` contains all 27 approved Malaysia sources.
- `lib/services/info-rantau-ingestion.ts` supplies deterministic normalization, canonicalization, cross-source dedupe, richer-source upgrade, idempotency, and provenance.
- `lib/mission-registry.ts` contains six mission websites, news URLs, official social channels, and purpose-separated service URLs.
- `/info` truthfully contains current UI and does not claim uncontrolled automatic ingestion.
- Platform adapters/feeds/APIs/collectors must be proven from repository/runtime evidence. Do not fake them.

Next recovery action after the technical gate: search available historical artifacts and operational records for the prior connector implementation and credentials/configuration names without exposing values. Decide RECOVER versus CONNECT only after provenance is established.

## Product and regulatory locks

- Consumer membership: **FREE**.
- Core navigation: **Hari Ini · Tanya DUTA · Keperluan · Rantau · Saya**.
- Jaga Diri remains separate and persistent.
- Notification Inbox does not become a sixth bottom-navigation item.
- Pasar Rantau: **DISCOVER → EVALUATE → CONNECT**.
- Finance: **INFORM → CONNECT → AUTHORISED PARTY EXECUTES**.
- Jobs provide information, discovery, connection, and moderated submission. DUTA is not a worker-placement agency.
- Citizen Report is private/moderator-first.
- Precise device location is disabled.
- Do not invent a new age/minor rule.

## Identity and trust model

Keep these identities separate:

1. Visitor
2. DUTA Member
3. Verified Person
4. Seller
5. Organization Representative
6. Partner

A Member is not automatically a Verified Person. A Seller or Organization Representative requires entity/authority checks separate from personal membership. Partner status requires its own agreement and permissions. User-generated content remains labeled and moderated; official-source trust does not transfer to unrelated claims. Publication, verification, eligibility, and execution authority are separate decisions.

## Current open checkpoint: P5-R2

### P5-R2A exact route inspection result

`app/api/ai/transcribe/route.ts` already has an unrelated/uncommitted worktree change relative to HEAD.

HEAD failure response contains:

```ts
{ error, code: "TRANSCRIPTION_PROVIDER_UNAVAILABLE", errorCategory: result.errorCategory, diagnostics: result.diagnostics, diagnosticChain: result.diagnosticChain }
```

Current worktree failure response contains only:

```ts
{ error, code: "TRANSCRIPTION_PROVIDER_UNAVAILABLE" }
```

The current worktree therefore removes provider diagnostic metadata from the public 503 response. Authentication, multipart validation, MIME checks, 10 MiB size limit, ASR invocation, success response, and generic catch remain unchanged in this one-line diff. Internal ASR diagnostics remain in the provider layer at HEAD.

Classification: `ACTIVE`. The earlier reported PowerShell attempt stopped before `Set-Content`, but the present repository now contains the containment diff. Do not assume its provenance; preserve it and review it as current dirty work.

Recommended minimal next step: inspect the one-line diff and associated focused route/ASR tests, then validate only the public-response contract and internal diagnostic preservation. If accepted, stage this route deliberately with its own workstream. Do not blindly reapply the replacement and do not include visual changes accidentally.

## Expected next checkpoints

1. **P5-R2 — Public ASR diagnostic containment**: review and validate the existing minimal route diff.
2. **P5-R3 — One representative post-0044 staging E2E regression proof**: use the real staging application path to prove the former empty-source blocker is gone. One authoritative-source journey is sufficient unless it reveals a new defect. This is not another six-mission governance test, full provider retest, or full voice retest.
3. **Final technical/security gate**.
4. Continue in this order: **TECHNICAL GATE → RECOVER → CONNECT → COMPLETE → AI ORCHESTRATION → KILLER UX → BUILD GENUINELY MISSING CAPABILITIES**.

## Open-risk register

| Risk | State | Required handling |
|---|---|---|
| Public ASR response previously exposed safe provider metadata | ACTIVE containment diff | Validate minimal route contract; preserve internal diagnostics |
| Dirty visual UX work mixed in worktree | ACTIVE | Preserve and review as a separate workstream |
| Historical live News connector provenance | RECOVERY_UNRESOLVED | Recover evidence before rebuild/reconnection |
| Post-0044 real application proof | OPEN | Run one representative P5-R3 staging journey after P5-R2 |
| 0044 Production state | GOVERNED_OFF | Not executed; requires explicit Founder authorization |
| Email Spam placement | OPEN, nonblocking | Deliverability hardening; do not reopen auth acceptance |
| External integrations and execution products | DEFERRED/GOVERNED_OFF | Require product, regulatory, security, and provider gates |

## Explicit DO NOT REPEAT list

- Do not reapply migration 0044 to shared staging.
- Do not reopen completed auth signup/login/callback/API acceptance without a new defect.
- Do not repeat six-mission registry/RLS/governance validation merely for handover.
- Do not rebuild the R2.1/R2.1-F visual port from scratch.
- Do not replace the Groq-primary/OpenAI-fallback ASR architecture.
- Do not remove internal ASR diagnostics or expose them in the public failure response.
- Do not say Info Rantau News was never implemented; use `RECOVERY_UNRESOLVED`.
- Do not weaken authoritative-source requirements to make an AI answer pass.
- Do not collapse identity classes or trust states.
- Do not add transactional marketplace/finance behavior outside the approved product boundary.
- Do not reset, clean, stash, or overwrite the dirty work listed below.
- Do not touch Production or apply Production migration 0044 without explicit Founder authorization.

## Dirty-work classification

No files are staged.

Tracked modifications:

| Path | Likely workstream | Checkpoint relation | Preserve | Safe for a handover commit |
|---|---|---|---|---|
| `app/api/ai/transcribe/route.ts` | P5-R2 diagnostic containment | Directly related | YES | Only after focused validation; keep separate from visual work |
| `app/visual-port.css` | Tanya DUTA interaction/voice visual refinement | Separate active work | YES | Not in P5-R2 commit; review with UI workstream |
| `components/ai-chat.tsx` | Tanya DUTA voice/composer UX refinement | Separate active work | YES | Not in P5-R2 commit; review with UI workstream |

Untracked grouping rules apply to every path in the exhaustive inventory:

- `AGENTS.md`, `CLAUDE.md`: local agent guidance; preserve; review before any commit.
- `*.pre-*`: point-in-time backups for ASR/Tanya work; preserve; do not commit with product code unless Founder explicitly chooses archival documentation.
- `docs/duta-v2.5/KPP_03A1R_*`: design/specification evidence; preserve; separate documentation review required.
- `docs/duta-v2.5/killer-product/visual-proof-r1/**`, `r2/**`, `r21/**`, `r21f/**`: generated visual proof, scripts, assets, and renders; preserve; never stage wholesale; commit only through a deliberate evidence package review.

## Exhaustive dirty-path inventory

The following is the authoritative path-level inventory captured at H0. `M` means tracked modification and `??` means untracked. No staged entries exist.

```text
M app/api/ai/transcribe/route.ts
M app/visual-port.css
M components/ai-chat.tsx
?? AGENTS.md
?? CLAUDE.md
?? CODEX_HANDOVER_CHECKPOINT.md
?? app/api/ai/transcribe/route.ts.pre-asr-diagnostic
?? app/api/ai/transcribe/route.ts.pre-r6d
?? app/visual-port.css.pre-tanya-ux
?? components/ai-chat.tsx.pre-tanya-ux
?? docs/duta-v2.5/KPP_03A1R_ASTRA_MASTER_EXPERIENCE_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_CODEX_IMPLEMENTATION_HANDOFF.md
?? docs/duta-v2.5/KPP_03A1R_COMPONENT_DESIGN_CONTRACT.md
?? docs/duta-v2.5/KPP_03A1R_DESIGN_TOKEN_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_FINAL_DESIGN_DECISION_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_FOUNDER_VISUAL_ANCHOR_MANIFEST.md
?? docs/duta-v2.5/KPP_03A1R_R20_EXPERIENCE_CONNECTIVITY_MAP.md
?? docs/duta-v2.5/KPP_03A1R_R20_FEATURE_COMPLETENESS_MATRIX.md
?? docs/duta-v2.5/KPP_03A1R_R20_HIDDEN_BY_DESIGN_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_R20_MISSING_DESIGN_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_R20_R2_DELTA_SCOPE.md
?? docs/duta-v2.5/KPP_03A1R_R20_RI_ROUTING_SOURCE_GAP_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_R21F_MICRO_POLISH_REPORT.md
?? docs/duta-v2.5/KPP_03A1R_R21_ACCESSIBILITY_PERFORMANCE.md
?? docs/duta-v2.5/KPP_03A1R_R21_AI_PHOTOGRAPHY_SYSTEM.md
?? docs/duta-v2.5/KPP_03A1R_R21_FINAL_FOUNDER_REVIEW.md
?? docs/duta-v2.5/KPP_03A1R_R21_FOUNDER_LOCK_RECONCILIATION.md
?? docs/duta-v2.5/KPP_03A1R_R21_REMAINING_DEPENDENCIES.md
?? docs/duta-v2.5/KPP_03A1R_R21_VISUAL_SIGNATURE_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_R21_WORLD_DIFFERENTIATION.md
?? docs/duta-v2.5/KPP_03A1R_R2_ATOMIC_RECONCILIATION.md
?? docs/duta-v2.5/KPP_03A1R_R2_CAPABILITY_CONNECTIVITY_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_R2_CODEX_03B_HANDOFF.md
?? docs/duta-v2.5/KPP_03A1R_R2_FOUNDER_DECISION_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_R2_GAYA_TEMAN_DUTA_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_R2_MASTER_VISUAL_REFINEMENT_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_R2_PERFORMANCE_DESIGN_BUDGET.md
?? docs/duta-v2.5/KPP_03A1R_R2_RI_MISSION_EXPERIENCE_SPEC.md
?? docs/duta-v2.5/KPP_03A1R_R2_SCREEN_STATE_REGISTER.md
?? docs/duta-v2.5/KPP_03A1R_SCREEN_STATE_REGISTER.md
?? docs/duta-v2.5/killer-product/visual-proof-r1/01-landing-desktop.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/02-landing-mobile.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/03-today.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/04-text.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/05-voice.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/06-answer.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/07-safety.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/08-needs.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/09-rantau.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/10-support.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/11-auth.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/12-activation.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/13-report.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/14-receipt.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/README.md
?? docs/duta-v2.5/killer-product/visual-proof-r1/build.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r1/index.html
?? docs/duta-v2.5/killer-product/visual-proof-r1/proof.css
?? docs/duta-v2.5/killer-product/visual-proof-r1/render.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/01-landing-desktop-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/01-landing-desktop.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/02-landing-mobile-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/02-landing-mobile.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/03-today-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/03-today.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/04-text-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/04-text.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/05-voice-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/05-voice.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/06-answer-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/06-answer.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/07-safety-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/07-safety.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/08-needs-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/08-needs.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/09-rantau-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/09-rantau.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/10-support-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/10-support.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/11-auth-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/11-auth.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/12-activation-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/12-activation.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/13-report-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/13-report.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/14-receipt-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/14-receipt.png
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/checks.json
?? docs/duta-v2.5/killer-product/visual-proof-r1/renders/contact-sheet.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/01-landing-desktop.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/02-landing-mobile.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/03-hari-public.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/04-hari-member.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/05-tanya-text.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/06-tanya-answer.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/07-tanya-voice.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/08-keperluan.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/09-kerja.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/10-layanan-ri.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/11-appointment.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/12-ri-updates.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/13-jaga-diri.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/14-location-consent.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/15-mission-result.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/16-manual-area.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/17-rantau.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/18-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/19-create-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/20-activity.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/21-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/22-create-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/23-pasar.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/24-seller.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/25-map.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/26-info.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/27-saya.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/28-belajar.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/29-privacy.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/30-trust.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/31-support.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/32-activation.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/FILES_CREATED.md
?? docs/duta-v2.5/killer-product/visual-proof-r2/README.md
?? docs/duta-v2.5/killer-product/visual-proof-r2/before-after.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/build.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r2/index.html
?? docs/duta-v2.5/killer-product/visual-proof-r2/manifest.json
?? docs/duta-v2.5/killer-product/visual-proof-r2/proof.css
?? docs/duta-v2.5/killer-product/visual-proof-r2/proof.js
?? docs/duta-v2.5/killer-product/visual-proof-r2/render.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/01-landing-desktop-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/01-landing-desktop.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/02-landing-mobile-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/02-landing-mobile.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/03-hari-public-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/03-hari-public.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/04-hari-member-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/04-hari-member.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/05-tanya-text-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/05-tanya-text.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/06-tanya-answer-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/06-tanya-answer.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/07-tanya-voice-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/07-tanya-voice.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/08-keperluan-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/08-keperluan.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/09-kerja-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/09-kerja.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/10-layanan-ri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/10-layanan-ri.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/11-appointment-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/11-appointment.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/12-ri-updates-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/12-ri-updates.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/13-jaga-diri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/13-jaga-diri.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/14-location-consent-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/14-location-consent.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/15-mission-result-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/15-mission-result.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/16-manual-area-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/16-manual-area.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/17-rantau-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/17-rantau.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/18-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/18-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/19-create-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/19-create-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/20-activity-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/20-activity.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/21-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/21-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/22-create-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/22-create-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/23-pasar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/23-pasar.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/24-seller-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/24-seller.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/25-map-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/25-map.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/26-info-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/26-info.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/27-saya-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/27-saya.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/28-belajar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/28-belajar.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/29-privacy-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/29-privacy.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/30-trust-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/30-trust.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/31-support-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/31-support.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/32-activation-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/32-activation.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/checks.json
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/contact-sheet.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/sheet-1.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/sheet-2.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/sheet-3.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/sheet-4.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-auth-success.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-case-appeal.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-kerja-stale.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-kinabatangan.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-location-denied.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-mission-tawau.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-tanya-outage.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-voice-listening.png
?? docs/duta-v2.5/killer-product/visual-proof-r2/renders/state-voice-searching.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/01-landing-desktop.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/02-landing-mobile.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/03-hari-public.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/04-hari-member.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/05-tanya-text.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/06-tanya-answer.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/07-tanya-voice.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/08-keperluan.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/09-kerja.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/10-layanan-ri.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/11-appointment.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/12-ri-updates.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/13-jaga-diri.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/14-location-consent.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/15-mission-result.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/16-manual-area.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/17-rantau.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/18-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/19-create-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/20-activity.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/21-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/22-create-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/23-pasar.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/24-seller.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/25-map.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/26-info.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/27-saya.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/28-belajar.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/29-privacy.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/30-trust.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/31-support.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/32-activation.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/FILES_CREATED.md
?? docs/duta-v2.5/killer-product/visual-proof-r21/README.md
?? docs/duta-v2.5/killer-product/visual-proof-r21/assets/ai-hari-commute.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/assets/ai-kerja-life.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/assets/ai-rantau-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/before-after.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/build.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r21/index.html
?? docs/duta-v2.5/killer-product/visual-proof-r21/manifest.json
?? docs/duta-v2.5/killer-product/visual-proof-r21/proof.css
?? docs/duta-v2.5/killer-product/visual-proof-r21/proof.js
?? docs/duta-v2.5/killer-product/visual-proof-r21/render.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/01-landing-desktop-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/01-landing-desktop.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/02-landing-mobile-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/02-landing-mobile.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/03-hari-public-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/03-hari-public.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/04-hari-member-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/04-hari-member.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/05-tanya-text-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/05-tanya-text.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/06-tanya-answer-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/06-tanya-answer.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/07-tanya-voice-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/07-tanya-voice.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/08-keperluan-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/08-keperluan.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/09-kerja-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/09-kerja.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/10-layanan-ri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/10-layanan-ri.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/11-appointment-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/11-appointment.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/12-ri-updates-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/12-ri-updates.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/13-jaga-diri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/13-jaga-diri.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/14-location-consent-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/14-location-consent.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/15-mission-result-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/15-mission-result.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/16-manual-area-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/16-manual-area.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/17-rantau-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/17-rantau.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/18-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/18-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/19-create-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/19-create-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/20-activity-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/20-activity.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/21-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/21-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/22-create-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/22-create-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/23-pasar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/23-pasar.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/24-seller-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/24-seller.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/25-map-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/25-map.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/26-info-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/26-info.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/27-saya-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/27-saya.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/28-belajar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/28-belajar.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/29-privacy-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/29-privacy.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/30-trust-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/30-trust.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/31-support-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/31-support.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/32-activation-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/32-activation.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/checks.json
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/contact-sheet.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/sheet-1.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/sheet-2.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/sheet-3.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/sheet-4.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-auth-success.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-case-appeal.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-kerja-stale.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-kinabatangan.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-location-denied.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-mission-tawau.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-tanya-outage.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-voice-listening.png
?? docs/duta-v2.5/killer-product/visual-proof-r21/renders/state-voice-searching.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/01-landing-desktop.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/02-landing-mobile.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/03-hari-public.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/04-hari-member.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/05-tanya-text.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/06-tanya-answer.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/07-tanya-voice.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/08-keperluan.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/09-kerja.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/10-layanan-ri.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/11-appointment.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/12-ri-updates.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/13-jaga-diri.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/14-location-consent.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/15-mission-result.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/16-manual-area.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/17-rantau.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/18-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/19-create-community.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/20-activity.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/21-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/22-create-organization.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/23-pasar.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/24-seller.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/25-map.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/26-info.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/27-saya.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/28-belajar.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/29-privacy.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/30-trust.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/31-support.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/32-activation.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/FILES_CREATED.md
?? docs/duta-v2.5/killer-product/visual-proof-r21f/README.md
?? docs/duta-v2.5/killer-product/visual-proof-r21f/assets/ai-hari-commute.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/assets/ai-kerja-life.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/assets/ai-rantau-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/before-after.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/build.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r21f/index.html
?? docs/duta-v2.5/killer-product/visual-proof-r21f/manifest.json
?? docs/duta-v2.5/killer-product/visual-proof-r21f/proof.css
?? docs/duta-v2.5/killer-product/visual-proof-r21f/proof.js
?? docs/duta-v2.5/killer-product/visual-proof-r21f/render.cjs
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/01-landing-desktop-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/01-landing-desktop.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/02-landing-mobile-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/02-landing-mobile.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/03-hari-public-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/03-hari-public.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/04-hari-member-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/04-hari-member.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/05-tanya-text-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/05-tanya-text.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/06-tanya-answer-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/06-tanya-answer.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/07-tanya-voice-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/07-tanya-voice.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/08-keperluan-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/08-keperluan.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/09-kerja-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/09-kerja.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/10-layanan-ri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/10-layanan-ri.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/11-appointment-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/11-appointment.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/12-ri-updates-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/12-ri-updates.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/13-jaga-diri-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/13-jaga-diri.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/14-location-consent-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/14-location-consent.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/15-mission-result-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/15-mission-result.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/16-manual-area-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/16-manual-area.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/17-rantau-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/17-rantau.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/18-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/18-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/19-create-community-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/19-create-community.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/20-activity-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/20-activity.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/21-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/21-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/22-create-organization-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/22-create-organization.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/23-pasar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/23-pasar.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/24-seller-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/24-seller.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/25-map-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/25-map.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/26-info-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/26-info.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/27-saya-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/27-saya.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/28-belajar-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/28-belajar.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/29-privacy-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/29-privacy.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/30-trust-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/30-trust.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/31-support-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/31-support.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/32-activation-full.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/32-activation.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/checks.json
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/contact-sheet.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/sheet-1.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/sheet-2.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/sheet-3.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/sheet-4.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-auth-success.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-case-appeal.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-kerja-stale.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-kinabatangan.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-location-denied.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-mission-tawau.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-tanya-outage.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-voice-listening.png
?? docs/duta-v2.5/killer-product/visual-proof-r21f/renders/state-voice-searching.png
?? lib/services/asr-provider.ts.pre-r6
?? lib/services/asr-provider.ts.pre-r6d
?? tests/asr-provider.test.ts.pre-r6
```

## Founder authorization boundaries for continuation

Explicit Founder authorization is required before:

- any shared-staging migration or data mutation;
- any Production migration, environment change, deployment, or promotion;
- applying migration 0044 anywhere beyond its already completed shared-staging application;
- committing or pushing mixed/dirty work when scope has not been reviewed;
- enabling external News collectors or adding provider credentials;
- enabling payment, wallet, escrow, delivery, identity-provider, surveillance, voting, or other regulated execution.

Read-only inspection and focused local validation may proceed when requested, while preserving dirty work and secrets.

## Exact next action

Start **P5-R2A/P5-R2 review** from the current one-line route diff. Confirm the public 503 response remains limited to the generic message and `TRANSCRIPTION_PROVIDER_UNAVAILABLE`, while internal provider diagnostics and `diagnosticChain` remain available server-side. Inspect whether focused tests currently assert public diagnostic exposure. Make no unrelated UI change. After a reviewed P5-R2 result, perform **P5-R3**, one representative post-0044 staging authoritative-source journey, then the final technical/security gate.

---

H0 HANDOVER PREPARED — WAITING FOR FOUNDER REVIEW
