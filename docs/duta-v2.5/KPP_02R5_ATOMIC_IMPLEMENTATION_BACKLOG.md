# KPP-02R.5 Atomic Implementation Backlog

Status: planning only. Every item is reversible where practical and requires
its listed evidence before completion. `L/S/P/F` = legal/Shariah/privacy/Founder
gate. Historical migrations are frozen evidence and never edited.

| ID | Title | Type | 02R3/02R4 | P | Wave | Readiness | Evidence / dependency | Build/change and done verification | Out of scope / safety |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W0-01 | Record age legal decision | LEGAL_DEPENDENCY | DEFER / LEGAL | P0 | 0 | BLOCKED_EXTERNAL | R4 LSP-01 | Store approved age decision record; legal evidence review | No DOB/passport flow. |
| W0-02 | Record Pasar legal boundary | LEGAL_DEPENDENCY | DEFER / LEGAL | P0 | 0 | BLOCKED_EXTERNAL | R4 LSP-02 | Record category/release decision; reviewed evidence | No transactions. |
| W0-03 | Obtain source-use feasibility | LEGAL_DEPENDENCY | BUILD / SOURCE | P0 | 0 | BLOCKED_EXTERNAL | R4 LSP-03 | Source terms/permission evidence recorded | No scraping/circumvention. |
| W0-04 | Establish Shariah review authority | SHARIAH_DEPENDENCY | BUILD / BLOCKED | P0 | 0 | BLOCKED_EXTERNAL | R4 LSP-05 | Qualified reviewer/policy authority evidenced | No fatwa by AI/Codex. |
| W0-05 | Resolve privacy/vendor register gates | LEGAL_DEPENDENCY | BUILD / LEGAL | P0 | 0 | BLOCKED_EXTERNAL | R4 LSP-04 | Cross-border/vendor/DPIA decision evidence | No geography/compliance claim. |
| W0-06 | Verify six-mission sources | VERIFICATION | CHANGE / SOURCE | P0 | 0 | READY_WITH_DEPENDENCY | source registry/emergency data | Per-mission link/verified/current/display states tested | Do not invent contacts. |
| W0-07 | Define public-safety release checklist | GOVERNANCE | KEEP / BOUNDARY | P0 | 0 | READY | `app/jaga-diri`, R4 G-01 | Checklist proves public/AI-independent/fallback state | No emergency authority claim. |
| W1-01 | Reconcile consumer payment runtime | REMOVE | REMOVE / — | P0 | 1 | READY | `memberships`, `payments` legacy schema | Remove consumer UI/runtime paths with regression tests | Forward-only schema later; retain history. |
| W1-02 | Create free-Member entitlement contract | FOUNDATION | BUILD / CONDITIONAL | P0 | 1 | READY | auth/profile foundations | Explicit free Member capability boundary/API tests | No subscription tier. |
| W1-03 | Reconcile primary IA model | CHANGE | CHANGE / — | P1 | 1 | READY | `components/app-shell.tsx` | HARI/TANYA/KEPERLUAN/RANTAU/SAYA + persistent Jaga Diri tests | No visual redesign here. |
| W1-04 | Demote Info primary-nav treatment | REMOVE | REMOVE / — | P1 | 1 | READY | app shell | Navigation contract test, Info retained as browse/archive | Do not delete Info. |
| W1-05 | Add public-access policy map | SECURITY | CHANGE / CONDITIONAL | P0 | 1 | READY | auth guards/routes | Route/API authorization matrix tests | Safety/help never gated. |
| W1-06 | Add public bounded-Tanya guard | SECURITY | CHANGE / BLOCKED | P0 | 1 | READY_WITH_DEPENDENCY | AI API/rate limit | Anonymous boundary + abuse/rate tests | Not unrestricted AI. |
| W2-01 | Source health model | DATA | BUILD / SOURCE | P0 | 2 | READY | `official_sources`, migration 0039 | Owner/status/checked/success/failure fields + RLS tests | No source claim without evidence. |
| W2-02 | Source verification workflow | OPERATIONS | BUILD / SOURCE | P0 | 2 | READY_WITH_DEPENDENCY | W0-03, source registry | Reviewer transition/audit tests | Terms gate remains. |
| W2-03 | Normalize/dedup/classify pipeline | BUILD | BUILD / BLOCKED | P1 | 2 | READY_WITH_DEPENDENCY | W2-01/02 | Idempotent fixtures/source tests | No raw social dump. |
| W2-04 | Prioritization/freshness engine | BUILD | BUILD / BLOCKED | P1 | 2 | READY_WITH_DEPENDENCY | W2-03 | stale/unavailable/current behavior tests | No paid trust input. |
| W2-05 | Distribution adapters | BUILD | BUILD / BLOCKED | P1 | 2 | READY_WITH_DEPENDENCY | W2-04 | Hari/Tanya/Info contract tests | One truth system. |
| W2-06 | Correction/version loop | BUILD | BUILD / BLOCKED | P1 | 2 | READY | reports/moderation foundation | source correction/audit tests | Report is not auto-truth. |
| W3-01 | Hari Ini public general state | BUILD | BUILD / BLOCKED | P1 | 3 | READY_WITH_DEPENDENCY | W2-05 | public curated empty/loading/error tests | Not chronological feed. |
| W3-02 | Hari Ini prioritized surfaces | BUILD | BUILD / BLOCKED | P1 | 3 | READY_WITH_DEPENDENCY | W3-01 | Penting/Update/Continue source provenance tests | No false RESMI. |
| W3-03 | Hari Ini personalized state | BUILD | BUILD / BLOCKED | P1 | 3 | READY_WITH_DEPENDENCY | Member contract, privacy gate | Untuk Anda/Sekitar consent boundary tests | No precise-location default. |
| W3-04 | Info browse/archive integration | CHANGE | CHANGE / CONDITIONAL | P1 | 3 | READY_WITH_DEPENDENCY | W2-05 | archive/freshness/provenance tests | Not primary mandatory nav. |
| W3-05 | Tanya source/action responses | CHANGE | CHANGE / BLOCKED | P1 | 3 | READY_WITH_DEPENDENCY | W2-05 | intent→source→answer→action API tests | No invented jobs/official facts. |
| W3-06 | Tanya correction/report UI | BUILD | BUILD / BLOCKED | P1 | 3 | READY_WITH_DEPENDENCY | W2-06 | report case/version integration tests | Human review required. |
| W3-07 | Tanya provider fallback | OPERATIONS | CHANGE / BLOCKED | P0 | 3 | READY | provider abstractions | provider outage/fallback tests | Voice optional. |
| W4-01 | Member profile lifecycle | CHANGE | CONDITIONAL | P1 | 4 | READY | profile/auth | profile authorization/API tests | No age decision embedded. |
| W4-02 | Saves/follows/RSVP | BUILD | BLOCKED | P2 | 4 | READY_WITH_DEPENDENCY | W1-02, entity scopes | per-user RLS/integration tests | No social spam. |
| W4-03 | Alerts/preferences/inbox | BUILD | BLOCKED | P1 | 4 | READY_WITH_DEPENDENCY | W1-02, privacy gate | consent/preferences tests | No broadcast shortcut. |
| W4-04 | Tanya history/personalization | BUILD | BLOCKED | P2 | 4 | READY_WITH_DEPENDENCY | privacy gate, W3 | retention/access tests | No sensitive prompt retention default. |
| W4-05 | Account deletion/compromise journey | SECURITY | CHANGE / LEGAL | P0 | 4 | READY_WITH_DEPENDENCY | deletion SQL/auth | E2E recovery/deletion/incident tests | Legal retention exceptions documented. |
| W5-01 | Rantau discovery hierarchy | BUILD | CONDITIONAL | P1 | 5 | READY | community/org foundations | Orang/Komuniti/Aktiviti/Org route tests | Discovery only where public. |
| W5-02 | Community join/leave/privacy | BUILD | BLOCKED | P1 | 5 | READY_WITH_DEPENDENCY | W1-02, W7 safety | RLS/public-private tests | Community remains free. |
| W5-03 | Creator eligibility adapter | SECURITY | LEGAL | P0 | 5 | BLOCKED_EXTERNAL | W0-01 | consumes future AGE_ASSURANCE_RESULT tests | No passport default. |
| W5-04 | Community roles/transfer/audit | BUILD | BLOCKED | P1 | 5 | READY_WITH_DEPENDENCY | W7 RBAC | owner/admin/mod/member transfer tests | Entity-scoped only. |
| W5-05 | Community UGC/events/polls | BUILD | BLOCKED | P1 | 5 | READY_WITH_DEPENDENCY | W7 moderation | moderation/RSVP/abuse tests | Investment purpose prohibited. |
| W5-06 | Organization status/rep separation | CHANGE | CONDITIONAL | P1 | 5 | READY | org/verification schema | status/authority display tests | Seller != Organization. |
| W6-01 | Kerja official discovery handoff | CHANGE | CONDITIONAL | P1 | 6 | READY_WITH_DEPENDENCY | W0-03, jobs endpoint | source/freshness/fallback tests | No placement/applications/fees. |
| W6-02 | Tanya JOB_SEARCH adapter | BUILD | CONDITIONAL | P2 | 6 | READY_WITH_DEPENDENCY | W3-05, W6-01 | no-invented-vacancy tests | Official navigation only. |
| W6-03 | Pasar seller/listing state machine | CHANGE | LEGAL | P0 | 6 | BLOCKED_EXTERNAL | W0-02, seller schema | separate seller/listing/review tests | No transaction capability. |
| W6-04 | Pasar public browse/connect/disclosure | CHANGE | LEGAL | P1 | 6 | BLOCKED_EXTERNAL | W6-03 | public disclosure/contact/report tests | Discover→Evaluate→Connect only. |
| W6-05 | Pasar complaint/revocation/appeal | BUILD | LEGAL | P1 | 6 | READY_WITH_DEPENDENCY | W7 case system | scoped seller/listing appeal tests | Private evidence only. |
| W6-06 | Map/Sekitar public information | BUILD | BLOCKED | P2 | 6 | READY_WITH_DEPENDENCY | privacy/source gates | location consent/source tests | No precise location default. |
| W7-01 | Control Center permission expansion | CHANGE | BLOCKED | P0 | 7 | READY | `lib/domain/rbac.ts` | scoped-role/least-privilege tests | No admin=true. |
| W7-02 | Moderation state transitions | BUILD | BLOCKED | P0 | 7 | READY | migration 0033/domain moderation | hold/hide/remove/restore audit tests | AI not final ban authority. |
| W7-03 | Human review/enforcement/appeal | BUILD | BLOCKED | P0 | 7 | READY_WITH_DEPENDENCY | W7-01/02 | reviewer/reinstate/scoped appeal tests | High-impact safeguards. |
| W7-04 | Trust Center unified cases | BUILD | BLOCKED | P1 | 7 | READY_WITH_DEPENDENCY | W7-03 | category/case/evidence tests | Privacy/AI reports included. |
| W7-05 | Anti-spam controls | SECURITY | BUILD | P0 | 7 | READY | rate-limit/quota foundation | link/velocity/duplicate/report-abuse tests | No public trust score. |
| W7-06 | Broadcast governance | BUILD | BLOCKED | P1 | 7 | READY_WITH_DEPENDENCY | W4-03/W7-01 | all-member preview/approval/audit tests | Partner no direct broadcast. |
| W7-07 | Privacy Center and rights requests | BUILD | LEGAL | P0 | 7 | READY_WITH_DEPENDENCY | W0-05/deletion foundation | access/correct/delete/retention tests | No false compliance claim. |
| W7-08 | Security incident/admin session controls | SECURITY | CHANGE | P0 | 7 | READY_WITH_DEPENDENCY | W7-01, provider ops | incident/re-auth/audit tests | No deployment claim. |
| W7-09 | Shariah policy registry | GOVERNANCE | BLOCKED | P1 | 7 | BLOCKED_EXTERNAL | W0-04 | policy/version/reviewer/audit tests | No fatwa automation. |
| W8-01 | DUTA Belajar framework/modules | BUILD | CONDITIONAL | P2 | 8 | READY_WITH_DEPENDENCY | content/source authority | completion/label tests | No certification claim. |
| W8-02 | Visual anchor manifest | FOUNDER_DEPENDENCY | FOUNDER | P1 | 8 | BLOCKED_EXTERNAL | R4 G-12 | non-biometric asset/rights/approval manifest verified | No face recognition/new imagery. |
| W8-03 | DUTA Photo governance design | FOUNDER_DEPENDENCY | DEFER | P3 | 8 | DEFERRED | R4 G-11 | approved consent/rights specification | No activation. |
| W8-04 | Points/badges decision | FOUNDER_DEPENDENCY | DEFER | P3 | 8 | DEFERRED | R3 U-08 | Founder decision record | No volume incentive. |
| W9-01 | Public-core release verification | VERIFICATION | — | P0 | 9 | READY_WITH_DEPENDENCY | Waves 1–6 | access/source/fallback E2E evidence | No deploy implied. |
| W9-02 | UGC/admin security verification | TEST | — | P0 | 9 | READY_WITH_DEPENDENCY | Wave 7 | RBAC/RLS/appeal/abuse test pack | No autonomous-ban approval. |
| W9-03 | Accessibility/responsive/degraded verification | TEST | — | P1 | 9 | READY_WITH_DEPENDENCY | relevant waves | keyboard/mobile/reduced-motion/outage checks | No visual redesign. |
| W9-04 | Release evidence pack | OPERATIONS | — | P0 | 9 | READY_WITH_DEPENDENCY | all prior evidence | traceable release-gate record | No release authorization itself. |
| W4-06 | Add Saya → Bantuan & Hubungi DUTA entry | UX_IMPLEMENTATION | BUILD / CONDITIONAL | P1 | 4 | READY | IA contract/W1-03 | Support entry routing tests | Not primary bottom nav. |
| W7-10 | Define shared case type/scoping foundation | FOUNDATION | BUILD / BLOCKED | P0 | 7 | READY | reports/moderation schema | case-type/visibility/RBAC tests | No cross-queue evidence access. |
| W7-11 | Report DUTA problem intake | BUILD | BUILD / CONDITIONAL | P1 | 7 | READY_WITH_DEPENDENCY | W7-10/privacy gate | category/receipt/status API tests | Not Trust/Safety report. |
| W7-12 | Privacy-safe diagnostic context | SECURITY | BUILD / LEGAL | P0 | 7 | READY_WITH_DEPENDENCY | W7-11/W0-05 | allowlist/redaction tests | Never collect secrets/docs/location by default. |
| W7-13 | Approved screenshot/file handling | SECURITY | BUILD / LEGAL | P1 | 7 | BLOCKED_EXTERNAL | privacy/retention decision | access/retention/malware tests | No upload before approval. |
| W7-14 | Support case status/receipt | BUILD | BUILD / CONDITIONAL | P1 | 7 | READY_WITH_DEPENDENCY | W7-10 | DITERIMA/DISEMAK status/owner privacy tests | No staff-security details. |
| W7-15 | General Contact DUTA routing | BUILD | BUILD / CONDITIONAL | P2 | 7 | READY_WITH_DEPENDENCY | W7-10/RBAC | category/queue routing tests | No realtime/response promise. |
| W7-16 | Feedback/suggestion intake | BUILD | BUILD / CONDITIONAL | P2 | 7 | READY_WITH_DEPENDENCY | W7-10 | feedback receipt/segregation tests | No promise to implement. |
| W7-17 | Contextual report/help router | CHANGE | BUILD / CONDITIONAL | P1 | 7 | READY_WITH_DEPENDENCY | W7-10 | error/AI/listing/community/privacy route tests | Avoid duplicate case systems. |
| W7-18 | Support RBAC/audit queues | SECURITY | BUILD / BLOCKED | P0 | 7 | READY_WITH_DEPENDENCY | W7-01/W7-10 | least-privilege/audit tests | Support cannot read restricted Trust/Privacy evidence. |
| W7-19 | Support status notifications | BUILD | BUILD / BLOCKED | P2 | 7 | READY_WITH_DEPENDENCY | W4-03/W7-14 | preference/status-delivery tests | No marketing consent reuse. |
| W7-20 | Support graceful degradation | OPERATIONS | BUILD / CONDITIONAL | P1 | 7 | READY_WITH_DEPENDENCY | W7-11/approved fallback | retry/alternate/report UX tests | No stack trace/secrets/invented channel. |
| W7-21 | Corporate partnership inquiry | BUILD | FOUNDER | P2 | 7 | READY_WITH_DEPENDENCY | W7-10/partner gate | corporate queue/segregation tests | No Partner privilege. |
| W7-22 | Investor-relations inquiry | BUILD | FOUNDER | P2 | 7 | READY_WITH_DEPENDENCY | W7-10/legal/corporate gate | interest-only routing tests | No public solicitation/terms/returns. |
| W7-23 | Corporate inquiry routing | BUILD | CONDITIONAL | P2 | 7 | READY_WITH_DEPENDENCY | W7-21/22/RBAC | management queue/audit tests | Investor != seller/partner/org. |
| W7-24 | Support analytics with privacy boundaries | OPERATIONS | BUILD / LEGAL | P2 | 7 | READY_WITH_DEPENDENCY | W0-05/W7-11 | started/submitted/resolved metrics tests | No marketing consent/manipulation. |
