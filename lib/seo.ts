export const siteUrl = new URL('https://www.dutarantau.com');

// Vercel sets this independently from NODE_ENV.  A Preview build also runs
// production-optimised code, so NODE_ENV is not an indexing signal.
export const isProductionIndexingEnabled = () => process.env.VERCEL_ENV === 'production';

export const publicRoutes = ['/', '/info', '/layanan', '/jaga-diri'] as const;
export const indexableStaticRoutes = ['/', '/info', '/layanan', '/jaga-diri', '/tentang', '/metodologi-editorial', '/privasi', '/ketentuan'] as const;
export const privateRoutePrefixes = ['/admin', '/auth', '/notifikasi', '/profil', '/tanya', '/beranda', '/komunitas', '/organisasi', '/pasar', '/sekitar', '/belajar', '/kerja', '/bantuan'] as const;

export const isReservedInfoSlug = (slug: string) => slug === 'tempat-wisata';

export const publicRobots = () => isProductionIndexingEnabled()
  ? { index: true, follow: true }
  : { index: false, follow: false };

export const noIndexRobots = () => ({ index: false, follow: false });
export const absoluteUrl = (path: string) => new URL(path, siteUrl).toString();
