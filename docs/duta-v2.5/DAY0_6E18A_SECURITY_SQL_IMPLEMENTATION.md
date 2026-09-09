# Day 0.6E-1.8A Staging Security SQL Artifacts

Five unapplied staging-only artifacts implement the reviewed minimal security-test model: five tables and eight RLS policies. The model uses `auth.uid()` and assumes, without claiming a production fact, that synthetic profile IDs equal controlled `auth.users.id` UUIDs.

The policy set allows only own-profile access, member-visible organisations/jobs, owner-limited updates, and actor-bound audit insertion. It deliberately has no ordinary membership write policy and no authenticated delete policy. The seed is a psql placeholder template only; it contains no real UUIDs, identities, emails, passwords, tokens, keys, cookies, or production identifiers.

Static review must confirm no broad write predicate, service-role dependency, `BYPASSRLS`, or `SUPERUSER` grant before any future staging application. No hosted SQL was executed in this phase.
