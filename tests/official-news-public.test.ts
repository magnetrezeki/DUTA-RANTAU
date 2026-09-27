import { beforeEach, describe, expect, it, vi } from 'vitest';
import { getTableColumns } from 'drizzle-orm';
import { PgDialect } from 'drizzle-orm/pg-core';
import { officialNewsStories } from '../db/schema';
const { execute, transaction } = vi.hoisted(() => ({ execute: vi.fn(), transaction: vi.fn() }));
vi.mock('@/lib/db/identity-bridge', () => ({ withPublicTransaction: transaction }));
import { getPublicNewsList, getPublicNewsBySlug } from '../lib/services/public-news';
beforeEach(() => {
  execute.mockReset(); transaction.mockReset();
  transaction.mockImplementation(work => work({ execute }));
});
describe('0046 public application boundary', () => {
  it('maps a real nullable text column, not a source-code comment', () => {
    const column = getTableColumns(officialNewsStories).publicSlug;
    expect(column.name).toBe('public_slug'); expect(column.getSQLType()).toBe('text');
    expect(column.notNull).toBe(false);
  });
  it('executes the list through the public transaction and only the projection', async () => {
    const rows = [{ public_slug: 'official-story' }]; execute.mockResolvedValue(rows);
    expect(await getPublicNewsList(7)).toBe(rows);
    const query = new PgDialect().sqlToQuery(execute.mock.calls[0][0]);
    expect(query.sql).toContain('from public.official_news_public_stories');
    expect(query.sql).not.toMatch(/official_news_stories\b|select\s+\*/i);
    expect(query.params).toEqual([7]); expect(transaction).toHaveBeenCalledOnce();
  });
  it('parameterizes singular detail lookup through the same projection', async () => {
    const story = { public_slug: 'official-story' }; execute.mockResolvedValue([story]);
    expect(await getPublicNewsBySlug('official-story')).toBe(story);
    const query = new PgDialect().sqlToQuery(execute.mock.calls[0][0]);
    expect(query.sql).toContain('from public.official_news_public_stories');
    expect(query.sql).not.toMatch(/official_news_stories\b|select\s+\*/i);
    expect(query.params).toEqual(['official-story']);
    execute.mockResolvedValue([]); expect(await getPublicNewsBySlug('unknown')).toBeNull();
    execute.mockResolvedValue([story, story]); await expect(getPublicNewsBySlug('official-story')).rejects.toThrow('cardinality');
  });
  it('rejects invalid input before database access', async () => {
    expect(await getPublicNewsBySlug("bad' OR true--")).toBeNull();
    await expect(getPublicNewsList(101)).rejects.toThrow('limit');
    expect(transaction).not.toHaveBeenCalled();
  });
});
