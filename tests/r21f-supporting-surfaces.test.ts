import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
const read=(file:string)=>readFileSync(file,'utf8');
const navSource=()=>read('components/app-shell.tsx').split('const nav = [')[1]?.split('] as const')[0]??'';

describe('R2.1-F supporting surfaces',()=>{
  it('keeps Belajar bounded to real discovery routes and no invented catalogue',()=>{const page=read('app/belajar/page.tsx');for(const href of ['/info','/kerja','/jaga-diri','/profil'])expect(page).toContain(href);expect(page).toContain('Katalog pembelajaran belum diterbitkan.');expect(page).toContain('kemajuan, sertifikat, atau status official yang direka');expect(page).not.toContain('setProgress(')});
  it('keeps Inbox honest while owner-scoped retrieval has no runtime policy',()=>{const inbox=read('app/notifikasi/page.tsx');const rls=read('db/migrations/0038_core_runtime_rls_enforcement.sql');expect(inbox).toContain('bacaan owner-scoped belum diotorisasi oleh RLS');expect(inbox).toContain('jumlah belum dibaca rekaan');expect(inbox).not.toContain('unreadCount');expect(rls).toContain('notifications,');expect(rls).not.toContain('notifications_owner_select')});
  it('retains exactly five primary intents and a separate protection action',()=>{const shell=read('components/app-shell.tsx');const nav=navSource();expect((nav.match(/\['\//g)??[]).length).toBe(5);for(const intent of ['Hari Ini','Tanya DUTA','Keperluan','Rantau','Saya'])expect(nav).toContain(intent);expect(nav).not.toContain('Jaga Diri');expect(shell).toContain('className="vp-safety"');expect(shell).toContain('href="/jaga-diri"')});
});
