# Post-0040 Preview Redeployment and Staging Application Smoke 001

Date: 2026-09-18 (Asia/Kuala_Lumpur)

## Scope and identity

This record covers the authorized Preview-only redeployment and non-destructive
staging smoke gate. No secret values are recorded.

| Item | Result |
| --- | --- |
| Vercel project | `amar99/duta-rantau` |
| Environment | `Preview` |
| Branch | `duta-v2.5` |
| Authorized/source commit | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Deployment ID | `dpl_5umHkvwhLEMWHS9qPTAYwTcbAf8z` |
| Unique deployment domain | `duta-rantau-mv2bklc7z-amar99.vercel.app` |
| Branch Preview URL | `https://duta-rantau-git-duta-v25-amar99.vercel.app` |
| Status | `READY` |
| Deployment timestamp | 2026-09-18 09:29:42 GMT+8 |
| Public Supabase target | staging `bftdfvihtewjwotrzwwe` |
| Server database target | staging `bftdfvihtewjwotrzwwe` |
| Server database role | restricted `duta_app` |

Before redeployment, the Vercel dashboard showed Preview branch-scoped entries
for `NEXT_PUBLIC_APP_URL`, `NEXT_PUBLIC_SUPABASE_URL`,
`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, and `APP_DATABASE_URL`. The two
non-secret URL values matched the authorized Preview domain and staging
Supabase endpoint. The database target and restricted role were established
from the approved secret mechanism without displaying the secret. Vercel then
redeployed the existing candidate directly; no Git push was used.

## Public and database-backed smoke

The root, registration, login, information, service, safety, jobs, market,
organization, community, and question routes loaded without a 500 or visible
configuration failure. `/jaga-diri` and `/organisasi/paket` returned HTTP 200.
Calling `/auth/konfirmasi` without a token followed the designed same-origin
failure path to `/masuk?error=confirmation`; it did not redirect to Production.

Safe application reads returned:

| Path | Result |
| --- | --- |
| `GET /api/admin/health` | 200; database and staging Auth configuration present |
| `GET /api/sources` | 200; empty source list, consistent with staging data |
| `GET /api/jobs/official` | 200; empty official-job list |
| `GET /api/safety/contacts` | 200; expected public directory payload |
| `GET /api/auth/me` | 401; expected anonymous-session result |

These server-side reads succeeded after the Preview secret change became active.
The application connection contract rejects elevated or substitute roles, and
the approved staging secret was independently established as `duta_app`.

## Authentication smoke

The registration and login entries loaded on the Preview origin. A synthetic,
nonexistent invalid login reached staging Auth and returned the expected 401
without creating a user or session. The confirmation failure path stayed on the
Preview origin. Account creation, recovery, and a positive authenticated session
were not attempted because no repository-authorized synthetic account fixture
was available under this gate. Authentication smoke is therefore `PARTIAL`, not
a claim of a complete signup/session lifecycle.

## 0039/0040 behavior and security

The application `official_sources` read path succeeded through the restricted
runtime role and returned the expected empty result. There is no current
repository-defined public application read path for the sensitive governance or
evidence tables, so no data was fabricated to exercise one.

A final catalog-only check ran inside `BEGIN TRANSACTION READ ONLY` and confirmed:

- `official_sources`, `official_source_governance`, and
  `official_source_evidence` still exist with RLS enabled;
- governance and evidence retain zero policies and zero rows;
- all three source tables retain zero rows;
- `anon`, `authenticated`, `duta_app`, and `duta_system` have no sensitive-table
  privilege, while `service_role` retains its provider grants;
- `duta_app` remains non-superuser, non-BYPASSRLS, non-CREATEROLE,
  non-CREATEDB, and non-replication;
- `duta_app` retains `SELECT` and `DELETE` on `official_sources`, no table-level
  `INSERT` or `UPDATE`, the accepted nine INSERT columns, and the accepted three
  UPDATE columns;
- the `postgres` public-table default ACL remains limited to `postgres` and
  `service_role`.

No 0039 or 0040 migration was rerun and no database mutation was performed.

## Launch locks and logs

The runtime checks returned the intended locked behavior:

| Path | Result |
| --- | --- |
| `GET /api/marketplace` | 503; marketplace data unavailable |
| `POST /api/admin/jobs` | 410; direct job submission unavailable |
| `POST /api/admin/marketplace` | 410; seller listing unavailable |
| `/organisasi/paket` | 200; Preview copy states that no payment is processed |

Repository-defined locks continue to withhold consumer paywall processing,
marketplace transactions, regulated finance execution, health functionality,
e-voting, CCTV, MyDigital ID execution, and unsafe public Citizen Report
publishing. No deferred feature was enabled.

Vercel runtime logs for deployment `dpl_5umHkvwhLEMWHS9qPTAYwTcbAf8z` showed
the expected smoke requests and statuses. The reviewed window contained no 500,
database authentication failure, permission error, staging/Production target
mismatch, unhandled exception, secret leakage, or migration/schema error.

## Classification

- Public route smoke: `PASS`
- Database-backed smoke: `PASS`
- Authentication smoke: `PARTIAL`
- 0039/0040 application smoke: `PASS`
- Security negative verification: `PASS`
- Launch-lock smoke: `PASS`
- Runtime log review: `PASS`
- Final database safety: `PASS`
- Overall: `STAGING_APPLICATION_SMOKE_PARTIAL`

The only incomplete item is a positive signup/session lifecycle. It requires a
separately governed staging test identity or an already-authorized fixture; it
is not evidence of an observed defect. Production actions, database mutation,
push, merge, and Production deployment were all `NONE`.
