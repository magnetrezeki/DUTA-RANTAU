import { evaluateOrganizationApplicationGeography, type MembershipGeography } from './community-access';
import type { PresenceStatus } from './presence';

export const organizationMembershipApplicationStatuses = ['pending', 'approved', 'rejected', 'withdrawn', 'cancelled'] as const;
export type OrganizationMembershipApplicationStatus = typeof organizationMembershipApplicationStatuses[number];
export const organizationMembershipApplicationSources = ['direct_application', 'invite', 'referral', 'event', 'admin_added', 'legacy'] as const;
export type OrganizationMembershipApplicationSource = typeof organizationMembershipApplicationSources[number];
export type OrganizationReviewerRole = 'OWNER' | 'ADMIN' | 'VIEWER' | 'NONE';

type ApplicationGate = {
  entityType: 'organisation' | 'community' | 'business';
  geography: MembershipGeography | undefined;
  hasActiveMembership: boolean;
  hasPendingApplication: boolean;
  legalStatus?: 'registration_not_verified' | 'foreign_registered' | 'registered' | 'unknown';
  presence?: { countryCode: string; status: PresenceStatus; expiresAt: Date | null };
  declaredAccessCountryCode?: string;
  organizationPlan?: 'FREE' | 'PLUS' | 'PRO';
};

export function evaluateOrganizationMembershipApplication(input: ApplicationGate) {
  if (input.entityType !== 'organisation') return { allowed: false, reason: 'ORGANISATION_ONLY' };
  if (input.hasActiveMembership) return { allowed: false, reason: 'ALREADY_MEMBER' };
  if (input.hasPendingApplication) return { allowed: false, reason: 'PENDING_APPLICATION_EXISTS' };
  return evaluateOrganizationApplicationGeography(input.geography, input.presence, input.declaredAccessCountryCode);
}

export function canReadOrganizationMembershipApplication(input: {
  applicantUserId: string;
  actorUserId: string;
  isOrganizationOwnerOrAdmin: boolean;
}) {
  return input.applicantUserId === input.actorUserId || input.isOrganizationOwnerOrAdmin;
}

export function canWithdrawOrganizationMembershipApplication(input: {
  status: OrganizationMembershipApplicationStatus;
  applicantUserId: string;
  actorUserId: string;
}) {
  return input.status === 'pending' && input.applicantUserId === input.actorUserId;
}

export function reviewOrganizationMembershipApplication(input: {
  status: OrganizationMembershipApplicationStatus;
  applicantUserId: string;
  reviewerUserId: string;
  reviewerRole: OrganizationReviewerRole;
  applicationOrganizationId: string;
  reviewerOrganizationId: string;
  decision: 'approved' | 'rejected';
}) {
  if (input.status !== 'pending') return { allowed: false, reason: 'APPLICATION_NOT_PENDING', createsMembership: false };
  if (input.applicationOrganizationId !== input.reviewerOrganizationId) return { allowed: false, reason: 'CROSS_ORGANIZATION_REVIEW_DENIED', createsMembership: false };
  if (input.applicantUserId === input.reviewerUserId) return { allowed: false, reason: 'SELF_REVIEW_DENIED', createsMembership: false };
  if (input.reviewerRole !== 'OWNER' && input.reviewerRole !== 'ADMIN') return { allowed: false, reason: 'REVIEWER_NOT_AUTHORIZED', createsMembership: false };
  return { allowed: true, reason: 'ALLOWED', createsMembership: input.decision === 'approved' };
}