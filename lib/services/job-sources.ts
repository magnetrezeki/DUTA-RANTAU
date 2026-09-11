export type JobSourceAdapter = 'SISKOP2MI_OFFICIAL' | 'DIRECT_EMPLOYER' | 'LICENSED_APS';
export type ExternalJobSourceStatus = 'active' | 'stale' | 'unknown' | 'closed';

export type ExternalJobListing = {
  externalJobId: string;
  sourceType: 'OFFICIAL' | 'DIRECT_EMPLOYER' | 'LICENSED_APS';
  sourceName: string;
  sourceUrl: string;
  destinationCountry: string;
  jobTitle: string;
  sourceStatus: ExternalJobSourceStatus;
  expiresAt: Date | null;
  lastCheckedAt: Date | null;
};

const siskopHost = 'siskop2mi.bp2mi.go.id';

export function isApprovedSiskop2miUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && url.hostname === siskopHost && (/^\/lowongan\/detail\/\d+$/.test(url.pathname) || url.pathname === '/lowongan/list');
  } catch {
    return false;
  }
}

export function normalizeSiskop2miMalaysiaJob(input: Omit<ExternalJobListing, 'sourceType' | 'sourceName'>): ExternalJobListing | undefined {
  if (input.destinationCountry.trim().toUpperCase() !== 'MALAYSIA' || !isApprovedSiskop2miUrl(input.sourceUrl) || !input.externalJobId.trim() || !input.jobTitle.trim()) return undefined;
  return { ...input, externalJobId: input.externalJobId.trim(), jobTitle: input.jobTitle.trim(), destinationCountry: 'MALAYSIA', sourceType: 'OFFICIAL', sourceName: 'SISKOP2MI / KP2MI' };
}

export function isVisibleOfficialMalaysiaJob(job: ExternalJobListing, now = new Date()): boolean {
  if (job.sourceType !== 'OFFICIAL' || job.sourceName !== 'SISKOP2MI / KP2MI' || job.destinationCountry !== 'MALAYSIA') return false;
  if (job.sourceStatus !== 'active' || !isApprovedSiskop2miUrl(job.sourceUrl) || !job.lastCheckedAt) return false;
  if (job.expiresAt && job.expiresAt <= now) return false;
  return now.getTime() - job.lastCheckedAt.getTime() <= 7 * 24 * 60 * 60 * 1000;
}
