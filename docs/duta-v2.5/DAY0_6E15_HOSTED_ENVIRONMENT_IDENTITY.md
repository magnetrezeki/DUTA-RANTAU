# Day 0.6E-1.5 Hosted Environment Identity

## Repository-Visible Identity

The local configuration names `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`; server code additionally references `SUPABASE_SECRET_KEY`. Database code references `APP_DATABASE_URL` and `SYSTEM_DATABASE_URL`. The checked-in example contains placeholders only.

The local configuration hostname is `uokljxqqvpujwmubildy.supabase.co`, with project reference `uokljxqqvpujwmubildy`. This confirms only that repository-visible local configuration points to that project. It does not prove whether the project is production, staging, preview, or an owned test project.

`vercel.json` contains only the Next.js framework declaration. No repository-visible Vercel environment mapping identifies whether Preview or Production uses the same Supabase project. Both mappings are therefore unknown.

## Test Account Requirements

Account A and Account B must be separate, project-owner-controlled, synthetic ordinary authenticated users. Neither may be an administrator, service account, real end user, or associated with a historical exposed credential. No safe repository fixture identifies a candidate account; the safe count is zero.

## Synthetic Data Requirements

| Item | Requirement |
| --- | --- |
| Profiles A and B | New synthetic data required. |
| Organisations A and B | New synthetic data required. |
| Membership rows | New synthetic data required: A belongs only to organisation A; B belongs only to organisation B. |
| Employer/job content | New synthetic data required if the deployed project exposes these tables to the chosen test identities. |
| Public/inactive content and official sources | Existing synthetic data is unknown; create only approved synthetic fixtures if absent. |
| Documents, meetings, transcripts, marketplace resources | Unknown until a non-production project schema is confirmed; create only the minimum synthetic resource for selected read-only tests. |

## Production Safety Decision

Read-only verification against production is only conditionally safe after project-owner confirmation that the two accounts and every target resource are synthetic and isolated. Reversible writes are not safe against production. Security-sensitive writes are not safe against production and require a separate confirmed non-production project.

## Required Abort Guards

Abort before any hosted request if the project reference or hostname differs from the approved identity; the environment is unknown; the target cannot be shown non-production for a write test; account ownership is unknown; an account or resource belongs to a real user; a service role would be required; or any historical password, cookie, refresh token, or local service-role-like key would be needed.

## Next Gate

An owner must classify `uokljxqqvpujwmubildy` as production, staging, or test; confirm Preview and Production mappings; and provide two owned synthetic accounts and isolated synthetic data before hosted read-only RLS verification can begin.
