# Staging Security-Test Pre-Apply Checklist

Stop immediately and do not run any SQL if any item fails.

- [ ] Project name is exactly `DUTA-RANTAU-V25-STAGING`.
- [ ] Project reference is exactly `bftdfvihtewjwotrzwwe`.
- [ ] Target URL is the approved staging URL and does not contain the production reference `uokljxqqvpujwmubildy`.
- [ ] Environment is confirmed staging, not production.
- [ ] The staging project contains no production data.
- [ ] Only the five named test tables will be affected, and all five names are absent before `001` runs.
- [ ] Accounts A and B are distinct, owner-controlled synthetic Auth users; B is also the synthetic MEMBER of Organisation A.
- [ ] Placeholder substitutions are kept in an uncommitted ephemeral input and contain no production identifiers.
- [ ] No production credential, historical credential, cookie, refresh token, or service-role key is used.
- [ ] Ordinary Auth sessions, not a service role, will run behavioral RLS checks.
- [ ] The executor understands that `005` is transaction-scoped and must report all twelve PASS outcomes.
- [ ] Any write test beyond the rolled-back harness has separate authorization.

ABORT if project identity, account ownership, synthetic-data status, target URL, or scope cannot be proved.
