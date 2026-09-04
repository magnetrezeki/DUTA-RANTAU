# DUTA-RANTAU Phase 4 Demo/Data Audit

## Scope

The user-facing discovery routes were audited and changed to read production tables. No runtime route falls back to `lib/demo-data.ts`; that file was removed.

## Remediated runtime consumers

| Former file/function | Route/component | Former data source | Current data source | Status |
|---|---|---|---|---|
| `app/api/jobs/GET` | `/api/jobs` | hardcoded jobs | `public.jobs`, `ACTIVE`, unexpired | production query |
| `app/kerja/page.tsx` | `/kerja` | hardcoded jobs | `public.jobs` via `withPublicTransaction` | production query + empty state |
| `app/api/marketplace/GET` | `/api/marketplace` | hardcoded products | `public.products` + `public.sellers` | production query |
| `app/pasar/page.tsx` | `/pasar` | hardcoded products | `public.products` + `public.sellers` | production query + empty state |
| `app/api/community/GET` | `/api/community` | hardcoded communities | `public.communities`, `ACTIVE` | production query |
| `app/komunitas/page.tsx` | `/komunitas` | hardcoded communities | `public.communities`, `ACTIVE` | production query + empty state |
| `app/api/organizations/GET` | `/api/organizations` | sample organizations | `public.organizations` + membership | production query |
| `app/organisasi/page.tsx` | `/organisasi` | sample organizations | `public.organizations` + `organization_members` | production query + empty state |
| `app/organisasi/[id]/page.tsx` | `/organisasi/[id]` | sample organization detail | authorized database query | production query |
| `app/organisasi/[id]/sekretaris/page.tsx` | `/organisasi/[id]/sekretaris` | local demo workspace | authorized organization lookup; Pro is blocked | coming soon, no fake actions |
| `app/api/sources/GET` | `/api/sources` | source catalog | `public.official_sources` | production query |
| `app/layanan/page.tsx` | `/layanan` | source catalog | `public.official_sources` | production query + empty state |
| `app/admin/sumber/page.tsx` | `/admin/sumber` | source catalog | authorized `public.official_sources` | production admin manager |
| `app/page.tsx` | `/` | sample nearby events | no sample event cards | real empty state |
| `lib/services/ai-router.ts` | `/api/ai/chat` | demo source/jobs/community/product context | no fake records; general source-first response | no demo context |
| `lib/services/duta-gemini.ts` | `/api/ai/chat` | demo records in Gemini context | intent/location context only | no demo context |

## New production management routes

- `/api/admin/jobs`
- `/api/admin/marketplace`
- `/api/admin/community`
- `/api/admin/organizations`
- `/api/sources/[id]`
- `/admin/content`
- `/admin/sumber`

All require server-side admin/editor authorization and use the identity bridge. Admin mutations set moderation state explicitly and create audit entries.

## Legitimate non-runtime data

The following are retained deliberately and are not runtime demo fallbacks:

- `lib/official-source-catalog.ts`: curated owner seed catalog for official channels; runtime reads the database.
- `scripts/seed-official-sources.ts`: explicit owner/system seed command.
- `scripts/security/seed-phase1a.ts`: isolated local security-test fixtures; never imported by user routes.
- `db/supabase-bootstrap.sql`: deployment bootstrap and supplied official records.
- `lib/official-emergency-data.ts`: bundled official emergency fallback records, not sample organizations/jobs/products/communities.
- `tests/`: test fixtures and assertions.

## Database/RLS

Phase 4 adds `db/migrations/0008_phase4_real_content_rls.sql` and `db/supabase-phase4-content.sql`. These grant admin-only mutation paths for jobs, marketplace, communities, organizations, and sources while retaining ownership/RLS controls for normal users. `0009_organization_archival_workflow.sql` then removes physical organization DELETE and enforces archival-only behavior.

Arena did not execute any migration or modify production data. Local PostgreSQL verification still requires the Windows LOCAL_STAGING environment.
