# KPP-02R.2 Authority / Implementation Matrix

Status: read-only gap audit. Evidence levels: schema/API/UI are not equivalent
to runtime wiring, tests or deployment proof. `LEGAL_REVIEW_REQUIRED` denotes
unresolved applicability, never an inferred conclusion.

| Authority ID | Domain / requirement | Current repository state | Classification | Runtime evidence | Data/schema evidence | Test evidence | Legal dependency / risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A-01 | Public value before login; free Member | Landing/public discovery routes exist; member actions not consistently wired. | PARTIAL | `app/page.tsx`, public route pages | legacy memberships/payments | `consumer-membership-retirement.test.ts` | Paywall legacy risk |
| A-02 | Hari Ini proactive curated intelligence | Static service links and two demo nearby cards; no Penting/Untuk Anda/Update Resmi/Lanjutkan model. | MISSING | `app/beranda/page.tsx` | none found | landing tests only | Medium product/trust |
| A-03 | Tanya text + optional voice, source→answer→action | Text/UI voice transcription; auth-gated chat; official-required plan can source answer; no report/correction UI. | PARTIAL | `components/ai-chat.tsx`; `app/api/ai/chat/route.ts` | AI telemetry/quota tables | `ai-*.test.ts`, voice tests | AI/provider availability |
| A-04 | Shared trusted information engine | Source registry/read service exists; no proven fetch→verify→normalize→dedup→classify→prioritize worker or Hari Ini integration. | PARTIAL | `lib/services/sources.ts`; `lib/services/ai-router.ts` | `official_sources`, migration 0039 | source integrity tests | Source freshness/trust |
| A-05 | Info Rantau browse/archive layer | Route exists, most categories disabled and latest state empty; no feed linkage proven. | PARTIAL | `app/info/page.tsx` | source registry only | `info-rantau.test.ts` | Low-medium |
| A-06 | Public RI appointments/safety | Public Layanan and Jaga Diri with source/contact links and fallback directory. Six-mission freshness/link completeness not deployment-proven. | PARTIAL | `app/layanan/page.tsx`; `components/emergency-contacts.tsx` | official sources/emergency records | emergency/source tests | High safety/source review |
| A-07 | Jaga Diri persistent/elevated, calm, AI-independent | Public AI-independent route and direct contacts exist. Global nav uses red safety link/card and does not prove the new calm amber direction. | PARTIAL | `app/jaga-diri/page.tsx`; `components/app-shell.tsx` | emergency data | emergency tests | High safety UX |
| A-08 | Kerja is official-source discovery, no agency | Official SISKOP2MI API filters exist; `/kerja` reads generic jobs and exposes unwired “Pasang lowongan”. No ingestion proven. | PARTIAL | `app/api/jobs/official/route.ts`; `app/kerja/page.tsx` | jobs/external listings, migrations 0031-32 | job-source/posting tests | High regulatory/source |
| A-09 | Pasar discovery/connect only | UI/API are withheld; schemas/admin/create endpoints exist but current public discovery unavailable. No checkout runtime proven. | LEGACY | `app/pasar/page.tsx`; marketplace GET 503 | products/sellers, migration 0028 | marketplace tests | LEGAL_REVIEW_REQUIRED |
| A-10 | Community/Kawan Rantau free, scoped | Public list only; create CTA no evidenced action; no Orang/Aktiviti, join/leave/ownership transfer runtime. | PARTIAL | `app/komunitas/page.tsx`; API GET | communities/entities | community tests | Age/safety review |
| A-11 | Proportional Community Creator eligibility | No creator flow located; existing verification model is general. | NOT_VERIFIABLE | no wired flow found | verification tables | eligibility tests | Age/identity minimization |
| A-12 | Investment Community prohibition | No category/form/moderation rule specifically implementing this boundary found. | MISSING | no runtime evidence | generic moderation schema | moderation tests generic | High regulatory/safety |
| A-13 | Organization distinct from Seller | Entity/organization/seller foundations and scoped organization roles exist. Product UI/payment remnants remain. | PARTIAL | organization APIs/pages | `organizations`, `sellers`, eligibility | organization tests | Legal-status distinction |
| A-14 | Partner/sponsor controlled/dormant | No partner/campaign/broadcast runtime located. | MISSING | none found | no partner model found | none specific | High disclosure/governance |
| A-15 | DUTA Belajar secondary capability | No route/service/course model located. | MISSING | none found | none found | none specific | Certification claim must remain absent |
| A-16 | DUTA Photo not identity verification | No Photo/Selfie route or storage flow located. | NOT_APPLICABLE | none found | no dedicated model found | none specific | Privacy contract needed if introduced |
| A-17 | Hybrid moderation, appeal, audit | Moderation case/action/evidence schema/RLS and role helper exist; user report/appeal/control-center operations not runtime-proven. | PARTIAL | `lib/domain/moderation.ts` | migration 0033 | moderation-trust tests | High enforcement risk |
| A-18 | Scoped RBAC / Control Center | Four roles/capabilities and entity roles exist; required specialist roles, dual approval, MFA/session control and full audit UI missing. | PARTIAL | `lib/domain/rbac.ts`; admin pages | migration 0029/user roles | rbac tests | Privileged access |
| A-19 | Broadcast/notification governance | Notification table and visual bell; no preferences, all-member broadcast, scope/approval/audit system found. | MISSING | `components/app-shell.tsx` | notifications table | no specific tests | High consent/spam |
| A-20 | Trust Center complaints/appeals | Reports + moderation tables exist; unified public case/appeal architecture not found. | PARTIAL | domain moderation only | reports/cases/actions | moderation tests | High due process |
| A-21 | Anti-spam/platform integrity | In-memory rate limiting for registration/AI and AI quotas; no horizontal semantic/velocity/report-abuse/mass-action controls proven. | PARTIAL | `lib/rate-limit.ts`; auth/AI routes | quota tables | AI/auth tests | Abuse risk |
| A-22 | Shariah governance separate from legal | No policy registry/reviewer/versioned runtime found. | MISSING | none found | none found | none specific | Qualified review required |
| A-23 | Privacy/data lifecycle | Framework/register docs, deletion SQL and some minimization exist; no Privacy Center/DSAR runtime, retention execution, DPO/DPIA or cross-border conclusion. | PARTIAL | auth/telemetry service | deletion migration, telemetry tables | governance/telemetry tests | LEGAL_REVIEW_REQUIRED |
| A-24 | Security/incident/degraded operation | Auth/session/recovery, audit, RLS and safety fallback exist; user-facing incident/compromised-account flow not found. | PARTIAL | `lib/auth/**`; contact fallback | RLS/security migrations | security tests | High continuity |
| A-25 | Search/recommendation integrity | No general search/ranking/sponsored separation runtime found. | MISSING | search UI filters only | source trust field | AI source-ranking test | Sponsorship trust risk |
| A-26 | Age proposed, no default passport | Registration has no DOB/document; no default passport flow found. Final age contract absent from runtime by design. | MATCH | `app/api/auth/register/route.ts` | no DOB in schema | auth tests | LEGAL_REVIEW_REQUIRED |
| A-27 | Required IA/navigation | Existing nav: Beranda/Tanya/Layanan/Jaga/Komunitas/Kerja/Pasar/Organisasi/Info/Saya. Required KEPERLUAN/RANTAU hierarchy and Map/Orang/Aktiviti absent. | CONFLICT | `components/app-shell.tsx` | n/a | landing/navigation tests | Medium UX |
| A-28 | Founder visual anchors locked | KPP-03A.1 assets/specs exist; no explicit two-subject identity manifest/reference was located in runtime, and runtime does not consume those assets. | PARTIAL | `app/page.tsx` | prototype docs/assets | visual checks | Rights/consent required |
| A-29 | Lightweight human-cinematic | Next Image used, no autoplay video found; current landing is symbol/card-based rather than human-cinematic. No measured web vitals. | PARTIAL | `app/page.tsx`; CSS | n/a | landing tests | Performance unmeasured |

## Test coverage interpretation

The repository has targeted unit/repository tests for AI, sources, RBAC,
moderation, jobs, marketplace, community, migrations, RLS and auth. This is
`PARTIALLY_TESTED` across technical foundations. It is not evidence of full
product behavior, source freshness, provider operation, visual conformance,
legal compliance, or deployed-production behavior.
