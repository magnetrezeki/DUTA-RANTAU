import { EmptyState, PageHeader } from '@/components/ui';

export const metadata = { title: 'Tempat Wisata' };

export default function TempatWisataPage() {
  return <div className="page"><PageHeader eyebrow="INFO RANTAU" title="Tempat Wisata" description="Rekomendasi akan ditampilkan setelah sumber dan tanggal pemeriksaannya tersedia."/><section className="section"><EmptyState title="Belum ada tempat wisata terverifikasi." description="DUTA RANTAU belum menerbitkan rekomendasi tanpa sumber resmi atau tanggal pemeriksaan."/></section></div>;
}
