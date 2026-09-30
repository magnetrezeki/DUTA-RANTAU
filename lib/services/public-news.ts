import 'server-only';
import { cache } from 'react';
import { sql } from 'drizzle-orm';
import { withPublicTransaction } from '@/lib/db/identity-bridge';
import { isReservedInfoSlug } from '@/lib/seo';

export type PublicNewsSourceReference = { institution: string; channel: string; originalUrl: string; sourcePublishedAt: string | null };
export type PublicNewsStory = {
  publicSlug: string; displayTitle: string; conciseSummary: string; contentType: string;
  publishedAt: string; updatedAt: string; sourcePublishedAt: string | null; canonicalUrl: string;
  originalUrl: string; originalSourcePublishedAt: string | null; officialSourceInstitution: string;
  officialSourceChannel: string; sourceReferences: PublicNewsSourceReference[];
};
export type PublicNewsPage = { stories: PublicNewsStory[]; page: number; pageSize: number; hasMore: boolean };
type PublicNewsRow = Record<string, unknown>;

const fields = sql`public_slug, display_title, concise_summary, content_type, published_at,
 updated_at, source_published_at, canonical_url, original_url, original_source_published_at,
 official_source_institution, official_source_channel, source_references`;
const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const maxPageSize = 50;
const asText = (value: unknown, field: string) => { if (typeof value !== 'string' || !value.trim()) throw new Error(`Invalid public News ${field}`); return value.trim(); };
const asDate = (value: unknown, field: string, nullable = false): string | null => { if (value == null) { if (nullable) return null; throw new Error(`Invalid public News ${field}`); } const date = value instanceof Date ? value : new Date(typeof value === 'string' ? value : Number.NaN); if (Number.isNaN(date.getTime())) throw new Error(`Invalid public News ${field}`); return date.toISOString(); };
const asHttpsUrl = (value: unknown, field: string) => { const candidate = asText(value, field); let parsed: URL; try { parsed = new URL(candidate); } catch { throw new Error(`Invalid public News ${field}`); } if (parsed.protocol !== 'https:' || parsed.username || parsed.password) throw new Error(`Invalid public News ${field}`); return parsed.toString(); };

function normalizeReferences(value: unknown): PublicNewsSourceReference[] {
  const parsed = typeof value === 'string' ? JSON.parse(value) : value;
  if (!Array.isArray(parsed) || parsed.length === 0) throw new Error('Invalid public News source references');
  return parsed.map(reference => { if (!reference || typeof reference !== 'object') throw new Error('Invalid public News source reference'); const row = reference as Record<string, unknown>; return { institution: asText(row.institution, 'source institution'), channel: asText(row.channel, 'source channel'), originalUrl: asHttpsUrl(row.original_url, 'source URL'), sourcePublishedAt: asDate(row.source_published_at, 'source publication date', true) }; });
}

export function normalizePublicNewsStory(row: PublicNewsRow): PublicNewsStory {
  const publicSlug = asText(row.public_slug, 'slug');
  if (!slugPattern.test(publicSlug) || isReservedInfoSlug(publicSlug)) throw new Error('Invalid public News slug');
  return { publicSlug, displayTitle: asText(row.display_title, 'title'), conciseSummary: asText(row.concise_summary, 'summary'), contentType: asText(row.content_type, 'content type'), publishedAt: asDate(row.published_at, 'publication date')!, updatedAt: asDate(row.updated_at, 'update date')!, sourcePublishedAt: asDate(row.source_published_at, 'source publication date', true), canonicalUrl: asHttpsUrl(row.canonical_url, 'canonical URL'), originalUrl: asHttpsUrl(row.original_url, 'original URL'), originalSourcePublishedAt: asDate(row.original_source_published_at, 'original source publication date', true), officialSourceInstitution: asText(row.official_source_institution, 'institution'), officialSourceChannel: asText(row.official_source_channel, 'channel'), sourceReferences: normalizeReferences(row.source_references) };
}

export async function getPublicNewsPage(page = 1, pageSize = 20): Promise<PublicNewsPage> {
  if (!Number.isInteger(page) || page < 1) throw new RangeError('Invalid News page');
  if (!Number.isInteger(pageSize) || pageSize < 1 || pageSize > maxPageSize) throw new RangeError('Invalid News page size');
  const offset = (page - 1) * pageSize;
  if (!Number.isSafeInteger(offset)) throw new RangeError('Invalid News page');
  const rows = await withPublicTransaction(tx => tx.execute(sql`select ${fields} from public.official_news_public_stories order by published_at desc, public_slug asc limit ${pageSize + 1} offset ${offset}`)) as PublicNewsRow[];
  return { stories: (rows.slice(0, pageSize) as PublicNewsRow[]).map(normalizePublicNewsStory), page, pageSize, hasMore: rows.length > pageSize };
}

export async function getPublicNewsList(limit = 20): Promise<PublicNewsStory[]> { return (await getPublicNewsPage(1, limit)).stories; }
export async function getAllPublicNews(): Promise<PublicNewsStory[]> {
  const stories: PublicNewsStory[] = [];
  for (let page = 1; ; page += 1) {
    const result = await getPublicNewsPage(page, maxPageSize);
    stories.push(...result.stories);
    if (!result.hasMore) return stories;
  }
}
export const getPublicNewsBySlug = cache(async (slug: string): Promise<PublicNewsStory | null> => { if (!slugPattern.test(slug) || isReservedInfoSlug(slug)) return null; const rows = await withPublicTransaction(tx => tx.execute(sql`select ${fields} from public.official_news_public_stories where public_slug=${slug}`)) as PublicNewsRow[]; if (rows.length > 1) throw new Error('Public News cardinality violation'); return rows[0] ? normalizePublicNewsStory(rows[0]) : null; });
