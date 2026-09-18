# KPP-02R.2 Repository Inventory

Status: read-only evidence inventory, 2026-09-19. KPP-02R.1 is controlling;
historical documents are evidence only.

## Runtime surface map

| Surface | Repository evidence | Observed state |
| --- | --- | --- |
| Public landing | `app/page.tsx` | Public landing with links to core discovery/safety routes; no human-cinematic recurring-hero image runtime evidence. |
| Hari Ini | `app/beranda/page.tsx` | Static greeting, AI widget, service links and two `DEMO DATA` nearby cards. |
| Tanya DUTA | `app/tanya/page.tsx`, `components/ai-chat.tsx`, `app/api/ai/chat/route.ts`, `app/api/ai/transcribe/route.ts` | Text UI and optional microphone/transcription UI; chat API requires authenticated API authorization. |
| Info Rantau | `app/info/page.tsx`, `app/info/tempat-wisata/page.tsx` | Routed; mostly disabled categories and an empty verified-article state. |
| Layanan RI / safety | `app/layanan/page.tsx`, `app/jaga-diri/page.tsx`, `components/emergency-contacts.tsx`, `app/api/safety/contacts/route.ts` | Public routes using official-source/contact data; contact fallback exists. |
| Kerja | `app/kerja/page.tsx`, `app/api/jobs/route.ts`, `app/api/jobs/official/route.ts`, `lib/services/job-sources.ts` | Public DB listing view and official SISKOP2MI/KP2MI API filter; UI does not call official API. |
| Pasar | `app/pasar/page.tsx`, `app/api/marketplace/route.ts` | UI and public API intentionally withheld/503. Create/detail/admin endpoints exist as files but were not runtime-proven. |
| Community | `app/komunitas/page.tsx`, `app/api/community/route.ts` | Public list read; create button has no evidenced wired action. |
| Organizations | `app/organisasi/**`, `app/api/organizations/**`, `lib/services/organizations.ts` | Organization pages/APIs and scoped organization domain present. |
| Auth/profile | `app/daftar/page.tsx`, `app/masuk/page.tsx`, `app/auth/**`, `app/api/auth/**`, `app/profil/page.tsx` | Email/password registration, login, logout and recovery routes; consumer flow is free but completion was historically deferred. |
| Admin | `app/admin/**`, `app/api/admin/**`, `lib/domain/rbac.ts` | Admin pages/content manager and four platform role domains; no full Control Center domain coverage. |
| AI/provider | `lib/services/ai-*`, `lib/services/asr-provider.ts`, `lib/services/tts-provider.ts` | Routed provider, deterministic source answer, quota and telemetry foundations. |

## Data and security inventory

| Domain | Evidence | Observed state |
| --- | --- | --- |
| Identity/auth | `db/schema.ts`, `db/supabase-auth.sql`, `lib/auth/**` | Supabase identity bridge and application user model. No DOB field found in `db/schema.ts`; registration takes name/email/password/city. |
| Membership/payment legacy | `db/schema.ts:49,79` | `memberships` includes plan/price and `payments` tables: legacy schema remnant; no consumer payment runtime was established. |
| Verification | `db/schema.ts:13-15,55`; `db/migrations/0025_verification_foundation.sql` | Verification/evidence model and privileged RLS exist. No ordinary Member passport-upload UI/API was found. |
| Organizations/sellers/jobs | `db/schema.ts:57-81`; migrations `0026`–`0032` | Entity-scoped foundations, eligibility, employer and official-job-source controls. |
| Moderation | `db/migrations/0033_moderation_trust_foundation.sql`; `lib/domain/moderation.ts` | Case/action/evidence schema and moderation-admin RLS; no complete end-user case/appeal runtime found. |
| Source governance | `db/schema.ts:61`; `lib/services/sources.ts`; migration `0039` | Official source registry/read service and source-governance foundation. No proven fetch/normalize/dedup/publish worker. |
| Privacy | `docs/duta-v2.5/R2A02_*`; `db/migrations/0022_account_deletion_function.sql` | Governance documents and account-deletion database foundation; runtime Privacy Center not found. |
| Notifications | `db/schema.ts:80`; `components/app-shell.tsx` | Per-user table and an unwired-looking bell; no broadcast management/runtime evidence. |

## Test and prototype inventory

`tests/` contains focused Vitest suites for AI, sources, RBAC, moderation,
marketplace, community, authorization, migrations and security. They establish
unit/repository evidence, not deployment proof. `tests/hosted-staging/` and
staging evidence document prior controlled checks.

KPP-03A.1 visual evidence exists under
`docs/duta-v2.5/killer-product/visual-proof/`, including hero/prototype renders
and specifications. Runtime `app/page.tsx` uses logo/symbol imagery rather than
those prototype hero assets.
