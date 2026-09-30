import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { publicRobots } from '@/lib/seo';

export const metadata: Metadata = { title: 'Tentang DUTA RANTAU', description: 'Tentang DUTA RANTAU, platform untuk orang Indonesia di Malaysia.', alternates: { canonical: '/tentang' }, robots: publicRobots() };
export default function AboutPage() { return <div className="vp-page vp-narrow"><header className="vp-top"><span className="vp-eyebrow">Tentang DUTA RANTAU</span><h1>Teman menjalani hidup di Malaysia.</h1><p className="vp-lead">DUTA RANTAU adalah platform untuk orang Indonesia di Malaysia.</p></header><section className="vp-section"><h2>Peran DUTA</h2><p>DUTA membantu orang menemukan informasi dan jalur yang dapat diperiksa. DUTA bukan layanan pemerintah dan bukan bagian dari perwakilan diplomatik Indonesia.</p></section><section className="vp-section"><h2>Informasi yang dapat diperiksa</h2><p>Info Rantau menyajikan ringkasan DUTA atas informasi dari sumber resmi, dengan tautan ke sumber asal agar pembaca dapat memeriksa informasi secara langsung.</p><Link className="vp-btn" href="/info">Buka Info Rantau <ArrowUpRight size={16}/></Link></section><footer className="vp-footer"><Link href="/metodologi-editorial">Metodologi editorial <ArrowUpRight size={16}/></Link></footer></div>; }
