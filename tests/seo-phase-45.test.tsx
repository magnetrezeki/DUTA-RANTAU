import { describe, expect, it } from 'vitest';
import { renderToStaticMarkup } from 'react-dom/server';
import { JsonLd } from '../components/json-ld';
import { indexableStaticRoutes, noIndexRobots, publicRobots, siteUrl } from '../lib/seo';

describe('SEO Phase 4–5 contract', () => {
  it('keeps the production origin explicit and has no inherited root canonical', () => {
    expect(siteUrl.toString()).toBe('https://www.dutarantau.com/');
    expect(indexableStaticRoutes).toContain('/info');
  });
  it('keeps private routes explicitly noindex', () => expect(noIndexRobots()).toEqual({ index: false, follow: false }));
  it('indexes only Vercel production', () => {
    const prior = process.env.VERCEL_ENV;
    process.env.VERCEL_ENV = 'production'; expect(publicRobots()).toEqual({ index: true, follow: true });
    process.env.VERCEL_ENV = 'preview'; expect(publicRobots()).toEqual({ index: false, follow: false });
    if (prior === undefined) delete process.env.VERCEL_ENV; else process.env.VERCEL_ENV = prior;
  });
  it('serializes JSON-LD safely without injecting markup', () => {
    const html = renderToStaticMarkup(<JsonLd data={{ '@context': 'https://schema.org', name: '<unsafe>' }} />);
    expect(html).toContain('\\u003cunsafe>'); expect(html).not.toContain('<unsafe>');
  });
});
