# Day 0.7A — Manual Owner Checklist

Use legitimate dashboard access only. Report non-secret metadata to Codex; never paste passwords, JWTs, cookies, refresh tokens, API keys, service-role keys, database connection strings, or screenshots containing them. Do not change anything during this checklist.

## Supabase production

**What to look for:** project ref, project name, API-key types and safe UI identifiers, creation dates, enabled/retired status, Auth account ownership for R1/R2, session-revocation capability, and any server secret consumers.

**What not to change yet:** keys, signing keys, users, passwords, sessions, RLS, schema, grants, and environment variables.

**Report back:** whether the confirmed production ref is the project for R1/R2/R3 (yes/no/unknown); credential type/status/scope; non-secret safe suffix only if the UI exposes one; creation date; and identified dependent deployment names.

## Supabase V2.5 staging

**What to look for:** staging ref, project name, staging-only Auth users, publishable-key metadata, and whether any exposed item is associated with this project.

**What not to change yet:** synthetic users, passwords, sessions, schema, policies, keys, or staging settings.

**Report back:** whether R1/R2/R3 is associated with the staging project (yes/no/unknown), plus non-secret key/status/scope metadata.

**Completed finding:** project `bftdfvihtewjwotrzwwe` was manually inspected. It contains two known synthetic security users and no unexpected or older user. CRED-01/CRED-02 are excluded from this staging project on current evidence. Nothing was modified.

## Supabase production completed finding

Project `uokljxqqvpujwmubildy` was manually inspected. It contains two users, but the historical `login-test` account could not be identified with high confidence; account purpose and status remain unknown. This does not establish a production linkage for CRED-01/CRED-02. Nothing was modified. Do not reset either account or revoke sessions without future high-confidence identity evidence.

## Vercel production

**What to look for:** production project ownership, environment-variable names/scopes, deployment credentials, and which server paths use `SUPABASE_SECRET_KEY`, database URLs, or audit salt.

**What not to change yet:** Production variables, deployments, domains, tokens, integrations, or project membership.

**Report back:** variable names only, scope, project/deployment name, and whether each is set or unset. Do not report values.

## Vercel Preview / duta-v2.5

**What to look for:** Preview project ownership; whether Preview points to the designated V2.5 staging endpoint; and set/unset state of server-only variables.

**What not to change yet:** Preview variables, aliases, deployments, domains, or tokens.

**Report back:** Preview project name, variable names and scopes only, endpoint project-ref classification, and whether a service-role/server secret is set.

## Auth sessions

**What to look for:** R1 account identity/purpose, project/environment, recovery access, active-session listing or global sign-out controls, and evidence that R2 corresponds to that account.

**What not to change yet:** password, email, account metadata, users, or session state.

**Report back:** account purpose (test/user/project/unknown), project ref, environment, recovery path confirmed (yes/no), global-revocation capability (yes/no), and active/revoked/unknown state. Do not report identifiers beyond an approved non-secret label.

## AI providers

**What to look for:** whether an AI/Gemini/NVIDIA account, key, or deployment currently exists for DUTA RANTAU and its environment scope.

**What not to change yet:** provider keys, billing, quotas, models, or integrations.

**Report back:** provider, project/account owner, environment scope, key status, creation date, and current consumer name, if any. NVIDIA remains future-only unless a separately approved implementation establishes it.

## Unknown / legacy credentials

**What to look for:** the issuer of R3, whether its local runtime still exists, whether it has consumers, and whether it was ever reused outside that runtime.

**What not to change yet:** Docker/local runtime configuration, local data, keys, or legacy branches.

**Report back:** issuer/runtime name, active/retired/unknown status, local/hosted scope, consumer count/category, and authoritative retirement or reuse evidence. Never disclose the key.
