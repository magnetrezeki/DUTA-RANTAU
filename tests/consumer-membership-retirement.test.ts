import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { organizationPlans } from '@/lib/domain/organization-plans';

const consumerRuntimeFiles = [
  'app/beranda/page.tsx',
  'app/profil/page.tsx',
  'components/auth-form.tsx',
];

describe('consumer membership retirement', () => {
  it('removes the consumer Member UI and checkout implementation', () => {
    const runtime = consumerRuntimeFiles.map(file => readFileSync(file, 'utf8')).join('\n');
    for (const text of ['DUTA MEMBER', 'RM9.90', '/membership', 'DUTA_MEMBER_MONTHLY']) expect(runtime).not.toContain(text);
    expect(existsSync('app/membership/page.tsx')).toBe(false);
    expect(existsSync('app/api/membership/checkout/route.ts')).toBe(false);
    expect(existsSync('lib/services/payment-provider.ts')).toBe(false);
  });

  it('sends an immediately authenticated user to the free application home', () => {
    expect(readFileSync('components/auth-form.tsx', 'utf8')).toContain("router.push('/beranda')");
    expect(readFileSync('components/auth-form.tsx', 'utf8')).toContain('emailConfirmationRequired');
  });

  it('preserves organisation membership and package concepts', () => {
    expect(existsSync('lib/domain/membership-applications.ts')).toBe(true);
    expect(existsSync('db/migrations/0027_community_membership_growth_foundation.sql')).toBe(true);
    expect(organizationPlans.map(plan => plan.id)).toEqual(['FREE', 'PLUS', 'PRO']);
  });
});
