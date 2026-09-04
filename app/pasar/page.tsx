import { DemoBadge,PageHeader,TrustBadge } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { MapPin,Plus,Utensils,Palette,Package } from 'lucide-react';
import { products } from '@/db/schema';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

const icons=[Utensils,Palette,Package];

export const dynamic='force-dynamic';

export const metadata={title:'Pasar Rantau'};

async function getProducts() {
    return await withPublicTransaction(async (tx) => {
        return await tx.select().from(products);
    });
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

