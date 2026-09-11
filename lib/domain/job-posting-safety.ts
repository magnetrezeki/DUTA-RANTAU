import { evaluateEntityPermission, type EligibilityStatus } from './eligibility';

export function evaluateJobPostingPermission(input: {
  entityType?: 'business' | 'organisation' | 'community';
  entityActive: boolean;
  actorAuthorized: boolean;
  employerEligibility?: { type: 'employer'; status: EligibilityStatus; expiresAt: Date | null };
  postingKind: 'direct_employer' | 'agency' | 'candidate_placement';
}) {
  if (!input.entityType) return { allowed: false, reason: 'ENTITY_REQUIRED' };
  if (input.entityType === 'community') return { allowed: false, reason: 'EMPLOYER_ENTITY_TYPE_UNSUPPORTED' };
  if (input.postingKind !== 'direct_employer') return { allowed: false, reason: 'CANDIDATE_PLACEMENT_NOT_SUPPORTED' };
  const permission = evaluateEntityPermission({ key: 'job.post.create', actorAuthorized: input.actorAuthorized, entityActive: input.entityActive, eligibility: input.employerEligibility });
  return permission.allowed ? { allowed: true, reason: 'ALLOWED' } : { allowed: false, reason: permission.reason };
}
