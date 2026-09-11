import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { canCreateReport, canDecideModeration, canReadPrivateModeration, hasEffectiveRestriction } from '../lib/domain/moderation';
import { getTrustSummary } from '../lib/domain/trust-summary';

describe('moderation and factual trust foundation', () => {
  it('accepts controlled reports as signals without a guilt shortcut', () => { expect(canCreateReport('marketplace_listing','suspected_fraud')).toBe(true); expect(canCreateReport('unknown','suspected_fraud')).toBe(false); expect(canCreateReport('job','unknown')).toBe(false); });
  it('does not make repeated reports an automatic ban', () => { expect(hasEffectiveRestriction('UNDER_REVIEW')).toBe(false); expect(hasEffectiveRestriction('SUSPENDED')).toBe(true); });
  it('allows only moderation_admin to make moderation decisions', () => { expect(canDecideModeration(['moderation_admin'],'SUSPENDED')).toBe(true); expect(canDecideModeration(['compliance_admin'],'SUSPENDED')).toBe(false); expect(canDecideModeration(['verification_reviewer'],'BANNED')).toBe(false); expect(canDecideModeration(['super_admin'],'REGULATORY_HOLD')).toBe(false); });
  it('keeps private reports and evidence away from entity and non-moderation roles', () => { expect(canReadPrivateModeration(['moderation_admin'])).toBe(true); expect(canReadPrivateModeration(['compliance_admin'])).toBe(false); expect(canReadPrivateModeration([])).toBe(false); });
  it('does not treat plan, verification, eligibility, or provenance as a universal trust score', () => { const summary=getTrustSummary({identityVerified:true,entityRegistrationChecked:true,commercialEligibility:'approved',employerEligibility:'other',officialSource:'SISKOP2MI / KP2MI',moderationStatus:'UNDER_REVIEW'}); expect(summary).toMatchObject({identity:'CHECKED',commercialEligibility:'CURRENT',employerEligibility:'NOT_CURRENT',officialSource:'SISKOP2MI / KP2MI',moderation:'UNDER_REVIEW'}); expect(JSON.stringify(summary)).not.toContain('TRUSTED'); });
  it('records private, audited moderation state without eligibility or verification mutation', () => { const migration=readFileSync('db/migrations/0033_moderation_trust_foundation.sql','utf8'); expect(migration).toContain('moderation_actions'); expect(migration).toContain("role='moderation_admin'"); expect(migration).toContain('Reporter identity and evidence remain private'); expect(migration).not.toContain('entity_eligibilities'); expect(migration).not.toContain('entity_verifications'); expect(migration).not.toContain('report_count'); });
  it('keeps sponsored or paid visibility from removing a restriction', () => { expect(hasEffectiveRestriction('LIMITED')).toBe(true); expect(hasEffectiveRestriction('BANNED')).toBe(true); });
});
