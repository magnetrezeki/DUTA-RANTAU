import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { evaluateEntityPermission } from '../lib/domain/eligibility';
import { evaluateJobPostingPermission } from '../lib/domain/job-posting-safety';

const approved = { type: 'employer' as const, status: 'approved' as const, expiresAt: null };
const employer = { entityType: 'business' as const, entityActive: true, actorAuthorized: true, employerEligibility: approved, postingKind: 'direct_employer' as const };

describe('job posting safety', () => {
  it('keeps job discovery separate from employer posting permission', () => {
    expect(evaluateJobPostingPermission(employer)).toMatchObject({ allowed: true });
  });

  it('requires an active authorized employer entity', () => {
    expect(evaluateJobPostingPermission({ ...employer, entityType: undefined })).toMatchObject({ allowed: false, reason: 'ENTITY_REQUIRED' });
    expect(evaluateJobPostingPermission({ ...employer, actorAuthorized: false })).toMatchObject({ allowed: false, reason: 'ACTOR_NOT_AUTHORIZED' });
    expect(evaluateJobPostingPermission({ ...employer, entityActive: false })).toMatchObject({ allowed: false, reason: 'ENTITY_INACTIVE' });
    expect(evaluateJobPostingPermission({ ...employer, entityType: 'community' })).toMatchObject({ allowed: false, reason: 'EMPLOYER_ENTITY_TYPE_UNSUPPORTED' });
  });

  it('fails missing, pending, rejected, expired, and suspended employer eligibility closed', () => {
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: undefined })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: { ...approved, status: 'pending' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_PENDING' });
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: { ...approved, status: 'rejected' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REJECTED' });
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: { ...approved, status: 'suspended' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_SUSPENDED' });
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: { ...approved, expiresAt: new Date(0) } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_EXPIRED' });
  });

  it('does not allow candidate placement or agency posting through the direct-employer path', () => {
    expect(evaluateJobPostingPermission({ ...employer, postingKind: 'agency' })).toMatchObject({ allowed: false, reason: 'CANDIDATE_PLACEMENT_NOT_SUPPORTED' });
    expect(evaluateJobPostingPermission({ ...employer, postingKind: 'candidate_placement' })).toMatchObject({ allowed: false, reason: 'CANDIDATE_PLACEMENT_NOT_SUPPORTED' });
  });

  it('keeps commercial, paid-event, payment, plans, verification, and legal status outside employer eligibility', () => {
    expect(evaluateJobPostingPermission({ ...employer, employerEligibility: undefined })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateEntityPermission({ key: 'payment.partner.connect', actorAuthorized: true, entityActive: true, eligibility: approved })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
  });

  it('keeps the database boundary entity-scoped and excludes placement workflows', () => {
    const migration = readFileSync('db/migrations/0031_job_posting_employer_eligibility_foundation.sql', 'utf8');
    expect(migration).toContain('job employer entity is required');
    expect(migration).toContain("ee.eligibility_type='employer'");
    expect(migration).toContain('candidate placement and agency posting are not supported');
    expect(migration).toContain('DROP POLICY IF EXISTS jobs_admin_all');
    expect(migration).not.toContain('candidate_profiles');
  });
});
