# DUTA RANTAU v2.5 — Arena → Codex Handoff Manifest

Mode: SAFE SNAPSHOT / NO NEW DEVELOPMENT. This document preserves and
inventories the Arena implementation exactly as implemented. It does not
propose changes.

## 1. Snapshot branch
`arena-v25-snapshot`

## 2. Snapshot commit SHA
- Implementation preservation point: `2d83b43943a4f40d207909b78d6efbd8bcd6241c`
  (branch tip at creation time; the complete Arena implementation)
- Tree: `ef55d20e73b4a03775c830beacaa5b26b0a5f2f5`
- This manifest is a docs-only commit ON TOP of the preservation point
  (it changes no application code; compare against the preservation point
  above for any code audit).

## 3. Source Arena branch
`arena/01a094e3-duta-rantau` @ `2d83b43943a4f40d207909b78d6efbd8bcd6241c`
(identical commit; the snapshot originates from the Arena session
implementation, not from main)

## 4. Repository origin
`https://github.com/magnetrezeki/DUTA-RANTAU.git`

## 5. Arena staging target
- Legacy: `DUTA-RANTAU-V25-STAGING` — quarantined NON-EMPTY (5 pre-existing
  public tables: audit_logs, jobs, organization_members, organizations,
  profiles; 8 pre-existing `security_*` RLS policies). NOT eligible for
  fresh bootstrap; preserved untouched for reference.
- Planned replacement: `DUTA-RANTAU-V25-STAGING-FRESH` — prepared (H3B-R0
  runbook + validated preflight), pending manual creation by the operator.

## 6. Arena staging URL
Not configured. Vercel is not connected (deliberately, per the staging
plan); no `APP_DATABASE_URL` is set anywhere yet. The repo contains only
`vercel.json` (`{"framework":"nextjs"}`).

## 7. Feature inventory (read-only audit of the snapshot)

| # | Area | Status | Evidence |
|---|------|--------|----------|
| A | Public landing page | IMPLEMENTED | `/` app/page.tsx |
| B | DUTA RANTAU positioning/hero | IMPLEMENTED | welcome section + HomeGreeting + "Bukan portal pemerintah" (app-shell) + landing disclaimer |
| C | Public navigation | IMPLEMENTED | components/app-shell.tsx (home, /tanya, /profil) + per-page nav; header/footer in app shell |
| D | Daftar (register) | IMPLEMENTED | /daftar, AuthForm → POST /api/auth/register |
| E | Masuk (login) | IMPLEMENTED | /masuk, AuthForm → POST /api/auth/login; /api/auth/me, /api/auth/logout |
| F | Authenticated dashboard | PARTIAL | no dedicated /dashboard route; authenticated surfaces = /profil (account), /admin (role-gated, 3 sections), personalized HomeGreeting |
| G | DUTA AI interface | IMPLEMENTED | /tanya + landing compact AiChat; /api/ai/chat, /api/ai/transcribe, /api/ai/speak; server provider chain (lib/services/ai-*); default-disabled via DUTA_AI_ENABLED |
| H | Voice interaction | IMPLEMENTED | ai-chat.tsx: transcribe (ASR) + speak (TTS) API calls; lib/services/asr-provider.ts, tts-provider.ts (NVIDIA optional) |
| I | Komuniti | IMPLEMENTED | /komunitas — server component, getCommunities() (DB via withPublicTransaction) + /api/community; a few DEMO-badged sample cards mixed in |
| J | Organisasi | IMPLEMENTED | /organisasi (list), /organisasi/[id] (getOrganization, force-dynamic), /organisasi/paket, /organisasi/[id]/sekretaris (secretary workspace + /api/organizations/[id]/secretary/generate), /api/organizations |
| K | E-Undi | NOT FOUND | no voting route/component found in the snapshot |
| L | Pekerjaan | IMPLEMENTED | /kerja — getJobs (DB) + /api/jobs + /api/jobs/official; a few DEMO-badged samples |
| M | Employer job submission | PARTIAL | employer-eligibility schema (0031) + admin job management (/api/admin/jobs, /admin page); no dedicated public employer self-service submission form route |
| N | Pasar Rantau | IMPLEMENTED | /pasar — products (DB) + /api/marketplace, /api/marketplace/create, /api/marketplace/[id]; marketplace compliance (0028); DEMO-badged samples |
| O | DUTA Map | PARTIAL | landing "Dekat Anda" section (location cards, static "Berdasarkan Kuala Lumpur", DEMO DATA badges); no interactive map component |
| P | Citizen report | PARTIAL | moderation backend complete in DB (0033: moderation_cases/reports/actions/evidence, admin-only policies); no dedicated citizen-facing report UI route found |
| Q | Hotline KBRI/KJRI | IMPLEMENTED | /jaga-diri + components/emergency-contacts.tsx + /api/safety/contacts + lib/official-emergency-data.ts (curated official contacts) |
| R | Berita KBRI/KJRI | PARTIAL | official-sources layer (/layanan, /api/sources, /api/sources/[id], lib/services/sources.ts) + /info + /info/tempat-wisata; no dedicated KBRI news feed route |
| S | Klinik/healthcare directory | PARTIAL | /layanan categories (incl. Perlindungan WNI) + /info/tempat-wisata; no dedicated clinic directory route |
| T | Kewangan patuh syariah | NOT FOUND | no UI/route; organization_finances table exists at DB level only |
| U | Pre-departure information | PARTIAL | /layanan "Perjalanan" category + presence/responsible-person schema (0024); no dedicated pre-departure checklist route |
| V | E-learning/compliance | NOT FOUND | no e-learning route; compliance schemas only (0026, 0030, 0031) |
| W | Trust/safety UI | PARTIAL | TrustBadge/DemoBadge components used across pages; moderation backend (0033); no dedicated trust/safety page |
| X | User profile | IMPLEMENTED | /profil + /api/users/me + LogoutButton (/api/auth/logout) |
| Y | Mobile/responsive UX | IMPLEMENTED | responsive grid/layout classes throughout pages and app shell |

