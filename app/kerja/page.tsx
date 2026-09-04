import { DemoBadge,PageHeader,TrustBadge } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { Bookmark,Briefcase,Clock,MapPin,Plus } from 'lucide-react';

export const metadata={title:'Kerja'};

async function getJobs() {
    const res = await fetch(
        `/api/jobs`,
        { cache: 'no-store' }
    );

    const json = await res.json();
    return json.data ?? [];
}

export default async function Page() {

    const jobs = await getJobs();

    return (
        <div className="page">
            <PageHeader
                eyebrow="PELUANG UNTUK PERANTAU"
                title="Temukan pekerjaan"
                description="Jelajahi lowongan komunitas."
                action={<button className="primary"><Plus/>Pasang lowongan</button>}
            />

            <SearchFilter placeholder="Posisi, perusahaan, atau lokasi…" />

            <div className="content-layout">
                <div className="cards-list jobs">
                    {jobs.map((x:any)=>
                        <article className="job-card" key={x.id}>
                            <div className="job-logo"><Briefcase/></div>

                            <div className="job-main">
                                <div className="badge-row">
                                    <DemoBadge/>
                                    <TrustBadge/>
                                </div>

                                <h2>{x.title}</h2>

                                <b>{x.employer}</b>

                                <div className="meta">
                                    <span><MapPin/>{x.city}</span>
                                    <span><Clock/>{x.employmentType}</span>
                                </div>
                            </div>

                            <button className="icon-btn">
                                <Bookmark/>
                            </button>
                        </article>
                    )}
                </div>
            </div>
        </div>
    );
}

