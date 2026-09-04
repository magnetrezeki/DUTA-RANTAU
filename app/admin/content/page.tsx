import { AdminContentManager } from '@/components/admin-content-manager';
import { PageHeader } from '@/components/ui';

export const dynamic = 'force-dynamic';
export const metadata = { title: 'Manajemen Konten Production' };

export default function Page() { return <div className="page admin-page"><PageHeader eyebrow="ADMIN · PRODUCTION CONTENT" title="Manajemen konten" description="Buat, edit melalui API, publish, archive, dan delete record database dengan archival-only protection untuk organizations." /><AdminContentManager /></div>; }
