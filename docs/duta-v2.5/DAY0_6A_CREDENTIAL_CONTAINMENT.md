# Day 0.6A — credential containment and rotation plan

2026-09-08. Diagnostic/planning only. Authoritative workspace: D:\DUTA-RANTAU; branch duta-v2.5; HEAD 1de693ac50fdcfe5a1560bf860234f36d2a91d3d. No credential use, rotation, file deletion, environment change, hosted-service query, application edit, commit or history rewrite performed. Only this document was created.

## Findings and counting

Confirmed secret findings: 3; likely secret findings: 1. These count logical artifact/type groups, not individual token strings. Three session artifact versions contain one distinct account/issuer pair; the account matches the password artifact, by in-memory comparison only. No account identifier, issuer, token, password or fingerprint is recorded.

ROTATIONS REQUIRED: 3 containment actions/families: account password replacement, revocation of the affected account's sessions, and replacement/invalidation of the historical local internal API key if still accepted. Session revocation covers both cookie findings together. The local-key action may be closed with authoritative evidence of prior invalidation; no active validity was tested.

First/last known commits below mean earliest/latest containing snapshots in the locally reachable topological history inspected, not first publication time or last modification time. The inspection did not fetch remote refs, inspect remote services, or cover unreachable objects/forks/clones. Current file checks and HEAD checks are separate.

### C1

ID: C1
SECRET TYPE: SESSION_TOKEN — Supabase user access/refresh session container; CONFIRMED_SECRET; private.
CURRENT FILE: cookies.txt:5
CURRENTLY TRACKED: YES
PRESENT IN GIT HISTORY: YES
FIRST KNOWN COMMIT: fe3d61ec93981b9a9fc0c2650d6915caf1909809
LAST KNOWN COMMIT: 1de693ac50fdcfe5a1560bf860234f36d2a91d3d
CURRENT FILE STILL CONTAINS IT: YES
LIKELY LIVE: UNKNOWN
SCOPE: UNKNOWN
RISK: HIGH
ROTATION REQUIRED: YES
REPOSITORY CLEANUP REQUIRED: YES
HISTORY CLEANUP REQUIRED: REVIEW
REASON: Actual user-session material remains in HEAD. Recorded access expiry elapsed, but refresh validity is unknown; a diagnostic filename does not establish a development-only account. Twenty containing commits were found. Revoke sessions rather than rotating unrelated project keys.

### C2

ID: C2
SECRET TYPE: SESSION_TOKEN — historical Supabase access/refresh session containers; CONFIRMED_SECRET; private.
CURRENT FILE: autotest-cookies.txt:5 (historical path; absent currently)
CURRENTLY TRACKED: NO
PRESENT IN GIT HISTORY: YES
FIRST KNOWN COMMIT: fe3d61ec93981b9a9fc0c2650d6915caf1909809
LAST KNOWN COMMIT: 4a634aac10daaf43eb0c9314de353e22d390b418
CURRENT FILE STILL CONTAINS IT: NO
LIKELY LIVE: UNKNOWN
SCOPE: UNKNOWN
RISK: HIGH
ROTATION REQUIRED: YES
REPOSITORY CLEANUP REQUIRED: NO
HISTORY CLEANUP REQUIRED: REVIEW
REASON: Two historical versions, seventeen containing commits, same account/issuer as C1. Removal from current files does not revoke refresh credentials. C1/C2 share one account-session containment action; no current file needs deleting for C2.

### C3

ID: C3
SECRET TYPE: API_KEY — SUPABASE_INTERNAL_SECRET_KEY from historical local runtime; CONFIRMED_SECRET; private elevated internal credential, not a publishable key.
CURRENT FILE: phase3-package/supabase/.temp/start-secrets/supabase_edge_runtime_phase3-package/env/docker.env:6 (historical path; absent currently)
CURRENTLY TRACKED: NO
PRESENT IN GIT HISTORY: YES
FIRST KNOWN COMMIT: d6b1c797eba43dc83a0bbc4b3888e9ba7478c1f9
LAST KNOWN COMMIT: 3223a1d3d85c90524331229582fe8add5d2e1de7
CURRENT FILE STILL CONTAINS IT: NO
LIKELY LIVE: UNKNOWN
SCOPE: DEVELOPMENT (artifact provenance; reuse elsewhere UNKNOWN)
RISK: HIGH
ROTATION REQUIRED: YES
REPOSITORY CLEANUP REQUIRED: NO
HISTORY CLEANUP REQUIRED: REVIEW
REASON: Non-placeholder secret API credential in generated local runtime material. Three containing commits; reachable through backup-before-secret-cleanup. No local origin reference contains these commits. That does not prove the material was never shared or pushed previously. Do not assume this is the hosted application's SUPABASE_SECRET_KEY.

### L1

