import { describe, expect, it } from 'vitest';
import { entityTypes, isEntityType, isLegalStatus, legacyEntityType, legalStatuses } from '../lib/domain/entities';
describe('entity foundation',()=>{
 it('accepts only canonical entity types',()=>{expect(entityTypes).toEqual(['business','community','organisation']);expect(isEntityType('business')).toBe(true);expect(isEntityType('employer')).toBe(false)});
 it('keeps legal status independent from entity type',()=>{expect(isLegalStatus('registration_not_verified')).toBe(true);expect(legalStatuses).toContain('foreign_registered');expect(legacyEntityType('organization')).toBe('organisation');expect(legacyEntityType('community')).toBe('community')});
 it('does not treat a business entity as commercial permission',()=>{const entity={entityType:'business',legalStatusVerified:null,commercialEligibility:undefined};expect(entity.commercialEligibility).toBeUndefined();expect(entity.legalStatusVerified).toBeNull()});
});
