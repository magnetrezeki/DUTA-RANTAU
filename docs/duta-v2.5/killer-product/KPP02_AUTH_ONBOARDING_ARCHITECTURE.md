# KPP-02 Auth and Minimum Onboarding Architecture

## Entry model

Login/register distinctions disappear from the primary new-user experience.
The entry asks users to **Continue with Google** or **Continue with email**.
Email means passwordless magic link. A quiet “Use existing password” route may
remain only for compatible existing accounts. Google One Tap, phone OTP and
WhatsApp OTP remain deferred.

Auth is invoked only when a user chooses an identity/persistence/mutation action.
The request includes an allowlisted relative `returnTo` plus a non-secret
action intent. OAuth callback and magic-link completion validate it and resume
the intended task; invalid/missing values fall back to TODAY, never a Preview
profile. Current callbacks that always target `/profil` are not the target.

## Required states

- **Google:** starting, provider redirect, callback validation, success,
  cancellation, provider unavailable and collision/duplicate-account review.
- **Magic link:** email entry, generic sent state, resend timer, use another
  email, waiting across devices, expired/used link and safe restart.
- **Collision:** explain that an account already exists, identify the safe
  sign-in method without exposing private account data, and never silently
  merge. Linking occurs only after explicit reauthentication and tested
  Supabase-native behavior.
- **Failure:** retain intended task, offer the other approved method and a
  public/non-persistent continuation where possible.

## Data classification

| Datum | Classification | Rule |
| --- | --- | --- |
| Provider identifier/email | IDENTITY_REQUIRED | Supplied by chosen provider; disclose purpose |
| Provider credential | IDENTITY_REQUIRED | Provider-managed; DUTA must not duplicate it |
| 18+ self-attestation | FIRST_SESSION_REQUIRED | At account creation/identity-bound action under current policy; legal review required |
| Full name | JUST_IN_TIME | Ask only when a feature needs a display/legal name |
| Coarse city/state | OPTIONAL | Explain relevance; skippable |
| Current need/intent | JUST_IN_TIME | Derive from chosen task where possible |
| Profession, origin, interests | OPTIONAL | Feature-specific and editable |
| Precise location | DO_NOT_COLLECT_AT_ONBOARDING | Request only in a benefiting capability |
| Full DOB | DO_NOT_COLLECT_AT_ONBOARDING | Prohibited by locked default |
| Birth year | DO_NOT_COLLECT_AT_ONBOARDING | Do not collect for convenience |
| Phone/WhatsApp | DO_NOT_COLLECT_AT_ONBOARDING | Deferred identity method |

The minimum first session is provider identity plus lightweight 18+ attestation
where required. All other context is skipped unless the chosen action needs it.

## Location

Location is never a generic onboarding step. A benefiting feature offers **Allow
once**, **Allow where platform support and an approved contract exist**, and
**Not now / choose area manually**. Denial leaves a complete coarse/manual path.

## Legacy compatibility

Legacy password sign-in and recovery stay separated from the new-user primary
path, clearly labeled for existing accounts. Their presence must not imply that
new password registration remains the target.
