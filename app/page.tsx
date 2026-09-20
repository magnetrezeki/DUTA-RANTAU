import type { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';
import { ArrowUpRight, Briefcase, Building2, Compass, HeartHandshake, MapPin, MessageCircle, ShieldCheck, ShoppingBag, Users } from 'lucide-react';
import { LandingCta } from '@/components/landing-cta';
import styles from './landing.module.css';

const title = 'DUTA RANTAU — Rumah Digital Orang Indonesia di Malaysia';
export const metadata: Metadata = {
  title: { absolute: title },
  description: 'DUTA RANTAU membantu orang Indonesia di Malaysia menemukan informasi, komunitas, peluang kerja, layanan, akses bantuan, dan langkah berikutnya.',
  openGraph: { title, description: 'Informasi, komunitas, kerja, keselamatan, layanan sekitar, dan bantuan DUTA AI dalam satu rumah digital.' },
};
const services = [
  { href: '/tanya', title: 'DUTA AI', text: 'Bantuan untuk memahami informasi dan menemukan langkah berikutnya.', icon: MessageCircle },
  { href: '/kerja', title: 'Kerja', text: 'Temukan peluang dan informasi kerja dengan sumber yang ditampilkan.', icon: Briefcase },
  { href: '/komunitas', title: 'Komuniti', text: 'Terhubung dengan Kawan Rantau di sekitar Anda.', icon: Users },
  { href: '/organisasi', title: 'Organisasi', text: 'Ruang digital untuk kegiatan dan pengelolaan organisasi.', icon: Building2 },
  { href: '/pasar', title: 'Pasar Rantau', text: 'Jelajahi produk dan jasa komunitas.', icon: ShoppingBag },
  { href: '/jaga-diri', title: 'Jaga Diri', text: 'Akses bantuan, rujukan, dan kontak penting.', icon: ShieldCheck },
];
const navigation = [['/beranda', 'Hari Ini'], ['/tanya', 'Tanya DUTA'], ['/layanan', 'Keperluan'], ['/komunitas', 'Rantau'], ['/profil', 'Saya']];

export default function PublicLanding() {
  return <div className={styles.landing}>
    <a className={styles.skip} href="#konten">Langsung ke isi</a>
    <header className={styles.header}>
      <Link className={styles.brand} href="/" aria-label="DUTA RANTAU — beranda publik"><Image src="/logo.png" alt="" width={42} height={42} priority /><span><b>DUTA</b> RANTAU<small>INDONESIA · MALAYSIA</small></span></Link>
      <nav className={styles.desktopNav} aria-label="Navigasi utama">{navigation.map(([href, label]) => <Link key={href} href={href}>{label}</Link>)}<Link href="/jaga-diri">Jaga Diri</Link></nav>
      <div className={styles.headerActions}><Link href="/masuk">Masuk</Link><LandingCta /></div>
      <details className={styles.mobileMenu}><summary>Menu</summary><nav aria-label="Navigasi utama mobile">{navigation.map(([href, label]) => <Link key={href} href={href}>{label}</Link>)}<Link href="/jaga-diri">Jaga Diri</Link><Link href="/masuk">Masuk</Link></nav></details>
    </header>
    <main id="konten">
      <section className={styles.hero}>
        <div><p className={styles.eyebrow}>DEKAT DI HATI. TERHUBUNG DI RANTAU.</p><p className={styles.heroBrand}><b>DUTA</b> RANTAU</p><h1>Rumah Digital Orang Indonesia <em>di Malaysia.</em></h1><p className={styles.lead}>Informasi, komunitas, peluang kerja, layanan sekitar, akses bantuan, dan pendampingan DUTA AI dalam satu tempat untuk perjalanan rantau Anda.</p><div className={styles.actions}><LandingCta /><a className={styles.secondary} href="#tentang">Kenali DUTA RANTAU <ArrowUpRight size={18} /></a></div><p className={styles.heroNote}>Mulai gratis. Untuk pekerja, pelajar, keluarga, dan komunitas Indonesia.</p></div>
        <div className={styles.heroVisual} aria-label="Ilustrasi ekosistem DUTA RANTAU">
          <div className={styles.visualTop}><span><MapPin size={16} /> MALAYSIA · FASE PERTAMA</span><span className={styles.dot} /></div>
          <div className={styles.homeSymbol}><Image src="/arti_ikon-duta.png" alt="Simbol DUTA" width={84} height={84} /><h2>Satu rumah.<br />Banyak koneksi.</h2></div>
          <div className={styles.visualCards}><span><Users />Temukan kawan</span><span><Compass />Temukan arah</span><span><HeartHandshake />Saling terhubung</span></div>
          <p>Jarak boleh jauh.<br /><strong>Rasa dekat tetap ada.</strong></p>
        </div>
      </section>
      <section id="tentang" className={styles.intro}><p className={styles.eyebrow}>KENALI DUTA RANTAU</p><h2>Satu rumah digital untuk<br />perjalanan rantau Anda.</h2><p>Tinggal di rantau sering membuat informasi terasa tersebar. DUTA RANTAU membantu Anda menemukan langkah berikutnya, terhubung dengan komunitas, dan melihat sumber yang relevan dengan lebih jelas.</p><div className={styles.pillRow}><span>Informasi</span><span>Komunitas</span><span>Peluang</span><span>Akses bantuan</span></div></section>
      <section id="layanan" className={styles.section}><div className={styles.sectionHeading}><div><p className={styles.eyebrow}>EKOSISTEM DUTA</p><h2>Untuk keseharian Anda<br />di Malaysia.</h2></div><p>Mulai dari kebutuhan hari ini.<br />Temukan ruang yang sesuai untuk Anda.</p></div><div className={styles.grid}>{services.map(({ href, title: name, text, icon: Icon }) => <Link href={href} className={styles.card} key={href}><Icon size={26} /><h3>{name}</h3><p>{text}</p><span>Jelajahi <ArrowUpRight size={17} /></span></Link>)}</div></section>
      <section id="duta-ai" className={styles.aiSection}><div><p className={styles.eyebrow}>ASISTEN UNTUK LANGKAH BERIKUTNYA</p><h2>DUTA AI,<br />untuk membantu Anda mulai.</h2><p>DUTA AI membantu menjelajahi DUTA RANTAU, memahami informasi, dan menemukan sumber atau langkah yang relevan.</p><p className={styles.finePrint}>AI adalah bantuan, bukan pengganti keputusan resmi atau penilaian akhir. Penggunaan mengikuti ketersediaan dan batas layanan di aplikasi.</p><Link className={styles.secondary} href="/tanya">Kenali ruang DUTA AI <ArrowUpRight size={18} /></Link></div><div className={styles.aiExample}><span>ILUSTRASI PERCAKAPAN · BUKAN JAWABAN LANGSUNG</span><p className={styles.question}>Di mana saya bisa menemukan komunitas?</p><div><MessageCircle /><p>Mulai dari Kawan Rantau. Jelajahi komunitas dan lihat informasi yang tersedia sebelum bergabung.</p><Link href="/komunitas">Jelajahi Komuniti →</Link></div></div></section>
      <section className={styles.twoSections}><article><p className={styles.eyebrow}>KERJA & PELUANG</p><h2>Cari peluang<br />dengan lebih jelas.</h2><p>Jelajahi informasi sumber resmi dan peluang yang tersedia di platform. Periksa asal informasi dan pihak yang memasang lowongan.</p><p className={styles.finePrint}>DUTA membantu menemukan informasi, bukan agen penempatan tenaga kerja. Keputusan perekrutan berada pada pihak yang berwenang.</p><Link href="/kerja">Jelajahi informasi kerja <ArrowUpRight size={18} /></Link></article><article id="komuniti"><p className={styles.eyebrow}>KAWAN & ORGANISASI</p><h2>Tidak perlu menjalani<br />rantau sendirian.</h2><p>Temukan komunitas, organisasi, dan ruang untuk saling terhubung. Dari percakapan sehari-hari hingga kegiatan bersama.</p><div className={styles.actions}><Link href="/komunitas">Temukan Kawan Rantau <ArrowUpRight size={18} /></Link><Link href="/organisasi">Lihat Organisasi <ArrowUpRight size={18} /></Link></div></article></section>
      <section id="keselamatan" className={styles.safety}><ShieldCheck size={38} /><div><p className={styles.eyebrow}>JAGA DIRI</p><h2>Saat Anda butuh bantuan.</h2><p>Temukan rujukan keselamatan dan akses kontak resmi KBRI/KJRI yang relevan. Sumber resmi ditampilkan agar dapat Anda periksa kembali.</p><p className={styles.finePrint}>DUTA RANTAU independen, bukan institusi pemerintah, dan tidak mewakili KBRI/KJRI.</p></div><Link className={styles.secondary} href="/jaga-diri">Buka Jaga Diri <ArrowUpRight size={18} /></Link></section>
      <section className={styles.discovery}><div><span className={styles.coming}>SEGERA HADIR</span><h2>DUTA Map</h2><p>Ruang untuk menemukan layanan dan tempat di sekitar Anda sedang dipersiapkan. Peta interaktif belum tersedia.</p></div><div className={styles.mapIllustration} aria-label="Ilustrasi peta, bukan lokasi aktual"><MapPin size={46} /><span>Lebih dekat dengan sekitar Anda.</span></div></section>
      <section className={styles.trust}><p className={styles.eyebrow}>PERIKSA SEBELUM PERCAYA</p><h2>Informasi dengan konteks yang jelas.</h2><div className={styles.trustGrid}><article><h3>Sumber terlihat</h3><p>Periksa asal informasi dan kanal resmi sebelum mengambil langkah.</p></article><article><h3>Status punya batas</h3><p>Verifikasi, kelayakan, popularitas, atau promosi berbayar bukan jaminan keselamatan.</p></article><article><h3>Tinjauan manusia tetap penting</h3><p>Laporan dan sinyal AI adalah masukan untuk ditinjau, bukan vonis. Tidak adanya laporan juga bukan jaminan aman.</p></article></div></section>
      <section className={styles.free}><p className={styles.eyebrow}>MULAI GRATIS</p><h2>Rumah digital ini<br />juga untuk Anda.</h2><p>Akses dasar untuk menjelajahi DUTA RANTAU tersedia tanpa biaya. Layanan tertentu dapat memiliki ketentuan masing-masing.</p><div className={styles.actions}><LandingCta /><Link className={styles.secondary} href="/masuk">Sudah punya akun? Masuk</Link></div><p className={styles.finePrint}>Satu rumah digital untuk perjalanan rantau Anda.</p></section>
    </main>
    <footer className={styles.footer}><div><Link className={styles.brand} href="/"><span><b>DUTA</b> RANTAU<small>Rumah Digital Orang Indonesia di Malaysia</small></span></Link><p>DUTA RANTAU adalah platform independen. Selalu periksa prosedur terbaru melalui kanal institusi terkait.</p></div><nav aria-label="Tautan footer"><Link href="/layanan">Layanan RI</Link><Link href="/jaga-diri">Jaga Diri</Link><Link href="/komunitas">Komuniti</Link><Link href="/kerja">Kerja</Link><Link href="/pasar">Pasar Rantau</Link><Link href="/organisasi">Organisasi</Link><Link href="/info">Info Rantau</Link></nav></footer>
  </div>;
}
