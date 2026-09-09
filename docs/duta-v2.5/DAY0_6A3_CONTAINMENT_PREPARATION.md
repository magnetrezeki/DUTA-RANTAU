# Day 0.6A-3 — current-HEAD containment preparation

2026-09-08. Workspace D:\DUTA-RANTAU; branch duta-v2.5. Planning only. Only this document was created. No application/configuration/test files, credentials, database, Supabase or Git history were changed. No tests, diagnostic requests, rotations, revocations, commits or pushes were executed.

## Current containment files

| FILE | TRACKED | PURPOSE | SECRET CLASS | PRODUCTION RUNTIME DEPENDENCY | TEST DEPENDENCY | SAFE CONTAINMENT ACTION |
|---|---|---|---|---|---|---|
| cookies.txt | YES | Saved authenticated diagnostic cookie jar | SESSION_TOKEN, confirmed private material | None found in application runtime | scripts/autotest-full.ps1 uses it for authenticated requests; scripts/diagnose-server.ps1 conditionally uses it | DELETE / REMOVE_ARTIFACT; do not substitute another real session |
| login-test.json | YES | Login payload used by operational authentication tests | TEST_PASSWORD artifact containing likely real private password/account data | None found in application runtime | scripts/autotest.ps1 submits it; scripts/autotest-full.ps1 references the path but does not submit it as a login payload in inspected code | REPLACE with explicitly synthetic, deliberately non-authenticating JSON |

FILES SAFE TO DELETE: 1. FILES REQUIRING SYNTHETIC REPLACEMENT under this plan: 1. The cookie jar is a regenerable diagnostic artifact, not an application dependency. Removing its working copy does not erase Git history/evidence. The password fixture remains in place only to preserve its expected JSON shape and make its non-operational status explicit; it must not retain any original identity/password value.

Neither filename establishes test-only account ownership. No leaked value needs to be replayed to implement this repository-only containment.

## Synthetic fixture design

Proposed login-test.json replacement, NOT written during this phase:

```json
{
  "email": "synthetic-do-not-login@example.invalid",
  "password": "SYNTHETIC_ONLY_NOT_A_CREDENTIAL"
}
```

These are deliberately public dummy strings, not generated secrets. The reserved invalid domain and obvious marker identify the fixture as synthetic. They must never be provisioned as credentials on any service. The password also fails this repository's registration digit requirement. This does not prove an arbitrary external service cannot manually provision any chosen strings; the design requirement is to keep this fixture non-operational and never use it to establish an account.

The current login API does not reject this marker locally: it can forward login inputs to Supabase. Therefore do not run the real operational login test with the synthetic fixture as a containment validation. Validate shape/markers offline. A later separately scoped diagnostic improvement may reject synthetic inputs before any network request or obtain isolated test credentials through private inputs.

Preserved behavior: file existence and JSON email/password fields. Intentionally unpreserved behavior: successful login and subsequent authenticated operations. Pretending a fake credential can preserve real authentication success would be incorrect. No token/session fixture is needed because the cookie dump should be removed rather than replaced.

## Gitignore recommendation

Existing .gitignore covers dependencies, Next output, .env/.env.local/.env*, coverage, logs, TypeScript incremental cache, .vercel and supabase/.temp/. It does not explicitly exclude root diagnostic cookie jars. Existing broad .env* rules do not remove previously tracked files.

Recommended narrow additions in a later patch:

```gitignore
/cookies.txt
/autotest-cookies.txt
```

Keep the intentionally synthetic login-test.json tracked; ignoring that tracked path would not protect against overwriting it with a real password. For future real test inputs, separately design a private external input or narrowly ignored local fixture path and update its consumer under explicit scope. Do not introduce such a consumer change in the minimum patch.

No broad source-directory exclusion or blanket JSON ignore is recommended. Temporary response/backup outputs may merit a later privacy review, but are not added speculatively to this containment patch. Historical local-runtime secret prevention is separate from these two current files.

## Minimum patch — exact paths and actions

| FILE PATH | ACTION TYPE |
|---|---|
| D:\DUTA-RANTAU\cookies.txt | DELETE |
| D:\DUTA-RANTAU\login-test.json | REPLACE_WITH_SYNTHETIC_FIXTURE |

MINIMUM PATCH FILE COUNT: 2. This is the strict minimum for removing the two identified current-file credential findings. The recommended prevention addition is a third file:

| FILE PATH | ACTION TYPE |
|---|---|
| D:\DUTA-RANTAU\.gitignore | ADD_NARROW_ARTIFACT_RULES |

Thus the recommended implementation is three affected files, while the minimum exposure-removal patch is two. Neither patch rotates credentials or removes history/remote copies.

