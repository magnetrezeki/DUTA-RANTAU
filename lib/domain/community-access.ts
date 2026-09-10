import { isMalaysiaPresenceCurrent, type PresenceStatus } from './presence';

export const communityAccessScopes = ['malaysia_present_only', 'pre_arrival_allowed', 'global'] as const;
export type CommunityAccessScope = typeof communityAccessScopes[number];

export const membershipGeographies = ['malaysia_present_only', 'malaysia_and_indonesia', 'global'] as const;
export type MembershipGeography = typeof membershipGeographies[number];

type PresenceCheck = { countryCode: string; status: PresenceStatus; expiresAt: Date | null };
export type AccessDecision = { allowed: boolean; reason: string };

export function evaluateCommunityJoinAccess(scope: CommunityAccessScope | undefined, presence?: PresenceCheck, communityActive = true): AccessDecision {
  if (!communityActive) return { allowed: false, reason: 'COMMUNITY_INACTIVE' };
  if (scope === undefined) return { allowed: true, reason: 'ALLOWED_LEGACY' };
  if (!communityAccessScopes.includes(scope)) return { allowed: false, reason: 'UNKNOWN_COMMUNITY_ACCESS_SCOPE' };
  if (scope === 'global' || scope === 'pre_arrival_allowed') return { allowed: true, reason: 'ALLOWED' };
  return presence && isMalaysiaPresenceCurrent(presence)
    ? { allowed: true, reason: 'ALLOWED' }
    : { allowed: false, reason: 'MALAYSIA_PRESENCE_REQUIRED' };
}

/**
 * This gate controls whether an application may be submitted. It never infers
 * nationality, residency, immigration status, or work authorization. An ID
 * country code is a self-declared application context for administrator review,
 * not proof of any legal status.
 */
export function evaluateOrganizationApplicationGeography(
  geography: MembershipGeography | undefined,
  presence?: PresenceCheck,
  declaredAccessCountryCode?: string,
): AccessDecision {
  if (geography === undefined) return { allowed: true, reason: 'ALLOWED_LEGACY' };
  if (!membershipGeographies.includes(geography)) return { allowed: false, reason: 'UNKNOWN_MEMBERSHIP_GEOGRAPHY' };
  if (geography === 'global') return { allowed: true, reason: 'ALLOWED' };
  if (geography === 'malaysia_present_only') {
    return presence && isMalaysiaPresenceCurrent(presence)
      ? { allowed: true, reason: 'ALLOWED' }
      : { allowed: false, reason: 'MALAYSIA_PRESENCE_REQUIRED' };
  }
  if (presence && isMalaysiaPresenceCurrent(presence)) return { allowed: true, reason: 'ALLOWED' };
  return declaredAccessCountryCode === 'ID'
    ? { allowed: true, reason: 'ALLOWED_INDONESIA_DECLARATION_REQUIRES_REVIEW' }
    : { allowed: false, reason: 'MALAYSIA_OR_INDONESIA_REQUIRED' };
}
export function retainExistingCommunityMembership() {
  return { retained: true, reason: 'EXISTING_MEMBERSHIP_UNCHANGED' };
}
