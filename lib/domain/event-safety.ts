import { evaluateEntityPermission, type EligibilityStatus } from './eligibility';

export type EventRiskTier = 'LOW' | 'REVIEW' | 'PROHIBITED';
export type EventCategoryPolicy = { riskTier: EventRiskTier; requiresManualReview: boolean; prohibited: boolean };

const categoryPolicies: Record<string, EventCategoryPolicy> = {
  community_gathering: { riskTier: 'LOW', requiresManualReview: false, prohibited: false },
  education_session: { riskTier: 'LOW', requiresManualReview: false, prohibited: false },
  networking: { riskTier: 'LOW', requiresManualReview: false, prohibited: false },
  cultural_event: { riskTier: 'LOW', requiresManualReview: false, prohibited: false },
  internal_meeting: { riskTier: 'LOW', requiresManualReview: false, prohibited: false },
  food_and_beverage: { riskTier: 'REVIEW', requiresManualReview: true, prohibited: false },
  large_gathering: { riskTier: 'REVIEW', requiresManualReview: true, prohibited: false },
  investment: { riskTier: 'PROHIBITED', requiresManualReview: false, prohibited: true },
  recruitment: { riskTier: 'PROHIBITED', requiresManualReview: false, prohibited: true },
  regulated_service: { riskTier: 'PROHIBITED', requiresManualReview: false, prohibited: true },
};

export function getEventCategoryPolicy(category: string): EventCategoryPolicy | undefined {
  return categoryPolicies[category.trim().toLowerCase()];
}

function paidFromPrice(priceMyr: number | string | null | undefined): boolean | undefined {
  if (priceMyr === null || priceMyr === undefined || priceMyr === '') return false;
  const value = typeof priceMyr === 'number' ? priceMyr : Number(priceMyr);
  if (!Number.isFinite(value) || value < 0) return undefined;
  return value > 0;
}

export function evaluateEventCreatePermission(input: {
  entityType?: 'business' | 'organisation' | 'community';
  entityActive: boolean;
  actorAuthorized: boolean;
  priceMyr: number | string | null | undefined;
  category: string;
  paidEventEligibility?: { type: 'paid_event'; status: EligibilityStatus; expiresAt: Date | null };
  manualReviewApproved?: boolean;
}) {
  if (!input.entityType) return { allowed: false, reason: 'ENTITY_REQUIRED' };
  if (!input.actorAuthorized) return { allowed: false, reason: 'ACTOR_NOT_AUTHORIZED' };
  if (!input.entityActive) return { allowed: false, reason: 'ENTITY_INACTIVE' };
  if (input.entityType === 'business') return { allowed: false, reason: 'EVENT_TYPE_UNSUPPORTED' };
  const isPaid = paidFromPrice(input.priceMyr);
  if (isPaid === undefined) return { allowed: false, reason: 'INVALID_EVENT_PRICE' };
  const policy = getEventCategoryPolicy(input.category);
  if (!policy) return { allowed: false, reason: 'UNKNOWN_EVENT_RISK' };
  if (policy.prohibited) return { allowed: false, reason: 'EVENT_PROHIBITED' };
  if (policy.requiresManualReview && !input.manualReviewApproved) return { allowed: false, reason: 'EVENT_REVIEW_REQUIRED' };
  if (!isPaid) return { allowed: true, reason: 'ALLOWED', isPaid, riskTier: policy.riskTier };
  if (input.entityType === 'community') return { allowed: false, reason: 'COMMUNITY_PAID_EVENT_NOT_ALLOWED' };
  const permission = evaluateEntityPermission({ key: 'paid_event.create', actorAuthorized: input.actorAuthorized, entityActive: input.entityActive, eligibility: input.paidEventEligibility });
  if (!permission.allowed) return { allowed: false, reason: permission.reason };
  return { allowed: true, reason: 'ALLOWED', isPaid, riskTier: policy.riskTier };
}
