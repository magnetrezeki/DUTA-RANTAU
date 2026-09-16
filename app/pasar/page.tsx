import { PageHeader } from '@/components/ui';

export const metadata = { title: 'Pasar Rantau' };

export default function Page() {
  return <div className="page">
    <PageHeader
      eyebrow="PASAR RANTAU"
      title="Sedang dipersiapkan"
      description="Pasar Rantau akan tersedia setelah kontrol informasi, pengaduan, dan moderasi disiapkan dengan baik."
    />
  </div>;
}
