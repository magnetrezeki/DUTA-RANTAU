import type { MetadataRoute } from 'next';
import { getAllPublicNews } from '@/lib/services/public-news';
import { absoluteUrl, indexableStaticRoutes, isProductionIndexingEnabled } from '@/lib/seo';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  if (!isProductionIndexingEnabled()) return [];
  const staticEntries = indexableStaticRoutes.map(path => ({ url: absoluteUrl(path), changeFrequency: path === '/' ? 'weekly' as const : 'monthly' as const, priority: path === '/' ? 1 : 0.7 }));
  // Public news is optional during build. A temporary database/auth-query
  // outage must not prevent the core sitemap from being generated.
  const stories = await getAllPublicNews().catch(() => []);
  return [...staticEntries, ...stories.map(story => ({ url: absoluteUrl(`/info/${story.publicSlug}`), changeFrequency: 'monthly' as const, priority: 0.6 }))];
}
