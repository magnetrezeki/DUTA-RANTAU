import { beforeEach, describe, expect, it, vi } from 'vitest';
import { getTableColumns } from 'drizzle-orm';
import { PgDialect } from 'drizzle-orm/pg-core';
import { officialNewsStories } from '../db/schema';
const { execute, transaction } = vi.hoisted(() => ({ execute: vi.fn(), transaction: vi.fn() }));
vi.mock('@/lib/db/identity-bridge', () => ({ withPublicTransaction: transaction }));
import { getPublicNewsBySlug, getPublicNewsPage, normalizePublicNewsStory } from '../lib/services/public-news';

const sourceReference = { institution: 'KBRI Kuala Lumpur', channel: 'INSTAGRAM', original_url: 'https://instagram.com/p/official', source_published_at: '2026-09-29T00:00:00.000Z' };
function row(overrides: Record<string, unknown> = {}) { return { public_slug: 'official-story', display_title: 'Maklumat rasmi', concise_summary: 'Ringkasan yang jelas.', content_type: 'ANNOUNCEMENT', published_at: '2026-09-30T00:00:00.000Z', updated_at: '2026-09-30T00:00:00.000Z', source_published_at: '2026-09-29T00:00:00.000Z', canonical_url: 'https://instagram.com/p/official', original_url: 'https://instagram.com/p/official', original_source_published_at: '2026-09-29T00:00:00.000Z', official_source_institution: 'KBRI Kuala Lumpur', official_source_channel: 'INSTAGRAM', source_references: [sourceReference], ...overrides }; }

beforeEach(() => { execute.mockReset(); transaction.mockReset(); transaction.mockImplementation(work => work({ execute })); });
describe('0046 public application boundary', () => {
  it('maps a real nullable text column, not a source-code comment', () => { const column = getTableColumns(officialNewsStories).publicSlug; expect(column.name).toBe('public_slug'); expect(column.getSQLType()).toBe('text'); expect(column.notNull).toBe(false); });
  it('executes the list through only the projection and normalizes its page DTO', async () => { execute.mockResolvedValue([row()]); const result = await getPublicNewsPage(1, 7); expect(result.stories[0].publicSlug).toBe('official-story'); expect(result.stories[0]).not.toHaveProperty('id'); const query = new PgDialect().sqlToQuery(execute.mock.calls[0][0]); expect(query.sql).toContain('from public.official_news_public_stories'); expect(query.sql).not.toMatch(/official_news_stories\b|select\s+\*|\bid\b/i); expect(query.params).toEqual([8, 0]); });
  it('parameterizes singular detail lookup through the same projection', async () => { execute.mockResolvedValue([row()]); expect((await getPublicNewsBySlug('official-story'))?.publicSlug).toBe('official-story'); const query = new PgDialect().sqlToQuery(execute.mock.calls[0][0]); expect(query.sql).toContain('from public.official_news_public_stories'); expect(query.params).toEqual(['official-story']); });
  it('paginates deterministically and normalizes runtime dates and JSON', async () => { execute.mockResolvedValue([row({ public_slug: 'a', published_at: new Date('2026-09-30T00:00:00.000Z'), source_references: JSON.stringify([sourceReference]) }), row({ public_slug: 'b' }), row({ public_slug: 'c' })]); const result = await getPublicNewsPage(2, 2); expect(result).toMatchObject({ page: 2, pageSize: 2, hasMore: true }); expect(result.stories[0].publishedAt).toBe('2026-09-30T00:00:00.000Z'); const query = new PgDialect().sqlToQuery(execute.mock.calls[0][0]); expect(query.sql).toContain('order by published_at desc, public_slug asc'); expect(query.params).toEqual([3, 2]); });
  it('rejects invalid input before database access', async () => { expect(await getPublicNewsBySlug("bad' OR true--")).toBeNull(); await expect(getPublicNewsPage(1, 51)).rejects.toThrow('size'); expect(transaction).not.toHaveBeenCalled(); });
  it('does not normalize editorial fields into a public story', () => { const story = normalizePublicNewsStory(row({ review_state: 'DRAFT', created_by: 'private' })); expect(story).not.toHaveProperty('review_state'); expect(story).not.toHaveProperty('created_by'); });
});
