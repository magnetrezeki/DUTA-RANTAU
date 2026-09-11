import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { evaluateEntityPermission } from '../lib/domain/eligibility';
import { evaluateEventCreatePermission, getEventCategoryPolicy } from '../lib/domain/event-safety';

const approved = { type: 'paid_event' as const, status: 'approved' as const, expiresAt: null };
const organisation = { entityType: 'organisation' as const, entityActive: true, actorAuthorized: true, priceMyr: 0, category: 'community_gathering' };

describe('event safety', () => {
  it('allows an authorised active organisation to create a free low-risk event without paid-event eligibility', () => {
    expect(evaluateEventCreatePermission(organisation)).toMatchObject({ allowed: true, isPaid: false, riskTier: 'LOW' });
  });

  it('allows the current paid-event eligible organisation paid low-risk path', () => {
    expect(evaluateEventCreatePermission({ ...organisation, priceMyr: '25.00', paidEventEligibility: approved })).toMatchObject({ allowed: true, isPaid: true });
  });

  it('allows a community free event but denies every community paid event', () => {
    expect(evaluateEventCreatePermission({ ...organisation, entityType: 'community' })).toMatchObject({ allowed: true });
    expect(evaluateEventCreatePermission({ ...organisation, entityType: 'community', priceMyr: 1, paidEventEligibility: approved })).toMatchObject({ allowed: false, reason: 'COMMUNITY_PAID_EVENT_NOT_ALLOWED' });
  });

  it('requires an accountable active entity and authorised actor', () => {
    expect(evaluateEventCreatePermission({ ...organisation, entityType: undefined })).toMatchObject({ allowed: false, reason: 'ENTITY_REQUIRED' });
    expect(evaluateEventCreatePermission({ ...organisation, actorAuthorized: false })).toMatchObject({ allowed: false, reason: 'ACTOR_NOT_AUTHORIZED' });
    expect(evaluateEventCreatePermission({ ...organisation, entityActive: false })).toMatchObject({ allowed: false, reason: 'ENTITY_INACTIVE' });
    expect(evaluateEventCreatePermission({ ...organisation, entityType: 'business' })).toMatchObject({ allowed: false, reason: 'EVENT_TYPE_UNSUPPORTED' });
  });

  it('fails missing, pending, rejected, expired, and suspended paid-event eligibility closed', () => {
    const paid = { ...organisation, priceMyr: 5 };
    expect(evaluateEventCreatePermission(paid)).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateEventCreatePermission({ ...paid, paidEventEligibility: { ...approved, status: 'pending' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_PENDING' });
    expect(evaluateEventCreatePermission({ ...paid, paidEventEligibility: { ...approved, status: 'rejected' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REJECTED' });
    expect(evaluateEventCreatePermission({ ...paid, paidEventEligibility: { ...approved, status: 'suspended' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_SUSPENDED' });
    expect(evaluateEventCreatePermission({ ...paid, paidEventEligibility: { ...approved, expiresAt: new Date(0) } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_EXPIRED' });
  });

  it('derives paid status from the authoritative price and rejects invalid prices', () => {
    expect(evaluateEventCreatePermission({ ...organisation, priceMyr: 100 })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateEventCreatePermission({ ...organisation, priceMyr: -1 })).toMatchObject({ allowed: false, reason: 'INVALID_EVENT_PRICE' });
    expect(evaluateEventCreatePermission({ ...organisation, priceMyr: 'not-a-price' })).toMatchObject({ allowed: false, reason: 'INVALID_EVENT_PRICE' });
  });

  it('keeps plans, commercial eligibility, verification, legal status, and payment permission outside the paid-event gate', () => {
    expect(evaluateEventCreatePermission({ ...organisation, priceMyr: 10 })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateEntityPermission({ key: 'payment.partner.connect', actorAuthorized: true, entityActive: true, eligibility: approved })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
  });

  it('fails unknown and review-required risks closed without a reviewer decision', () => {
    expect(evaluateEventCreatePermission({ ...organisation, category: 'unknown' })).toMatchObject({ allowed: false, reason: 'UNKNOWN_EVENT_RISK' });
    expect(evaluateEventCreatePermission({ ...organisation, category: 'food_and_beverage' })).toMatchObject({ allowed: false, reason: 'EVENT_REVIEW_REQUIRED' });
  });

  it('denies prohibited investment, recruitment, and regulated-service event leakage', () => {
    for (const category of ['investment', 'recruitment', 'regulated_service']) {
      expect(evaluateEventCreatePermission({ ...organisation, priceMyr: 10, paidEventEligibility: approved, category })).toMatchObject({ allowed: false, reason: 'EVENT_PROHIBITED' });
    }
  });

  it('uses a small policy map rather than trusting a client risk claim', () => {
    expect(getEventCategoryPolicy('community_gathering')).toMatchObject({ riskTier: 'LOW' });
    expect(getEventCategoryPolicy('investment')).toMatchObject({ prohibited: true });
  });

  it('keeps the future database write boundary entity-scoped and price-derived', () => {
    const migration = readFileSync('db/migrations/0030_event_safety_paid_event_foundation.sql', 'utf8');
    expect(migration).toContain('event organizer entity is required');
    expect(migration).toContain("ee.eligibility_type='paid_event'");
    expect(migration).toContain('community paid events are not allowed');
    expect(migration).toContain('DROP POLICY IF EXISTS events_org_manage');
    expect(migration).not.toContain('is_paid');
  });
});
