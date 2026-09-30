import type { MetadataRoute } from 'next';
import { isProductionIndexingEnabled, publicRoutes, siteUrl } from '@/lib/seo';
export default function sitemap(): MetadataRoute.Sitemap { if(!isProductionIndexingEnabled())return [];return publicRoutes.map(path => ({ url:new URL(path,siteUrl).toString(), changeFrequency:path==='/'?'weekly':'monthly', priority:path==='/'?1:0.7 })); }
