# Day 0.6D-3 Minimal Local Database Bootstrap

## Scope

This prepares a future, disposable PostgreSQL path for only the six tests blocked by a missing `APP_DATABASE_URL`: five source-integrity assertions and one AI-router source-date assertion. It does not run a database, execute SQL, set an environment variable, or run tests during Day 0.6D-3.

## Artifacts

- `tests/db/bootstrap-local-test.sql` creates the restricted `duta_app` runtime role and the minimal `public.official_sources` schema.
- `tests/db/seed-local-test.sql` supplies two deterministic synthetic rows: one active P0 `KJRI Penang` fixture checked on `2026-08-16`, and one inactive fixture that demonstrates filtering. The institution label matches the application routing test; the row values and URLs are synthetic.
- `tests/db/verify-local-test.sql` fails on missing schema, unsafe role attributes, non-SELECT grants, absent RLS, incorrect policy count, missing seed rows, or exposure of the inactive row.
- `scripts/run-local-db-tests.ps1` is an unexecuted future-use runner. It requires explicit `-Execute`, permits only loopback PostgreSQL URLs, requires `duta_local_test` or a `duta_local_test_*` name, redacts URL credentials in output, and restores `APP_DATABASE_URL` before exit.

## Minimal Schema and RLS Fidelity

The bootstrap defines only `public.official_sources` and the `trust_level` enum values required by the six tests. It creates no Supabase Auth schema, JWT simulation, custom identity functions, extra runtime roles, extensions, or application migrations.

`duta_app` is a login role without superuser, bypass-RLS, database-creation, role-creation, or replication capability. It receives only schema usage and SELECT on `official_sources`. RLS is enabled with one `duta_app` SELECT policy that exposes active rows. This provides high confidence for the direct restricted-role source queries covered by these six tests; it does not validate broader application RLS or authentication behavior.

## Future Execution Boundary

Use a fresh, disposable, loopback-only PostgreSQL database named `duta_local_test` (or `duta_local_test_*`). A future operator must deliberately provide separate bootstrap and runtime connection URLs for that same database and pass `-Execute`. The runner does not create or start Docker, create a database, write `.env` files, persist Windows environment variables, or contact hosted services.

The runner is ready for a future local Docker PostgreSQL container named `duta-local-test-db`, bound only to a loopback port and using synthetic local credentials. It contains no Docker command, so creating or starting that container remains an explicit later action.

Expected future order:

1. Deliberately create an isolated local database outside this phase.
2. Run the guarded script with safe loopback URLs and `-Execute`; it bootstraps, seeds, verifies, then supplies `APP_DATABASE_URL` only to its own process while running the six tests.
3. Optionally request the full suite with `-RunFullSuite` after the targeted tests pass.

## Validation Performed in This Phase

The implementation was reviewed statically only. No database connection, SQL execution, Docker action, application test, credential operation, migration, or hosted-service action was performed.

Lint, typecheck, and the production build passed with the established process-local npm workaround. Database integration tests were intentionally not run because this phase does not provision a database.

## Remaining Work

The repository's migration chronology still requires repair before any full migration replay can be considered. Credential rotation and any subsequent Git-history cleanup remain separate work; this bootstrap contains no credential material and performs no rotation action.
