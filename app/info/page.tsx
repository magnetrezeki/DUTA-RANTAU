import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { infoCategories } from '@/lib/mission-registry';
import { dutaSummaryLabel, presentContentType, presentDate, presentPlatform } from '@/lib/news-presentation';
import { getPublicNewsPage } from '@/lib/services/public-news';
import { publicRobots } from '@/lib/seo';

export const dynamic = 'force-dynamic';
export const metadata: Metadata = { title: 'Info Rantau', description: 'Ringkasan DUTA atas informasi resmi perwakilan dan fungsi Indonesia di Malaysia.', alternates: { canonical: '/info' }, robots: publicRobots() };

const pageNumber = (value: string | string[] | undefined) => {
  const candidate = Array.isArray(value) ? value[0] : value;
  return candidate && /^[1-9]\d*$/.test(candidate) ? Number(candidate) : 1;
};

export default async function Page({ searchParams }: { searchParams: Promise<{ page?: string | string[] }> }) {
  const { page: suppliedPage } = await searchParams;
  const result = await getPublicNewsPage(pageNumber(suppliedPage));
  return <div className="vp-page vp-wide"><header className="vp-top"><span className="vp-eyebrow">Maklumat · Info Rantau</span><h1>Informasi yang dapat<br/><em>Anda periksa.</em></h1><p className="vp-lead">Ringkasan DUTA atas informasi resmi, dengan tautan ke sumber asal yang spesifik.</p></header><section className="vp-section"><h2>Update resmi</h2>{result.stories.length ? <div>{result.stories.map(story => <article className="vp-row" key={story.publicSlug}><span><strong>{story.displayTitle}</strong><small>{presentContentType(story.contentType)} · {story.officialSourceInstitution} · {presentPlatform(story.officialSourceChannel)}</small><p>{dutaSummaryLabel}: {story.conciseSummary}</p>{presentDate(story.sourcePublishedAt) ? <small>Sumber dipublikasikan {presentDate(story.sourcePublishedAt)}</small> : null}</span><Link href={`/info/${story.publicSlug}`}>Baca ringkasan <ArrowUpRight size={16}/></Link></article>)}</div> : <div className="vp-empty"><strong>Belum ada artikel terverifikasi untuk diterbitkan.</strong><p>Artikel akan tampil di sini setelah melewati verifikasi dan publikasi manusia. DUTA tidak membuat suapan berita atau rekomendasi tanpa provenance.</p></div>}{result.hasMore ? <nav className="vp-actions" aria-label="Halaman Info Rantau"><Link className="vp-btn" href={`/info?page=${result.page + 1}`}>Lihat update berikutnya <ArrowUpRight size={16}/></Link></nav> : null}</section><section className="vp-section"><h2>Kategori berguna</h2><div className="vp-grid">{infoCategories.map(([title,text])=><article className="vp-empty" key={title}><strong>{title}</strong><p>{text}</p>{title==='Hidup di Malaysia'?<Link href="/info/tempat-wisata">Tempat Wisata <ArrowUpRight size={14}/></Link>:null}</article>)}</div></section><section className="vp-note"><strong>Sumber tetap di tangan penerbit asal.</strong><p>{dutaSummaryLabel} menjelaskan informasi yang tersedia tanpa menggantikan pengumuman, prosedur, atau formulir dari sumber resmi.</p></section></div>;
}
