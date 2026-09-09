# DUTA 2.5 migration and phase plan

## Day 0.5 status correction

Toolchain availability is restored for validation shells using a process-only prefix override, without reinstalling. Lint, typecheck and production build passed; tests report 24 passed and 6 failures due to absent APP_DATABASE_URL. Do not connect production services or install packages merely to bypass these failures. Credential rotation/containment remains required. Four missing journal-referenced files and thirteen unjournaled SQL files are confirmed; two missing paths have reachable history, but no migration was restored or applied. Day 1 remains blocked pending a separately authorized baseline-remediation task. See DAY0_5_BASELINE_RECOVERY.md; the original phase plan below has not been implemented.

Day 0 is complete as inspection/documentation, but the Day 1 gate is NO. Four validation commands could not start due to the missing npm CLI target. Tracked credentials and high-severity repository policy concerns need assessment. This document is a proposed later sequence, not permission to implement now.

## Preservation principles

Develop on duta-v2.5; keep main stable. Preserve application routes, current Supabase identities/data, official directory and working services. Do not rebuild from scratch or import another workspace. Reconcile migration history and real schema before proposing additive changes. Never replay bootstrap SQL against an existing database as a shortcut.

Use additive, reviewed migrations with forward compatibility and explicit deployment order. Establish an authorized backup/restore test first. Keep new provider/voice/RAG modules behind independent server flags. Support old text contracts through adapters until consumers migrate. New optional tables should not change existing behavior while flags are off.

Rollback means disable the relevant feature, select the safe provider/template fallback, and redeploy the previous compatible application. Preserve data and avoid destructive down migrations; plan forward repair for schema issues. Repeated requests must be idempotent. A provider outage must not block navigation/account/data modules.

Use isolated Preview credentials/data under a later authorized setup, never assume a preview deployment has isolated Supabase data. No staging folder was accessed or used for this audit. Separate private conversation/voice consent from existing login. Long-running realtime infrastructure may move outside Vercel without changing domain authorization or tools.

## Proposed phases and exit gates

| Phase | Scope | Exit gate |
|---|---|---|
| DAY 1 — architecture/foundation | First restore validation availability in an authorized task; assess/revoke exposed sessions as appropriate, verify sensitive RLS/grants, reconcile migration baseline; settle boundaries/flags/contracts | Known executable baseline, critical/high exposure decisions, no unexplained auth drift; extend Day 1 if needed |
| DAY 2 — provider abstraction | Typed requests/results/errors, server registry, deterministic adapter and capability flags | Mock contracts and disabled-provider non-AI regression pass |
| DAY 3 — NVIDIA hosted inference | One configurable adapter; model selected through Indonesian/Malay evaluations, budgets/timeouts/fallback | Hosted Preview contract/latency/safety tests; no credential leakage |
| DAY 4 — router/orchestrator | Separate transport, source policy, orchestration and response validation; retain conservative templates | Official/safety precedence, injection and failure-path tests |
| DAY 5 — trusted knowledge/RAG foundation | Reviewed source/revision metadata, additive schema proposal, ingestion/dedup/chunk/version design; initially small verified corpus | Approved provenance/access/deletion design and retrieval evaluation; no broad unsupervised ingestion |
| DAY 6 — DUTA tool calling | Read-only official/consulate/jobs/community/marketplace/organization services after refactor | Authorization, tenant isolation, bounded query/output and source metadata tests |
| DAY 7 — voice input prototype | Optional push-to-talk, consent, bounded ASR, editable transcript, cancellation | Permission denial/mobile/network failures leave text usable |
| DAY 8 — voice output prototype | Optional TTS of validated text, playback/stop, cost limits | Text/source parity and playback compatibility |
| DAY 9 — voice-first UI | Accessible responsive states, interruption/retry, capability-driven controls; PWA planning | Actual supported browser/device checks, no private offline caching |
| DAY 10 — security/testing | Threat model, negative RLS/tool tests on authorized isolated data, provider injection/evasion, deletion and abuse checks | Security risks triaged; meaningful unit/integration/browser/build checks pass |
| DAY 11 — Preview beta | Explicitly staged rollout with isolated data, observability, flags, bounded user cohort | Failure drills, latency/cost/reliability and feedback reviewed |
| DAY 12 — production readiness | Backup/restore/rollback proof, retention/operations review, supported browser matrix, release decision | Explicit release authorization and evidence; no automatic production promotion |

These are dependency stages, not a guarantee of twelve calendar days. Day 1 security/reproducibility work takes priority; defer RAG/tool/voice activation rather than bypass unresolved permissions. No model, provider contract, production deployment or database migration is approved by this plan.

## Top five Day 1 priorities

1. Resolve npm launcher availability and run the existing test/lint/typecheck/build baseline without silently changing dependency versions.
2. Contain tracked session/password exposure and verify direct-client user-role and organization-membership policy restrictions.
3. Reconcile migration journal, missing files, runtime grants and actual schema provenance before any additive migration.
4. Align organization/API authorization paths and document real versus preview module contracts.
5. Establish provider/input/output/source-policy interfaces and independent off-by-default flags, preserving current text fallback.
