# Day 0.6E-1 Hosted Authorization and RLS Verification Preparation

## Scope and Boundary

This is a static repository review only. No hosted Supabase project, production database, credentials, users, sessions, or policies were accessed or changed. The inconsistent migration chronology means the repository cannot prove the policy state of any hosted project.

## Authorization Inventory

| Module | Tables | Application-side check | Repository-visible database check | Hosted verification |
| --- | --- | --- | --- | --- |
| `lib/supabase/server.ts`, `client.ts` | Supabase Auth | Server/browser session clients use publishable configuration | Depends on hosted Auth and RLS | Yes |
| `lib/supabase/admin.ts`, `lib/audit/security-audit.ts` | `audit_logs` | Admin client is available when its named server configuration exists; audit fallback uses system transaction | Audit INSERT policies constrain `actor_id` and, in one path, role | Yes, high priority |
| `lib/auth/session.ts`, `api-guard.ts`, `authorization.ts` | `users` | Retrieves Auth user and establishes application identity | `users_runtime_select` and `users_runtime_update` compare current application identity | Yes |
| `lib/services/organizations.ts`, `organization-access.ts` | `organizations`, `organization_members`, organisation resources | API routes call `getOrganizationAccess` for feature access | Visible organisation policies check system roles; membership-table policy coverage is not established | Yes, critical |
| Admin routes for jobs, community, marketplace, sources | `jobs`, `communities`, `sellers`, `products`, `official_sources` | `authorizeApi` and role checks | `*_admin_all` policies use `current_app_has_role` | Yes, critical |
| User profile API | `users`, `audit_logs` | Authenticated user identity is used | self SELECT/UPDATE and actor-bound audit INSERT | Yes |
| Membership/organisation package routes | `memberships`, organisation package tables | Route-level guards and organisation access helper | No complete current RLS inventory is present for these tables | Yes, high |
| Secretary and meeting routes | documents, projects, transcripts, audit | `getOrganizationAccess` before writes | Database policy coverage is not proven from current migration sequence | Yes, high |
| Account deletion migration | `users`, related records, audit | No complete route-level flow identified statically | Function and policy deployment state cannot be inferred | Yes, security-sensitive |

No browser client should be able to substitute for server-side authorization. The future verification must test direct authenticated Supabase requests because application-side guards alone do not prove RLS enforcement.

## RLS Policy Inventory

Nineteen policy definitions were reviewed across the relevant migration files, including superseded definitions. High-value active/intended definitions include:

| Table | Policy | Command / role | Condition summary | Priority |
| --- | --- | --- | --- | --- |
| `organizations` | `organizations_runtime_select` | SELECT / `duta_app` | system role is `ORG_ADMIN` or `SUPER_ADMIN` | Critical |
| `organizations` | `organizations_admin_insert` | INSERT / `duta_app` | system role plus pending/user-generated state | Critical |
| `organizations` | `organizations_admin_update` | UPDATE / `duta_app` | system role, verified activation restriction | Critical |
| `audit_logs` | `audit_logs_content_admin` | INSERT / `duta_app` | actor matches current identity and system role | High |
| `users` | `users_runtime_select` | SELECT / `duta_app` | own identity only | High |
| `users` | `users_runtime_update` | UPDATE / `duta_app` | own identity only | High |
| `jobs`, `communities`, `sellers`, `products`, `official_sources` | `*_admin_all` | ALL / `duta_app` | `ORG_ADMIN` or `SUPER_ADMIN` | Critical |
| `jobs`, `products`, `communities` | `*_public` | SELECT / anon, authenticated, `duta_app` | active/published public content predicate | Medium |
| `official_sources` | `official_sources_public` | SELECT / anon, authenticated, `duta_app` | active official sources | Medium |
| `audit_logs` | historical `audit_user_insert`, `audit_logs_self_insert` | INSERT / `duta_app` | actor-bound, one superseded by migration `0021` | High |

The principal static risks are broad `FOR ALL` policies gated by identity-bridge functions, the absence of a complete visible current membership-policy chain, and superseded policy definitions that cannot establish hosted state.

## Organisation Authorization Assessment

The application calls `getOrganizationAccess` before organisation-secretary and meeting writes, which is a useful application control. The reviewed SQL does not establish complete direct-client RLS protection for `organization_members` or every organisation-scoped table. Therefore organisation authorization is **PARTIAL**: normal users should not be assumed unable to self-assign admin/owner, alter another member, or bypass route checks until hosted RLS tests prove it.

Potential privilege-escalation paths to test are: self-assignment in `organization_members`; role/owner alteration of another member; direct client changes to another organisation; and direct client writes through broad role-gated content policies when identity propagation is incorrect.

## Hosted Test Matrix

Use two normal, user-owned synthetic test accounts (A and B), two synthetic organisations with separate ownership, and synthetic resources only. Verify the project identity and a non-production environment before any request.

| Test | Expected result | Class |
| --- | --- | --- |
| A reads own profile | ALLOW | Read-only |
| A reads B private profile | DENY | Read-only |
| A reads own organisation data | ALLOW where feature permits | Read-only |
| A reads B private organisation data | DENY | Read-only |
| A reads public active source/content | ALLOW | Read-only |
| A reads unpublished/inactive content | DENY | Read-only |
| A updates a disposable own-profile field then restores it | ALLOW | Reversible write |
| A updates B profile | DENY | Security-sensitive write |
| A inserts an organisation membership granting A admin | DENY | Security-sensitive write |
| A updates A membership to OWNER | DENY | Security-sensitive write |
| A updates B membership or organisation | DENY | Security-sensitive write |
| A deletes B organisation/resource | DENY | Security-sensitive write |

No role, ownership, deletion, account, or membership test may be run without a later explicit write-test authorization.

## Future Hosted Safety Requirements

Required configuration names only: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, and any server-only Supabase admin configuration only when separately justified. Do not use historical passwords, cookies, refresh tokens, or the historical local service-role-like key. Prefer ordinary authenticated test accounts.

Abort immediately if the project identity is not proven, the environment might be production, either account ownership is unknown, data is not synthetic, a real user could be affected, or a requested test requires destructive production action. Hosted policy checks must use normal authenticated test users; service roles bypass the authorization subject under examination.

## Next Gate

Hosted read-only verification can be prepared after a user confirms a non-production project identity and two owned synthetic test accounts. Hosted write tests remain unsafe until separately authorized.