Important Git distinction: an uncommitted patch changes the working tree, not HEAD. After later authorized implementation, the working-tree scan can report no identified secrets in these files, but CURRENT HEAD SECRET EXPOSURE remains YES until a separately authorized normal commit contains the patch. This planning task prohibits committing. A later commit can produce a clean tip snapshot without rewriting earlier history; origin remains unchanged until separately authorized publication. No claim is made that HEAD is already contained.

## Test and diagnostic impact

TESTS POTENTIALLY AFFECTED: 3 operational test/diagnostic scripts, not three Vitest assertions. No tests were run.

| TEST | EXPECTED IMPACT | Detail |
|---|---|---|
| scripts/autotest.ps1 | REQUIRES_FIXTURE_UPDATE | Reads login-test.json at lines 90–102. Synthetic replacement prevents legitimate login success; dependent authenticated profile operations will lack the intended login. An isolated private credential source or mocked auth test would be needed later to restore positive authentication coverage |
| scripts/autotest-full.ps1 | REQUIRES_FIXTURE_UPDATE | Cookie supplied only when file exists and request requests authentication (lines 117–122). Deletion means authenticated checks run without that cookie and may fail. Its LoginFile reference alone does not supply authentication |
| scripts/diagnose-server.ps1 | REQUIRES_FIXTURE_UPDATE | Conditional cookie branch at lines 218–229 skips the cookie-backed diagnostic when file is absent and reports the missing file. Script can continue, but authenticated diagnostic coverage is removed until a safe private session input is designed |
| Existing six tests/ Vitest test files | NONE | No references to these artifact paths found; previously observed six missing-database failures remain independent |
| Existing lint/typecheck/build commands | NONE expected | No runtime TypeScript/configuration dependency found. This is static impact assessment, not a new validation result |

Do not modify the diagnostics to accept unauthorized responses as successful authentication merely to make checks pass. Keep the temporary loss of positive login coverage explicit. No dependency on these files was found in application routes/components or production build configuration.

## History cleanup timing

HISTORY CLEANUP TIMING: AFTER_ROTATION.

Establish credential revocation/replacement or authoritative prior invalidation first. Working-tree containment may be prepared independently now; Git history rewriting does not invalidate a session or password. Later history cleanup requires owner coordination across affected refs, including remote main, collaborator clones and backup refs. Stabilize the baseline and agree a recovery procedure before any rewrite execution. This is not permission to touch main or delete backup evidence.

ROTATION STILL REQUIRED: YES. Unknown ownership/environment prevents unconditional execution of the separate rotation plan; it does not block removing exposed credential material from application-independent diagnostic files under a later authorized containment task.

## Production safety

PROPOSED PATCH PRODUCTION IMPACT: NONE for repository-visible legitimate application behavior. The two artifacts are not imported by application code, and production configuration/schema/auth architecture are untouched. Operational diagnostic behavior changes as documented. External consumers not represented in the repository cannot be certified, but no evidence suggests a production runtime dependency.

CURRENT HEAD CAN BE SAFELY CONTAINED: YES via the planned working-tree changes and a later separately authorized normal commit. SAFE TO IMPLEMENT CONTAINMENT PATCH: YES under the defined file scope; this is a readiness assessment, not execution or rotation approval.

## Prepared implementation plan — not executed

1. Affected file: cookies.txt. Operation: remove the obsolete diagnostic cookie dump from the working tree only. Reason: confirmed private sessions have no app-runtime dependency. Validation: verify absence without printing content; inspect status by filenames; confirm diagnostic code's missing-file behavior statically. Do not make another secret backup or rewrite history.
2. Affected file: login-test.json. Operation: replace the entire file with the synthetic JSON above, stripping all original data. Reason: preserve fixture shape without an actual account/password. Validation: parse in memory with raw exceptions suppressed; verify exact synthetic fields and absence of original values using boolean output only. Do not execute a login request. Document loss of positive auth diagnostic coverage.
3. Affected file: .gitignore (recommended prevention addition). Operation: add only the two root cookie artifact patterns. Reason: prevent regenerated session dumps from accidentally being staged later. Validation: inspect ignore-pattern behavior, ensure no application source is excluded, and run a redacted working-tree scan/diff-name check. Confirm no other application/configuration changes and no secret-bearing diff output. Do not report HEAD clean until a separately authorized commit actually contains the changes; stop before any commit/push/rotation.

Required later validation must remain local/offline where possible. Do not run operational scripts that send retained cookies/passwords to hosted services. Any request to rerun existing safe local validation should preserve the known isolated/missing-database boundary and must not silently supply production access.

## Final state

Only docs/duta-v2.5/DAY0_6A3_CONTAINMENT_PREPARATION.md created. No existing documentation altered. Current credential artifacts and HEAD are unchanged. No tests executed. No containment implementation, credential rotation, session revocation, database/Supabase change, history rewrite, commit or push occurred.

BLOCKERS: NONE for preparing/implementing the scoped containment patch in a subsequent authorized task. Separate rotation still requires ownership/environment verification; remote/history remediation and committing remain outside this phase.