ID: L1
SECRET TYPE: TEST_PASSWORD — login diagnostic password; LIKELY_SECRET; private. This class describes the artifact, not proof of synthetic content.
CURRENT FILE: login-test.json:1
CURRENTLY TRACKED: YES
PRESENT IN GIT HISTORY: YES
FIRST KNOWN COMMIT: fe3d61ec93981b9a9fc0c2650d6915caf1909809
LAST KNOWN COMMIT: 1de693ac50fdcfe5a1560bf860234f36d2a91d3d
CURRENT FILE STILL CONTAINS IT: YES
LIKELY LIVE: UNKNOWN
SCOPE: UNKNOWN
RISK: HIGH
ROTATION REQUIRED: YES
REPOSITORY CLEANUP REQUIRED: YES
HISTORY CLEANUP REQUIRED: REVIEW
REASON: Nonempty password paired with the same account as the confirmed sessions. No evidence establishes it as harmless synthetic data; validity/reuse must be resolved by the owner, not a login attempt. Twenty containing commits were found.

## Public versus private material

Additional Day 0.5 candidates remain outside the four secret findings above:

| Material | Credential class | Public/private | Decision |
|---|---|---|---|
| Historical docker.env anonymous JWT | SUPABASE_ANON_KEY | Intended public client configuration | FALSE_POSITIVE for secret exposure; no rotation merely because public |
| Historical internal publishable key | OTHER (publishable API configuration) | Intended public key class | FALSE_POSITIVE; verify scope, no automatic rotation |
| Historical public JWKS | OTHER | Public verification keys; parsed keys had no private d component | FALSE_POSITIVE; no secret cleanup required |
| Historical demo-issuer service-role JWT | SUPABASE_SERVICE_ROLE_KEY | Privileged even though demo fixture | TEST_FIXTURE; no hosted rotation inferred. Reassess if a reachable service accepts it or it was reused |
| Historical conventional local DB credential | DATABASE_CREDENTIAL | Private operational credential despite familiar default | TEST_FIXTURE from local runtime; isolate local services; replace if reused/exposed |
| Historical standard local-demo JWT signing secret | OTHER | Private signing role despite known demo default | TEST_FIXTURE; unsuitable for public/production deployments; no production reuse established |
| .env.example connection template | DATABASE_CREDENTIAL | Placeholder | No live-secret rotation; retain only clearly synthetic, non-operational examples |

The runtime's NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY are not evidence of secret exposure. Server secret API keys and legacy service-role JWTs are different credential classes; user session revocation does not require replacing publishable keys. [Supabase API key classes](https://supabase.com/docs/guides/getting-started/api-keys).

No evidence in these findings requires rotating GitHub, Vercel, hosted database passwords, NVIDIA/Gemini API keys or the hosted JWT signing key. Do not expand rotation to unrelated credentials without evidence of reuse/exposure.

## Current and remote exposure

CURRENT HEAD SECRET EXPOSURE: YES

Confirmed-secret file: cookies.txt.

Additional likely-secret file: login-test.json.

GIT HISTORY SECRET EXPOSURE: YES. Containing commit/path pairs are recorded in C1–L1 above; matching contents were never printed in this phase.

REMOTE EXPOSURE LIKELY: YES for C1, C2 and L1. Their containing commits are ancestors of locally stored refs/remotes/origin/main, origin/duta-v2.5, origin/feature/marketplace-crud and origin/HEAD. Local HEAD equals the stored origin/duta-v2.5 commit. These refs are evidence of likely origin publication, not a fresh server verification. Repository visibility, remote retention, forks and download activity are UNKNOWN.

C3 remote exposure: UNKNOWN. No locally stored origin ref contains its three snapshots; its last containing commit is reachable from refs/heads/backup-before-secret-cleanup. Do not delete that branch or assume its historical secret is inactive. No network Git operation or private third-party service query was made.

## Rotation plan — not executed

Prerequisite: the account/project owner must identify the affected account/project privately through legitimate existing account access and establish control. Do not authenticate with a leaked cookie/password to identify it. Confirm which local runtime issued C3 and which services still consume it. Do not paste replacement credentials into chat or diagnostic output.

| Order / findings | System | What must change | Where the owner acts | Application configuration update | Expected impact |
|---|---|---|---|---|---|
| 1 — L1 | Supabase Auth account authentication | Replace affected account password with a unique password; assess reuse on other owner-controlled accounts | Verified application's account/password recovery flow or owner-managed Supabase Auth user administration for the correct project; use supported recovery if app UI is incomplete | None for normal app login. Future diagnostics must obtain test credentials privately rather than tracked JSON | Account must use new password. Do not assume this alone revokes every existing session |
| 2 — C1/C2 | Supabase Auth sessions, same account | Revoke all affected account sessions/refresh tokens, including other devices | Supported global sign-out/session revocation under the correct account or authorized owner administration, using legitimate access, never copied exposed tokens | No API-key/env changes. Browser session state refreshes through normal auth | Devices sign in again. Already-issued access tokens can remain usable until their expiration; avoid claiming instant JWT invalidation |
| 3 — C3 | Local Supabase development runtime | Invalidate/replace the specific internal secret key, or establish that its issuing runtime was already retired and no service accepts it | Owner-managed local Supabase runtime configuration/lifecycle after identifying the issuer and data-preserving procedure | Update only identified local runtime consumers. Update app SUPABASE_SECRET_KEY or other deployments only if matching reuse is privately confirmed | Local dependent services may need coordinated restart; do not delete/reset local database data |

