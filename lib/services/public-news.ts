import 'server-only';
import { sql } from 'drizzle-orm';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

export type PublicNewsStory = {
  id: string; public_slug: string; display_title: string; concise_summary: string;
  content_type: string; published_at: string; updated_at: string;
  source_published_at: string | null; canonical_url: string; original_url: string;
  original_source_published_at: string | null; official_source_institution: string;
  official_source_channel: string;
  source_references: { institution: string; channel: string; original_url: string; source_published_at: string | null }[];
};
const fields = sql`id, public_slug, display_title, concise_summary, content_type, published_at,
 updated_at, source_published_at, canonical_url, original_url, original_source_published_at,
 official_source_institution, official_source_channel, source_references`;

export async function getPublicNewsList(limit = 20): Promise<PublicNewsStory[]> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw new RangeError('Invalid News limit');
  return withPublicTransaction(async tx => tx.execute(sql`
    select ${fields} from public.official_news_public_stories
    order by published_at desc, id limit ${limit}`));
}

export async function getPublicNewsBySlug(slug: string): Promise<PublicNewsStory | null> {
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) return null;
  return withPublicTransaction(async tx => {
    const rows = await tx.execute(sql`select ${fields} from public.official_news_public_stories where public_slug=${slug}`);
    if (rows.length > 1) throw new Error('Public News cardinality violation');
    return rows[0] ?? null;
  });
}
