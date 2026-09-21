import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
const read=(file:string)=>readFileSync(file,'utf8');
const navSource=()=>read('components/app-shell.tsx').split('const nav = [')[1]?.split('] as const')[0]??'';

describe('R2.1-F supporting surfaces',()=>{
  it('keeps Belajar bounded to real discovery routes and no invented catalogue',()=>{const page=read('app/belajar/page.tsx');for(const href of ['/info','/kerja','/jaga-diri','/profil'])expect(page).toContain(href);expect(page).toContain('Katalog pembelajaran belum diterbitkan.');expect(page).toContain('kemajuan, sertifikat, atau status official yang direka');expect(page).not.toContain('setProgress(')});
  it('keeps Inbox honest with recipient-scoped retrieval and no fabricated unread count',()=>{const inbox=read('app/notifikasi/page.tsx');const rls=read('db/migrations/0042_product_capability_completion.sql');expect(inbox).toContain('withUserTransaction');expect(inbox).toContain('eq(notifications.userId,session.id)');expect(inbox).toContain('DUTA tidak membuat konten atau unread state');expect(inbox).not.toContain('unreadCount');expect(rls).toContain('notifications_runtime_owner');expect(rls).toContain('user_id=public.current_app_user_id()')});
  it('retains exactly five primary intents and a separate protection action',()=>{const shell=read('components/app-shell.tsx');const nav=navSource();expect((nav.match(/\['\//g)??[]).length).toBe(5);for(const intent of ['Hari Ini','Tanya DUTA','Keperluan','Rantau','Saya'])expect(nav).toContain(intent);expect(nav).not.toContain('Jaga Diri');expect(shell).toContain('className="vp-safety"');expect(shell).toContain('href="/jaga-diri"')});
});
