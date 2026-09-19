import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync } from 'node:fs';
import { NextResponse } from 'next/server';
import { AppShell } from '@/components/app-shell';
import AdminLayout from '@/app/admin/layout';
import { GET as adminHealth } from '@/app/api/admin/health/route';

// Shell trust residuals (R1/R2) and admin containment (R3).
// These are deliberately deterministic and environment-independent: they render
// the shell directly and exercise the admin gate with a stubbed session, so they
// never need a database, provider, or network.

const nav = vi.hoisted(() => ({ path: '/beranda', redirects: [] as string[] }));
const session = vi.hoisted(() => ({ user: null as null | { id: string; name: string; email: string; role: string } }));

vi.mock('next/navigation', () => ({
  usePathname: () => nav.path,
  redirect: (to: string) => {
    nav.redirects.push(to);
    throw new Error(`NEXT_REDIRECT:${to}`);
  },
}));

vi.mock('@/lib/auth/session', () => ({ getCurrentUser: async () => session.user }));

// The admin API guard is stubbed so the containment wiring can be asserted
// deterministically. The real guard's own same-origin and role behaviour is
// covered by the repository's existing authorization tests.
const guard = vi.hoisted(() => ({ result: null as null | { user: unknown; response: Response | null } }));
vi.mock('@/lib/auth/api-guard', () => ({ authorizePlatformApi: async () => guard.result }));

function shellHtml(path: string) {
  nav.path = path;
  return renderToStaticMarkup(<AppShell><div>Isi</div></AppShell>);
}

describe('shell trust residuals', () => {
  beforeEach(() => {
    nav.redirects = [];
    session.user = null;
  });

  it('R1 does not render a notification control or an unbacked unread indicator', () => {
    const html = shellHtml('/beranda');
    expect(html).not.toContain('Notifikasi');
    // No bare <i> element may survive in the shell: the red unread dot was an
    // unconditional, data-free indicator. (/<i[ >]/ avoids matching <img.)
    expect(html).not.toMatch(/<i[ >]/);
  });

  it('R2 does not render fake personal initials for an unauthenticated visitor', () => {
    const html = shellHtml('/beranda');
    expect(html).not.toMatch(/>AR</);
    expect(html).not.toContain('AKUN PREVIEW');
    // The account affordance remains a real destination, not a fake identity.
    expect(html).toContain('href="/profil"');
  });

  it('R2 does not present a hardcoded location as the user location', () => {
    const html = shellHtml('/beranda');
    expect(html).not.toContain('Kuala Lumpur');
    expect(html).not.toContain('class="location"');
  });

  it('keeps the application shell on existing URLs and exactly five bottom-nav items', () => {
    for (const path of ['/beranda', '/masuk', '/profil', '/tanya']) {
      const html = shellHtml(path);
      expect(html).toContain('class="sidebar"');
      const bottom = html.slice(html.indexOf('class="bottom-nav"'));
      expect((bottom.match(/<a /g) ?? []).length).toBe(5);
    }
  });

  it('renders no application chrome on the public landing route', () => {
    expect(shellHtml('/')).not.toContain('class="topbar"');
  });
});

describe('admin containment', () => {
  beforeEach(() => {
    nav.redirects = [];
    session.user = null;
  });

  it('denies an unauthenticated visitor and sends them to sign-in', async () => {
    await expect(AdminLayout({ children: null })).rejects.toThrow('NEXT_REDIRECT:/masuk');
    expect(nav.redirects).toEqual(['/masuk']);
  });

  it('denies an ordinary Member', async () => {
    session.user = { id: 'u1', name: 'Anggota', email: 'member@example.test', role: 'MEMBER' };
    await expect(AdminLayout({ children: null })).rejects.toThrow('NEXT_REDIRECT:/profil');
    expect(nav.redirects).toEqual(['/profil']);
  });

  it('denies legacy roles that do not hold the admin capability', async () => {
    for (const role of ['USER', 'VERIFIED_MEMBER', 'SELLER', 'ORG_ADMIN', 'ORG_STAFF', 'EDITOR', 'MODERATOR', 'GUEST']) {
      nav.redirects = [];
      session.user = { id: 'u2', name: 'Bukan Admin', email: 'no@example.test', role };
      await expect(AdminLayout({ children: null })).rejects.toThrow('NEXT_REDIRECT:/profil');
      expect(nav.redirects).toEqual(['/profil']);
    }
  });

  it('admits only a role that already holds the platform admin capability', async () => {
    session.user = { id: 'u3', name: 'Admin', email: 'admin@example.test', role: 'SUPER_ADMIN' };
    const out = await AdminLayout({ children: React.createElement('div', null, 'ADMIN_OK') });
    expect(renderToStaticMarkup(out)).toContain('ADMIN_OK');
    expect(nav.redirects).toEqual([]);
  });

  it('pins the containment contract to existing server-side primitives', () => {
    const source = readFileSync('app/admin/layout.tsx', 'utf8');
    // Server-side authorization only, reusing the existing RBAC contract.
    expect(source).toContain('getCurrentUser');
    expect(source).toContain('canUsePlatformCapability');
    expect(source).toContain('legacyPlatformRoles');
    expect(source).toContain('platform.config.manage');
    // No invented privileges or bypasses.
    expect(source).not.toContain('admin=true');
    expect(source).not.toContain('isFounder');
    expect(source.toLowerCase()).not.toContain('@gmail.com');
    expect(source).not.toContain("=== 'SUPER_ADMIN'");
    expect(source).not.toContain('use client');
  });

  it('does not expose deployment configuration posture to an unauthenticated caller', async () => {
    guard.result = {
      user: null,
      response: NextResponse.json({ error: 'Silakan masuk untuk melanjutkan.' }, { status: 401 }),
    };
    const res = await adminHealth({} as never);
    expect(res.status).toBe(401);
    const body = (await res.json()) as Record<string, unknown>;
    // No configuration posture may accompany a denial.
    expect(body).not.toHaveProperty('database');
    expect(body).not.toHaveProperty('auth');
    expect(body).not.toHaveProperty('aiProvider');
  });

  it('exposes only configuration categories once authorized, never the underlying values', async () => {
    guard.result = { user: { id: 'admin' }, response: null };
    const res = await adminHealth({} as never);
    expect(res.status).toBe(200);
    const body = (await res.json()) as Record<string, unknown>;
    expect(body.status).toBe('ok');
    expect(['configured', 'pending-connection-string']).toContain(body.database);
    expect(['supabase-configured', 'not-configured']).toContain(body.auth);
    const serialized = JSON.stringify(body);
    // Categories only — never a connection string, URL, or key.
    expect(serialized).not.toContain('postgres');
    expect(serialized).not.toContain('http');
    expect(serialized).not.toContain('key');
  });

  it('pins admin API containment to the existing platform capability contract', () => {
    const source = readFileSync('app/api/admin/health/route.ts', 'utf8');
    expect(source).toContain('authorizePlatformApi');
    expect(source).toContain('platform.config.manage');
  });

  it('does not reintroduce the removed shell residuals in source', () => {
    const shell = readFileSync('components/app-shell.tsx', 'utf8');
    expect(shell).not.toContain('aria-label="Notifikasi"');
    expect(shell).not.toContain('<i/>');
    expect(shell).not.toContain('Kuala Lumpur');
    expect(shell).not.toContain('>AR<');
    const css = readFileSync('app/globals.css', 'utf8');
    expect(css).not.toContain('.top-actions i{');
  });
});
