import { describe, expect, it } from 'vitest';
import { evaluateCommunityJoinAccess, evaluateOrganizationApplicationGeography, retainExistingCommunityMembership } from '../lib/domain/community-access';

const currentMalaysiaPresence = { countryCode: 'MY', status: 'verified' as const, expiresAt: null };
const expiredMalaysiaPresence = { countryCode: 'MY', status: 'expired' as const, expiresAt: null };

describe('community access', () => {
  it('keeps legacy and overseas scopes available', () => {
    expect(evaluateCommunityJoinAccess(undefined).allowed).toBe(true);
    expect(evaluateCommunityJoinAccess('pre_arrival_allowed').allowed).toBe(true);
    expect(evaluateCommunityJoinAccess('global').allowed).toBe(true);
  });

  it('allows Malaysia-only communities only for current Malaysia presence', () => {
    expect(evaluateCommunityJoinAccess('malaysia_present_only').allowed).toBe(false);
    expect(evaluateCommunityJoinAccess('malaysia_present_only', currentMalaysiaPresence).allowed).toBe(true);
    expect(evaluateCommunityJoinAccess('malaysia_present_only', expiredMalaysiaPresence).allowed).toBe(false);
    expect(evaluateCommunityJoinAccess('malaysia_present_only', { countryCode: 'MY', status: 'revoked', expiresAt: null }).allowed).toBe(false);
  });

  it('denies joining inactive communities and does not evict existing members for missing presence', () => {
    expect(evaluateCommunityJoinAccess('global', undefined, false)).toMatchObject({ allowed: false, reason: 'COMMUNITY_INACTIVE' });
    expect(retainExistingCommunityMembership()).toMatchObject({ retained: true });
  });

  it('does not treat a phone number as presence evidence', () => {
    expect(evaluateCommunityJoinAccess('malaysia_present_only', { countryCode: '+60', status: 'verified', expiresAt: null }).allowed).toBe(false);
  });

  it('fails unknown runtime scopes closed', () => {
    expect(evaluateCommunityJoinAccess('unknown_scope' as never).allowed).toBe(false);
  });
});

describe('organisation membership geography', () => {
  it('allows only current Malaysia presence for Malaysia-only memberships', () => {
    expect(evaluateOrganizationApplicationGeography('malaysia_present_only', currentMalaysiaPresence).allowed).toBe(true);
    expect(evaluateOrganizationApplicationGeography('malaysia_present_only').allowed).toBe(false);
  });

  it('supports Malaysia or explicit Indonesia application context without inferring nationality', () => {
    expect(evaluateOrganizationApplicationGeography('malaysia_and_indonesia', currentMalaysiaPresence).allowed).toBe(true);
    expect(evaluateOrganizationApplicationGeography('malaysia_and_indonesia', undefined, 'ID').allowed).toBe(true);
    expect(evaluateOrganizationApplicationGeography('malaysia_and_indonesia').allowed).toBe(false);
  });

  it('allows global membership and preserves legacy organisations', () => {
    expect(evaluateOrganizationApplicationGeography('global').allowed).toBe(true);
    expect(evaluateOrganizationApplicationGeography(undefined).allowed).toBe(true);
  });

  it('fails unknown membership geography closed', () => {
    expect(evaluateOrganizationApplicationGeography('unknown_geography' as never).allowed).toBe(false);
  });
});