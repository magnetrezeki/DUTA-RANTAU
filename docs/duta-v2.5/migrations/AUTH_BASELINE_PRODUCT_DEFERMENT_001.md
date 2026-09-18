# Auth Baseline Product Deferment 001

Date: 2026-09-18 (Asia/Kuala_Lumpur)

## Owner decision

The owner stopped further email/password staging ceremony testing pending the
DUTA RANTAU v2.5 Killer Product Pass. This is a product-contract deferment, not
technical validation of the unfinished email/password lifecycle.

The next product pass must evaluate authentication and onboarding first. Its
candidate set is Google OAuth/one-tap as the primary direction, phone or
WhatsApp OTP as secondary candidates, and email/password as a fallback or
retirement candidate. No candidate is selected or authorized for implementation
by this record.

## Preserved Auth evidence

| Item | Classification |
| --- | --- |
| Existing Preview registration route reached | Confirmed |
| Initial staging SMTP failure | Confirmed: provider rejected authentication |
| SMTP configuration remediation | `STAGING_SMTP_READY_FOR_AUTH_RETRY` |
| Final controlled SMTP delivery proof | `NOT_COMPLETED` |
| Positive email confirmation | `NOT_COMPLETED` |
| Positive login/session/logout lifecycle | `NOT_COMPLETED` |
| Password-recovery token/password-change lifecycle | `NOT_COMPLETED` |
| Email/password Auth | `DEFERRED_BY_PRODUCT_DECISION` |

The later user-visible registration retry was stopped from further testing by
the owner decision. It does not supply controlled SMTP-delivery proof or prove
the remaining lifecycle. No unfinished step is recorded as PASS, and the owner
deferment alone does not establish a new application defect.

No identity, email address, password, token, cookie, secret URL, SMTP credential,
API key, or connection string is recorded here.

## Independent technical baseline

The previously established non-Auth-lifecycle baseline remains:

- public routes: `PASS`;
- anonymous `/api/auth/me` contract: `PASS`;
- database-backed baseline through restricted `duta_app`: `PASS`;
- migrations 0039/0040 application compatibility: `PASS`;
- security-negative baseline: `PASS`;
- launch boundaries: `PASS`;
- runtime-log review: `PASS`;
- final staging database safety: `PASS`.

No independent technical or security blocker remains in the authorized
technical-foundation scope. The unresolved email/password proof is now an
explicitly accepted product-contract residue, not a claim that the flow works.

## Foundation decision

- Email/password Auth: `DEFERRED_BY_PRODUCT_DECISION`
- Independent technical blockers: `NONE`
- Technical foundation: `CLOSED_WITH_AUTH_PRODUCT_DEFERMENT`
- Classification: `TECHNICAL_FOUNDATION_CLOSED_WITH_AUTH_PRODUCT_DEFERMENT`
- Next external gate: `DUTA RANTAU v2.5 — KILLER PRODUCT PASS — MASTER PRODUCT CONTRACT RECONCILIATION`

The first decision in that gate must be the authentication and onboarding
contract. It must evaluate Google OAuth, Google one-tap UX where appropriate,
phone OTP, WhatsApp OTP, email/password fallback, account recovery, identity
linking, duplicate-account prevention, phone-number recycling risk, provider
dependency, cost, privacy/data minimization, security, mobile usability,
low-friction onboarding, and existing Supabase compatibility. WhatsApp OTP is a
candidate only and is not selected by this record.

No registration retry, email-delivery test, application/Auth implementation,
Supabase configuration change, migration, push, merge, Production action, or UI
redesign was performed under this decision gate.
