# Day 0.5 — baseline recovery and security verification

Date: 2026-09-08. Workspace/Git root: D:\DUTA-RANTAU. Branch: duta-v2.5. No other project workspace was accessed. No installation, application edit, credential rotation, hosted SQL, migration, policy change, deployment, commit, merge or push was performed.

## A. Toolchain root cause and recovery

Node resolves first to C:\Program Files\nodejs\node.exe, version v24.14.1. A bundled Codex Node also appears later in PATH, but is not the selected runtime. npm resolves to npm.ps1/npm.cmd in C:\Program Files\nodejs. The relevant PATH entries also include the roaming npm directory and bundled runtime directory.

The standard launcher runs npm-prefix.js, receives the roaming-profile prefix, then selects that prefix's npm-cli.js when Test-Path succeeds. Both the installation npm-cli.js and the roaming npm-cli.js exist according to filesystem metadata. Reading the roaming entry is denied in this execution context, and Node reports MODULE_NOT_FOUND for it. Therefore Day 0's literal 'missing file' diagnosis was incomplete: this is a prefix-selected inaccessible npm installation, not evidence that the repository or primary Node installation is broken. Underlying ACL/security restriction was not changed or conclusively attributed to a specific machine policy.

The primary installation's npm-cli.js executes successfully and reports 11.11.0. Classification: F — another cause (prefix selection plus access restriction), with a secondary npm copy present; not a stale PATH selecting the wrong Node executable. No reinstall is necessary for these validations.

Recovery used a process-only NPM_CONFIG_PREFIX pointing to C:\Program Files\nodejs before invoking npm in each validation shell. npm --version then reports 11.11.0. No persistent PATH, npmrc, machine ACL, environment file or production configuration was changed. This is an operational session workaround, not a permanent machine repair; future shells need the same local override until the user chooses to investigate the roaming installation's accessibility. Do not use this prefix choice to install global packages into Program Files.

## B. Dependencies

Existing node_modules is available and was reused. package.json and package-lock.json remained byte-for-byte unchanged in Git. Lockfile v3. Installed Next.js 16.3.1, React 19.2.8, TypeScript 5.9.3, Vitest 3.2.7 and ESLint 9.39.5 were inspected. No dependency installation or version upgrade was attempted. Successful validation commands establish availability, not a full supply-chain integrity audit.

## C. Local validation

Commands ran individually, in order, using the process-only prefix override.

| Command | Result | Evidence |
|---|---|---|
| npm test | FAIL | 30 tests: 24 passed, 6 failed; 4 files passed, 2 failed |
| npm run lint | PASS | Exit 0, no lint diagnostics |
| npm run typecheck | PASS | Exit 0 |
| npm run build | PASS | Exit 0; Next compiled, typechecked, generated 32 static outputs and listed dynamic routes |

Six failures: the official-source answer test in tests/ai-router.test.ts and all five tests/source-integrity.test.ts tests report APP_DATABASE_URL is not configured. APP_DATABASE_URL and SYSTEM_DATABASE_URL were absent from the effective inspected process/local-file setup. The test paths fail before opening a database connection. No hosted database URL was supplied; no hosted SQL was executed. Existing .env.local contains other names, but the application deliberately does not fall back to its generic DATABASE_URL.

Passing build does not prove runtime database pages work: those routes are dynamic. No browser end-to-end, hosted RLS or live authentication tests were performed. The test failures are meaningful baseline gaps and have not been waived as unrelated.

Build/test/typecheck refreshed generated artifacts: the ignored tsconfig.tsbuildinfo changed, while next-env.d.ts remained byte-for-byte unchanged; .next/node_modules caches may also refresh. Git reports no tracked application/configuration/cache changes. Temporary protective copies of generated metadata were placed outside the repository and removed after verification; the ignored incremental cache was retained as validation output. No diagnostic script was left in the repository.

## D. Credential exposure assessment

The scan inspected current tracked text and 437 reachable text blobs from local Git refs, using credential/token/password patterns. It did not fetch remote history, inspect unreachable/reflog-only objects, test credentials, or claim exhaustive detection of every secret encoding. Historical artifact paths below are Git object labels, not accesses to another workspace. Values are intentionally omitted.

Counts use one logical path/type finding, grouping repeated versions of the same credential container. Two historical versions of autotest-cookies.txt count as one finding; access and refresh tokens inside a session are one container finding. CONFIRMED_SECRET means actual credential material is present, not proven live validity.

