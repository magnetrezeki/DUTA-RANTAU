# Migration 0050 validation

Purpose: forward reconciliation of the missing eligibility prerequisite and jobs runtime security contract required by the accepted jobs capability design.

Production dependency inspection established that `public.entities`, `public.users`, `public.user_role`, `public.has_system_role(public.user_role[])`, and `auth.uid()` exist, while `public.entity_eligibilities` and the three eligibility enums are absent. Production inspection also established that the jobs safety trigger/function and the accepted `jobs_runtime_*` policies are absent.

The migration creates the minimum eligibility foundation required by job-posting safety: `eligibility_type`, `eligibility_status`, `eligibility_decision_source`, `public.entity_eligibilities`, its status index, RLS, owner-read policy, and `duta_app` SELECT access.

The migration restores `public.enforce_job_posting_safety()` as a SECURITY DEFINER trigger function and installs the jobs safety trigger. ACTIVE publication requires an active business/organisation employer with current approved employer eligibility. The migration also restores `jobs_runtime_owner`, `jobs_runtime_moderator`, and `jobs_runtime_moderator_read`, restricts `jobs_public` to anon/authenticated, and grants SELECT/INSERT/UPDATE on `public.jobs` to `duta_app`.

No existing Production row is backfilled, rewritten, or deleted by this migration.

Disposable validation on PostgreSQL 17 passed. The migration executed transactionally from the expected missing state. Poststate verification proved the eligibility table and enums, safety function and trigger, all three jobs runtime policies, `jobs_public` roles `{anon,authenticated}`, and exactly INSERT/SELECT/UPDATE table privileges for `duta_app` in the validation fixture.

The disposable validation container was removed after verification. Production was not touched during validation.

Recovery remains the previously validated Production logical recovery artifact and restore rehearsal.