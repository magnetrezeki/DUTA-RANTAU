# Post-0040 Preview Baseline 001

Date: 2026-09-18 (Asia/Kuala_Lumpur)

## Source and deployment identity

| Item | Evidence |
| --- | --- |
| Application candidate under test | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Live `origin/duta-v2.5` head | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Local pre-record HEAD | `7e32a40a94ba372b59d5805509b3692666d9ff86` |
| Local commits ahead before this record | 8 |
| Branch | `duta-v2.5` |
| Pre-record worktree/index | clean |
| Vercel project/environment | `amar99/duta-rantau` / Preview |
| Deployment ID | `dpl_5umHkvwhLEMWHS9qPTAYwTcbAf8z` |
| Deployment source | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Branch URL | `https://duta-rantau-git-duta-v25-amar99.vercel.app` |
| Deployment state | Ready |
| Staging Supabase ref | `bftdfvihtewjwotrzwwe` |
| Application database role | restricted `duta_app` |

The live remote branch was queried read-only and still equals the authorized
application candidate. The newer local commits are migration authority and
sanitized evidence history; they were not pushed or deployed. The current Ready
deployment therefore remains attributable to the exact remote candidate.

Preview-scoped configuration for the application URL, public Supabase URL,
publishable key, and server database URL was previously verified in the Vercel
dashboard without recording secret values. The public endpoint identifies
staging, and the approved server secret mechanism identifies the staging target
and restricted `duta_app` role. No Production target was accessed.

## Baseline results

The public route and database-backed results in
`POST_0040_PREVIEW_SMOKE_001.md` remain current. Root, login, registration,
confirmation failure routing, and major navigation completed without HTTP 500,
fatal routing, environment, hydration, or staging-target errors. Safe server
reads through `APP_DATABASE_URL` succeeded, including `/api/sources` and
`/api/jobs/official` with expected empty staging data.

Additional master-gate checks produced:

| Check | Result |
| --- | --- |
| `GET /auth/lupa-password` | 200 |
| `POST /api/auth/password-recovery` with a nonexistent synthetic address | 200 generic response; provider accepted the recovery request without account-existence disclosure |
| `GET /auth/reset-password` without a recovery token | 307 to same-origin `/masuk?error=password-recovery`, then 200 |
| `GET /api/auth/me` without a session | 401 with `user: null`; expected |
| `POST /api/ai/chat` without a session and with the correct origin | 401 `AUTH_REQUIRED`; expected authorization boundary |
| `GET /api/admin/health` | 200; database and Auth configured, AI provider disabled |

The current provider state is `CONTROLLED_UNAVAILABLE`: the health contract
reports the provider disabled, and the AI route rejects unauthenticated access
before provider execution. No provider secret was exposed and no provider was
activated.

## Authentication residue

Anonymous Auth integration, invalid-login handling, recovery-request handling,
confirmation/reset error routing, and anonymous session recognition passed. A
positive registration-confirmation-login-session-logout lifecycle was not run.
The repository records staging test identities as private, process-local inputs;
none was available, and this gate prohibits placing credentials or tokens in
evidence. Completing that positive lifecycle therefore requires a governed
staging test identity plus a human-only authentication/confirmation ceremony.

Classification: `HUMAN_AUTH_ACTION_REQUIRED`. This is an evidence gap, not an
observed application defect.

## 0039/0040, launch boundaries, logs, and final safety

The official-source application read remains compatible with the accepted
restricted role. No application path required prohibited governance/evidence
privileges. Sensitive table access remains absent for `anon`, `authenticated`,
`duta_app`, and `duta_system`; provider `service_role` access remains preserved.
No migration-owner credential or client-visible server secret was observed.

Marketplace, direct job submission, and seller-listing runtime locks returned
their intended 503/410 results. The existing repository boundaries continue to
withhold consumer payment, regulated finance, health, e-voting, CCTV, MyDigital
ID, marketplace transactions, and unsafe public Citizen Report publication.

The Vercel smoke window showed only the expected 200, 307, 401, 403, 410, and
503 outcomes. The 403 was an intentional same-origin guard probe and was
subsequently confirmed as 401 `AUTH_REQUIRED` with the correct Preview origin.
There were no 500s, uncaught exceptions, database authentication failures,
unexpected permission failures, schema mismatches, Production references, or
secret leakage.

The final staging database check ran inside a read-only transaction. It
confirmed empty source/governance/evidence tables, RLS enabled and FORCE RLS
disabled on sensitive tables, zero sensitive-table policies, denied sensitive
privileges for all application-facing roles, preserved `service_role`, and the
accepted `postgres`/`service_role` public-table default ACL. No database mutation,
migration, ACL change, privilege change, or unauthorized grant occurred.

## Technical-foundation decision

All independently executable technical baseline checks pass. The positive Auth
lifecycle remains human-dependent and has not yet been explicitly accepted as
residue. Consequently:

- Technical foundation: `NOT_CLOSED`
- Classification: `TECHNICAL_FOUNDATION_BLOCKED`
- Sole blocker: positive governed staging Auth lifecycle evidence
- Required next gate: human staging Auth ceremony and session lifecycle
  validation, followed by the technical-foundation exit decision

No application code changed. No push, merge, Production action, database
migration, or database mutation occurred.
