import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { ArrowUpRight } from 'lucide-react';
import { canonicalSource, dutaSummaryLabel, originalSourceLabel, presentContentType, presentDate, presentPlatform } from '@/lib/news-presentation';
import { getPublicNewsBySlug } from '@/lib/services/public-news';
import { publicRobots } from '@/lib/seo';

type Props = { params: Promise<{ slug: string }> };
export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const story = await getPublicNewsBySlug(slug);
  if (!story) notFound();
  return { title: story.displayTitle, description: story.conciseSummary, alternates: { canonical: `/info/${story.publicSlug}` }, robots: publicRobots(), openGraph: { type: 'article', url: `/info/${story.publicSlug}`, title: story.displayTitle, description: story.conciseSummary, publishedTime: story.publishedAt }, twitter: { card: 'summary', title: story.displayTitle, description: story.conciseSummary } };
}

export default async function PublicInfoStory({ params }: Props) {
  const { slug } = await params;
  const story = await getPublicNewsBySlug(slug);
  if (!story) notFound();
  const canonical = canonicalSource(story);
  const additionalSources = story.sourceReferences.filter(source => source.originalUrl !== canonical.originalUrl || source.institution !== canonical.institution || source.channel !== canonical.channel);
  return <article className="vp-page vp-narrow"><nav className="vp-quiet" aria-label="Breadcrumb"><Link href="/">DUTA RANTAU</Link><span aria-hidden="true"> / </span><Link href="/info">Info Rantau</Link><span aria-hidden="true"> / </span><span>{story.displayTitle}</span></nav><header className="vp-top"><span className="vp-eyebrow">{presentContentType(story.contentType)} · {story.officialSourceInstitution}</span><h1>{story.displayTitle}</h1><p className="vp-lead"><strong>{dutaSummaryLabel}</strong><br/>{story.conciseSummary}</p></header><section className="vp-section"><h2>Sumber informasi</h2><p><strong>{story.officialSourceInstitution}</strong> · {presentPlatform(story.officialSourceChannel)}</p>{presentDate(story.publishedAt) ? <p>DUTA menerbitkan ringkasan ini pada {presentDate(story.publishedAt)}.</p> : null}{presentDate(canonical.sourcePublishedAt) ? <p>Sumber menerbitkan informasi asal pada {presentDate(canonical.sourcePublishedAt)}.</p> : null}<div className="vp-actions"><a className="vp-btn" href={canonical.originalUrl} target="_blank" rel="noreferrer">{originalSourceLabel(canonical)} <ArrowUpRight size={16}/></a></div></section>{additionalSources.length ? <section className="vp-section"><h2>Rujukan resmi lain</h2>{additionalSources.map(source => <a className="vp-row" href={source.originalUrl} target="_blank" rel="noreferrer" key={source.originalUrl}><span><strong>{source.institution}</strong><small>{presentPlatform(source.channel)}{presentDate(source.sourcePublishedAt) ? ` · ${presentDate(source.sourcePublishedAt)}` : ''}</small></span><ArrowUpRight size={16}/></a>)}</section> : null}<footer className="vp-footer"><Link href="/info">Kembali ke Info Rantau <ArrowUpRight size={16}/></Link></footer></article>;
}
