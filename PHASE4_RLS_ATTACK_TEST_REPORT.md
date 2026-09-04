# PHASE4 RLS ATTACK TEST REPORT

## Scope

This report covers the Phase 4 organization archival/workflow hardening:

- organization rows cannot be physically deleted by `duta_app`;
- admin archival uses `record_status = 'ARCHIVED'`;
- historical child rows remain untouched;
- admin-created organization drafts cannot be `ACTIVE` or `DUTA_VERIFIED`;
- organization approval remains a separate workflow.

## Files under test

```text
db/migrations/0008_phase4_real_content_rls.sql
db/migrations/0009_organization_archival_workflow.sql
db/supabase-phase4-content.sql
db/supabase-phase4-organization-archival.sql
scripts/security/phase3_attack_matrix.sql
```

## Static controls

| Test | Expected result | Source control |
|---|---|---|
| `organizations_admin_delete` policy exists after migrations | FAIL / absent | 0009 drops it and creates no replacement |
| `DELETE FROM organizations` as admin runtime role | DENIED | `REVOKE DELETE ON public.organizations FROM duta_app` plus no DELETE policy |
| Admin archive update | ALLOWED | `organizations_update` permits `status='ARCHIVED'` |
| Admin insert with `status='ACTIVE'` | DENIED | admin insert policy requires `status='PENDING'` |
| Admin insert with `verification='DUTA_VERIFIED'` | DENIED | admin insert policy requires `USER_GENERATED` |
| Admin insert draft | ALLOWED | status `PENDING`, application `PENDING_REVIEW`, verification `USER_GENERATED` |
| Admin sets pending organization to active without approval | DENIED | update policy and `protect_organization_archival` trigger |
| Admin sets organization verified without approval | DENIED | `protect_organization_archival` trigger |
| Anonymous access to admin organization policies | DENIED | policies target `duta_app` locally / `authenticated` in Supabase |
| Historical child rows on archive | PRESERVED | archive is an UPDATE; no DELETE/CASCADE is executed |
| Archival audit event | REQUIRED | `content_admin_archive` action in `audit_user_insert` allowlist |

## Runtime SQL matrix additions

`scripts/security/phase3_attack_matrix.sql` now includes:

- physical organization DELETE denial;
- direct ACTIVE + DUTA_VERIFIED admin insert denial;
- admin archive update attempt;
- admin PENDING / USER_GENERATED draft insert attempt rolled back.

## Execution status

```text
STATIC_REVIEW: PASS
LOCAL_POSTGRESQL_EXECUTION: NOT RUN BY ARENA
PHASE3_ATTACK_MATRIX_SQL_PASS: PENDING WINDOWS LOCAL_STAGING
PHASE3_POOL_IDENTITY_TEST_PASS: PENDING WINDOWS LOCAL_STAGING
PRODUCTION_EXECUTION: FORBIDDEN / NOT RUN
```

## Required Windows verification

Run only against the local Docker database using the existing guarded apply script:

```powershell
.\phase3_apply_local.ps1
npm run phase3:seed
npm run test:rls
npm run phase3:pool-test
```

Required security markers:

```text
PHASE3_ATTACK_MATRIX_SQL_PASS
PHASE3_POOL_IDENTITY_TEST_PASS
```

This report does not certify production safety until those local runtime markers are returned and reviewed.
