'use client';

import Link from 'next/link';
import { ArrowUpRight, BookOpen, Briefcase, Landmark, MapPin, Shield, Users } from 'lucide-react';
import { useEffect, useState } from 'react';

const memberPaths = [
  ['/belajar', 'DUTA Belajar', 'Mulai dari panduan yang tersedia.', BookOpen],
  ['/kerja', 'Jalur kerja', 'Periksa sumber resmi sebelum bertindak.', Briefcase],
] as const;

function MemberHariIni() {
  return <div className="member-shell"><style jsx global>{`.hari-public{display:none}.member-thread{border-top:1px solid var(--line-r);padding-top:28px}`}</style><div className="page home member-home">
    <section className="welcome"><div><p className="eyebrow">HARI INI · MEMBER</p><h1>Untuk Anda,<br /><em>masih berjalan.</em></h1><p>Ruang ini hanya menampilkan hal yang benar-benar tersedia untuk akun Anda.</p></div><Link className="safety-link" href="/jaga-diri"><Shield size={18} />Jaga Diri</Link></section>
    <section className="section"><div className="section-title"><h2>Penting Hari Ini</h2><span>Mulai dengan sumber yang nyata dan tersedia.</span></div><div className="notice"><Landmark /><div><b>Periksa sumber resmi sebelum mengambil langkah.</b><p>Informasi dapat berubah. DUTA membantu Anda menemukan jalur yang relevan tanpa mengada-adakan pembaruan.</p><Link href="/layanan">Buka Layanan RI <ArrowUpRight size={14} /></Link></div></div></section>
    <section className="section"><div className="section-title"><h2>Untuk Anda</h2><span>Pilihan berikut bukan rekomendasi yang dipersonalisasi.</span></div><div className="service-grid">{memberPaths.map(([href, title, description, Icon]) => <Link href={href} key={href} className="service-card"><i><Icon size={22} /></i><div><b>{title}</b><span>{description}</span></div><ArrowUpRight size={17} /></Link>)}</div></section>
    <section className="section panel"><div className="section-title"><h2>Sekitar Anda</h2><span>Lokasi belum dipilih untuk sesi ini.</span></div><div className="notice"><MapPin /><div><b>Belum ada informasi sekitar yang dapat ditampilkan.</b><p>DUTA tidak menebak lokasi atau membuat aktivitas setempat. Pilih jalur yang tersedia untuk melanjutkan pencarian secara sadar.</p><Link href="/komunitas">Jelajahi Kawan Rantau</Link></div></div></section>
    <section className="section"><div className="section-title"><h2>Update Resmi</h2><span>Jelajahi arkib dan sumber, bukan suapan rekaan.</span></div><Link className="primary" href="/info">Jelajahi Info Rantau <ArrowUpRight size={16} /></Link></section>
    <section className="section member-thread"><div className="section-title"><h2>Lanjutkan</h2><span>Kelanjutan yang tersimpan akan muncul di sini apabila tersedia.</span></div><div className="notice"><Users /><div><b>Belum ada kelanjutan tersimpan.</b><p>Tidak ada urusan, komuniti, atau pelan yang direka untuk akun ini.</p><Link href="/tanya">Mulai dengan Tanya DUTA</Link></div></div></section>
    <section className="disclaimer-wide"><Shield size={21} /><div><b>DUTA RANTAU bukan institusi pemerintah</b><p>Kami membantu Anda menemukan informasi dari sumber resmi. Selalu periksa prosedur terbaru pada kanal institusi terkait.</p></div></section>
  </div></div>;
}

export function HariIniMember() {
  const [isMember, setIsMember] = useState(false);
  useEffect(() => { let active = true; fetch('/api/auth/me', { credentials: 'same-origin' }).then((response) => response.ok ? response.json() : null).then((payload) => { if (active) setIsMember(Boolean(payload?.user)); }).catch(() => { if (active) setIsMember(false); }); return () => { active = false; }; }, []);
  return isMember ? <MemberHariIni /> : null;
}
