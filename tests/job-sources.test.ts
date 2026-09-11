import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { isApprovedSiskop2miUrl, isVisibleOfficialMalaysiaJob, normalizeSiskop2miMalaysiaJob } from '../lib/services/job-sources';

const current = { externalJobId: '479376', sourceUrl: 'https://siskop2mi.bp2mi.go.id/lowongan/detail/479376', destinationCountry: 'MALAYSIA', jobTitle: 'Operator', sourceStatus: 'active' as const, expiresAt: null, lastCheckedAt: new Date() };

describe('SISKOP2MI official Malaysia source boundary', () => {
  it('keeps official Malaysia provenance and visible status', () => {
    const job = normalizeSiskop2miMalaysiaJob(current);
    expect(job).toMatchObject({ sourceType: 'OFFICIAL', sourceName: 'SISKOP2MI / KP2MI', destinationCountry: 'MALAYSIA' });
    expect(job && isVisibleOfficialMalaysiaJob(job)).toBe(true);
  });

  it('excludes non-Malaysia, unsafe, and incomplete source records', () => {
    expect(normalizeSiskop2miMalaysiaJob({ ...current, destinationCountry: 'JAPAN' })).toBeUndefined();
    expect(normalizeSiskop2miMalaysiaJob({ ...current, sourceUrl: 'https://example.invalid/lowongan/detail/479376' })).toBeUndefined();
    expect(normalizeSiskop2miMalaysiaJob({ ...current, externalJobId: ' ' })).toBeUndefined();
  });

  it('fails stale, unknown, closed, expired, and forged outbound records closed', () => {
    const job = normalizeSiskop2miMalaysiaJob(current)!;
    expect(isVisibleOfficialMalaysiaJob({ ...job, sourceStatus: 'unknown' })).toBe(false);
    expect(isVisibleOfficialMalaysiaJob({ ...job, sourceStatus: 'closed' })).toBe(false);
    expect(isVisibleOfficialMalaysiaJob({ ...job, lastCheckedAt: new Date(0) })).toBe(false);
    expect(isVisibleOfficialMalaysiaJob({ ...job, expiresAt: new Date(0) })).toBe(false);
    expect(isApprovedSiskop2miUrl('javascript:alert(1)')).toBe(false);
  });

  it('keeps discovery public and application outside DUTA', () => {
    const route = readFileSync('app/api/jobs/official/route.ts', 'utf8');
    expect(route).toContain("application: 'external_official_source'");
    expect(route).toContain("source: 'SISKOP2MI / KP2MI'");
    expect(route).not.toContain('authorizeApi');
    expect(route).not.toContain('candidate');
  });

  it('uses a stable source identifier without changing DUTA eligibility', () => {
    const migration = readFileSync('db/migrations/0032_siskop2mi_official_job_source_foundation.sql', 'utf8');
    expect(migration).toContain('UNIQUE(source_type,external_job_id)');
    expect(migration).toContain("destination_country<>'MALAYSIA'");
    expect(migration).toContain('official source URL is not approved');
    expect(migration).toContain("NEW.source_status:='stale'");
    expect(migration).not.toContain('entity_eligibilities');
    expect(migration).not.toContain('candidate_profiles');
  });
});
