import { redirect } from 'next/navigation';
import { PageHeader } from '@/components/ui';
import { LogoutButton } from '@/components/logout-button';
import { Lock, MapPin, Shield } from 'lucide-react';
import { getCurrentUser } from '@/lib/auth/session';

export const metadata = { title: 'Profil Saya' };

export default async function Page() {
  const user = await getCurrentUser();
  if (!user) redirect('/masuk');
  const initial = user.name.trim().slice(0, 2).toUpperCase() || 'DR';
  return <div className="page"><PageHeader eyebrow="AKUN & PRIVASI" title="Profil Saya" description="Informasi yang ditampilkan berasal dari sesi akun Anda." /><div className="profile-layout"><section className="profile-card"><div className="big-avatar" aria-hidden="true">{initial}</div><div><h2>{user.name}</h2><p>{user.city ? <><MapPin />{user.city}, Malaysia</> : 'Lokasi belum ditambahkan.'}</p></div></section></div><section className="settings" aria-label="Status akun"><h2>Akun</h2><div className="notice"><Lock /><div><b>Pengelolaan profil dan preferensi belum aktif.</b><p>DUTA tidak menampilkan riwayat, notifikasi, lencana, atau pengaturan rekaan. Hubungi dukungan bila perlu memperbarui data akun.</p></div></div><div className="notice"><Shield /><div><b>Privasi tetap dikendalikan.</b><p>Jaga Diri dan layanan publik tetap dapat diakses tanpa membuat data aktivitas rekaan pada profil Anda.</p></div></div></section><LogoutButton /></div>;
}

