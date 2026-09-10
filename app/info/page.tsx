import Link from 'next/link';
import { EmptyState, PageHeader } from '@/components/ui';
import { Banknote, Bus, GraduationCap, HeartPulse, Home, Landmark, MapPinned, Phone, Scale, ShoppingBag, Utensils } from 'lucide-react';

const unavailableCategories = [[Bus, 'Transportasi'], [Home, 'Tempat tinggal'], [GraduationCap, 'Pendidikan'], [HeartPulse, 'Kesehatan'], [Banknote, 'Perbankan'], [Phone, 'Telekomunikasi'], [Utensils, 'Makanan'], [ShoppingBag, 'Belanja'], [Scale, 'Dasar hukum'], [Landmark, 'Layanan publik']] as const;

export const metadata = { title: 'Info Rantau' };

export default function Page() {
  return <div className="page"><PageHeader eyebrow="PANDUAN HIDUP DI MALAYSIA" title="Info Rantau" description="Konten berbasis lokasi dengan sumber, tanggal, kategori, dan status verifikasi yang jelas."/><div className="category-grid"><Link href="/info/tempat-wisata" aria-label="Tempat Wisata"><MapPinned/><span>Tempat Wisata</span></Link>{unavailableCategories.map(([Icon, label]) => <button key={label} type="button" disabled aria-label={`${label}: belum tersedia`}><Icon/><span>{label}</span></button>)}</div><section className="section"><div className="section-title"><h2>Informasi terbaru</h2><span>Hanya konten yang telah memiliki sumber</span></div><EmptyState title="Belum ada artikel terverifikasi." description="Admin dapat menambahkan konten melalui CMS setelah sumber diperiksa."/></section></div>;
}

