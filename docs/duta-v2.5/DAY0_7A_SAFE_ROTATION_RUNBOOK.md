# Day 0.7A — Safe Rotation Runbook

Date: 2026-09-09. This runbook is a plan only. No credential, session, hosted environment, or Git history was changed.

## Security stop conditions

Stop before a rotation if credential ownership is unknown; the target environment is unclear; a replacement path or rollback is unavailable; a credential is shared across environments; production dependency is unclear; health validation cannot be performed; active compromise is indicated; a current-head secret is found; or dashboard evidence conflicts with this repository map.

## Phase 1 — establish ownership and scope

| EXECUTOR | PRECONDITION | ACTION | VALIDATION | ROLLBACK | STOP CONDITION |
|---|---|---|---|---|---|
| BOS_MANUAL | Legitimate owner access to provider dashboards | Identify the Auth account for R1/R2, its project ref, environment, account purpose, and recovery path. Identify R3 issuer and consumers. Inventory Supabase, Vercel, database, and AI credentials by metadata only. | Record non-secret metadata, owner, environment, status, and dependency. | None; this is read-only. | Any item cannot be tied to an owner/environment. |
| CODEX_STANDARD | Bos supplies non-secret metadata and explicit next-phase authorization | Update the rotation matrix/runbook with confirmed scope only. | Documentation matches supplied metadata. | Revert documentation only if incorrect. | Metadata would require guessing a target. |

## Phase 2 — prepare bounded replacements

| EXECUTOR | PRECONDITION | ACTION | VALIDATION | ROLLBACK | STOP CONDITION |
|---|---|---|---|---|---|
| BOS_MANUAL | Correct project/account and recovery path are confirmed | Prepare replacement password/credential through the owning provider's supported control. Do not place it in chat, source, diagnostic fixtures, or environment files without a separately authorized change. | Provider confirms replacement is ready; affected app path and recovery account are identified. | Preserve provider-supported prior state only when safe; never restore a disclosed credential. | Shared or production dependency is discovered without a tested rollout. |
| BOS_MANUAL | R3 issuer and all consumers are confirmed | Prepare local-runtime replacement or document authoritative retirement/non-reuse. | Consumer map and restart sequence exist. | Provider/runtime-specific only. | R3 is actually reused in a hosted project without a separate hosted plan. |

## Phase 3 — rotate/revoke the exposed account family

| EXECUTOR | PRECONDITION | ACTION | VALIDATION | ROLLBACK | STOP CONDITION |
|---|---|---|---|---|---|
| BOS_MANUAL | Phase 1 and Phase 2 complete for R1 | Reset the affected account password using legitimate owner controls. | New password signs in through the intended account flow; no secret is reported to Codex. | Provider-supported recovery only; do not restore old password. | Auth account or project does not match mapped target. |
| BOS_MANUAL | R1 replacement succeeded, unless active compromise requires immediate revocation | Globally revoke/sign out the affected account's sessions and refresh tokens using supported Supabase/Auth controls. | Provider indicates the action completed; intended account can reauthenticate with replacement. | Reauthentication only; revoked sessions cannot be restored. | Scope expands beyond confirmed account or affects an unverified project. |
| BOS_MANUAL | R3 remains active and local-only | Replace/invalidate R3 using its identified local runtime procedure; restart only mapped consumers. | Local runtime health and mapped consumers pass approved checks. | Provider/runtime-specific; do not reset local data. | Any evidence of hosted reuse or unknown consumer. |

## Phase 4 — update dependencies and validate

| EXECUTOR | PRECONDITION | ACTION | VALIDATION | ROLLBACK | STOP CONDITION |
|---|---|---|---|---|---|
| BOS_MANUAL | A server, database, Vercel, or provider credential was proven exposed and has a replacement | Update only the confirmed environment scope through the owning dashboard or secret store. | Deployment/health checks and ordinary user operation succeed in that scope. | Restore the previously active safe configuration only if the old credential has not been revoked; otherwise use provider recovery. | Production outage risk or inability to validate. |
| CODEX_STANDARD | Explicit authorization and private process-local inputs are supplied | Run approved local/static tests or the staging real-auth harness. Do not log credentials. | Relevant tests and health checks pass. | Stop tests; no secret-bearing files are created. | Any unexpected authorization, RLS, or deployment failure. |

## Phase 5 — completion evidence

Bos records finding ID, operator, timestamp, provider/project scope, action outcome, and non-secret health result. Codex may update documentation only under a separate authorized task. Do not mark lifecycle status as revoked or replaced without provider or owner evidence.

## Post-rotation Git history remediation

History cleanup remains later work. It requires confirmed rotation/revocation, baseline stabilization, authorization verification, a ref/tag/branch inventory, protected-branch and collaborator coordination, a force-push plan, re-clone/rebase guidance, cache/fork considerations, and GitHub secret-scanning follow-up. A rewrite reduces redisclosure but cannot invalidate copied credentials. Do not rewrite `main` or any branch without a separately approved coordinated plan.

## Unidentified historical Auth credential containment

V2.5 staging was manually inspected and excluded as the owner of CRED-01/CRED-02: it has two known synthetic security users and no unexpected or older user. Production was manually inspected, but the historical diagnostic account could not be identified with high confidence among its two accounts. Therefore production linkage is unproven.

Do not reset either production account or revoke production sessions based on account count, filename, or inference. CRED-01 and CRED-02 are classified as compromised historical material and must never be reused. Current-head/worktree secret scanning remains PASS. If legitimate future evidence identifies the owning account/project, immediately reopen the password-reset and session-revocation workflow with owner, dependency, recovery, validation, and rollback evidence.

## Local runtime secret containment

CRED-03 has local-only historical provenance in the `phase3-package` Supabase CLI/Docker runtime and no current repository-visible consumer. It is quarantined as compromised and must never be reused. Do not rotate a hosted key or modify an existing local runtime from this evidence. Recreate a local runtime later only if an authorized owner establishes a valid need; first map issuer, current lifecycle, consumers, and any hosted reuse. This is containment, not a claim that the historical issuer has been retired or rotated.
