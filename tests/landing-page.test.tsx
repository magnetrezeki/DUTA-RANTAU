import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, it, expect, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import Landing from '@/app/page';
import Home from '@/app/beranda/page';
import { AppShell } from '@/components/app-shell';

const routing = vi.hoisted(() => ({ path: '/' }));
vi.mock('next/navigation', () => ({ usePathname: () => routing.path }));
vi.mock('@/components/ai-chat', () => ({ AiChat: () => React.createElement('div', { 'data-live-ai': true }, 'App AI') }));
vi.mock('@/components/home-greeting', () => ({ HomeGreeting: () => React.createElement('h1', null, 'Kawan Rantau') }));

const base = 'c26fa221b508e59bca95efbf371fad667f93a79c';
function baseline(file: string) { return execFileSync('git', ['show', `${base}:${file}`], { encoding: 'utf8' }).replace(/\r\n/g, '\n'); }

describe('public landing and preserved application home', () => {
  it('renders marketing content without app chrome or live AI', () => {
    routing.path = '/';
    const html = renderToStaticMarkup(<AppShell><Landing /></AppShell>);
    expect(html).toContain('Teman menjalani hidup di Malaysia.');
    expect(html).toContain('href="/tanya"');
    expect(html).toContain('href="/beranda"');
    expect(html).not.toContain('class="sidebar"');
    expect(html).not.toContain('class="topbar"');
    expect(html).not.toContain('data-live-ai');
    expect(html).toContain('Jelajahi kebutuhan');
    expect(html).toContain('Independen. Bukan layanan pemerintah.');
    for (const claim of ['E-Undi', 'Citizen Report', 'Trust Score', 'wallet', 'investasi', 'e-learning']) expect(html).not.toContain(claim);
  });
  it('keeps the application home and navigation without a consumer membership offer', () => {
    routing.path = '/beranda';
    const html = renderToStaticMarkup(<AppShell><Home /></AppShell>);
    expect(html).toContain('class="sidebar"');
    expect(html).toContain('href="/beranda"');
    expect(html).toContain('data-live-ai');
    for (const text of ['Penting Hari Ini', 'Untuk Anda', 'Sekitar Anda', 'Penemuan tanpa lokasi presisi atau aktivitas rekaan.']) expect(html).toContain(text);
    for (const text of ['DUTA MEMBER', 'RM9.90', '/membership']) expect(html).not.toContain(text);
  });
  it('retains the application shell on existing URLs', () => {
    for (const path of ['/masuk', '/daftar', '/tanya', '/profil']) {
      routing.path = path;
      expect(renderToStaticMarkup(<AppShell><div>Existing route</div></AppShell>)).toContain('class="sidebar"');
    }
  });
  it('preserves Q4 Auth and AI security files exactly', () => {
    const protectedFiles = ['app/api/auth/password-recovery/route.ts', 'app/auth/lupa-password/page.tsx', 'app/auth/reset-password/route.ts', 'app/auth/reset-password/form/page.tsx', 'app/auth/reset-password/form/reset-password-form.tsx', 'lib/auth/password-recovery.ts', 'tests/password-recovery.test.ts', 'app/masuk/page.tsx', 'app/api/ai/chat/route.ts', 'lib/services/ai-quota-policy.ts', 'db/migrations/0034_ai_fair_use_foundation.sql', 'db/migrations/0035_ai_telemetry_foundation.sql', 'db/migrations/0036_ai_telemetry_correlation.sql'];
      expect(execFileSync('git', ['diff', '--exit-code', base, '--', ...protectedFiles], { encoding: 'utf8' }).trim()).toBe('');
  }, 30000);
});
