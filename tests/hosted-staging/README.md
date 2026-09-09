# Hosted Staging Security Tests

These files are for the isolated staging security-test project only. They are not migrations and must never be applied to production. Apply them only after separately confirming the approved staging project, two controlled synthetic Auth accounts, and placeholder replacement. Use ordinary authenticated users for policy tests; service-role access does not test RLS.

Order: schema, policies, seed template, structural verification, read-only tests, then separately authorized write tests. Stop if any project identity, account ownership, or synthetic-data guard fails.

## Completed real-auth workflow

The SQL Editor simulation in 005 is not security sign-off. The real-auth
runner is authoritative for API authorization behavior. Do not rerun 003
blindly. The real-auth runner can create one exact append-only audit residue:
run 013 to inspect it, run 010 only when that exact residue is confirmed, and
run 011 to prove baseline restoration. Do not rerun the authenticated harness
unnecessarily because T12_ALLOWED creates that residue.

## Focused security review

The previous static PASS was too strong. The original files left inherited/default
grants and unrelated permissive policies intact, allowed actor A to attach audit
entries to B's resources, and did not constrain writable identity/linkage columns.
The patches reject table/policy collisions, enable RLS atomically with creation,
reset API grants, allow only named update columns, and bind audit inserts to an
owned job in the actor's organisation. No SQL has been executed to validate this.

This is a standalone policy model, not proof of the application's deployed RLS:
the source document describes application users but implements profiles here.
Equal profile/Auth UUIDs are an explicit acceptable fixture assumption only.
The structural verifier is not a behavioral test runner and cannot establish all
12 outcomes. Review effective column grants, inherited roles, policy expressions,
and seeded relationships before testing; a catalog count alone is insufficient.

## Preserve the twelve cases

T01/T02: A reads own/B profile. T03: A changes and restores private_note.
T04/T05: A reads own/B organisation. T06: A reads B membership. T07: A reads own job.
These retain six read-only cases and one reversible write case.
T08: A cannot update B profile. T09: B cannot promote itself to ADMIN or OWNER in
Organisation A (two distinct escalation attempts). T10: B cannot change A's owner
membership role (third escalation attempt) or Organisation A.
T11: A cannot update B's job. T12: A cannot spoof B's audit actor (fourth escalation attempt),
attach an own-actor audit to B's job/organisation, or delete B's job.
T08–T12 remain five security-sensitive cases with explicit subchecks.

Account A owns Organisation A. Account B owns Organisation B and is also a MEMBER
of Organisation A. B supplies the required MEMBER-to-ADMIN and MEMBER-to-OWNER
denial checks without changing a pre-existing owner fixture. Do not treat a
successful zero-row mutation as proof unless the target row was verified first.
Use actual ordinary authenticated sessions, never an administrator for behavioral
checks. Verify A and B differ and every target exists using the controlled fixture
manifest. A zero-row mutation can represent RLS denial; a foreign-key error,
invalid UUID, missing resource or transport failure is not an authorization pass.
Audit's allowed positive control is an own-job synthetic.job_note insert without
RETURNING; authenticated audit SELECT is intentionally denied.

## Apply gate

No apply is approved by this review. Confirm the separately approved staging
project and empty target names before execution; these scripts cannot determine
the hosted project identity themselves. Use psql (the files contain psql commands).
Keep seed substitutions in an uncommitted ephemeral input, validate two distinct
owned synthetic Auth accounts, and never edit committed templates with real IDs.
Do not run against application tables. A future phase must resolve behavioral
test fidelity and complete static verification of exact grants/policy definitions
before claiming readiness. Writes need separate explicit approval.

## Future execution order

1. Verify the staging project identity and target URL.
2. Complete [000_preapply_checklist.md](000_preapply_checklist.md).
3. Apply `001_security_schema.sql`.
4. Apply `002_security_policies.sql`.
5. Create the two owned synthetic Auth accounts outside these SQL files.
6. Populate the placeholder values in an uncommitted ephemeral input; Account B is also the MEMBER fixture for Organisation A.
7. Apply `003_security_seed_template.sql`.
8. Run `004_security_verify.sql`.
9. Require `004` to pass before continuing.
10. Execute `005_security_behavioral_tests.sql` in its transaction-scoped staging harness.
11. Require all twelve reported outcomes to pass.
12. Independently inspect the four escalation subchecks using ordinary Account A/B sessions through the hosted API.
13. Authorize any next phase only after those checks pass.

Do not execute this sequence during preparation. The controlled SQL executor uses
`SET LOCAL ROLE authenticated` plus transaction-local JWT claim settings solely
to exercise RLS. It must not be a service role used to represent an ordinary
application user. The direct hosted API session checks in step 12 are required
because claim simulation does not prove gateway authentication behavior.
