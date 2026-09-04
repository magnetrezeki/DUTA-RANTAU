import { DemoBadge,PageHeader,TrustBadge } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { MapPin,Plus,Utensils,Palette,Package } from 'lucide-react';

const icons=[Utensils,Palette,Package];

export const metadata={title:'Pasar Rantau'};

async function getProducts() {
    const res = await fetch(
        `${process.env.NEXT_PUBLIC_APP_URL}/api/marketplace`,
        { cache: 'no-store' }
    );

    if (!res.ok) return [];

    const json = await res.json();
    return json.data ?? [];
}

export default async function Page() {
    const demoProducts = await getProducts();

    return <div className="page">
        <PageHeader
            eyebrow="DARI KOMUNITAS, UNTUK KOMUNITAS"
            title="Pasar Rantau"
            description="Temukan produk dan jasa dari warga Indonesia di Malaysia."
            action={<button className="primary"><Plus/>Mulai berjualan</button>}
        />

        <SearchFilter placeholder="Cari makanan, produk, atau jasa…"/>

        <div className="cards-grid market">
            {demoProducts.map((x:any,i:number)=>{
                const Icon=icons[i % icons.length];

                return <article className="product-card" key={x.id}>
                    <div className={`product-image p${(i % icons.length)+1}`}>
                        <Icon/>
                        <DemoBadge/>
                    </div>

                    <div className="card-body">
                        <span className="category">{x.category}</span>
                        <h2>{x.name}</h2>
                        <p className="seller">{x.seller}</p>

                        <p>
                            <MapPin/>{x.location}
                        </p>

                        <div className="card-foot">
                            <b>{x.price}</b>
                            <TrustBadge
                                level={x.trust==='MEMBER_SELLER'
                                    ? 'member'
                                    : 'unverified'}
                            />
                        </div>
                    </div>
                </article>
            })}
        </div>
    </div>
}
