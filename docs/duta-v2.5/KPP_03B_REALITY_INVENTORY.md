# KPP-03B Reality Inventory — Initial Evidence

| Capability | Surface | Actual state | Evidence / gap | Expected beta state |
|---|---|---|---|---|
| Landing | `/` | STATIC_UI | Public landing has working links but differs materially from R2.1 target design | LIVE_CONNECTED after conformance work |
| Hari Ini | `/beranda` | LIVE_PARTIAL | App shell and AI component exist; prior static demo activities removed in this pass | LIVE_CONNECTED only with real continuity data |
| Google auth | `/masuk` | EXTERNAL_DEPENDENCY | UI invokes Supabase OAuth; end-to-end provider session not established in this local execution | LIVE_CONNECTED after staging ceremony |
| Tanya text | `/tanya`, `/api/ai/chat` | LIVE_PARTIAL | Auth, rate-limit, source-first routing and provider/error handling exist; requires configured DB/provider for full journey | LIVE_CONNECTED or honestly unavailable |
| Tanya voice | `/api/ai/transcribe` | EXTERNAL_DEPENDENCY | Browser recording and route exist; transcription/provider availability unresolved | Clearly unavailable unless verified |
| Layanan RI | `/layanan` | LIVE_PARTIAL | Source service and public route exist; verification status depends on source data | SOURCE_VERIFICATION_GATE where unverified |
| Jaga Diri | `/jaga-diri` | LIVE_PARTIAL | Public, manual/geolocation fallback and contact component exist; contacts must remain source-governed | LIVE_CONNECTED only with verified contacts |
| Kerja | `/kerja` | LIVE_PARTIAL | Database read UI exists; posting action is a dead button and records carry demo badge | PUBLIC discovery only, no placement execution |
| Community | `/komunitas`, `/api/community` | LIVE_PARTIAL | DB read route exists; create/detail/join controls are not wired | BLOCKED_TECHNICAL |
| Pasar | `/pasar`, `/api/marketplace/*` | PLACEHOLDER | Page says preparing; item endpoint returns placeholder success messages | NOT_IN_PUBLIC_BETA_SCOPE unless real discovery/connect flow added |
| Organizations | `/organisasi` | LIVE_PARTIAL | DB/API and scoped services exist; UI includes preview/product-plan remnants | BLOCKED_TECHNICAL / policy reconciliation |
| Notifications | app shell bell, `/profil` | DEAD_ACTION | Bell and preferences are static UI, no Inbox route/data contract found | BLOCKED_TECHNICAL |
| DUTA Belajar | none | MISSING_IMPLEMENTATION | No public route found | NOT_IN_PUBLIC_BETA_SCOPE unless implemented with source governance |
| Search | `SearchFilter` | DEAD_ACTION | Input/filter UI has no query or filtering behavior | NOT_IN_PUBLIC_BETA_SCOPE |
| Reports/cases/appeals | none | MISSING_IMPLEMENTATION | No public flow route found | BLOCKED_TECHNICAL |

This is an initial code-and-route inventory only. It makes no staging database, provider or production-runtime claim.
