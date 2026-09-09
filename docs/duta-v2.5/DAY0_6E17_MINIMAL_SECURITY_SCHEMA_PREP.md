# Day 0.6E-1.7 Minimal Hosted Security-Test Schema Preparation

## Scope

This is a staging-only design for project `bftdfvihtewjwotrzwwe`. It is not a migration plan and must not be applied to production. It avoids the inconsistent repository migration chain and contains no production data, credentials, identifiers, or account details.

## Minimum Table Set

| Table | Why required | Tests | Minimum columns and constraints | RLS |
| --- | --- | --- | --- | --- |
| `profiles` | Maps an Auth identity to an application profile and tests own/cross-profile access. | T01–T03, T08 | `id uuid` primary key, `display_name text`, `private_note text`; `id` references `auth.users(id)` | Yes |
| `organizations` | Tests organisation ownership, read isolation, and cross-organisation update denial. | T04–T05, T10 | `id uuid` primary key, `name text`, `owner_id uuid` references `profiles(id)`; unique synthetic name | Yes |
| `organization_members` | Tests membership visibility and blocks self-admin/owner escalation. | T06, T09–T10 | `organization_id`, `user_id`, `role`; composite primary key; role check limited to `OWNER`, `ADMIN`, `MEMBER` | Yes |
| `jobs` | Tests resource ownership and cross-user/cross-organisation modification denial. The current repository stores employer as text; no employer table is required. | T07, T11–T12 | `id uuid` primary key, `organization_id`, `owner_id`, `title text`, `employer text`, `status text`; foreign keys to organisation/profile | Yes |
| `audit_logs` | Tests actor-bound audit insertion and no broad user reads/updates/deletes. | T12 | `id uuid` primary key, `actor_id`, `organization_id` nullable, `action text`, `entity_type text`, `entity_id uuid` nullable; foreign keys to profile/organisation | Yes |

No marketplace, products, documents, meetings, payments, employer table, or unrelated business fields are required for the twelve authorization tests.

## Identity and Organisation Model

The application retrieves the Supabase Auth user and compares that UUID with its application `users` row before authorizing transactions. The minimum hosted test model should use `profiles.id = auth.users.id` for both accounts. This mapping is **PARTIAL** rather than fully confirmed because the current deployed schema cannot be inferred from the inconsistent migration history.

Two ordinary synthetic Auth identities are required. Account A owns Organisation A and has an `OWNER` membership only there. Account B owns Organisation B and has an `OWNER` membership only there. No account starts with a system-admin role. The required role model (`OWNER`, `ADMIN`, `MEMBER`) is confirmed from the repository enum; its hosted deployment remains unverified.

## Intended Policies

Eight policies are required; all are defined in terms of `auth.uid()` for direct hosted authenticated requests:

| Table | Command | Actor / allow condition | Deny condition and risk |
| --- | --- | --- | --- |
| `profiles` | SELECT | own row | another user’s private row; cross-profile disclosure |
| `profiles` | UPDATE | own row, immutable `id` | other profile or identity reassignment |
| `organizations` | SELECT | member of that organisation | non-member private organisation access |
| `organizations` | UPDATE | owner of that organisation | cross-organisation changes; member/admin ambiguity |
| `organization_members` | SELECT | member of that organisation | membership enumeration by outsiders |
| `jobs` | SELECT | owner or member of that organisation | non-member private resource access |
| `jobs` | UPDATE | resource owner and organisation member | cross-user/cross-organisation changes |
| `audit_logs` | INSERT | `actor_id = auth.uid()` and actor owns referenced resource where applicable | actor spoofing and broad audit writes |

There must be no INSERT, UPDATE, or DELETE policy on `organization_members` for ordinary authenticated users. There must be no DELETE policy on `profiles`, `organizations`, `jobs`, or `audit_logs` for these tests. This makes self-owner/self-admin assignment, peer membership modification, and destructive actions deny by default. No policy may use `USING (true)`, `WITH CHECK (true)`, or broad authenticated writes.

## Synthetic Data Plan and Test Matrix

Seed only two accounts, two profiles, two organisations, two memberships, two jobs, and two audit rows if read-denial tests require their presence. Every identifier must be newly generated at execution and clearly designated as synthetic; the eventual seed template must contain placeholders only.

| ID | Actor | Target / operation | Expected | Table/policy | Class |
| --- | --- | --- | --- | --- | --- |
| T01 | A | read Profile A | allow | profiles SELECT | Read-only |
| T02 | A | read Profile B | deny | profiles SELECT | Read-only |
| T03 | A | update disposable Profile A field then restore | allow | profiles UPDATE | Reversible write |
| T04 | A | read Organisation A | allow | organizations SELECT | Read-only |
| T05 | A | read Organisation B | deny | organizations SELECT | Read-only |
| T06 | A | read Organisation B memberships | deny | organization_members SELECT | Read-only |
| T07 | A | read Job A | allow | jobs SELECT | Read-only |
| T08 | A | update Profile B | deny | profiles UPDATE | Security-sensitive write |
| T09 | A | insert/update own membership to ADMIN | deny | no membership write policy | Security-sensitive write |
| T10 | A | update B membership or Organisation B | deny | membership default deny / organizations UPDATE | Security-sensitive write |
| T11 | A | update Job B | deny | jobs UPDATE | Security-sensitive write |
| T12 | A | spoof B in audit insert or delete Job B | deny | audit INSERT / no DELETE policy | Security-sensitive write |

## Invariants

- A normal user cannot assign themselves `ADMIN` or `OWNER`.
- A member cannot change any other member’s role.
- A user cannot read or update another user’s private profile or organisation.
- Organisation membership gates organisation-scoped resource access.
- A user cannot update or delete another user’s resource.
- Audit actor identity cannot be spoofed.
- Normal actions require no service role.

## Future File Plan

Create these files only in a later explicitly authorized implementation phase:

1. `tests/hosted-staging/001_security_schema.sql`
2. `tests/hosted-staging/002_security_policies.sql`
3. `tests/hosted-staging/003_security_seed_template.sql`
4. `tests/hosted-staging/004_security_verify.sql`
5. `tests/hosted-staging/README.md`

The seed template must use placeholders, never actual account UUIDs, passwords, tokens, emails, keys, or production identifiers.

## Apply, Rollback, and Abort Plan

1. Confirm project reference equals `bftdfvihtewjwotrzwwe` and classify it as staging.
2. Abort if the production project reference appears, if migration replay is proposed, or if an identifier cannot be shown synthetic.
3. Apply the schema and policies only after separate authorization.
4. Create owner-controlled synthetic Auth accounts outside the SQL files.
5. Insert only their generated synthetic IDs and verify baseline policy behavior.
6. Run read-only tests; obtain separate authorization for any reversible or security-sensitive write.
7. Roll back by deleting only the named staging test schema/data and synthetic accounts after verification, never by altering production or rewriting migration history.

Stop immediately if project identity/environment is unproven, data is not synthetic, a service role becomes necessary without justification, or a destructive target is not known synthetic.
