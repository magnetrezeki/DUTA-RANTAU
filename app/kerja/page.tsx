import { PageHeader,TrustBadge } from '@/components/ui';
import { Briefcase,ExternalLink } from 'lucide-react';

export const dynamic='force-dynamic';

export const metadata={title:'Kerja'};

export default function Page() {

    return (
        <div className="page">
            <PageHeader
                eyebrow="PELUANG UNTUK PERANTAU"
                title="Temukan pekerjaan"
                description="Informasi kerja dan navigasi ke sumber resmi. DUTA tidak menerima lamaran atau memasang lowongan dalam beta publik awal."
            />

            <div className="content-layout">
                <div className="cards-list jobs">
                    <article className="job-card">
                            <div className="job-logo"><Briefcase/></div>

                            <div className="job-main">
                                <div className="badge-row"><TrustBadge/></div>

                                <h2>Lowongan resmi untuk penempatan di Malaysia</h2>
                                <p>Periksa ketersediaan, syarat, dan proses lamaran langsung pada portal resmi SISKOP2MI / KP2MI.</p>
                                <a className="primary" href="https://siskop2mi.bp2mi.go.id/lowongan/list" target="_blank" rel="noreferrer">Buka sumber resmi <ExternalLink size={16}/></a>
                            </div>

                        </article>
                </div>
            </div>
        </div>
    );
}

