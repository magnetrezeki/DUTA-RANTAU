import { EmptyState,PageHeader } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { Lock,MapPin,Users } from 'lucide-react';
import { communities } from '@/db/schema';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

export const dynamic='force-dynamic';

export const metadata={title:'Kawan Rantau'};

async function getCommunities() {
    return await withPublicTransaction(async (tx) => {
        return await tx.select().from(communities);
    });
}

export default async function Page() {
    const communityRecords = await getCommunities().catch(() => []);

    return <div className="page">
        <PageHeader
            eyebrow="TEMUKAN · TERHUBUNG · BERTUMBUH"
            title="Kawan Rantau"
            description="Jelajahi komunitas yang tersedia tanpa membagikan lokasi presisi. Bergabung dan membuat komunitas belum tersedia dalam beta publik awal."
        />

        <SearchFilter placeholder="Cari komunitas, kota, atau minat…"/>

        <div className="cards-grid">
            {communityRecords.map((x:any,i:number)=>
                <article className="community-card" key={x.id}>
                    <div className={`cover c${i+1}`}>
                        <Users/>
                    </div>

                    <div className="card-body">
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

                        </div>
                    </div>
                </article>
            )}
            {!communityRecords.length && <EmptyState
                title="Belum ada komunitas yang dapat ditampilkan."
                description="Kawan Rantau saat ini menyediakan penemuan komunitas yang tersedia; pembuatan dan keanggotaan belum dibuka untuk beta publik awal."
            />}
        </div>

        <p className="privacy-note">
            <Lock size={16}/>
            Lokasi presisi anggota disembunyikan secara default.
        </p>
    </div>
}

