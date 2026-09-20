# 0041 Audit Runtime Write Grant — Validation Record

| Field | Value |
| --- | --- |
| Migration | `0041_audit_runtime_write_grant.sql` |
| Repository lifecycle | `PROPOSED` (not authority-accepted) |
| Validation status | `PENDING_MA03` |
| Data effect | `NONE` |
| Schema effect | `NONE` |
| Security effects | `ROLE_GRANT` |
| Rollback classification | `REVERSIBLE` |
| Applied to staging or Production | **No** |

> This record documents **local preparation validation only**. The migration is
> registered in the governed lifecycle as `PROPOSED`: it carries no checksum,
> no `introducedCommit`, and no validation reference in the manifest, and it has
> not been applied to any shared environment. Authority acceptance is a Founder
> act and has not been taken.

## Purpose

Close the audit-write privilege gap that the historical chain leaves open.

Migrations `0008`, `0009` and `0020` create three `FOR INSERT` policies on
`public.audit_logs`, two of them targeting `duta_app`. Migration `0038`
section E states, verbatim, that

> `duta_app` audit inserts (including `account_deletion` and
> `content_admin_archive`) are already covered by the chain.

They are not. No migration grants `INSERT` on `public.audit_logs` to
`duta_app`; `0038` section F grants it to `duta_system` only. A permissive
policy without the underlying table privilege is inert, because the privilege
check runs before RLS is evaluated. Every `duta_app` audit insert therefore
fails with `permission denied for table audit_logs` (`42501`) and the two
governed policies can never decide.

## Change

```sql
BEGIN;
GRANT INSERT ON public.audit_logs TO duta_app;
COMMIT;
```

This grants only the privilege the existing policies already authorise. No
policy is created, altered, or dropped. No row requirement is relaxed:
`audit_user_insert` still requires `actor_id = current_app_user_id()` with an
allowlisted action, and `audit_logs_content_admin` still requires an admin
actor. RLS remains the deciding layer.

## Validation performed

Environment: disposable PostgreSQL 18.4 loaded with the full governed chain
(37 historical + `0039` + `0040` + `0041`) via the local bootstrap harness.

### Structural

| Assertion | Result |
| --- | --- |
| Full governed bootstrap applies, 39/39 migrations | PASS |
| `duta_app` remains `NOSUPERUSER`, `NOBYPASSRLS`, `NOCREATEDB`, `NOCREATEROLE`, `NOREPLICATION` | PASS |
| `duta_app` owns no table | PASS |
| `duta_app` holds `audit_logs` `INSERT` | PASS |
| No `SELECT`, `UPDATE`, `DELETE`, or `TRUNCATE` on `audit_logs` | PASS |
| No column-level ACL entries on `audit_logs` | PASS |
| Raw table ACL for `duta_app` is exactly `a` (INSERT) | PASS |
| Policy count and RLS-enabled / not-forced state unchanged | PASS |

### Runtime behaviour, with denial layer distinguished

| Scenario | Expected | Result |
| --- | --- | --- |
| Valid actor, allowlisted action | allowed, one row persisted | PASS |
| Missing `app.user_id` | `RLS_DENIAL` | PASS |
| Actor attributable to another user | `RLS_DENIAL` | PASS |
| Action outside the allowlist | `RLS_DENIAL` | PASS |
| Denied writes | changed nothing | PASS |
| Identity does not leak after `COMMIT` / `ROLLBACK` | no leak | PASS |
| `duta_app` reading or destroying audit rows | `GRANT_DENIAL` | PASS |

Before/after on the same instance: with the grant revoked, the audit write is
denied at the **privilege** layer; with the migration applied, the identical
statement is allowed for a valid actor and denied at the **RLS** layer for a
missing or mismatched actor. The migration moves the decision to RLS, which is
what the chain intended.

### Repository gates

| Gate | Result |
| --- | --- |
| `npm run migration:check` | PASS (historical=35, forward=3) |
| `tests/migration-repository-enforcement.test.ts` | 13/13 PASS |
| `tests/migration-manifest.test.ts` | 7/7 PASS |
| Identity-bridge DB proof | 25/25 PASS |

## Assets

- `tests/db/migrations/0041/prestate.sql` — reproduces the defect (`duta_app`
  holds no `INSERT` while the two policies are present and inert).
- `tests/db/migrations/0041/verify.sql` — structural assertions above.
- `tests/db/migrations/0041/security-verify.sql` — negative authorization
  assertions, asserting the denial **layer** and not merely that a denial
  occurred.

All three were executed against the disposable instance; the prestate
reproduces `INSERT = false`, the migration yields `INSERT = true`, and both
verification scripts complete without a failed assertion.

## Blast radius if left unrepaired

Four routes insert audit rows inside `withUserTransaction`, so a
`GRANT_DENIAL` rolls back the entire transaction rather than only the audit
write:

- `app/api/admin/organizations/route.ts`
- `app/api/organizations/[id]/secretary/generate/route.ts`
- `app/api/organizations/[id]/meetings/transcribe/route.ts`
- `app/api/users/me/route.ts`

## Rollback

`REVERSIBLE`: `REVOKE INSERT ON public.audit_logs FROM duta_app;` restores the
prior state exactly, since the migration alters no schema, data, or policy.

## Founder gate

The migration is additive, non-destructive, and currently `PROPOSED`. It has
not been applied to shared staging or Production, and must not be until a
Founder authority decision accepts it.
