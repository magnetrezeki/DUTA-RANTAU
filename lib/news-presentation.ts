import type { PublicNewsSourceReference, PublicNewsStory } from '@/lib/services/public-news';

const contentTypeLabels: Record<string, string> = { ANNOUNCEMENT: 'Pengumuman resmi', CONSULAR: 'Informasi konsuler', PROTECTION: 'Pelindungan WNI', COMMUNITY: 'Kegiatan komunitas', EDUCATION: 'Pendidikan dan budaya', EMPLOYMENT: 'Informasi ketenagakerjaan', BUSINESS: 'Perdagangan dan bisnis', EVENT: 'Kegiatan' };
const platformLabels: Record<string, string> = { INSTAGRAM: 'Instagram', FACEBOOK: 'Facebook', X: 'X', YOUTUBE: 'YouTube', WEBSITE: 'Situs resmi' };
export const dutaSummaryLabel = 'Ringkasan oleh DUTA';
export const presentContentType = (value: string) => contentTypeLabels[value] ?? 'Informasi resmi';
export const presentPlatform = (value: string) => platformLabels[value] ?? 'Kanal resmi';
export const presentDate = (value: string | null) => value ? new Intl.DateTimeFormat('id-ID', { dateStyle: 'long', timeZone: 'UTC' }).format(new Date(value)) : null;
export const originalSourceLabel = (source: Pick<PublicNewsSourceReference, 'institution' | 'channel'>) => `Baca informasi asli — ${source.institution}/${presentPlatform(source.channel)}`;
export const canonicalSource = (story: PublicNewsStory): PublicNewsSourceReference => ({ institution: story.officialSourceInstitution, channel: story.officialSourceChannel, originalUrl: story.originalUrl, sourcePublishedAt: story.originalSourcePublishedAt });
