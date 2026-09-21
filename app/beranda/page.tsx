import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { HariIniMember } from '@/components/hari-ini-member';

function Row({ href, title, text }: { href: string; title: string; text: string }) {
  return <Link className="vp-row" href={href}><span><strong>{title}</strong><small>{text}</small></span><ArrowUpRight size={20}/></Link>;
}

export default function Home() {
  return <>
    <HariIniMember />
    <div className="vp-page vp-wide vp-hari-public">
      <header className="vp-top"><span className="vp-eyebrow">Hari Ini · Untuk semua</span><h1>Satu hari.<br/><em>Banyak kemungkinan.</em></h1><p className="vp-lead">Mulai dari hal yang paling berguna untuk hidup di Malaysia.</p></header>
      <div className="vp-grid vp-hari-grid">
        <div>
          <section className="vp-feature"><span className="vp-kicker">Penting Hari Ini</span><h2>Urus dokumen,<br/>dengan arah yang jelas.</h2><p>Kenali perwakilan yang melayani wilayah Anda sebelum membuka layanan.</p><div className="vp-actions"><Link className="vp-btn" href="/layanan">Mulai dari Layanan RI <ArrowUpRight size={17}/></Link></div></section>
          <section className="vp-section"><h2>Untuk semua</h2><Row href="/kerja" title="Sedang mencari informasi kerja?" text="Buka sumber yang dapat Anda periksa"/><Row href="/komunitas" title="Baru mulai mengenal sekitar?" text="Temukan ruang untuk terhubung"/></section>
        </div>
        <div><figure className="vp-scene"><img src="/visual-r21f/hari-commute.webp" alt="Ilustrasi AI perempuan di perjalanan kota Malaysia; bukan pengguna nyata"/><figcaption>Momen Hari Ini · prototipe AI</figcaption></figure><section className="vp-section"><h2>Sekitar Anda</h2><Row href="/layanan#sekitar" title="Pilih area, temukan yang dekat" text="Lokasi perangkat selalu opsional; hasil sekitar belum tersedia"/></section></div>
      </div>
      <div className="vp-grid"><section className="vp-section"><h2>Update Resmi</h2><span className="vp-note">Sumber perlu diverifikasi</span><h3>Kenali kanal perwakilan Anda.</h3><p>Belum ada berita terverifikasi untuk ditampilkan.</p><div className="vp-actions"><Link className="vp-quiet" href="/layanan">Lihat kanal & tindakan <ArrowUpRight size={16}/></Link><Link className="vp-quiet" href="/info">Lihat update lain <ArrowUpRight size={16}/></Link></div></section><section className="vp-section"><h2>Mulai dari yang berguna</h2><p>Hal yang Anda simpan akan mudah ditemukan kembali setelah kemampuan itu tersedia.</p><Link className="vp-outline" href="/profil">Kenali Member gratis <ArrowUpRight size={16}/></Link></section></div>
      <footer className="vp-footer"><span>DUTA RANTAU independen. Periksa langkah terbaru di kanal resmi.</span><Link href="/tanya">Tanya DUTA <ArrowUpRight size={16}/></Link></footer>
    </div>
  </>;
}
