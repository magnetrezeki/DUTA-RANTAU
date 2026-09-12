# Day 0.6D-5 POSIX Local Database Runner

## Scope

This adds a POSIX/CI counterpart to `scripts/run-local-db-tests.ps1` so the
documented isolated local-test procedure can run on Linux and macOS, not only on
Windows. It does not change application code, schema, RLS, migrations, tests, or
any hosted environment.

## Motivation

Six tests are blocked whenever `APP_DATABASE_URL` is unset: five assertions in
`tests/source-integrity.test.ts` and one in `tests/ai-router.test.ts`. They reach
`withPublicTransaction`, which fails closed with
`DatabaseSecurityError: APP_DATABASE_URL is not configured`. This is intended
behaviour, not a defect.

The existing runners do not cover non-Windows hosts:

- `scripts/run-local-db-tests.ps1` requires PowerShell and a `psql` client.
- `scripts/run-disposable-local-db-tests.ps1` additionally requires Docker
  Desktop at a hard-coded Windows path.

## Artifacts

- `scripts/run-local-db-tests.mjs` applies `tests/db/bootstrap-local-test.sql`,
  `tests/db/seed-local-test.sql`, and `tests/db/verify-local-test.sql`, then runs
  the blocked tests. SQL is executed through the `pg` driver the application
  already depends on, so no `psql` binary and no Docker are required. No new
  dependency was added.
- `package.json` gains a `test:db` entry pointing at that script. No existing
  script was changed or removed.

## Guard Parity

| Guard | `run-local-db-tests.ps1` | `run-local-db-tests.mjs` |
| --- | --- | --- |
| Scheme must be `postgres`/`postgresql` | Yes | Yes |
| Host restricted to `localhost`, `127.0.0.1`, `::1` | Yes | Yes |
| `supabase.co`, `supabase`, `production`, `prod` hosts rejected | Yes | Yes |
| Database name `duta_local_test` or `duta_local_test_*` | Yes | Yes |
| Application and bootstrap URLs must name the same database | Yes | Yes |
| Explicit `--execute` required; otherwise dry run | Yes (`-Execute`) | Yes |
| Required `tests/db` files must exist | Yes | Yes |
| Credentials redacted in output | Yes | Yes |
| `APP_DATABASE_URL` process-scoped, restored afterwards | Yes | Yes (child-process env only) |
| `duta_app` password assigned after bootstrap, never logged | Yes | Yes |

Additional guard in the POSIX runner: psql meta-commands are stripped before
execution, and any meta-command other than `\set` aborts the run instead of
being silently dropped.

## Credential Handling

Connection strings may be passed as `--local-url`/`--bootstrap-url` or as
`DUTA_LOCAL_DATABASE_URL`/`DUTA_LOCAL_BOOTSTRAP_DATABASE_URL`. The environment
form is preferred and is what CI should use.

Observed during verification: `npm run test:db -- --local-url postgresql://user:pw@…`
makes npm echo the resolved command line, printing embedded credentials to the
log even though the script's own output redacts them. Passing URLs through the
environment removes them from argv entirely, so nothing reaches the log. The
`duta_app` password itself is always read from the environment
(`DUTA_LOCAL_APP_PASSWORD` by default) and never accepted as an argument.

## Execution Performed

Verified against a disposable loopback-only PostgreSQL 18 instance bound to
`127.0.0.1:55433` with database `duta_local_test`, created and destroyed inside
this phase. The database was supplied by a scratch tool installed outside the
repository and is not a repository dependency.

- Baseline without `APP_DATABASE_URL`: 6 failed, 205 passed (211 tests);
  2 failed files, 34 passed (36). All six failures carried the identical
  `DatabaseSecurityError: APP_DATABASE_URL is not configured` cause.
- `verify-local-test.sql` passed unchanged, confirming the restricted `duta_app`
  role, RLS enablement, the single active-only SELECT policy, SELECT-only
  grants, and the deterministic two-row seed.
- A direct `duta_app` query returned exactly 1 row, confirming active-only RLS
  filtering from outside the application.
- Shipped script, targeted run: 2 files passed, 16 tests passed.
- Shipped script, `--full-suite`: 36 files passed, 211 tests passed.
- Shipped script via `npm run test:db -- --execute --full-suite` with URLs
  supplied through the environment: 36 files passed, 211 tests passed, and a
  scan of the captured output found no non-redacted URL credentials.
- `npm run lint`: 0 problems. `npm run typecheck`: clean.

Every guard was exercised and rejected the intended input: hosted host,
non-loopback host, disallowed database name, mismatched databases, non-Postgres
scheme, and `--execute` without a password. The `duta_local_test_*` variant was
accepted.

## Scope Limits

No `.env` or `.env.local` file was written; `APP_DATABASE_URL` was supplied only
to the test child process. No production database, hosted Supabase instance,
production credential, Vercel environment, or remote migration was accessed or
modified. No application test was edited, skipped, or deleted.

A note on lint: `eslint .` previously reported no findings because the flat
config lints only `.js`/`.mjs`/`.cjs` and the repository contained none. Adding
an `.mjs` file makes that surface live. The runner imports `console`, `process`,
`path`, `fs`, and `URL` from `node:` built-ins so it needs no globals and no
change to `eslint.config.mjs`.

## Remaining Work

Migration chronology repair, credential rotation, and Git-history cleanup remain
separate and were not performed here. The six database tests still require a
local database to run; on a host without one they continue to fail closed.
