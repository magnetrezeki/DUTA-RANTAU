import type { MetadataRoute } from 'next';
import { isProductionIndexingEnabled, siteUrl } from '@/lib/seo';

export default function robots(): MetadataRoute.Robots {
  if (!isProductionIndexingEnabled()) return { rules: { userAgent: '*', disallow: '/' } };
  return { rules: [{ userAgent: '*', allow: '/', disallow: ['/admin/','/api/','/auth/','/masuk','/daftar','/notifikasi','/profil','/tanya','/beranda','/komunitas/','/organisasi/','/pasar','/sekitar','/belajar','/info/tempat-wisata','/kerja','/bantuan'] }], sitemap: new URL('/sitemap.xml', siteUrl).toString(), host: siteUrl.toString() };
}
