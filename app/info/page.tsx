import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { infoCategories } from '@/lib/mission-registry';
import { dutaSummaryLabel, presentContentType, presentDate, presentPlatform } from '@/lib/news-presentation';
import { getPublicNewsPage } from '@/lib/services/public-news';
import { publicRobots } from '@/lib/seo';
import { JsonLd } from '@/components/json-ld';

export const dynamic = 'force-dynamic';
export const metadata: Metadata = { title: 'Info Rantau', description: 'Ringkasan DUTA atas informasi resmi perwakilan dan fungsi Indonesia di Malaysia.', alternates: { canonical: '/info' }, robots: publicRobots(), openGraph: { type: 'website', url: '/info', title: 'Info Rantau', description: 'Ringkasan DUTA atas informasi resmi perwakilan dan fungsi Indonesia di Malaysia.' }, twitter: { card: 'summary', title: 'Info Rantau', description: 'Ringkasan DUTA atas informasi resmi perwakilan dan fungsi Indonesia di Malaysia.' } };

const pageNumber = (value: string | string[] | undefined) => {
  const candidate = Array.isArray(value) ? value[0] : value;
  return candidate && /^[1-9]\d*$/.test(candidate) ? Number(candidate) : 1;
};

export default async function Page({ searchParams }: { searchParams: Promise<{ page?: string | string[] }> }) {
  const { page: suppliedPage } = await searchParams;
  const result = await getPublicNewsPage(pageNumber(suppliedPage));
  const items = result.stories.map(story => ({ '@type': 'ListItem', position: result.stories.indexOf(story) + 1, url: `https://www.dutarantau.com/info/${story.publicSlug}`, name: story.displayTitle }));
  return <div className="vp-page vp-wide"><JsonLd data={[{ '@context': 'https://schema.org', '@type': 'CollectionPage', name: 'Info Rantau', url: 'https://www.dutarantau.com/info', description: 'Ringkasan DUTA atas informasi resmi perwakilan dan fungsi Indonesia di Malaysia.' }, { '@context': 'https://schema.org', '@type': 'BreadcrumbList', itemListElement: [{ '@type': 'ListItem', position: 1, name: 'DUTA RANTAU', item: 'https://www.dutarantau.com/' }, { '@type': 'ListItem', position: 2, name: 'Info Rantau', item: 'https://www.dutarantau.com/info' }] }, ...(items.length ? [{ '@context': 'https://schema.org', '@type': 'ItemList', itemListElement: items }] : [])]}/><header className="vp-top"><span className="vp-eyebrow">Maklumat · Info Rantau</span><h1>Informasi yang dapat<br/><em>Anda periksa.</em></h1><p className="vp-lead">Ringkasan DUTA atas informasi resmi, dengan tautan ke sumber asal yang spesifik.</p></header><section className="vp-section"><h2>Update resmi</h2>{result.stories.length ? <div>{result.stories.map(story => <article className="vp-row" key={story.publicSlug}><span><strong>{story.displayTitle}</strong><small>{presentContentType(story.contentType)} · {story.officialSourceInstitution} · {presentPlatform(story.officialSourceChannel)}</small><p>{dutaSummaryLabel}: {story.conciseSummary}</p>{presentDate(story.sourcePublishedAt) ? <small>Sumber dipublikasikan {presentDate(story.sourcePublishedAt)}</small> : null}</span><Link href={`/info/${story.publicSlug}`}>Baca ringkasan <ArrowUpRight size={16}/></Link></article>)}</div> : <div className="vp-empty"><strong>Belum ada artikel terverifikasi untuk diterbitkan.</strong><p>Artikel akan tampil di sini setelah melewati verifikasi dan publikasi manusia. DUTA tidak membuat suapan berita atau rekomendasi tanpa provenance.</p></div>}{result.hasMore ? <nav className="vp-actions" aria-label="Halaman Info Rantau"><Link className="vp-btn" href={`/info?page=${result.page + 1}`}>Lihat update berikutnya <ArrowUpRight size={16}/></Link></nav> : null}</section><section className="vp-section"><h2>Kategori berguna</h2><div className="vp-grid">{infoCategories.map(([title,text])=><article className="vp-empty" key={title}><strong>{title}</strong><p>{text}</p>{title==='Hidup di Malaysia'?<Link href="/info/tempat-wisata">Tempat Wisata <ArrowUpRight size={14}/></Link>:null}</article>)}</div></section><section className="vp-note"><strong>Sumber tetap di tangan penerbit asal.</strong><p>{dutaSummaryLabel} menjelaskan informasi yang tersedia tanpa menggantikan pengumuman, prosedur, atau formulir dari sumber resmi.</p></section><footer className="vp-footer"><Link href="/metodologi-editorial">Bagaimana Info Rantau disiapkan <ArrowUpRight size={16}/></Link></footer></div>;
}
