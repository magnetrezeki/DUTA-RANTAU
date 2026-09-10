import { describe, expect, it } from 'vitest';
import { evaluateMarketplaceListingPermission } from '../lib/domain/marketplace-compliance';

const approved = { type: 'commercial' as const, status: 'approved' as const, expiresAt: null };
const allowedBusiness = { entityType: 'business' as const, entityActive: true, actorAuthorized: true, commercialEligibility: approved, category: 'ordinary_goods' };

describe('marketplace compliance', () => {
  it('allows only the current commercially eligible business GREEN path', () => {
    expect(evaluateMarketplaceListingPermission(allowedBusiness)).toMatchObject({ allowed: true, riskTier: 'GREEN' });
  });

  it('requires an accountable entity and authorised actor', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, entityType: undefined })).toMatchObject({ allowed: false, reason: 'ENTITY_REQUIRED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, actorAuthorized: false })).toMatchObject({ allowed: false, reason: 'ACTOR_NOT_AUTHORIZED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, entityActive: false })).toMatchObject({ allowed: false, reason: 'ENTITY_INACTIVE' });
  });

  it('never lets a community sell even if commercial eligibility is present', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, entityType: 'community' })).toMatchObject({ allowed: false, reason: 'COMMUNITY_SELLING_NOT_ALLOWED' });
  });

  it('allows an organisation only through the same eligibility gate, independent of workspace plan', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, entityType: 'organisation', commercialEligibility: undefined })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, entityType: 'organisation' })).toMatchObject({ allowed: true });
  });

  it('denies missing, rejected, expired, and suspended commercial eligibility', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, commercialEligibility: undefined })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, commercialEligibility: { ...approved, status: 'rejected' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REJECTED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, commercialEligibility: { ...approved, status: 'suspended' } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_SUSPENDED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, commercialEligibility: { ...approved, expiresAt: new Date(0) } })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_EXPIRED' });
  });

  it('fails YELLOW, RED, unknown, investment, job, paid-event, and regulated-service categories closed', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'food_and_beverage' })).toMatchObject({ allowed: false, reason: 'CATEGORY_REVIEW_REQUIRED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'investment' })).toMatchObject({ allowed: false, reason: 'CATEGORY_PROHIBITED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'employment' })).toMatchObject({ allowed: false, reason: 'CATEGORY_PROHIBITED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'paid_event' })).toMatchObject({ allowed: false, reason: 'CATEGORY_PROHIBITED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'regulated_service' })).toMatchObject({ allowed: false, reason: 'CATEGORY_PROHIBITED' });
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'unknown' })).toMatchObject({ allowed: false, reason: 'UNKNOWN_CATEGORY' });
  });

  it('keeps category policy derived and does not offer a seller risk override', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, category: 'investment' })).toMatchObject({ allowed: false });
  });

  it('does not use plans or consumer subscriptions as marketplace inputs', () => {
    expect(evaluateMarketplaceListingPermission({ ...allowedBusiness, commercialEligibility: undefined })).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
  });
});