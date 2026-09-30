import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { publicRobots } from '@/lib/seo';

export const metadata: Metadata = { title: 'Privasi', description: 'Informasi privasi DUTA RANTAU.', alternates: { canonical: '/privasi' }, robots: publicRobots() };
export default function PrivacyPage() { return <div className="vp-page vp-narrow"><header className="vp-top"><span className="vp-eyebrow">DUTA RANTAU</span><h1>Privasi</h1><p className="vp-lead">Halaman ini menjelaskan batas informasi yang disajikan DUTA secara publik.</p></header><section className="vp-section"><h2>Ruang publik dan akun</h2><p>Informasi publik disajikan untuk dibaca tanpa menampilkan data akun pribadi. Fitur yang memerlukan akun menggunakan sesi sesuai kebutuhan fitur tersebut.</p></section><section className="vp-section"><h2>Transparansi informasi</h2><p>DUTA berupaya membedakan ringkasan publik, informasi sumber asli, dan ruang akun. Detail kebijakan yang belum diterbitkan tidak diklaim di halaman ini.</p></section><footer className="vp-footer"><Link href="/tentang">Tentang DUTA RANTAU <ArrowUpRight size={16}/></Link></footer></div>; }