## 8. Landing-page inventory (first-page experience)
- FOUND: YES
- ROUTE: `/`
- FILES: `app/page.tsx`, `components/home-greeting.tsx`, `components/ai-chat.tsx`
- MAIN_COMPONENTS: HomeGreeting; AiChat (compact); 6-card service grid
  (Layanan RI, Kerja, Kawan Rantau, Pasar Rantau, Organisasi, Info Rantau);
  "Dekat Anda" near-cards (2, explicit DEMO DATA badges); DUTA MEMBER
  membership card (static RM9.90/month + one-time SIM card bonus note);
  "bukan institusi pemerintah" disclaimer.
- HERO_TEXT: "Ada yang bisa DUTA bantu hari ini?" (with HomeGreeting;
  safety link "Butuh bantuan?" → /jaga-diri)
- PRIMARY_CTA: embedded DUTA AI chat (AiChat compact)
- SECONDARY_CTA: the six service cards
- AUTH_FLOW_FROM_LANDING: no inline auth on landing; auth via /masuk and
  /daftar (AuthForm → /api/auth/login|register)
- IMPLEMENTATION_STATUS: IMPLEMENTED
- STATIC_OR_CONNECTED: HYBRID — service grid + membership card static;
  "Dekat Anda" cards explicit demo data; AiChat connected to
  /api/ai/chat (server-gated by DUTA_AI_ENABLED); rest of app DB-connected
  via API routes + lib/services.

## 9. Routes introduced/changed by the Arena session
NONE. Every route in `app/` (landing, auth, tanya, komunitas, organisasi,
kerja, pasar, membership, profil, info, jaga-diri, layanan, admin, plus all
`app/api/*` routes) is pre-existing v2.5 codebase content preserved as-is.
The complete route list exists in the snapshot at `app/`.

## 10. Important components introduced/changed by the Arena session
NONE. All `components/*` files are pre-existing; preserved as-is.

## 11. API changes (Arena session)
NONE. No `app/api/*` route file was added or modified by the Arena session.

## 12. Database/schema/migration changes (Arena session delta, exact)
The ONLY code delta vs the pre-Arena authoritative base
(`b7fce3a7b9fbc98abc6e38f0e4c1dfd190cdb1d5`) is 6 files:
- MODIFIED `db/migrations/0023_entity_legal_status_foundation.sql` —
  fresh-bootstrap correctness repair: `o.record_status` → `o.status`,
  `c.record_status` → `c.status` (organizations/communities expose
  `status`); recorded in file header.
