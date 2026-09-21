import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, it, expect, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import Landing from '@/app/page';
import Home from '@/app/beranda/page';
import { AppShell } from '@/components/app-shell';

const routing = vi.hoisted(() => ({ path: '/' }));
vi.mock('next/navigation', () => ({ usePathname: () => routing.path, useRouter: () => ({ push: vi.fn() }) }));

const base = 'c26fa221b508e59bca95efbf371fad667f93a79c';
function baseline(file: string) { return execFileSync('git', ['show', `${base}:${file}`], { encoding: 'utf8' }).replace(/\r\n/g, '\n'); }

// Reviewed Q4 Auth/AI security baselines. MUTATION_DETECTION_ONLY.
//
// These files were originally frozen against the single historical commit
// c26fa221b508e59bca95efbf371fad667f93a79c. The reviewed identity-bridge
// remediation (9fc80aeada82946fa5c8094e1ceca1d80ee5ab12) intentionally changed
// app/api/ai/chat/route.ts so the server-verified actor is supplied to
// telemetry, so that file carries its own reviewed baseline while the other
// twelve keep the baseline they were reviewed with. Every entry stays protected:
// any unreviewed edit to any listed file changes its hash and fails the control.
const q4SecurityBaselines: Record<string, string> = {
  'app/api/auth/password-recovery/route.ts': '2ae6400cae2bce64934c4bfbf4bd9b7bbf362bfbce72be51e353f9b90561ef9c',
  'app/auth/lupa-password/page.tsx': 'bf1cb845f616a4e267c0cadbe5f694abf6b273a6e6ab8b8b1d5e9500fe362b48',
  'app/auth/reset-password/route.ts': '51123d8dc989cd02b0eb928e9acac288c27d7f35bc14aab6f78a13b12a9f9d6b',
  'app/auth/reset-password/form/page.tsx': 'cedc4fa8c3870933b90aed3b02fdc4b68ca01668a4c05a1177b4b4d1b07a1626',
  'app/auth/reset-password/form/reset-password-form.tsx': '62d4693aaa5e59bdef761ceaa7bc2c04387eab0d8231fb4e0c1c980a97cea038',
  'lib/auth/password-recovery.ts': 'fffc8975864931ccdcd11207e3f3def3c7df37c16d620298611c863004d182f3',
  'tests/password-recovery.test.ts': '9fbb709748fbc9f4a44bf907258cac0e9de3635a59102886bb92c968a9bdea7f',
  'app/masuk/page.tsx': '4bcc4e623ceb0bb87bbcdab935b2dbb9bd290a430f97499a9286f2a2808b0e42',
  // Founder F04 authorizes voice transcripts to use the same guarded AI
  // boundary. The reviewed route still enforces auth, input limits, quota,
  // provider routing, source rules, and privacy-safe telemetry.
  'app/api/ai/chat/route.ts': '0cfd8d8ab7fd5541f682638f7b6de4cfc5d7e57433d5d434851efec0bd6c2bf8',
  'lib/services/ai-quota-policy.ts': 'e497aef109a2565b5091ca433c85fa9a8f011d7508400a22fda2f134e0ce646d',
  'db/migrations/0034_ai_fair_use_foundation.sql': '50e045e6b5f1bd42f9b93d9280e2408833e4ffc90db7f844ea0841331d44cddc',
  'db/migrations/0035_ai_telemetry_foundation.sql': 'ed765e37b4354eaef84d33fb64882a73bbd1fcf250b9009b0c7a3e2def693df3',
  'db/migrations/0036_ai_telemetry_correlation.sql': '332fd38674eb872ac11c318756c6378b9502c0d339b15c8b8aabe215c49be3a3',
};

function reviewedContentHash(file: string) {
  return createHash('sha256').update(readFileSync(file, 'utf8').replace(/\r\n/g, '\n')).digest('hex');
}

describe('public landing and preserved application home', () => {
  it('renders marketing content without app chrome or live AI', () => {
    routing.path = '/';
    const html = renderToStaticMarkup(<AppShell><Landing /></AppShell>);
    expect(html).toContain('Teman menjalani');
    expect(html).toContain('Malaysia.');
    expect(html).toContain('href="/tanya"');
    expect(html).toContain('href="/beranda"');
    expect(html).not.toContain('class="vp-app"');
    expect(html).toContain('/visual-r21f/hero.webp');
    expect(html).toContain('Jelajahi kebutuhan');
    expect(html).toContain('Independen. Bukan layanan pemerintah.');
    for (const claim of ['E-Undi', 'Citizen Report', 'Trust Score', 'wallet', 'investasi', 'e-learning']) expect(html).not.toContain(claim);
  });
  it('keeps the application home and navigation without a consumer membership offer', () => {
    routing.path = '/beranda';
    const html = renderToStaticMarkup(<AppShell><Home /></AppShell>);
    expect(html).toContain('class="vp-app"');
    expect(html).toContain('href="/beranda"');
    expect(html).toContain('/visual-r21f/hari-commute.webp');
    expect(html).not.toContain('class="ai-box');
    for (const text of ['Penting Hari Ini', 'Untuk semua', 'Sekitar Anda', 'Update Resmi']) expect(html).toContain(text);
    for (const text of ['DUTA MEMBER', 'RM9.90', '/membership']) expect(html).not.toContain(text);
  });
  it('retains the application shell on existing URLs', () => {
    for (const path of ['/masuk', '/daftar', '/tanya', '/profil']) {
      routing.path = path;
      const html = renderToStaticMarkup(<AppShell><div>Existing route</div></AppShell>);
      expect(html).toContain('class="vp-app"');
      expect((html.match(/<nav class="vp-navigation"/g) ?? []).length).toBe(1);
      expect((html.match(/<a[^>]*href="\/(?:beranda|tanya|layanan|komunitas|profil)"/g) ?? []).length).toBeGreaterThanOrEqual(5);
      expect(html).toContain('class="vp-safety"');
    }
  });
  it('preserves Q4 Auth and AI security files exactly', () => {
    const drifted = Object.entries(q4SecurityBaselines)
      .filter(([file, expected]) => reviewedContentHash(file) !== expected)
      .map(([file]) => file);

    expect(drifted).toEqual([]);
  }, 30000);
});
