import { DemoBadge,PageHeader } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { ArrowRight,Lock,MapPin,Plus,Users } from 'lucide-react';

export const metadata={title:'Kawan Rantau'};

async function getCommunities() {
    const res = await fetch(
        `${process.env.NEXT_PUBLIC_APP_URL}/api/community`,
        { cache: 'no-store' }
    );

    if (!res.ok) return [];

    const json = await res.json();
    return json.data ?? [];
}

export default async function Page() {
    const demoCommunities = await getCommunities();

    return <div className="page">
        <PageHeader
            eyebrow="TEMUKAN · TERHUBUNG · BERTUMBUH"
            title="Kawan Rantau"
            description="Temukan komunitas Indonesia berdasarkan kota, asal, profesi, dan minat—tanpa membagikan lokasi presisi."
            action={<button className="primary"><Plus/>Buat komunitas</button>}
        />

        <SearchFilter placeholder="Cari komunitas, kota, atau minat…"/>

        <div className="cards-grid">
            {demoCommunities.map((x:any,i:number)=>
                <article className="community-card" key={x.id}>
                    <div className={`cover c${i+1}`}>
                        <Users/>
                    </div>

                    <div className="card-body">
                        <DemoBadge/>
                        <h2>{x.name}</h2>

                        <p>
                            <MapPin/> {x.location}
                        </p>

                        <div className="card-foot">
                            <span>
                                {x.visibility==='COMMUNITY_ONLY'
                                    ? <Lock size={14}/>
                                    : <Users size={14}/>
                                }
                                {' '}{x.members} anggota
                            </span>

                            <button aria-label="Buka">
                                <ArrowRight/>
                            </button>
                        </div>
                    </div>
                </article>
            )}
        </div>

        <p className="privacy-note">
            <Lock size={16}/>
            Lokasi presisi anggota disembunyikan secara default.
        </p>
    </div>
}
