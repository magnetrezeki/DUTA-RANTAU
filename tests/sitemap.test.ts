import { afterEach, describe, expect, it, vi } from 'vitest';

const mocked = vi.hoisted(() => ({ all: vi.fn() }));
vi.mock('@/lib/services/public-news', () => ({ getAllPublicNews: mocked.all }));
const sitemap = (await import('../app/sitemap')).default;
const originalEnv = process.env.VERCEL_ENV;
afterEach(() => { mocked.all.mockReset(); if (originalEnv === undefined) delete process.env.VERCEL_ENV; else process.env.VERCEL_ENV = originalEnv; });

describe('production sitemap', () => {
  it('is empty outside approved production', async () => {
    process.env.VERCEL_ENV = 'preview';
    expect(await sitemap()).toEqual([]); expect(mocked.all).not.toHaveBeenCalled();
  });
  it('includes every eligible public story beyond the first 100 without invented timestamps', async () => {
    process.env.VERCEL_ENV = 'production';
    mocked.all.mockResolvedValue(Array.from({ length: 101 }, (_, index) => ({ publicSlug: `published-${index}`, updatedAt: '2026-01-01T00:00:00.000Z' })));
    const entries = await sitemap();
    expect(entries).toContainEqual(expect.objectContaining({ url: 'https://www.dutarantau.com/info/published-100' }));
    expect(entries).not.toContainEqual(expect.objectContaining({ lastModified: expect.anything() }));
  });
});
