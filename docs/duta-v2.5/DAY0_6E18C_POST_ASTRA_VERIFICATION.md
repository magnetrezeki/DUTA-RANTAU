# Day 0.6E-1.8C Post-Astra Static Patch Verification

## Result

The Astra patches were reviewed as static SQL only. They now fail closed if any
target table or policy already exists, enable RLS before the schema transaction
commits, remove `PUBLIC`, `anon`, and `authenticated` table grants, and restore
only narrow authenticated privileges. Ownership, organisation linkage, role, and
profile identity columns are not grant-writable by ordinary users.

The audit policy is append-only: it permits an authenticated actor to insert only
a `synthetic.job_note` for a job they own in an organisation where they are a
member. It does not permit audit SELECT, UPDATE, or DELETE. This closes actor
spoofing and cross-organisation audit references within the test model.

## Fixture Fidelity

The seed template now contains Account A, Account B, and synthetic Member C.
Member C belongs to Organisation A with the `MEMBER` role. The adversarial tests
must use C for MEMBER-to-ADMIN, MEMBER-to-OWNER, and another-member role-change
denials. A and B remain separate organisation owners for cross-user and
cross-organisation tests.

## Remaining Limit

No SQL was applied and no hosted behavior was tested. Static artifact review
cannot prove Supabase effective grants, JWT claims, policy execution, PostgREST
behavior, or actual denial responses. Before applying, a final pre-apply review
must inspect exact staged SQL, project identity, account ownership, substitutions,
and the behavioral test runner. Write tests remain separately authorization-gated.