| Path / location | Type | Classification | Currently tracked / history | Activity and severity | Remediation |
|---|---|---|---|---|---|
| cookies.txt:5 | Supabase access/refresh session container | CONFIRMED_SECRET | Yes / yes | Recorded access expiry elapsed; refresh validity UNKNOWN. HIGH | Revoke affected sessions/refresh tokens through an authorized owner action; assess repository exposure before sanitizing |
| autotest-cookies.txt:5, two historical versions | Supabase access/refresh session containers | CONFIRMED_SECRET | No / yes | Recorded access expiry elapsed; refresh validity UNKNOWN. HIGH | Same session remediation; removal from current tree alone does not remove history exposure |
| login-test.json:1 | Nonempty login password paired with account identifier | LIKELY_SECRET | Yes / yes | Not established as a harmless fixture; validity/reuse UNKNOWN. HIGH | Treat as exposed until owner verifies; rotate affected password and assess reuse; do not replay |
| Historical phase3-package/supabase/.temp/start-secrets/supabase_edge_runtime_phase3-package/env/docker.env:6 | Internal Supabase secret API key | CONFIRMED_SECRET | No / yes | Generated local-runtime credential; activity and reuse UNKNOWN. HIGH if still used | Invalidate/recreate affected local runtime credentials and verify no reuse in another environment |
| Same historical docker.env:3 | Service-role JWT with demo issuer | TEST_FIXTURE | No / yes | Local demo context; privileged if accepted by a running local service. LOW under isolated local use | Do not reuse outside isolated local development; verify exposure/isolation before dismissing |
| Same historical docker.env:4 | Local database credential using conventional local password | TEST_FIXTURE | No / yes | Local-host context; live use UNKNOWN. LOW under isolated local use | Keep local-only; replace if reused/exposed |
| Same historical docker.env:7 | Known local-demo JWT signing secret | TEST_FIXTURE | No / yes | Default local-demo value, not a production credential assessment. LOW under isolated local use | Never reuse in hosted/public environments |
| Same historical docker.env:2 | Anonymous Supabase JWT | FALSE_POSITIVE | No / yes | Public-role client credential, not service-role secret | Preserve correct role/grant boundaries |
| Same historical docker.env:5 | Internal publishable key | FALSE_POSITIVE | No / yes | Publishable key class, not a secret API key | Verify intended scope; no rotation demanded solely by publicity |
| Same historical docker.env:8 | Public JWKS | FALSE_POSITIVE | No / yes | Parsed keys contained no private d component | Public verification material is not private credential exposure |
| .env.example:2 | Example database connection template | PLACEHOLDER | Yes / yes | Example context; not counted as a confirmed active credential | Keep templates non-operational |

Totals: CONFIRMED SECRETS 3; LIKELY SECRETS 1; TEST FIXTURES 3; FALSE POSITIVES 3; PLACEHOLDERS 1. No fixture classification establishes that an internet-accessible deployment using a default credential is safe.

ROTATION REQUIRED: YES. No confirmed currently active credential was established because credentials were never replayed; unknown refresh validity must not be treated as invalidity. Owner-led revocation/rotation or authoritative proof of prior invalidation is required for affected real material. No automatic evidence deletion, history rewriting or credential changes were performed.

### Diagnostic handling incident

A JSON parser failure on a BOM-prefixed tracked login artifact accidentally emitted a sensitive source line in a tool diagnostic. The value is not reproduced here. The scanner was corrected to strip the BOM and suppress raw exceptions. The incident was disclosed to the user and reinforces the password remediation requirement. Earlier claims that no value was printed must not be interpreted as covering this incident. No evidence or output was silently deleted.

## E. Client/server boundary verification

Traced nine use-client roots and 13 reachable first-party modules. The reachable Supabase browser helper references only NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY. No traced client import reaches the admin helper or database credential module. Type-only/shared imports were conservatively included where matched.

Twenty existing browser JS files and twenty fresh production browser JS files were inspected. No sensitive server-variable symbols were found in the initial symbol scan, and no exact known local private values/current session tokens were found in the fresh browser JS scan. This is bounded evidence, not proof for every historical build, dynamic import or deployment. No NEXT_PUBLIC_* server-secret variable name was found. Public keys alone do not bypass correct RLS.

lib/supabase/admin.ts currently has server-side consumers but lacks an explicit server-only import. This remains a LOW preventive-boundary finding rather than confirmed browser leakage. Its secret client is used for auth deletion and audit; credentials are not serialized by those routes. The admin health route exposes presence/provider metadata, not the secret values.

## F. Authorization and RLS — repository only

Overall: REQUIRES HOSTED VERIFICATION. Static flaws and missing guarantees are understood, but hosted grants, installed triggers and policy order were not queried.

