# DUTA-RANTAU FINAL PHASE 4 HARDENING CHANGELOG

## Patch identity

- Base commit: `c41f365` — `feat: remove runtime demo data and wire production modules`
- Included commits:
  - `8f2e864` — `docs: add Phase 4 Windows verification runbook`
  - `803b255` — `fix: enforce organization archival workflow`
- Current source commit: `803b255`

## Changes included after `c41f365`

### Organization archival

- Removed the effective `organizations_admin_delete` policy in the new archival migration.
- Revoked `DELETE` on `public.organizations` from `duta_app`.
- Changed the admin organization DELETE API to update `record_status = 'ARCHIVED'`.
- Preserved organization history and all related memberships, documents, events, subscriptions, payments, and audit rows.
- Added `content_admin_archive` audit logging.
- Added `protect_organization_archival` trigger enforcement.

### Organization creation and approval

- New admin organization inserts are restricted to:
  - `status = 'PENDING'`
  - `verification = 'USER_GENERATED'`
  - `application_status = 'PENDING_REVIEW'`
- Direct ACTIVE or DUTA_VERIFIED organization creation is blocked.
- Existing organization approval and SK/member prerequisites remain required.
- Draft organization creation remains possible for authorized administrators.

### Migration safety

- `db/migrations/0008_phase4_real_content_rls.sql` now has an explicit `BEGIN` / `COMMIT` boundary.
- Functional policy behavior in migration 0008 was not intentionally changed by the transaction-boundary edit.
- `db/migrations/0009_organization_archival_workflow.sql` contains the archival and insert-workflow hardening.
- Supabase equivalent is included in `db/supabase-phase4-organization-archival.sql`.

### Security test artifacts

- Extended the local attack matrix for:
  - physical organization DELETE denial;
  - unsafe ACTIVE/DUTA_VERIFIED insert denial;
  - archival update path;
  - permitted PENDING/USER_GENERATED draft path.
- Updated local verification ledger/count expectations.
- Added `PHASE4_RLS_ATTACK_TEST_REPORT.md`.

## Verification evidence

```text
npm run typecheck: PASS
npm test: PASS — 53 tests
npm run lint: PASS — exit code 0; one existing <img> warning
npm run build: PASS
npm run db:generate: PASS — no pending schema changes
```

## Execution boundary

```text
Database migration executed: NO
RLS runtime attack matrix executed: NO
Production database touched: NO
GitHub push: NOT PERFORMED
Vercel deployment: NOT PERFORMED
```

Runtime verification still requires the Windows LOCAL_STAGING environment and the markers:

```text
PHASE3_ATTACK_MATRIX_SQL_PASS
PHASE3_POOL_IDENTITY_TEST_PASS
```
