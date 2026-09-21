import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { POST as submitEmployerJob } from '../app/api/admin/jobs/route';
import { POST as createSellerListing } from '../app/api/admin/marketplace/route';
import { GET as getMarketplace } from '../app/api/marketplace/route';

const read = (path: string) => readFileSync(path, 'utf8');

describe('Phase 4 production data boundaries', () => {
  it('removes the runtime demo catalog', () => {
    expect(existsSync('lib/demo-data.ts')).toBe(false);
    for (const path of ['app/kerja/page.tsx', 'app/pasar/page.tsx', 'app/komunitas/page.tsx', 'app/organisasi/page.tsx', 'app/organisasi/[id]/page.tsx', 'app/layanan/page.tsx']) {
      expect(read(path)).not.toContain('demo-data');
      expect(read(path)).not.toContain('DEMO DATA');
    }
  });

  it('uses database reads for the discovery APIs', () => {
    for (const path of ['app/api/jobs/route.ts', 'app/api/community/route.ts', 'app/api/organizations/route.ts', 'app/api/sources/route.ts']) {
      expect(read(path)).toMatch(/withPublicTransaction|withUserTransaction/);
      expect(read(path)).not.toContain('demo-data');
    }
  });

  it('opens marketplace discovery through an ACTIVE-only database read', async () => {
    const response = await getMarketplace();

    expect(response.status).toBe(503);
    await expect(response.json()).resolves.toEqual({ error: 'Data marketplace belum tersedia. Pasar Rantau sedang dipersiapkan.' });
    expect(read('app/api/marketplace/route.ts')).toContain('withPublicTransaction');
    expect(read('app/api/marketplace/route.ts')).toContain("eq(products.recordStatus,'ACTIVE')");
  });

  it('ships admin mutation boundaries for all requested content modules', () => {
    for (const path of ['app/api/admin/community/route.ts', 'app/api/admin/organizations/route.ts', 'app/api/sources/[id]/route.ts']) {
      expect(read(path)).toMatch(/authorize(?:Platform)?Api/);
      expect(read(path)).toContain('withUserTransaction');
    }
    const rls = read('db/migrations/0008_phase4_real_content_rls.sql');
    for (const policy of ['jobs_admin_all', 'products_admin_all', 'communities_admin_all', 'organizations_admin_insert', 'official_sources_admin_all']) expect(rls).toContain(policy);
  });

  it('keeps deprecated admin creation closed and opens authenticated owner submission', async () => {
    const [jobResponse, listingResponse] = await Promise.all([
      submitEmployerJob(),
      createSellerListing(),
    ]);

    expect(jobResponse.status).toBe(410);
    expect(listingResponse.status).toBe(410);
    for (const path of ['app/api/jobs/route.ts','app/api/marketplace/route.ts']) {
      expect(read(path)).toContain('authorizeApi');
      expect(read(path)).toContain('withUserTransaction');
      expect(read(path)).toContain("recordStatus:'PENDING'");
    }
  });

  it('hardens organization deletion into archival-only workflow', () => {
    const migration = read('db/migrations/0009_organization_archival_workflow.sql');
    const contentAdmin = read('app/api/admin/organizations/route.ts');
    expect(migration).toContain('BEGIN;');
    expect(migration).toContain('COMMIT;');
    expect(migration).toContain('REVOKE DELETE ON public.organizations FROM duta_app');
    expect(migration).toContain("status='ARCHIVED'");
    expect(migration).not.toContain('CREATE POLICY organizations_admin_delete');
    expect(contentAdmin).toContain("recordStatus: 'ARCHIVED'");
    expect(contentAdmin).toContain('content_admin_archive');
    expect(contentAdmin).not.toContain('tx.delete(organizations)');
  });

  it('keeps provider and database failures fail-closed', () => {
    expect(read('app/api/jobs/route.ts')).toContain("Data lowongan belum tersedia");
    expect(read('app/api/marketplace/route.ts')).toContain("Data marketplace belum tersedia");
    expect(read('app/api/community/route.ts')).toContain("Data komunitas belum tersedia");
    expect(read('app/api/sources/route.ts')).toContain("Data sumber belum tersedia");
    expect(read('lib/services/communication-ai.ts')).toContain('COMMUNICATION_PROVIDER_NOT_CONFIGURED');
  });
});
