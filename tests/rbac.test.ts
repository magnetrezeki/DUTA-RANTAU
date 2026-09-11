import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { canUseEntityPermission, canUsePlatformCapability, legacyPlatformRoles } from '../lib/domain/rbac';
import { evaluateEntityPermission } from '../lib/domain/eligibility';

describe('admin and entity RBAC boundaries', () => {
  it('keeps every platform review capability separate', () => {
    expect(canUsePlatformCapability(['compliance_admin'], 'eligibility.review')).toBe(true);
    expect(canUsePlatformCapability(['compliance_admin'], 'verification.review')).toBe(false);
    expect(canUsePlatformCapability(['verification_reviewer'], 'eligibility.review')).toBe(false);
    expect(canUsePlatformCapability(['moderation_admin'], 'eligibility.review')).toBe(false);
    expect(canUsePlatformCapability(['moderation_admin'], 'verification.review')).toBe(false);
  });

  it('does not let a platform role become an entity operator', () => {
    expect(canUseEntityPermission('moderation_admin', 'entity.read')).toBe(false);
    expect(canUseEntityPermission('compliance_admin', 'entity.settings.manage')).toBe(false);
  });

  it('does not turn super administration into an implicit eligibility or verification reviewer', () => {
    expect(canUsePlatformCapability(['super_admin'], 'platform.role.assign')).toBe(true);
    expect(canUsePlatformCapability(['super_admin'], 'eligibility.review')).toBe(false);
    expect(canUsePlatformCapability(['super_admin'], 'verification.review')).toBe(false);
  });

  it('keeps entity roles scoped and least-privilege', () => {
    expect(canUseEntityPermission('OWNER', 'entity.roles.manage')).toBe(true);
    expect(canUseEntityPermission('ADMIN', 'entity.roles.manage')).toBe(true);
    expect(canUseEntityPermission('SECRETARY', 'entity.roles.manage')).toBe(false);
    expect(canUseEntityPermission('TREASURER', 'entity.content.edit')).toBe(false);
    expect(canUseEntityPermission('MEMBER', 'entity.settings.manage')).toBe(false);
    expect(canUseEntityPermission('UNKNOWN', 'entity.read')).toBe(false);
  });

  it('keeps legacy platform flags distinct from entity authority', () => {
    expect(legacyPlatformRoles('MODERATOR')).toEqual(['moderation_admin']);
    expect(legacyPlatformRoles('EDITOR')).toEqual([]);
    expect(canUseEntityPermission(undefined, 'entity.read')).toBe(false);
  });

  it('makes viewers read-only and editors unable to manage roles or finance', () => {
    expect(canUseEntityPermission('MEMBER', 'entity.read')).toBe(true);
    expect(canUseEntityPermission('MEMBER', 'entity.content.edit')).toBe(false);
    expect(canUseEntityPermission('SECRETARY', 'entity.roles.manage')).toBe(false);
    expect(canUseEntityPermission('SECRETARY', 'entity.finance.manage')).toBe(false);
  });

  it('does not treat entity finance as payment connection authority', () => {
    expect(canUseEntityPermission('TREASURER', 'payment.partner.connect')).toBe(false);
    expect(canUseEntityPermission('OWNER', 'payment.partner.connect')).toBe(false);
  });

  it('keeps platform role composition deliberate', () => {
    expect(canUsePlatformCapability(['verification_reviewer', 'moderation_admin'], 'verification.review')).toBe(true);
    expect(canUsePlatformCapability(['verification_reviewer', 'moderation_admin'], 'moderation.manage')).toBe(true);
    expect(canUsePlatformCapability(['verification_reviewer'], 'moderation.manage')).toBe(false);
  });

  it('never lets entity authority, plans, verification, or legal status replace commercial eligibility', () => {
    const missing = evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: true, entityActive: true });
    const rejected = evaluateEntityPermission({ key: 'marketplace.listing.create', actorAuthorized: true, entityActive: true, eligibility: { type: 'commercial', status: 'rejected', expiresAt: null } });
    expect(missing).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REQUIRED' });
    expect(rejected).toMatchObject({ allowed: false, reason: 'ELIGIBILITY_REJECTED' });
  });

  it('records database protections against platform-to-entity takeover and self-promotion', () => {
    const migration = readFileSync('db/migrations/0029_admin_rbac_foundation.sql', 'utf8');
    expect(migration).toContain('members cannot change their own role');
    expect(migration).toContain('only an existing owner can grant privileged organization roles');
    expect(migration).toContain("public.has_platform_role('verification_reviewer')");
    expect(migration).not.toContain("public.has_system_role(ARRAY['MODERATOR','SUPER_ADMIN']");
  });
});
