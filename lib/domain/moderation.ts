import { canUsePlatformCapability, type PlatformRole } from './rbac';

export const reportableTargetTypes = ['user','entity','community','organisation','business','marketplace_listing','job','event','post','comment'] as const;
export const reportReasonCodes = ['suspected_fraud','misleading_information','impersonation','harassment','spam','prohibited_content','unsafe_commercial_activity','job_concern','event_concern','regulated_service_concern','other'] as const;
export type ModerationStatus = 'NORMAL'|'LIMITED'|'UNDER_REVIEW'|'SUSPENDED'|'BANNED'|'REGULATORY_HOLD'|'CLOSED';
export type ModerationScope = 'CONTENT_ONLY'|'MARKETPLACE'|'EVENTS'|'JOBS'|'COMMUNITY_POSTING'|'ENTITY_ACTIVITY'|'ACCOUNT';

export function canCreateReport(targetType: string, reason: string) { return reportableTargetTypes.includes(targetType as typeof reportableTargetTypes[number]) && reportReasonCodes.includes(reason as typeof reportReasonCodes[number]); }
export function canDecideModeration(roles: PlatformRole[], status: ModerationStatus) { return ['LIMITED','UNDER_REVIEW','SUSPENDED','BANNED','REGULATORY_HOLD','CLOSED'].includes(status) && canUsePlatformCapability(roles, 'moderation.manage'); }
export function canReadPrivateModeration(roles: PlatformRole[]) { return canUsePlatformCapability(roles, 'moderation.manage'); }
export function hasEffectiveRestriction(status: ModerationStatus) { return ['LIMITED','SUSPENDED','BANNED','REGULATORY_HOLD'].includes(status); }
