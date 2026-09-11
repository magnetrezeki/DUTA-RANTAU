import type { UserRole } from '@/types';

export const platformRoles = ['super_admin', 'compliance_admin', 'verification_reviewer', 'moderation_admin'] as const;
export type PlatformRole = typeof platformRoles[number];
export type PlatformCapability = 'platform.config.manage' | 'platform.role.assign' | 'audit.read' | 'eligibility.review' | 'verification.review' | 'moderation.manage';

export const entityRoles = ['OWNER', 'ADMIN', 'SECRETARY', 'TREASURER', 'STAFF', 'MEMBER'] as const;
export type EntityRole = typeof entityRoles[number];

const platformPermissions: Record<PlatformRole, readonly PlatformCapability[]> = {
  super_admin: ['platform.config.manage', 'platform.role.assign', 'audit.read'],
  compliance_admin: ['eligibility.review'],
  verification_reviewer: ['verification.review'],
  moderation_admin: ['moderation.manage'],
};

const entityPermissions: Record<EntityRole, readonly string[]> = {
  OWNER: ['entity.read', 'entity.settings.manage', 'entity.roles.manage', 'entity.content.edit', 'entity.finance.manage', 'entity.moderation.manage'],
  ADMIN: ['entity.read', 'entity.settings.manage', 'entity.roles.manage', 'entity.content.edit', 'entity.moderation.manage'],
  SECRETARY: ['entity.read', 'entity.content.edit'],
  TREASURER: ['entity.read', 'entity.finance.manage'],
  STAFF: ['entity.read', 'entity.content.edit'],
  MEMBER: ['entity.read'],
};

export function canUsePlatformCapability(roles: readonly PlatformRole[], capability: PlatformCapability): boolean {
  return roles.some((role) => platformPermissions[role]?.includes(capability));
}

export function canUseEntityPermission(role: string | undefined, permission: string): boolean {
  return !!role && (entityPermissions as Record<string, readonly string[]>)[role]?.includes(permission) === true;
}

// Legacy global roles remain a compatibility input only. They never become an
// entity role and do not grant compliance or verification review authority.
export function legacyPlatformRoles(role: UserRole): PlatformRole[] {
  if (role === 'SUPER_ADMIN') return ['super_admin'];
  if (role === 'MODERATOR') return ['moderation_admin'];
  return [];
}
