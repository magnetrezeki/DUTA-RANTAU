# Migration 0039 — Staging Preparation Gate 001

| Field | Value |
| --- | --- |
| Date | `2026-09-18` |
| Candidate | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Target environment | `STAGING` |
| Target Supabase project ref | `bftdfvihtewjwotrzwwe` |
| Production project ref (prohibited) | `uokljxqqvpujwmubildy` |
| Accepted migration checksum | `sha256:5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30` |
| Migration executed | `NO` |
| Database connection attempted | `NO` |
| Provider mutation performed | `STAGING_AUTH_SITE_URL_ONLY` |
| Gate result | `STAGING_PREPARATION_BLOCKED` |

## Local verification

- Local and remote candidate identities matched.
- The migration authority guard passed with `historical=35, forward=1`.
- The canonical migration file checksum matched the accepted checksum.
- No Supabase CLI or PostgreSQL client was available in the inspected command
  environment. No tooling was installed.

## Provider-access checkpoint 1

The staging dashboard URL for project `bftdfvihtewjwotrzwwe` was opened through
the available browser. The provider redirected to sign-in. The GitHub and
ChatGPT account routes both required interactive authentication; neither
exposed an existing authenticated session. No password, token, OTP, API key,
connection string, or other secret was requested, entered, printed, or stored.

Because authenticated staging administration could not be established, no Auth
redirect change, credential creation, backup operation, or database prestate
query was attempted. Generic local `DATABASE_URL` and `DIRECT_URL` values were
not used because prior evidence binds them to the prohibited production project.

## Unresolved gates

- Auth redirect allowlist inspection and correction: `BLOCKED`.
- Approved staging migration-owner/DDL credential: `BLOCKED`.
- Current staging backup reference, recovery owner, and recovery procedure:
  `BLOCKED`.
- Protocol-defined read-only staging identity/prestate inspection: `BLOCKED`.
- Migration 0039 applied state: `UNVERIFIED`.
- Restricted `duta_app` role and privilege readiness: `BLOCKED`.
- Preview `APP_DATABASE_URL`: `NOT_CONFIGURED`.

## Checkpoint 1 owner action

Interactive authentication was required at checkpoint 1 and was subsequently
completed by the owner outside chat. Checkpoint 2 below supersedes this resolved
authentication blocker.

This record is not staging execution authorization and does not establish
database applied state. Migration 0039 remains prohibited until a later explicit
`STAGING_EXECUTION_AUTHORIZED` decision after prestate and recovery gates pass.

## Provider-access checkpoint 2

The owner completed interactive authentication outside chat. The authenticated
dashboard then positively displayed all of the following together:

- project name `DUTA-RANTAU-V25-STAGING`;
- project ref `bftdfvihtewjwotrzwwe` in the dashboard URL;
- project endpoint `https://bftdfvihtewjwotrzwwe.supabase.co`;
- healthy primary database in `ap-southeast-1`.

The production ref `uokljxqqvpujwmubildy` was not selected or accessed.

### Staging Auth configuration

The existing redirect allowlist already contained the exact required URL:

`https://duta-rantau-git-duta-v25-amar99.vercel.app/auth/konfirmasi`

The staging Site URL was `http://localhost:3001`. Under the authorized staging
Auth scope, it was changed to the exact Preview origin and verified after save:

`https://duta-rantau-git-duta-v25-amar99.vercel.app`

No wildcard was added and no production Auth configuration was accessed.
Classification: `AUTH_REDIRECT_READY`.

### Recovery capability and stop condition

The authenticated staging Database Backups page states that the project is on
the Free Plan and that the Free Plan does not include project backups. The page
offers scheduled backups only through a plan upgrade. It displayed no existing
backup reference. No upgrade, purchase, backup, restore, or billing action was
attempted.

The migration execution plan requires a current recoverable backup/snapshot and
named recovery owner before target prestate verification. Because the provider
cannot supply a backup under the current plan and no independently approved
backup mechanism is available, recovery readiness is `BLOCKED`. Per the gate's
fail-closed sequencing, no database connection, SQL, credential provisioning,
prestate query, role inspection, or Preview database variable change followed.

Current unresolved classifications:

- approved staging migration-owner/DDL credential: `BLOCKED`;
- recovery reference: `NONE`;
- recovery owner and executable procedure: `BLOCKED`;
- database read-only precheck: `BLOCKED`;
- migration 0039 applied state: `UNVERIFIED`;
- staging prestate: `BLOCKED`;
- restricted `duta_app` role: `BLOCKED`;
- Preview `APP_DATABASE_URL`: `NOT_CONFIGURED`.

Required external decision: provide a provider-supported backup capability for
this staging project, or approve and establish a separate deterministic backup
and restore mechanism with a named recovery owner. Billing or plan changes are
outside this gate and were not performed.
