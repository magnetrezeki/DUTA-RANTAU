import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { malaysiaMissions } from '../lib/mission-registry';

const read = (path: string) => readFileSync(path, 'utf8');

describe('Founder product capability completion', () => {
  it('keeps six distinct missions and six purpose-specific consular destinations', () => {
    expect(malaysiaMissions).toHaveLength(6);
    expect(new Set(malaysiaMissions.map(m => m.id)).size).toBe(6);
    expect(new Set(malaysiaMissions.map(m => m.serviceUrl)).size).toBe(6);
    expect(malaysiaMissions.filter(m => m.runtimeEnabled)).toHaveLength(3);
    for (const mission of malaysiaMissions) {
      expect(mission.serviceUrl).toMatch(/^https:\/\//);
      expect(mission.newsUrl).not.toBe(mission.serviceUrl);
      expect(mission.lastVerified).toBeTruthy();
    }
  });

  it('uses manual map area selection without device location APIs', () => {
    const map = read('app/sekitar/page.tsx');
    expect(map).toContain("useState('Semua')");
    expect(map).toContain('DUTA tidak meminta lokasi perangkat');
    expect(map).not.toContain('getCurrentPosition');
    expect(map).not.toContain('watchPosition');
  });

  it('exposes account conversion and keeps AUTH_REQUIRED non-retryable', () => {
    const chat = read('components/ai-chat.tsx');
    const profile = read('app/profil/page.tsx');
    for (const source of [chat, profile]) {
      expect(source).toContain('Buat akun gratis');
      expect(source).toContain('/masuk?next=');
    }
    expect(chat).toContain("errorCode!=='AUTH_REQUIRED'");
  });

  it('provides owner edit endpoints for each moderated contribution type', () => {
    for (const route of ['app/api/jobs/[id]/route.ts','app/api/marketplace/[id]/route.ts','app/api/community/[id]/route.ts','app/api/organizations/[id]/route.ts']) {
      const source = read(route);
      expect(source).toContain('export async function PATCH');
      expect(source).toContain('authorizeApi');
      expect(source).toContain('withUserTransaction');
      expect(source).toContain("'PENDING'");
    }
  });

  it('enforces moderation and owner scope in the forward migration', () => {
    const sql = read('db/migrations/0042_product_capability_completion.sql');
    for (const policy of ['jobs_runtime_owner','products_runtime_owner','communities_runtime_owner_update','organizations_runtime_owner_update','notifications_runtime_owner']) expect(sql).toContain(policy);
    expect(sql).toContain("status IN ('DRAFT','PENDING','REJECTED','ARCHIVED')");
    expect(sql).toContain("role<>'OWNER'");
    expect(sql).not.toMatch(/TO\s+anon/i);
  });

  it('keeps Inbox bell separate from the five primary navigation intents', () => {
    const shell = read('components/app-shell.tsx');
    const nav = shell.split('const nav = [')[1]?.split('] as const')[0] ?? '';
    expect((nav.match(/\['\//g) ?? []).length).toBe(5);
    expect(shell).toContain('href="/notifikasi"');
    expect(shell).not.toContain('unreadCount');
  });
});
