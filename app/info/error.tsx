'use client';

import Link from 'next/link';

export default function InfoError() { return <div className="vp-page vp-narrow"><section className="vp-empty"><h1>Info Rantau belum dapat dimuat</h1><p>Coba lagi nanti. DUTA tidak menampilkan keadaan ini sebagai daftar informasi kosong.</p><Link href="/info">Coba lagi</Link></section></div>; }
