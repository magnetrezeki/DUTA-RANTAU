import { evaluateEntityPermission, type EligibilityStatus } from './eligibility';

export type MarketplaceRiskTier = 'GREEN' | 'YELLOW' | 'RED';
export type MarketplaceDecision = { allowed: false; reason: string } | { allowed: true; reason: 'ALLOWED'; riskTier: 'GREEN' | 'YELLOW' };
export type MarketplaceCategoryPolicy = {
  riskTier: MarketplaceRiskTier;
  requiresManualReview: boolean;
  prohibited: boolean;
};

const policies: Record<string, MarketplaceCategoryPolicy> = {
  ordinary_goods: { riskTier: 'GREEN', requiresManualReview: false, prohibited: false },
  food_and_beverage: { riskTier: 'YELLOW', requiresManualReview: true, prohibited: false },
  regulated_service: { riskTier: 'RED', requiresManualReview: false, prohibited: true },
  employment: { riskTier: 'RED', requiresManualReview: false, prohibited: true },
  paid_event: { riskTier: 'RED', requiresManualReview: false, prohibited: true },
  investment: { riskTier: 'RED', requiresManualReview: false, prohibited: true },
};

export function getMarketplaceCategoryPolicy(category: string): MarketplaceCategoryPolicy | undefined {
  return policies[category.trim().toLowerCase()];
}

export function evaluateMarketplaceListingPermission(input: {
  entityType?: 'business' | 'organisation' | 'community';
  entityActive: boolean;
  actorAuthorized: boolean;
  commercialEligibility?: { type: 'commercial'; status: EligibilityStatus; expiresAt: Date | null };
  category: string;
  yellowReviewApproved?: boolean;
}) {
  if (!input.entityType) return { allowed: false, reason: 'ENTITY_REQUIRED' };
  if (input.entityType === 'community') return { allowed: false, reason: 'COMMUNITY_SELLING_NOT_ALLOWED' };
  const permission = evaluateEntityPermission({
    key: 'marketplace.listing.create',
    actorAuthorized: input.actorAuthorized,
    entityActive: input.entityActive,
    eligibility: input.commercialEligibility,
  });
  if (!permission.allowed) return { allowed: false, reason: permission.reason };
  const policy = getMarketplaceCategoryPolicy(input.category);
  if (!policy) return { allowed: false, reason: 'UNKNOWN_CATEGORY' };
  if (policy.prohibited || policy.riskTier === 'RED') return { allowed: false, reason: 'CATEGORY_PROHIBITED' };
  if (policy.riskTier === 'YELLOW' && !input.yellowReviewApproved) return { allowed: false, reason: 'CATEGORY_REVIEW_REQUIRED' };
  return { allowed: true, reason: 'ALLOWED', riskTier: policy.riskTier };
}