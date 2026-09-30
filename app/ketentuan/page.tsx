import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { publicRobots } from '@/lib/seo';

export const metadata: Metadata = { title: 'Ketentuan', description: 'Ketentuan penggunaan dasar DUTA RANTAU.', alternates: { canonical: '/ketentuan' }, robots: publicRobots() };
export default function TermsPage() { return <div className="vp-page vp-narrow"><header className="vp-top"><span className="vp-eyebrow">DUTA RANTAU</span><h1>Ketentuan</h1><p className="vp-lead">Gunakan informasi DUTA sebagai arah untuk memeriksa sumber dan langkah yang relevan.</p></header><section className="vp-section"><h2>Gunakan sumber asal</h2><p>Ringkasan Info Rantau tidak menggantikan pengumuman, prosedur, atau formulir dari penerbit asal. Periksa informasi asli sebelum mengambil tindakan.</p></section><section className="vp-section"><h2>Ketersediaan fitur</h2><p>DUTA menampilkan kemampuan yang tersedia dan tidak mengklaim layanan, transaksi, atau status yang belum diterbitkan.</p></section><footer className="vp-footer"><Link href="/info">Buka Info Rantau <ArrowUpRight size={16}/></Link><Link href="/privasi">Privasi <ArrowUpRight size={16}/></Link></footer></div>; }