If suspicious account activity is observed, containment may start with session revocation before password replacement, followed by another global revocation after replacement. Complete both actions; do not leave an exposed password able to mint replacement sessions.

Global sign-out invalidates refresh sessions; access JWT validity has separate expiry semantics. [Supabase sign-out behavior](https://supabase.com/docs/guides/auth/signout), [JavaScript signOut reference](https://supabase.com/docs/reference/javascript/auth-signout).

For C3, there is no evidence supporting an exact dashboard button or an automatic hosted key operation. First map the local issuer/consumers; then select its supported key-replacement mechanism. Preserve local data. If owner verification instead proves reuse as a hosted secret key, prepare replacement consumers, revoke that specific old key and verify service health through approved steps. Do not rotate a shared legacy signing key merely to address a session-token leak. [Supabase API keys](https://supabase.com/docs/guides/getting-started/api-keys), [JWT signing-key lifecycle](https://supabase.com/docs/guides/auth/signing-keys).

Closure evidence should record only actor, time, affected finding IDs, revocation/replacement outcome and service health. Verify invalidation with owner/provider evidence without replaying exposed credentials. For already-retired C3, record authoritative retirement/non-reuse evidence instead of rotating an unrelated live system.

## Minimum repository cleanup plan — not executed

- cookies.txt: after owner-authorized evidence handling, remove the obsolete session dump from the working tree/tracked content. Do not substitute another real cookie. A later separate change can ignore diagnostic cookie outputs and put any necessary synthetic parsing fixtures in tests.
- login-test.json: if obsolete, remove it after authorized evidence handling; otherwise replace with unmistakably synthetic data that cannot authenticate. Any real test runner should read privately provided test credentials through an approved mechanism. Do not merely move the same secret to another committed file.
- autotest-cookies.txt and historical docker.env: no current file remains to delete. A later scoped prevention change may ignore generated secret/runtime artifacts. Do not recreate historical files to clean them.
- Do not remove public publishable/anon configuration solely because it resembles a key. Do not delete evidence or change ignore rules during this phase.

## History-cleanup decision

HISTORY CLEANUP: RECOMMENDED, after revocation/rotation and owner coordination.

Real session material appears in likely published history, and current credentials need cleanup. Sanitizing affected historical paths can reduce accidental redisclosure, including the local backup branch's internal key. It cannot revoke tokens or erase existing copies. Rotation/containment is the security priority.

Per-finding HISTORY CLEANUP REQUIRED remains REVIEW because mandatory rewriting is not established: repository visibility, collaborators, forks and reuse are unknown, and successful invalidation may make rewriting optional based on retention policy. Before any rewrite, the owner must inventory affected refs/clones and agree on disruption, protected branches and re-cloning/rebasing guidance. Origin main appears in exposure reachability, but this task does not authorize touching it. No rewrite commands, forced updates or deletion were executed.

## Accidental Day 0.5 diagnostic disclosure

The parser error emitted the login-test.json source line, containing the password artifact and an account identifier. Active validity remains UNKNOWN. The account correlates with confirmed sessions, so there is insufficient evidence to classify the disclosure as synthetic test data. Do not repeat the line.

The incident adds a disclosure surface for L1 but no newly identified credential family. The password replacement and session revocation already planned cover this account; extend to other accounts only if the owner confirms password reuse. The owner may review access/retention controls for the diagnostic conversation through supported controls, but no conversation or security evidence was deleted here.

## Gate and remaining blockers

SAFE TO ROTATE CREDENTIALS: NO for unconditional execution of the complete plan. This is a reviewed conditional plan, not a determination of correct account/project ownership or C3 runtime dependencies. Once the owner privately verifies targets and coordinates C3 consumers, the scoped actions can proceed in a separately authorized execution phase. Urgent legitimate account-owner password/session containment need not wait for Git history cleanup.

Blockers: affected account/project ownership and environment mapping unverified; refresh-token validity/reuse unknown; C3 runtime lifecycle/consumers unverified; repository visibility/collaborator impact unknown for history decisions. No rotation or remediation is claimed complete. Application, database, Supabase, Git history, environment variables and other documentation remain unchanged.
