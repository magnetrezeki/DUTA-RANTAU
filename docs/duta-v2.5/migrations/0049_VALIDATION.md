# 0049 Entities Structural Reconciliation Validation

## Purpose

Restore only the missing canonical `public.entities` structural prerequisite required for the Production jobs structural reconciliation.

This migration does not perform data backfill and does not modify RLS, policies, grants, roles, ACLs, functions, triggers, or existing rows.

## Production evidence

Production read-only inspection established:

- `public.users` exists.
- `public.record_status` exists.
- `public.entities` is absent.
- `public.entity_type` is absent.
- `public.legal_status` is absent.
- `public.jobs` is present but lacks the canonical `employer_entity_id` field required by migration 0048.
- Production jobs contain zero rows.

The previous Production execution of 0048 failed closed because `public.entities` was absent. No 0048 structural changes committed.

## Canonical structure

Migration 0049 restores only:

- `public.entity_type`
- `public.legal_status`
- `public.entities`
- `entities_slug_uq`
- `entities_type_idx`
- `entities_owner_idx`
- `entities_legal_status_idx`

The canonical `public.entities` relation contains 16 columns.

No organization, community, seller, responsible-person, verification, eligibility, backfill, or security state is restored by 0049.

## Disposable validation

Validated against PostgreSQL 17 using an isolated Docker container.

Result:

- migration transaction: PASS
- entity_type creation: PASS
- legal_status creation: PASS
- public.entities creation: PASS
- canonical column count: 16
- primary-key index: PASS
- unique slug index: PASS
- entity type index: PASS
- owner index: PASS
- legal-status index: PASS
- validation process exit code: 0
- Production touched: NO

## Scope boundary

0049 is a narrow forward structural reconciliation.

It MUST NOT be interpreted as restoration of the complete historical 0023-0026 entity subsystem.

Migration 0048 remains a separate governed reconciliation and may execute only after 0049 Production post-state is verified.
