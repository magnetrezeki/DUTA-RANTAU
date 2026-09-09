# Day 0.6E-1.9A Staging Behavioral Test Harness

## Artifacts

`005_security_behavioral_tests.sql` is an unapplied, transaction-scoped psql
harness for all twelve staging authorization cases. It uses only placeholder
UUIDs, creates a temporary result table, reports `PASS` or `FAIL` per test, and
rolls back every attempted mutation. It contains no cleanup that can affect
persistent or non-synthetic data.

The harness uses two ordinary synthetic identities. Account A owns Organisation
A. Account B owns Organisation B and is a MEMBER of Organisation A, enabling the
actual member-to-admin, member-to-owner, and peer-role-change denial attempts.

## Actor Model

The controlled staging executor must set `ROLE authenticated` and transaction-
local `request.jwt.claim.sub` and `request.jwt.claims` values from the supplied
placeholder UUIDs. This is database-level policy simulation only. The final
verification also requires requests from the two real ordinary hosted Auth
sessions, without a service role, to prove PostgREST/JWT behavior.

## Effective State Verification

`004_security_verify.sql` now checks the five-table RLS state, exact count and
metadata of eight expected policies, required policy expression fragments,
effective dangerous table grants for `anon` and `authenticated`, ownership by API
roles, membership/audit restrictions, and PUBLIC write grants. It cannot prove
the final hosted outcome until it runs on the confirmed staging project.

## Pre-Apply Gate

`000_preapply_checklist.md` requires the staging name and reference, rejection
of the production reference, synthetic account/data confirmation, target URL
confirmation, and ordinary-user execution. Any failed identity or scope check is
an abort condition.

No hosted service was accessed and no SQL was executed in this phase.
