export const entityTypes = ['business','community','organisation'] as const;
export const legalStatuses = ['registered','registered_under_other_law','foreign_registered','registration_pending','registration_not_verified','informal_group','unknown'] as const;
export type EntityType = typeof entityTypes[number];
export type LegalStatus = typeof legalStatuses[number];
export type Entity = { id:string; entityType:EntityType; displayName:string; legalStatus:LegalStatus; legalStatusClaim:LegalStatus|null; legalStatusVerified:LegalStatus|null; ownerUserId:string|null };
export const isEntityType = (value:string): value is EntityType => entityTypes.includes(value as EntityType);
export const isLegalStatus = (value:string): value is LegalStatus => legalStatuses.includes(value as LegalStatus);
export const legacyEntityType = (record:'organization'|'community'): EntityType => record === 'organization' ? 'organisation' : 'community';
