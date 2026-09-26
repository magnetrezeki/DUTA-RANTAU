import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { assertNewsTransition, fiveWContext, isPubliclyVisibleNews, validateManualOfficialNewsUrl } from '@/lib/domain/official-news';
import { canUseNewsCapability } from '@/lib/domain/rbac';

const migration = readFileSync('db/migrations/0045_official_news_editorial_foundation.sql','utf8');
const routine = { risk:'ROUTINE' as const, reviewState:'DRAFT' as const, publicationState:'DRAFT' as const, correctionState:'CURRENT' as const };
describe('official News editorial foundation', () => {
  it('has an additive transactional migration with RLS and null-safe search', () => { expect(migration).toContain('BEGIN;'); expect(migration.trimEnd()).toMatch(/COMMIT;$/); expect(migration).toContain('ENABLE ROW LEVEL SECURITY'); expect(migration).toContain("coalesce(display_title,'')"); });
  it('validates bounded 5W and rejects malformed states', () => { expect(fiveWContext.safeParse({version:1,who:{state:'SUPPORTED',text:'KBRI'},where:{state:'NOT_STATED'},when:{state:'NOT_MATERIAL'},why:{state:'NOT_STATED'}}).success).toBe(true); expect(fiveWContext.safeParse({version:1,who:{state:'INFERRED'},where:{state:'NOT_STATED'},when:{state:'NOT_MATERIAL'},why:{state:'NOT_STATED'}}).success).toBe(false); });
  it('keeps routine and high-risk paths separate', () => { expect(() => assertNewsTransition(routine,{id:'e',role:'EDITOR'},'VERIFY')).not.toThrow(); expect(() => assertNewsTransition({ ...routine,risk:'HIGH_RISK',reviewState:'READY_FOR_REVIEW' },{id:'e',role:'EDITOR'},'APPROVE')).toThrow('NEWS_TRANSITION_FORBIDDEN'); });
  it('has one public-visibility invariant', () => { expect(isPubliclyVisibleNews({publicationState:'PUBLISHED',correctionState:'CURRENT'})).toBe(true); expect(isPubliclyVisibleNews({publicationState:'PUBLISHED',correctionState:'WITHDRAWN'})).toBe(false); });
  it('rejects unsafe or wrong-source URLs without fetching', () => { expect(validateManualOfficialNewsUrl('https://www.instagram.com/p/a','INSTAGRAM','https://instagram.com/mission')).toContain('instagram.com'); expect(() => validateManualOfficialNewsUrl('http://127.0.0.1/a','INSTAGRAM','https://instagram.com/mission')).toThrow('NEWS_URL_UNSAFE'); expect(() => validateManualOfficialNewsUrl('https://example.com/a','INSTAGRAM','https://instagram.com/mission')).toThrow('NEWS_URL_SOURCE_MISMATCH'); });
  it('does not grant an Editor high-risk approval or source authority', () => { expect(canUseNewsCapability('EDITOR','news.submit_high_risk')).toBe(true); expect(canUseNewsCapability('EDITOR','news.review_high_risk')).toBe(false); expect(migration).toContain("source.source_purpose='NEWS'"); expect(migration).not.toContain('UPDATE public.official_sources'); });
  it('preserves source history instead of globally unique source URL or item id', () => { expect(migration).not.toContain('UNIQUE(official_source_id,canonical_url)'); expect(migration).not.toContain('UNIQUE(official_source_id,external_item_id)'); expect(migration).toContain('intake_idempotency_key'); });
  it('keeps the Drizzle News structure aligned with 0045 while retaining SQL-only security controls', () => {
    const schema = readFileSync('db/schema.ts','utf8');
    for (const object of ['officialNewsRiskReason','officialNewsRetentionClass','officialNewsEventType','officialNewsStories','officialNewsStorySourceReferences','officialNewsEvents','officialNewsCollectionConfig','officialNewsIngestionRuns']) expect(schema).toContain(object);
    for (const column of ['risk_reasons','verified_by','approved_by','published_by','withdrawn_at','superseded_by_story_id','retention_class','intake_idempotency_key','source_published_at']) expect(schema).toContain(column);
    expect(schema).toContain('official_news_source_ref_intake_uq');
    expect(schema).not.toContain('CREATE POLICY');
    expect(schema).not.toContain('SECURITY DEFINER');
  });
});
