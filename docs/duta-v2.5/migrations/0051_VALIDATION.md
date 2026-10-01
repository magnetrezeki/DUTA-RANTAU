# Migration 0051 Validation

Migration: `0051_record_status_rejected_reconciliation.sql`

SHA256:

`F8E785E6D46598855D1B47AB50B1F5132CF89874B3EA4678C7806B32B85184DE`

Purpose:

Restore the canonical `REJECTED` value in `public.record_status` that
was introduced by migration 0042 but is absent from the Production
database.

Scope:

- additive enum-value reconciliation only
- no table creation
- no row mutation
- no policy mutation
- no role or grant mutation
- no RLS mutation

Production apply of 0050 previously failed closed because `REJECTED`
was absent. PostgreSQL transaction rollback was independently verified
before 0051 was authored.

After 0051 is applied and verified, immutable migration 0050 may be
retried.