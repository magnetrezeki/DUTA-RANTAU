import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
const read=(path:string)=>readFileSync(path,'utf8');

describe('Jaga Diri mobile access',()=>{
  it('keeps five primary mobile intents and a structurally separate safety entry',()=>{const shell=read('components/app-shell.tsx');const nav=shell.split('const nav = [')[1]?.split('] as const')[0]??'';expect((nav.match(/\['\//g)??[]).length).toBe(5);expect(nav).not.toContain('Jaga Diri');expect(shell).toContain('className="vp-safety"');expect(shell).toContain('<nav className="vp-navigation"')});
  it('keeps the elevated safety action reachable while mobile navigation stays fixed',()=>{const css=read('app/visual-port.css');expect(css).toContain('.vp-header{position:sticky');expect(css).toContain('.vp-safety{');expect(css).toContain('.vp-navigation{position:fixed');expect(css).toContain('padding-bottom:110px')});
  it('keeps protection public and separates manual official referral from device location',()=>{const page=read('app/jaga-diri/page.tsx');expect(page).not.toContain('redirect(');expect(page).not.toContain('getCurrentUser');expect(page).not.toContain('EmergencyContacts');expect(page).not.toContain('getCurrentPosition');expect(page).toContain('Pilih wilayah secara manual');expect(page).toContain('officialEmergencyOffices');expect(page).toContain('Buka kanal resmi')});
});
