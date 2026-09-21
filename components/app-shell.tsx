'use client';
import Image from 'next/image';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Sun, MessageCircle, Compass, Users, UserRound, ShieldCheck, Bell } from 'lucide-react';

const nav = [
  ['/beranda', 'Hari Ini', Sun],
  ['/tanya', 'Tanya DUTA', MessageCircle],
  ['/layanan', 'Keperluan', Compass],
  ['/komunitas', 'Rantau', Users],
  ['/profil', 'Saya', UserRound],
] as const;

export function AppShell({ children }: { children: React.ReactNode }) {
  const path = usePathname();
  if (path === '/') return <>{children}</>;
  const active = (href: string) => href === '/layanan'
    ? ['/layanan', '/kerja', '/info', '/pasar'].some(route => path === route || path.startsWith(route + '/'))
    : href === '/komunitas'
      ? ['/komunitas', '/organisasi'].some(route => path === route || path.startsWith(route + '/'))
      : href === '/profil'
        ? ['/profil', '/notifikasi', '/belajar'].includes(path)
        : path === href;
  return <div className="vp-app">
    <header className="vp-header"><div className="vp-head-inner">
      <Link href="/beranda" className="vp-brand"><Image src="/visual-r21f/logo-small.png" alt="" width={32} height={32} unoptimized/><span><b>DUTA</b> RANTAU</span></Link>
      <Link href="/notifikasi" className="vp-notification" aria-label="Notification Inbox"><Bell size={19}/></Link>
      <Link href="/jaga-diri" className="vp-safety"><ShieldCheck size={18}/> Jaga Diri <span aria-hidden="true">↗</span></Link>
    </div></header>
    <nav className="vp-navigation" aria-label="Navigasi utama">{nav.map(([href,label,Icon]) => <Link key={href} href={href} aria-current={active(href) ? 'page' : undefined}><Icon size={19}/><span>{label}</span></Link>)}</nav>
    <main id="main">{children}</main>
  </div>;
}
