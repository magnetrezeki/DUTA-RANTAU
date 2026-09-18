# Staging Auth Ceremony Attempt 001

Date: 2026-09-18 (Asia/Kuala_Lumpur)

## Scope

This is sanitized evidence for the authorized staging-only positive Auth
lifecycle gate. No email address, password, token, cookie, secret URL,
connection string, or remote address is recorded.

| Item | Evidence |
| --- | --- |
| Application candidate | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Preview deployment | `dpl_5umHkvwhLEMWHS9qPTAYwTcbAf8z` |
| Preview origin | `https://duta-rantau-git-duta-v25-amar99.vercel.app` |
| Supabase project | staging `bftdfvihtewjwotrzwwe` |
| Identity class | synthetic, staging-only |

## Observed attempt

The human operator submitted one synthetic staging registration through the
actual Preview `/daftar` flow. Vercel recorded `POST /api/auth/register` as HTTP
400. Supabase staging Auth recorded the corresponding `/signup` request and the
correct same-origin confirmation callback target.

Supabase Auth attempted the `user_confirmation_requested` action but returned
HTTP 500 with SMTP response `535 Authentication credentials invalid` and Auth
error code `unexpected_failure`. The application intentionally mapped the
provider failure to its generic registration-error message.

This proves that the request reached the correct staging project and that the
Preview redirect target was supplied correctly. Registration did not complete
because staging email delivery credentials were rejected by the mail provider.

A catalog-only staging check inside a read-only transaction confirmed that the
attempted synthetic Auth identity was not persisted. No cleanup is required for
this attempt.

## Classification and boundary

- Registration: `FAIL`
- Primary classification: `AUTH_CONFIGURATION_DEFECT`
- Specific classification: `EMAIL_DELIVERY_DEFECT`
- Confirmation and subsequent lifecycle steps: `NOT_RUN`
- Cleanup: `NOT_APPLICABLE`
- Application code defect established: `NO`
- Production action: `NONE`
- Database migration or application-database mutation: `NONE`

The authorized gate expressly prohibits changing Supabase configuration or
application code after a lifecycle failure. The affected path therefore stops
at registration. Remediation requires the staging owner to repair or replace the
configured SMTP credentials using Supabase's supported Auth email settings,
then start a fresh synthetic registration attempt. Secret values must remain in
the provider UI and must not be placed in chat or repository evidence.

## Independent baseline recheck

After the failed attempt, Preview health and the database-backed source route
both returned HTTP 200; the source registry remained empty as expected. The
failed Auth transaction created no synthetic identity. The previously recorded
post-0040 application/database/security baseline therefore remains intact.

Technical foundation remains `NOT_CLOSED` until staging email delivery is
repaired and the full positive Auth lifecycle is completed.
