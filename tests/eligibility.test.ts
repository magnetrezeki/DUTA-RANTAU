import { describe, expect, it } from 'vitest';
import { eligibilityTypes, evaluateEntityPermission } from '../lib/domain/eligibility';

describe('eligibility engine', () => {
  it('fails high-risk actions closed', () => {
    expect(evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: true, entityActive: true }).allowed).toBe(false);
    expect(evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: true, entityActive: true, eligibility: { type: 'commercial', status: 'pending', expiresAt: null } }).allowed).toBe(false);
  });
  it('requires an authorized actor and approved current eligibility', () => {
    expect(evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: false, entityActive: true, eligibility: { type: 'commercial', status: 'approved', expiresAt: null } }).allowed).toBe(false);
    expect(evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: true, entityActive: true, eligibility: { type: 'commercial', status: 'approved', expiresAt: null } }).allowed).toBe(true);
    expect(eligibilityTypes).toContain('employer');
  });
  it('keeps the organization workspace low risk', () => {
    expect(evaluateEntityPermission({ key: 'organisation.workspace.access', actorAuthorized: true, entityActive: true }).allowed).toBe(true);
  });
});
