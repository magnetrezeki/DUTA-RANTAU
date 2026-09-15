'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';

export function LandingCta() {
  const [authenticated, setAuthenticated] = useState(false);
  useEffect(() => {
    const controller = new AbortController();
    void fetch('/api/auth/me', { cache: 'no-store', signal: controller.signal })
      .then(async response => response.ok ? response.json() : null)
      .then(data => { if (!controller.signal.aborted) setAuthenticated(Boolean(data?.user?.id)); })
      .catch(() => { /* Public acquisition links remain available on failure. */ });
    return () => controller.abort();
  }, []);

  return authenticated
    ? <Link className="landing-primary" href="/beranda">Buka DUTA RANTAU <span aria-hidden="true">↗</span></Link>
    : <Link className="landing-primary" href="/daftar">Daftar Gratis <span aria-hidden="true">↗</span></Link>;
}
