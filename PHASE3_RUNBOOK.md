# Phase 3 LOCAL_STAGING Runbook

## Scope

Run only from `D:\DUTA-RANTAU` against Docker container `duta-rantau-phase1a-postgres` and database `duta_rantau_staging`. Production is forbidden.

## Review before execution

1. Review `PHASE3_SECURITY_REVIEW.md`.
2. Review `phase3_migration_0004_revised.sql` against canonical `db/migrations/0004_phase1a_identity_bridge_rls.sql`.
3. Verify Docker Desktop is healthy.
4. Stop local Next.js processes.
5. Take a local Docker/PostgreSQL backup or snapshot.
6. Confirm migrations 0000–0003 only and RLS/policies are zero.

## Apply

```powershell
cd D:\DUTA-RANTAU
.\phase3_apply_local.ps1
```

The script verifies target/container/database/current role, executes read-only preflight, requires `LOCAL_STAGING_APPLY`, prompts for local passwords without storing them, provisions restricted roles, applies canonical migrations 0004 through 0009, and runs verification. Failure invokes rollback. Migration 0005 adds membership and organization applications; migration 0006 adds local identity-bridge RLS and workflow guards; migration 0007 adds face-verification prerequisites; migration 0008 adds admin content RLS; migration 0009 enforces organization archival-only workflow.

Expected marker:

```text
PHASE3_LOCAL_APPLY_PASS
```

## Configure local-only test environment

Set secrets only in the current PowerShell process or an untracked local file. Never commit URLs/passwords.

Required:

- `APP_DATABASE_URL` using `duta_app` at localhost:5433;
- `SYSTEM_DATABASE_URL` using `duta_system` at localhost:5433;
- `PHASE3_ADMIN_DATABASE_URL` using local `duta_rantau` for fixture/attack administration;
- `ALLOW_RLS_SECURITY_TESTS=true`.

Every URL must target `/duta_rantau_staging` and localhost/127.0.0.1.

## Fixtures and tests

```powershell
npm run phase3:seed
npm run test:rls
npm run phase3:pool-test
npm test
npm run typecheck
npm run build
```

Expected markers:

```text
PHASE3_TEST_FIXTURES_READY
PHASE3_ATTACK_MATRIX_SQL_PASS
PHASE3_POOL_IDENTITY_TEST_PASS
```

`phase3_attack_matrix.sql` covers SQL/RLS attacks. Pool commit/rollback/concurrency is tested by `test-identity-pool-phase1a.ts`, because separate concurrent connections cannot be proven by one SQL script.

## Read-only state verification

```powershell
Get-Content .\phase3_verification.sql -Raw |
docker exec -i duta-rantau-phase1a-postgres psql -v ON_ERROR_STOP=1 -U duta_rantau -d duta_rantau_staging
```

Expected marker: `PHASE3_LOCAL_VERIFICATION_PASS` with 36 RLS-enabled tables, 85 policies, and 10 protection triggers.

## Rollback

```powershell
.\phase3_rollback_local.ps1
```

Expected marker: `PHASE3_LOCAL_ROLLBACK_PASS` with state `0 RLS / 0 policies / 0 bridge helpers / 4 migrations`. Restricted roles remain inert for inspection and can be removed only after a separate dependency/session check.

## Stop conditions

Stop and rollback on wrong database/container, role privilege mismatch, runtime object ownership, migration failure, policy-count mismatch, stale identity, cross-user/cross-org access, privilege escalation, or any remote/production indicator.
