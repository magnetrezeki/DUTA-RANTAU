# Day 0.6A-4 — current-head credential containment implementation

Date: 2026-09-08. Workspace: D:\\DUTA-RANTAU. Branch: duta-v2.5. This phase performed only the authorized containment changes. No credential was used, rotated, revoked, tested against a remote service, or copied. No database, Supabase, environment, application code, Git history, commit or push was changed.

## Actions performed

| File | Action | Result |
|---|---|---|
| cookies.txt | Deleted | Confirmed absent from the working tree |
| login-test.json | Replaced | Valid JSON with clearly synthetic, non-authenticating email/password values |
| .gitignore | Updated | Added only /cookies.txt and /autotest-cookies.txt root artifact rules |

The synthetic fixture uses an example.invalid address and an obvious non-credential marker. It preserves the JSON email/password shape but intentionally cannot provide positive authentication coverage. No replacement token, session or real credential was created.

## Redacted containment scan

The original cookie artifact and original password were read only from the pre-change Git snapshot into memory and compared against current tracked files outside Git metadata and audit documentation. The scan returned no matches. The deleted cookie file does not exist; the replacement login JSON parsed and matched the intended synthetic markers. No secret value, account identifier or token was emitted.

CURRENT WORKING-TREE SECRET EXPOSURE FOR THE DAY 0.6A FINDINGS: NO.

Git terminology matters: the committed Git HEAD still points to the pre-patch commit until a later authorized normal commit is made. Accordingly, `git show HEAD` still contains the historical/current-at-start artifacts, and Git history exposure remains YES. This phase makes the working tree ready for a clean next commit; it does not rewrite or alter the existing HEAD/history.

CURRENT HEAD CONTAINMENT: PASS for the intended next committed snapshot, pending a separate authorization to commit. Git history exposure: YES. Rotation still required: YES.

## Diagnostic impact

- scripts/autotest-full.ps1 references cookies.txt. Its conditional authenticated checks now run without the artifact and can fail or lose authenticated coverage.
- scripts/diagnose-server.ps1 conditionally skips its cookie-backed diagnostic path and records that the file is absent.
- scripts/autotest.ps1 reads login-test.json. The synthetic payload should fail safely at login; dependent authenticated checks cannot establish a legitimate session.

These scripts are diagnostics, not application-runtime imports. No application route/component/server module references either containment artifact. The behavior change is limited to diagnostic authentication coverage. Do not treat expected login failure as a production application failure.

## Validation

The existing process-only npm prefix workaround was used; it was not persisted.

| Command | Result | Notes |
|---|---|---|
| npm test | FAIL | 24 passed, 6 failed. Same pre-existing database-dependent failures: APP_DATABASE_URL is not configured. No database access was attempted. |
| npm run lint | PASS | Exit 0 |
| npm run typecheck | PASS | Exit 0 |
| npm run build | PASS | Exit 0 |

No test was run with a retained cookie/password or a fabricated database URL. Tests do not reference the two containment artifact paths; their known database limitation is independent of this patch.

## Diff and safety review

`git diff -- cookies.txt login-test.json .gitignore` was executed with content suppressed to avoid redisclosing deleted material. `git diff --check` reported no whitespace errors. Final status lists only the three authorized containment paths as tracked changes and the pre-existing/new audit documentation directory as untracked. No unauthorized application, configuration, test or database file was modified.

Production runtime impact: NONE based on repository-visible code paths. External consumers outside this repository cannot be proven absent, but no repository evidence of a production runtime dependency was found.

## Remaining requirements

Credential rotation/session revocation remains separate and is still required. Git history cleanup remains separate and should occur only after rotation and baseline stabilization, with owner coordination. The unresolved test database configuration, account/project ownership, session validity, and historical local-runtime key consumer mapping remain blockers for those follow-up phases.