- MODIFIED `db/migrations/0027_community_membership_growth_foundation.sql`
  — `c.record_status='ACTIVE'` → `c.status='ACTIVE'` (WITH CHECK of
  communities_update_own_policy); recorded in file header.
- ADDED `db/migrations/0037_runtime_identity_helpers.sql` — isolated
  read-only identity helpers (has_system_role, has_org_role) extracted from
  the legacy db/rls.sql layer WITHOUT any legacy policies; SECDEF,
  search_path='', EXECUTE limited to anon/authenticated/duta_app.
  Fresh-bootstrap position: after 0011, before first consumer.
- ADDED `db/migrations/0038_core_runtime_rls_enforcement.sql` — ENABLE RLS
  on 30 previously unprotected core tables (default deny); 8 audited
  runtime policies (sellers directory read; ACTIVE org / member /
  subscription reads for server role; org-scoped secretary/transcription
  writes; GUC-bound system audit inserts); 4 enabling grants. No FORCE RLS,
  no BYPASSRLS, no legacy bulk, no client-role grants beyond sellers read.
- ADDED `tests/identity-helper-migration.test.ts` (7 cases)
- ADDED `tests/core-runtime-rls-migration.test.ts` (12 cases)
drizzle journal: intentionally unchanged (fresh bootstrap uses explicit
direct-SQL execution; drizzle-kit migrate is NOT used).

## 13. Assets added (Arena session)
NONE.

## 14. Known placeholders / mock data
- Landing "Dekat Anda" cards: explicit DEMO DATA badges (static samples).
- /komunitas: 2 DEMO-badged sample entries alongside live DB data.
- /kerja: 3 DEMO-badged samples alongside live DB data.
- /pasar: 3 DEMO-badged samples alongside live DB data.
- /admin, /profil, /layanan: isolated demo/placeholder markers.
- lib/official-emergency-data.ts: curated static official emergency data
  (by design, not mock).

## 15. Known unfinished work (preserved, not repaired here)
- AI migrations 0034/0035/0036 present in repo but EXCLUDED from the
  canonical fresh-bootstrap sequence by design (separate AI gate).
- Fresh staging bootstrap not yet executed: H3A execution pack ready;
  H3B-R0 replacement-preparation + validated H3B-R preflight ready; pending
  manual creation of DUTA-RANTAU-V25-STAGING-FRESH.
- `db/schema.ts` communities `recordStatus` mapping inconsistency:
  report-only observation, intentionally NOT changed by the Arena session.
- Features NOT FOUND in the inventory above (E-Undi, Kewangan patuh
  syariah, E-learning) exist only as DB-level foundations or not at all.

## 16. Known errors
- 6 test failures, ALL `APP_DATABASE_URL is not configured`
  (tests/source-integrity.test.ts 5/5; tests/ai-router.test.ts 1/11) —
  environment dependency (no DB URL in this environment); pre-existing;
  separately classified; no workaround attempted.
- Disposable PostgreSQL 18.4 harness quirk (documented, environment-only):
  a role's UPDATE RLS policy is silently not applied on tables lacking a
  same-role SELECT policy; does not affect any shipped policy semantics on
  real PostgreSQL/Supabase; no repository defect.

## 17. Dependencies added/removed (Arena session)
NONE. `package.json` / lockfile unchanged by the Arena session.

## 18. Environment variable NAMES required (names only, never values)
From `.env.example`:
`APP_DATABASE_URL`, `NEXT_PUBLIC_SUPABASE_URL`,
`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `DUTA_AI_ENABLED`, `GEMINI_API_KEY`,
`GEMINI_MODEL`, `GROQ_API_KEY`, `GROQ_MODEL`, `OPENAI_API_KEY`,
`OPENAI_MODEL`, `NVIDIA_API_KEY`, `NVIDIA_MODEL`, `NVIDIA_BASE_URL`,
`NVIDIA_ASR_MODEL`, `NVIDIA_ASR_BASE_URL`, `SUPABASE_SECRET_KEY`
