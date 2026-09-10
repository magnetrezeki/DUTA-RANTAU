import { describe, expect, it } from 'vitest';
import {
  canReadOrganizationMembershipApplication,
  canWithdrawOrganizationMembershipApplication,
  evaluateOrganizationMembershipApplication,
  reviewOrganizationMembershipApplication,
} from '../lib/domain/membership-applications';

const currentMalaysiaPresence = { countryCode: 'MY', status: 'verified' as const, expiresAt: null };
const validApplication = { entityType: 'organisation' as const, geography: 'global' as const, hasActiveMembership: false, hasPendingApplication: false };
const pendingReview = { status: 'pending' as const, applicantUserId: 'applicant', reviewerUserId: 'admin', reviewerRole: 'ADMIN' as const, applicationOrganizationId: 'org-a', reviewerOrganizationId: 'org-a' };

describe('organisation membership applications', () => {
  it('allows an eligible user to submit without creating a membership', () => {
    expect(evaluateOrganizationMembershipApplication(validApplication)).toMatchObject({ allowed: true });
  });

  it('rejects duplicate pending applications and existing active members', () => {
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, hasPendingApplication: true })).toMatchObject({ allowed: false, reason: 'PENDING_APPLICATION_EXISTS' });
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, hasActiveMembership: true })).toMatchObject({ allowed: false, reason: 'ALREADY_MEMBER' });
  });

  it('accepts only organisation entities', () => {
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, entityType: 'community' })).toMatchObject({ allowed: false, reason: 'ORGANISATION_ONLY' });
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, entityType: 'business' })).toMatchObject({ allowed: false, reason: 'ORGANISATION_ONLY' });
  });

  it('allows unverified and foreign-registered organisations to receive applications', () => {
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, legalStatus: 'registration_not_verified' })).toMatchObject({ allowed: true });
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, legalStatus: 'foreign_registered' })).toMatchObject({ allowed: true });
  });

  it('enforces geography before application submission', () => {
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, geography: 'malaysia_present_only' })).toMatchObject({ allowed: false, reason: 'MALAYSIA_PRESENCE_REQUIRED' });
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, geography: 'malaysia_present_only', presence: currentMalaysiaPresence })).toMatchObject({ allowed: true });
  });

  it('does not let a PRO plan bypass geography or approval', () => {
    expect(evaluateOrganizationMembershipApplication({ ...validApplication, organizationPlan: 'PRO', geography: 'malaysia_present_only' })).toMatchObject({ allowed: false, reason: 'MALAYSIA_PRESENCE_REQUIRED' });
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, reviewerRole: 'VIEWER', decision: 'approved' })).toMatchObject({ allowed: false, reason: 'REVIEWER_NOT_AUTHORIZED' });
  });

  it('keeps applications private and lets only the applicant withdraw while pending', () => {
    expect(canReadOrganizationMembershipApplication({ applicantUserId: 'a', actorUserId: 'a', isOrganizationOwnerOrAdmin: false })).toBe(true);
    expect(canReadOrganizationMembershipApplication({ applicantUserId: 'a', actorUserId: 'b', isOrganizationOwnerOrAdmin: false })).toBe(false);
    expect(canWithdrawOrganizationMembershipApplication({ status: 'pending', applicantUserId: 'a', actorUserId: 'a' })).toBe(true);
    expect(canWithdrawOrganizationMembershipApplication({ status: 'approved', applicantUserId: 'a', actorUserId: 'a' })).toBe(false);
  });

  it('denies self approval, viewer review, random-user review, and cross-organisation review', () => {
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, applicantUserId: 'admin', decision: 'approved' })).toMatchObject({ allowed: false, reason: 'SELF_REVIEW_DENIED' });
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, reviewerRole: 'VIEWER', decision: 'approved' })).toMatchObject({ allowed: false, reason: 'REVIEWER_NOT_AUTHORIZED' });
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, reviewerRole: 'NONE', decision: 'rejected' })).toMatchObject({ allowed: false, reason: 'REVIEWER_NOT_AUTHORIZED' });
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, reviewerOrganizationId: 'org-b', decision: 'approved' })).toMatchObject({ allowed: false, reason: 'CROSS_ORGANIZATION_REVIEW_DENIED' });
  });

  it('lets an authorised organisation admin approve exactly one membership outcome', () => {
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, decision: 'approved' })).toEqual({ allowed: true, reason: 'ALLOWED', createsMembership: true });
  });

  it('does not create membership for rejection, withdrawal, or non-pending records', () => {
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, decision: 'rejected' })).toMatchObject({ allowed: true, createsMembership: false });
    expect(reviewOrganizationMembershipApplication({ ...pendingReview, status: 'withdrawn', decision: 'approved' })).toMatchObject({ allowed: false, createsMembership: false });
  });
});