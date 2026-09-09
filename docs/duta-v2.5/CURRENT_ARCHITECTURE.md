# Current architecture

Evidence: app/, components/, lib/, db/schema.ts, db SQL and migration journal at commit 1de693a. Static repository findings; actual deployed grants/data are unverified.

## Request and data paths

Browser -> AppShell/pages -> route handler or server service -> transaction identity bridge -> restricted PostgreSQL connection. Supabase browser/server clients handle auth; proxy refreshes cookies. getCurrentUser validates the Supabase user, then loads the app profile and rejects suspended users. Browser role metadata is not the authority. Some older organization services use raw appDb and need reconciliation.

### Complete route inventory

Classification reflects implemented access, not the route name. API routes are classified API with actual access separately. All 19 page routes are public at the page boundary; profile/admin/secretary labels do not add authorization. There is no protected layout redirect. Protected APIs remain separately guarded.

| Route | Classification | Implemented access / purpose |
|---|---|---|
| / | PUBLIC | Homepage, compact AI and static nearby cards |
| /tanya | PUBLIC | DUTA AI text |
| /masuk | PUBLIC | Login form |
| /daftar | PUBLIC | Signup form; no separate onboarding route |
| /profil | PUBLIC | Preview account UI; no actual profile binding |
| /membership | PUBLIC | Membership presentation |
| /kerja | PUBLIC | Jobs database list |
| /komunitas | PUBLIC | Community database list |
| /pasar | PUBLIC | Product database list |
| /organisasi | PUBLIC | Organization list |
| /organisasi/paket | PUBLIC | Plans |
| /organisasi/[id] | PUBLIC | Active organization presentation |
| /organisasi/[id]/sekretaris | PUBLIC | Local draft preview, hard-coded PRO presentation |
| /layanan | PUBLIC | Official source directory |
| /jaga-diri | PUBLIC | Emergency contacts and nearby mission selection |
| /info | PUBLIC | Categories/empty information screen |
| /admin | PUBLIC | Intended admin; preview dashboard, no page guard |
| /admin/content | PUBLIC | Intended admin; API-backed content manager shell |
| /admin/sumber | PUBLIC | Intended admin; public sources list |
| /auth/konfirmasi | PUBLIC | GET exchanges confirmation code/token; fixed internal redirects |
| /api/ai/chat | API | POST public, input validation and IP limit |
| /api/auth/login | API | POST public; password login and IP limit |
| /api/auth/register | API | POST public; signup and IP limit |
| /api/auth/logout | API | POST session sign-out; no origin guard |
| /api/auth/me | API | GET current user or 401 |
| /api/users/me | API | GET/PATCH/DELETE authenticated + same-origin guard; profile/deletion |
| /api/jobs | API | GET public, RLS-backed |
| /api/community | API | GET public, RLS-backed |
| /api/marketplace | API | GET public, RLS-backed |
| /api/marketplace/create | API | POST public body echo; no persistence |
| /api/marketplace/[id] | API | GET/PATCH/DELETE public placeholders; no persistence |
| /api/organizations | API | GET public, RLS-backed |
| /api/organizations/[id]/secretary/generate | API | POST authenticated + org permission/plan; raw DB path |
| /api/organizations/[id]/meetings/transcribe | API | POST authenticated + org permission/plan/consent; provider unavailable |
| /api/membership/checkout | API | POST authenticated + limit; unavailable provider returns 503 |
| /api/sources | API | GET public active sources |
| /api/sources/[id] | API | PATCH EDITOR minimum + identity transaction |
| /api/safety/contacts | API | GET public Supabase directory with bundled fallback |
| /api/admin/health | API | GET public configuration presence and provider selector |
| /api/admin/jobs | API | POST EDITOR minimum |
| /api/admin/community | API | POST EDITOR minimum |
| /api/admin/marketplace | API | POST EDITOR minimum |
| /api/admin/organizations | API | GET/POST/PATCH/DELETE SUPER_ADMIN; DELETE archives |

Total: 19 pages, 1 non-API auth callback, 23 API route files. No separate map, news article, course, notification, onboarding, recovery or deletion page found. Account deletion is DELETE /api/users/me; notification/course-like buttons do not establish routes.

## Supabase and database integration

lib/supabase/client.ts uses createBrowserClient with public endpoint/publishable key. server.ts uses createServerClient with next/headers cookies. Cookie writes unavailable in Server Components are caught; proxy handles refresh. admin.ts creates a nonpersistent secret-key client, used by account deletion and security audit. It lacks a server-only import even though current import paths are server side.

db/client.ts separates APP_DATABASE_URL (pool max 10) and SYSTEM_DATABASE_URL (max 5), disables prepared statements, and refuses generic DATABASE_URL fallback. lib/db/identity-bridge.ts validates restricted role name, no ownership/BYPASSRLS/superuser privileges, verifies a branded user, sets transaction-local app.user_id and checks current database profile. getCurrentUser and older organization paths do not consistently use this wrapper.

Supabase auth trigger in db/supabase-auth.sql maps auth UUID to public.users with USER role and private defaults. Legacy sessions/password_hash schema remains; active login uses Supabase rather than those sessions. Drizzle schema/inferred types are present; no generated Supabase Database typing was found. Schema includes user/account, memberships/payments, jobs, communities, products/sellers, organizations and internal office tables, official sources/evidence/contacts, contents, notifications, AI conversations, reports and audits.

RPC-like SQL calls: current_app_user_id/current_app_has_role/current_app_has_org_role and delete_current_app_user. No supabase.rpc call, Edge Functions invocation, vector extension, embedding table, or operational Supabase Storage upload integration found. organization_documents.storage_key is a schema field, not a working storage flow. Official evidence is served from public/evidence. Meeting audio is buffered and zeroed in memory; copies/browser/provider retention are not guaranteed erased by that operation.

### SQL inventory and drift

db/migrations contains 0000_next_marrow, 0001_glorious_scarlet_witch, 0002_reflective_magdalene, 0003_stiff_sunspot, 0008_phase4_real_content_rls, 0009_organization_archival_workflow; 0010_runtime_database_roles, 0011_runtime_identity_bridge, 0012_runtime_role_grants, 0013_runtime_official_sources_rls, 0014_runtime_users_select, 0015_runtime_users_rls, 0016_runtime_content_select, 0017_runtime_sellers_select, 0018_runtime_users_self_update, 0019_runtime_audit_self_insert, 0020_account_deletion_audit_hardening, 0021_remove_broad_audit_self_insert, 0022_account_deletion_function (all .sql).

Journal references missing 0004_phase1a_identity_bridge_rls, 0005_membership_organization_registration, 0006_membership_organization_registration_rls, 0007_member_face_verification. Existing 0010–0022 are not in the journal. Migration 0008 references runtime helpers introduced by visible 0011. Do not assume npm run db:migrate can reconstruct the database.

Other db SQL: supabase-bootstrap.sql, supabase-auth.sql, rls.sql, organization-packages.sql, supabase-phase4-organization-archival.sql, official-emergency-records.sql and official-emergency-upsert.sql. Operational SQL also exists in scripts/security/phase3_verify_local.sql, scripts/security/phase3_attack_matrix.sql, and root phase3_rollback.sql, phase3_verification.sql. None executed.

db/rls.sql uses auth.uid() for anon/authenticated; newer files add duta_app/current_app identity. Visible runtime discovery policies and organization policy scopes differ. RLS enabled statements are not proof of deployed grants, FORCE RLS or installed policy order. Audit FK ON DELETE SET NULL in migration 0020 differs from db/schema.ts; deletion may encounter other references. Confirm live schema only in a later explicitly scoped inspection.
