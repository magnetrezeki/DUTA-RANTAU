# Migration 0048 validation

Purpose: forward structural reconciliation for `public.jobs`.

Production `public.jobs` had 17 columns while the canonical application schema expects 21. The canonical Drizzle projection therefore selected missing columns and `/api/jobs` returned HTTP 503.

The migration adds nullable, no-default `employer_entity_id uuid`, `posting_kind text`, `employer_eligibility_snapshot text`, and `published_at timestamptz`; the canonical `jobs_employer_entity_id_fkey` to `public.entities(id)` with NO ACTION update/delete behavior; and `jobs_employer_entity_idx (employer_entity_id, status)`.

Production evidence recorded zero total jobs and zero ACTIVE jobs. No backfill is performed. The migration changes no functions, triggers, RLS, policies, grants, roles, ACLs, or separately observed security drift.

Disposable validation on PostgreSQL 17.11 passed Tests A–E, including exact prestate, poststate/security preservation, transactional failure, incompatible-column fail-closed behavior, structural-conflict fail-closed behavior, and the canonical projection.

Recovery evidence: the existing Production logical recovery artifact and restore rehearsal were validated before this registration work.
