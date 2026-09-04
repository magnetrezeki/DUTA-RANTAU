import { PageHeader,TrustBadge } from '@/components/ui';
import { ExternalLink,Plus } from 'lucide-react';

export const metadata={title:'Manajemen Sumber'};

async function getSources() {
    const res = await fetch(
        `${process.env.NEXT_PUBLIC_APP_URL}/api/sources`,
        { cache: 'no-store' }
    );

    if (!res.ok) return [];

    const json = await res.json();
    return json.data ?? [];
}

export default async function Page() {
    const officialSources = await getSources();

    return <div className="page">
        <PageHeader
            eyebrow="ADMIN · SOURCE HEALTH"
            title="Manajemen Sumber"
            description="Tambah, periksa, verifikasi, dan nonaktifkan sumber resmi."
            action={<button className="primary"><Plus/>Tambah sumber</button>}
        />

        <div className="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Institusi</th>
                        <th>Kanal</th>
                        <th>Prioritas</th>
                        <th>Status</th>
                        <th>Terakhir diperiksa</th>
                        <th/>
                    </tr>
                </thead>

                <tbody>
                    {officialSources.map((s:any)=>
                        <tr key={s.id}>
                            <td><b>{s.institution}</b></td>
                            <td>{s.channel}</td>
                            <td><span className="priority">{s.priority}</span></td>
                            <td><TrustBadge/></td>
                            <td>{s.lastChecked ?? '-'}</td>
                            <td>
                                <a href={s.url} target="_blank" rel="noreferrer" aria-label="Buka">
                                    <ExternalLink/>
                                </a>
                            </td>
                        </tr>
                    )}
                </tbody>
            </table>
        </div>
    </div>
}
