# KPP-02R.3 — Keep / Change / Build / Defer / Remove Matrix

Status: classification only, 2026-09-19. No disposition authorizes a code,
schema, configuration or deployment change. Frozen migrations remain migration
history; obsolete schema is forward-only reconciliation later.

| ID | Domain | Capability / requirement | KPP-02R.2 state / evidence | Disposition | Scope | Authority basis | Legal / Founder dependency | Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F-01 | Foundation | Free Member auth/profile, existing recovery/RLS | Auth APIs, Supabase bridge, RLS migrations | KEEP | Retain security foundation | Free Member / security | — | Supports authority; no payment required. |
| F-02 | Foundation | Google OAuth, passwordless email direction | No implementation | DEFER | Feature/release decision | Product candidates not selected | FOUNDER_REVIEW_REQUIRED | Authority does not select an auth provider. |
| F-03 | Foundation | Email/password compatibility | Existing auth, unfinished ceremony evidence | DEFER | Product-contract decision | Auth deferment | FOUNDER_REVIEW_REQUIRED | Do not revive/rework before auth decision. |
| F-04 | Foundation | Consumer payment/membership runtime/schema | Legacy `memberships`/`payments` | REMOVE | REMOVE_RUNTIME; REMOVE_SCHEMA_LATER; retain migration history | Free Member | Migration-history constraint | Consumer paywall conflicts; no historical rewrite. |
| H-01 | Hari Ini | Proactive intelligence / curated surfaces | Static cards/demo only | BUILD | New product capability | Hari Ini proactive | Source governance | Required features absent. |
| H-02 | Hari Ini | Personalization, Penting/Untuk Anda/Sekitar/Update/Lanjutkan | No supporting model/wiring | BUILD | Product/data/runtime later | Hari Ini contract | Privacy/location review | Required subcomponents absent. |
| T-01 | Tanya | Bounded public Tanya | API authorization requires Member | CHANGE | Access policy/runtime later | Public value before login | Abuse/safety controls | Public bounded access is required, not unrestricted AI. |
| T-02 | Tanya | Text and optional voice | Text + optional microphone/transcription UI | KEEP | Preserve multimodal interaction | Text + optional voice | Provider availability | Aligned; voice is not mandatory. |
| T-03 | Tanya | Intent, trusted retrieval, provenance, answer/action | Planner/source answer foundation; report/action incomplete | CHANGE | Product wiring | Trusted answer → action | Source feasibility | Useful base requires authority alignment. |
| T-04 | Tanya | Correction/report | No end-user correction flow | BUILD | Trust capability | Correction path | Human review | Required path absent. |
| I-01 | Trusted information | Official source registry/read | Registry, RLS and source read exist | KEEP | Retain foundation | Source governance | — | Useful evidence foundation. |
| I-02 | Trusted information | Fetch/verify/normalize/dedup/classify/prioritize/freshness/health | No complete worker/pipeline proven | BUILD | Engine subcomponents | Shared engine | Source terms/feasibility | Documentation/schema alone insufficient. |
| I-03 | Trusted information | Distribute to Hari Ini/Tanya/Info | No coherent distribution | BUILD | Integration capability | One truth system | — | Required consumers are disconnected. |
| IR-01 | Info Rantau | Content layer, browse/archive | Routed but empty/disabled | CHANGE | Content UX/data wiring | Preserve Info layer | Source availability | Keep route; make it layer not primary. |
| IR-02 | Info Rantau | Primary-nav legacy | Still flat primary nav | REMOVE | REMOVE_UI navigation treatment | Supersession S-05 | — | Info need not be mandatory primary nav. |
| N-01 | Navigation | Hari Ini/Tanya/Keperluan/Rantau/Saya + Jaga Diri | Flat list, missing hierarchy | CHANGE | IA/UI later | Current IA | — | Existing routes can be reorganized. |
| K-01 | Keperluan | Kerja and public official navigation | Generic jobs UI; SISKOP API separate | CHANGE | Wire source-first public discovery | Kerja contract | Source feasibility | Keep official foundation, align UI. |
| K-02 | Keperluan | Pasar public browse/connect | Withheld UI/API | CHANGE | Public discovery/connect only | Conditional Pasar | LEGAL_REVIEW_REQUIRED | Replace blanket containment only within authority. |
| K-03 | Keperluan | DUTA Map/Sekitar | Landing says unavailable | BUILD | Public information capability | Required IA | Privacy/location | No map implementation. |
| R-01 | Rantau | Kawan Rantau / Orang / Komuniti / Aktiviti | Community list only | BUILD | Hierarchy and capabilities | Rantau contract | Age/safety | Required surfaces absent. |
| R-02 | Rantau | Free Community join/leave/roles/feed/events/RSVP/report/transfer | Data foundations but no full runtime | BUILD | Granular community controls | Free community | Age/safety | Do not infer organization authority. |
| R-03 | Rantau | Creator eligibility / investment prohibition | No creator policy or investment guard | BUILD | Eligibility/moderation controls | Proportional + prohibition | LEGAL_REVIEW_REQUIRED | No passport default; behavior not keyword only. |
| L-01 | Layanan RI | Six-mission public source links/information | Public source UI/contact data; completeness not proven | CHANGE | Coverage/freshness/provenance | Public Layanan RI | Source verification | Preserve public access, verify completeness. |
| J-01 | Jaga Diri | Public AI-independent direct protection contacts/degraded fallback | Public route + fallback exists | KEEP | Preserve safety access | Safety must not be gated | Source freshness | Strongest current alignment. |
| J-02 | Jaga Diri | Legal-help coverage, persistent calm shortcut | Partial; red/panic styling evidence | CHANGE | Content/IA/visual treatment | Priority not panic | Verified source only | Do not invent contacts. |
| P-01 | Pasar | Seller application/review/listing status/disclosures/connect | Schema/endpoints foundations; public flow withheld | CHANGE | Discovery/connect controls | Seller/listing separate | LEGAL_REVIEW_REQUIRED | Build only after legal gate. |
| P-02 | Pasar | Checkout/wallet/escrow/settlement/refund/delivery | No public execution proven | DEFER | Do not launch | Discovery + connect only | LEGAL_REVIEW_REQUIRED | Absence is intentional; not BUILD. |
| M-01 | Member | Saves/follows/alerts/history/personalization/RSVP/DUTA ID/points | Profile exists; benefits mostly absent | BUILD | Member capabilities | Free Member benefit | Privacy/anti-spam | Partner benefits excluded. |
| M-02 | Member | Points/badges non-cash, non-verification | No active points runtime proven | DEFER | Retain only if later designed | Gamification contract | FOUNDER_REVIEW_REQUIRED | Avoid creating incentive system by assumption. |
| O-01 | Organization | Entity model, verification, rep authority, scoped roles | Strong schema/APIs/RBAC base | KEEP | Preserve foundation | Entity distinction | — | Supports future scope. |
| O-02 | Organization | Paid CTA/software entitlement remnants | Organization subscriptions/payments schema | DEFER | Retain for evidence pending authority | Not consumer tier | FOUNDER_REVIEW_REQUIRED | Product entitlement direction unselected. |
| S-01 | Seller | Member→Seller eligibility, verification/review/revocation/appeal | Eligibility/verification schema, incomplete runtime | CHANGE | Forward-only seller controls | Seller separate from org/partner | LEGAL_REVIEW_REQUIRED | Keep private evidence and distinct statuses. |
| PA-01 | Partner | Partner application, screens, campaigns/disclosure/benefits | No partner domain | DEFER | Dormant until real approved partner | Partner-dependent | FOUNDER_REVIEW_REQUIRED | Do not invent partner launch capability. |
| B-01 | DUTA Belajar | Framework/modules/completion/tracks | Absent | BUILD | Secondary capability | DUTA Belajar | Content authority | Required product capability. |
| PH-01 | DUTA Photo | Upload/generation/deletion/retention/privacy | Absent | DEFER | Do not introduce speculative data flow | Not identity verification | Privacy/rights + FOUNDER_REVIEW_REQUIRED | Founder has not selected feature contract. |
| TS-01 | Trust/Safety | Cases/actions/evidence and moderator foundation | Schema/RLS/helpers exist | KEEP | Preserve foundation | Hybrid moderation | — | Useful technical base. |
| TS-02 | Trust/Safety | Human workflow: hold/hide/remove/restore/warn/restrict/suspend/reinstate/appeal | Incomplete runtime | BUILD | Scoped operations and appeal | Hybrid enforcement | Policy/human review | AI permanent ban is not a build target. |
| A-01 | Admin | Existing role model | Four platform roles | CHANGE | Expand scoped RBAC, not `admin=true` | Control Center | Security governance | Required domains/SOD incomplete. |
| A-02 | Admin | Dual approval, privileged auth/session/audit operations | No proof | BUILD | Admin safeguards | Least privilege/audit | Security policy | Required operational controls absent. |
| BN-01 | Broadcast | Preferences, scoped channels, approval/audit | Notifications table/bell only | BUILD | Governed notification center | No direct partner broadcast | Consent/privacy | No all-member shortcut. |
| TC-01 | Trust Center | Unified report/complaint/privacy/AI/appeal case flow | Reports/moderation fragmented | BUILD | Unified lifecycle | Trust Center | Privacy/legal | Schema does not equal user workflow. |
| AS-01 | Anti-spam | Rate limiting/quota | Auth/AI rate limit and quota exist | KEEP | Preserve foundation | Integrity | — | Useful bounded controls. |
| AS-02 | Anti-spam | Cross-surface abuse/duplicate/link/velocity/report/mass-message controls | Not proven | BUILD | Horizontal integrity | No mass messaging | Policy | Required breadth absent. |
| SH-01 | Shariah | Legal/Shariah separation, policy registry/reviewer | Absent | BUILD | Governance registry | Separate statuses | Qualified human review | No hard-coded conclusion. |
| PR-01 | Privacy | Deletion/RLS/telemetry minimization | SQL/docs and foundations exist | KEEP | Preserve foundation | Data minimization | — | Partial technical support. |
| PR-02 | Privacy | Privacy Center/DSAR/retention/vendor/DPIA/DPO/breach/incident | Not runtime-proven | BUILD | Governance operations | Privacy contract | LEGAL_REVIEW_REQUIRED | Cross-border unknown. |
| PR-03 | Security | Sessions/recovery/backups/degraded safety | Auth foundations/safety fallback partial | CHANGE | User continuity/incident operation | Continuity | Provider/recovery | Differentiate DB recovery from product UX. |
| SR-01 | Search | Organic/trust/freshness/sponsored separation | No ranking runtime | BUILD | Integrity layer | Paid != trusted | Sponsor policy | Required distinction absent. |
| IP-01 | IP | UGC/media rights/copyright/removal | No complete flow proven | BUILD | Rights/complaint capability | Asset rights | Legal review | Do not infer licenses. |
| AG-01 | Age | Final age gates/age assurance | No default passport/DOB flow | DEFER | No new age/passport flow | Proposed contract | LEGAL_REVIEW_REQUIRED | Passport is not a default Member requirement. |
| V-01 | Visual | Lightweight/mobile-first technical practices | Next Image/no hero video; no metrics | KEEP | Preserve existing lightweight basis | Human-cinematic lightweight | — | No measured performance claim. |
| V-02 | Visual | Human-cinematic runtime and anchor-preservation mechanism | KPP-03A.1 docs/assets only, no identity manifest/runtime consumption | CHANGE | Specification/asset governance later | Visual authority lock | Rights/consent | Preserve anchors; never substitute subjects. |
