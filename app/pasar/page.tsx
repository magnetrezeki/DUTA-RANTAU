import { DemoBadge, PageHeader } from '@/components/ui';
import { SearchFilter } from '@/components/search-filter';
import { MapPin, Plus, Utensils, Palette, Package } from 'lucide-react';
import { products } from '@/db/schema';
import { withPublicTransaction } from '@/lib/db/identity-bridge';

const icons=[Utensils,Palette,Package];
type PublicListing={id:string;name:string;description:string;category:string;priceMyr:string|null;images:string[]|null;state:string|null;city:string|null;publishedAt:Date|null};
const publicListingFields={id:products.id,name:products.name,description:products.description,category:products.category,priceMyr:products.priceMyr,images:products.images,state:products.state,city:products.city,publishedAt:products.publishedAt};

export const dynamic='force-dynamic';
export const metadata={title:'Pasar Rantau'};

async function getProducts() {
  return withPublicTransaction(tx => tx.select(publicListingFields).from(products));
}

export default async function Page() {
  const listings = await getProducts().catch(() => []) as PublicListing[];
  return <div className="page">
    <PageHeader eyebrow="DARI KOMUNITAS, UNTUK KOMUNITAS" title="Pasar Rantau" description="Temukan produk dan jasa dari warga Indonesia di Malaysia." action={<button className="primary"><Plus/>Mulai berjualan</button>}/>
    <SearchFilter placeholder="Cari makanan, produk, atau jasa…"/>
    <div className="cards-grid market">
      {listings.map((listing,i)=>{
        const Icon=icons[i % icons.length];
        const location=[listing.city,listing.state].filter(Boolean).join(', ') || 'Area layanan tidak dicantumkan';
        return <article className="product-card" key={listing.id}>
          <div className={`product-image p${(i % icons.length)+1}`}><Icon/><DemoBadge/></div>
          <div className="card-body">
            <span className="category">{listing.category}</span>
            <h2>{listing.name}</h2>
            <p>{listing.description}</p>
            <p><MapPin/>{location}</p>
            <div className="card-foot"><b>{listing.priceMyr ?? 'Hubungi penjual'}</b></div>
          </div>
        </article>;
      })}
    </div>
  </div>;
}