| Path / finding | Classification | Evidence and limits |
|---|---|---|
| users_self_update in db/rls.sql:50 and bootstrap:625 | REQUIRES_HOSTED_VERIFICATION | Row ID check does not constrain role/suspension columns. No authenticated column restriction found. Escalation depends on actual UPDATE grants/other protections. Later duta_app column grants protect a different role |
| org_members_manage in db/rls.sql:85 and bootstrap:660 | LIKELY_VULNERABILITY | FOR ALL WITH CHECK permits self user_id without limiting inserted membership role. INSERT uses this check; table grants/other deployed controls determine reachability |
| getOrganizationAccess and secretary/transcription routes | LIKELY_VULNERABILITY | Raw appDb operations lack transaction identity/restricted-role assertions, helper omits active membership status, transcription lacks meeting-to-org verification. Restricted deployed RLS may fail closed; enabling providers without resolving this is unsafe |
| authorizeApi + withUserTransaction profile PATCH | SAFE_BY_DESIGN | Supabase-verified app user, strict allowlisted fields, self ID predicate, database role/profile revalidation; does not accept client role changes. Safety assumes restricted runtime role and applied policies |
| Runtime profile SQL 0018 | SAFE_BY_DESIGN | Grants UPDATE only to profile fields and applies current_app_user_id; does not repair separate authenticated grants |
| Admin API vs 0008 policies | REQUIRES_HOSTED_VERIFICATION | API EDITOR minimum differs from SQL ORG_ADMIN/SUPER_ADMIN. Confirmed repository contract mismatch, not demonstrated live privilege escalation. Role hierarchy also grants MODERATOR the EDITOR minimum |
| Account deletion target selection / 0022 RPC privileges | SAFE_BY_DESIGN | Fixed current-user function, empty search_path, revoked execution from public/client/service/system roles, granted to duta_app; handler uses verified user transaction. Depends on actual grants |
| Cross-system account-deletion completion | LIKELY_VULNERABILITY | App deletion commits before Auth deletion; latter failure strands a profile-less auth account and may defeat normal retry. This is a confirmed recovery design gap, not cross-user deletion proof |
| Admin secret helper consumers | SAFE_BY_DESIGN | Currently server-only call graph with fixed actor target; preventive server-only marker absent |

H2/H3 remain high-impact conditional risks rather than confirmed hosted exploits. No CONFIRMED_VULNERABILITY label is used to claim live exploitation. No RLS or authentication application code was changed.

## G. Migration consistency

MIGRATION STATE: INCONSISTENT.

Journal version 7 has entries 0000–0009. There are 19 SQL migration files and only four snapshots (0000–0003). Duplicate journal tags: none.

Missing referenced SQL files:

- 0004_phase1a_identity_bridge_rls.sql — no reachable path history found.
- 0005_membership_organization_registration.sql — reachable path history present.
- 0006_membership_organization_registration_rls.sql — reachable path history present.
- 0007_member_face_verification.sql — no reachable path history found.

Existing but unjournaled files:

- 0010_runtime_database_roles.sql
- 0011_runtime_identity_bridge.sql
- 0012_runtime_role_grants.sql
- 0013_runtime_official_sources_rls.sql
- 0014_runtime_users_select.sql
- 0015_runtime_users_rls.sql
- 0016_runtime_content_select.sql
- 0017_runtime_sellers_select.sql
- 0018_runtime_users_self_update.sql
- 0019_runtime_audit_self_insert.sql
- 0020_account_deletion_audit_hardening.sql
- 0021_remove_broad_audit_self_insert.sql
- 0022_account_deletion_function.sql

Additional mismatches: 0008 depends on roles/helpers introduced in visible 0010/0011; missing earlier SQL may explain intended historical ordering but cannot be assumed. Runtime account deletion depends on 0022 while migration tooling's journal does not list it. Migration 0020 changes audit actor FK to ON DELETE SET NULL, unlike db/schema.ts. SQL policies mix auth.uid() and current_app identity. Separate bootstrap/RLS/operational SQL and absent later snapshots prevent a reproducible schema claim. Snapshot absence alone is not proof a handwritten migration is invalid; the journal/file mismatch is concrete.

Nothing was restored, renamed, regenerated or applied, including historically available files. Future reconciliation must establish intended chronology and actual schema before any migration repair.

## H. Safety and Day 1 gate

Security register remains CRITICAL 0, HIGH 5, MEDIUM 7, LOW 3. Historical credential artifacts expand H1 evidence, not the number of distinct architectural risks. Counts do not certify dependencies or hosted security.

Application/configuration files, package manifests, SQL, main and all hosted services remain unchanged. Only the three permitted Day 0 documents were amended and this report was added; earlier Day 0 documents remain untracked. No unrelated file remains in the repository.

SAFE TO BEGIN DAY 1: NO. Toolchain is operational with a session override, but six baseline tests fail and credential remediation is outstanding. High-risk policy uncertainty and exact migration drift are documented, not repaired. Recommended next action: authorize a narrowly scoped baseline-remediation task covering credential containment, an isolated test database/fixtures plan, and migration/authorization reconciliation before feature development. Do not connect tests to hosted production to make them pass.
