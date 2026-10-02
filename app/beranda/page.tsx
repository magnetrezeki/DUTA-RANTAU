import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { HariIniMember } from '@/components/hari-ini-member';
import { noIndexRobots } from '@/lib/seo';
import { getPublicNewsPage } from '@/lib/services/public-news';
import { jobs } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

export const metadata = { title: 'Hari Ini', robots: noIndexRobots() };

function Row({ href, title, text }: { href: string; title: string; text: string }) {
  return <Link className="vp-row" href={href}><span><strong>{title}</strong><small>{text}</small></span><ArrowUpRight size={20}/></Link>;
}

export const dynamic = 'force-dynamic';

export default async function Home() {
  const [news, activeJobs] = await Promise.all([
    getPublicNewsPage(1).catch(() => ({ stories: [], hasMore: false, page: 1 })),
    withPublicTransaction<Array<{ id: string; title: string; employer: string }>>(tx => tx.select({ id: jobs.id, title: jobs.title, employer: jobs.employer }).from(jobs).where(eq(jobs.recordStatus, 'ACTIVE')).limit(3)).catch(() => []),
  ]);
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
      <div className="vp-grid"><section className="vp-section"><h2>Info Rantau</h2><h3>Ringkasan dengan sumber yang dapat diperiksa.</h3>{news.stories.length ? news.stories.slice(0, 2).map(story => <Row key={story.publicSlug} href={`/info/${story.publicSlug}`} title={story.displayTitle} text="Ringkasan oleh DUTA · sumber resmi"/>) : <p>Belum ada artikel terverifikasi untuk diterbitkan. DUTA tidak mengisi ruang ini dengan berita rekaan.</p>}<div className="vp-actions"><Link className="vp-quiet" href="/info">Buka Info Rantau <ArrowUpRight size={16}/></Link></div></section><section className="vp-section"><h2>Kerja yang dapat diperiksa</h2>{activeJobs.length ? activeJobs.map(job => <Row key={job.id} href="/kerja" title={job.title} text={`${job.employer} · sumber dan syarat asal`}/>) : <p>Belum ada lowongan aktif yang diterbitkan. Periksa sumber resmi ketika Anda siap.</p>}<Link className="vp-outline" href="/kerja">Buka jalur Kerja <ArrowUpRight size={16}/></Link></section></div>
      <footer className="vp-footer"><span>DUTA RANTAU independen. Periksa langkah terbaru di kanal resmi.</span><Link href="/tanya">Tanya DUTA <ArrowUpRight size={16}/></Link></footer>
    </div>
  </>;
}
