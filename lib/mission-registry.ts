export type MissionVerification = 'VERIFIED_CURRENT' | 'FOUNDER_CONFIRMED_PENDING_CURRENT_REVERIFY' | 'OFFICIAL_BUT_CURRENT_STATUS_UNCLEAR' | 'UNAVAILABLE';

export type MissionRecord = {
  id: string;
  name: string;
  city: string;
  state: string;
  serviceUrl: string;
  serviceType: string;
  serviceStatus: MissionVerification;
  runtimeEnabled: boolean;
  website: string;
  newsUrl: string;
  socials: Partial<Record<'facebook'|'instagram'|'x'|'youtube'|'tiktok', string>>;
  lastVerified: string;
};

// Founder/project associations are retained as the baseline. Status is kept
// separate from the URL so a reachable link is never presented as a fresh
// official verification without evidence.
export const malaysiaMissions: MissionRecord[] = [
  {id:'kbri-kl',name:'KBRI Kuala Lumpur',city:'Kuala Lumpur',state:'Wilayah Persekutuan',serviceUrl:'https://antrean.kbrikl.id/',serviceType:'Layanan konsuler / antrean',serviceStatus:'FOUNDER_CONFIRMED_PENDING_CURRENT_REVERIFY',runtimeEnabled:false,website:'https://kemlu.go.id/kualalumpur',newsUrl:'https://kemlu.go.id/kualalumpur/berita',socials:{instagram:'https://www.instagram.com/indonesiainkualalumpur/',facebook:'https://www.facebook.com/IndonesianEmbassyKualaLumpur',x:'https://x.com/kbrikualalumpur',youtube:'https://www.youtube.com/@kbrikualalumpur'},lastVerified:'2026-09-21'},
  {id:'kjri-jb',name:'KJRI Johor Bahru',city:'Johor Bahru',state:'Johor',serviceUrl:'https://daftaronline.indonesiainjb.my/',serviceType:'Pendaftaran layanan daring',serviceStatus:'VERIFIED_CURRENT',runtimeEnabled:true,website:'https://kemlu.go.id/johorbahru',newsUrl:'https://kemlu.go.id/johorbahru/berita',socials:{instagram:'https://www.instagram.com/indonesiainjb/',facebook:'https://www.facebook.com/IndonesianInJohorBahru'},lastVerified:'2026-09-21'},
  {id:'kjri-penang',name:'KJRI Penang',city:'George Town',state:'Pulau Pinang',serviceUrl:'https://layananonline.kjripenang.my/',serviceType:'Layanan konsuler daring',serviceStatus:'VERIFIED_CURRENT',runtimeEnabled:true,website:'https://kemlu.go.id/penang',newsUrl:'https://kemlu.go.id/penang/berita',socials:{instagram:'https://www.instagram.com/indonesiainpenang/',facebook:'https://www.facebook.com/indonesiainpenang',x:'https://x.com/IndonesiaPenang',youtube:'https://www.youtube.com/@KJRIPenang',tiktok:'https://www.tiktok.com/@indonesiainpenang'},lastVerified:'2026-09-21'},
  {id:'kjri-kuching',name:'KJRI Kuching',city:'Kuching',state:'Sarawak',serviceUrl:'https://imigrasi.synergize.co/?i=1',serviceType:'Layanan imigrasi',serviceStatus:'FOUNDER_CONFIRMED_PENDING_CURRENT_REVERIFY',runtimeEnabled:false,website:'https://kemlu.go.id/kuching',newsUrl:'https://kemlu.go.id/kuching/berita',socials:{instagram:'https://www.instagram.com/indonesiainkuching/',facebook:'https://www.facebook.com/kjrikuching'},lastVerified:'2026-09-21'},
  {id:'kjri-kk',name:'KJRI Kota Kinabalu',city:'Kota Kinabalu',state:'Sabah',serviceUrl:'https://teman-baik.kjrikk.com/',serviceType:'TEMAN BAIK / temu janji',serviceStatus:'VERIFIED_CURRENT',runtimeEnabled:true,website:'https://kemlu.go.id/kotakinabalu',newsUrl:'https://kemlu.go.id/kotakinabalu/berita',socials:{instagram:'https://www.instagram.com/indonesiainkotakinabalu/'},lastVerified:'2026-09-21'},
  {id:'kri-tawau',name:'KRI Tawau',city:'Tawau',state:'Sabah',serviceUrl:'https://www.temujanjiantrianpelayanankritawau.org/dl/b1edeb',serviceType:'Temu janji / antrean layanan',serviceStatus:'FOUNDER_CONFIRMED_PENDING_CURRENT_REVERIFY',runtimeEnabled:false,website:'https://kemlu.go.id/tawau',newsUrl:'https://kemlu.go.id/tawau/berita',socials:{instagram:'https://www.instagram.com/indonesiaintawau/',facebook:'https://www.facebook.com/konsulatritawau',x:'https://x.com/indonesiaintwu'},lastVerified:'2026-09-21'},
];

export const infoCategories = [
  ['Pelayanan Perwakilan','Layanan, jadwal, dan pengumuman resmi dari enam misi RI.'],
  ['Pelindungan WNI','Kanal bantuan dan informasi keselamatan bersumber resmi.'],
  ['Kerja Aman','Panduan dan lowongan yang menunjuk sumber berwenang.'],
  ['Hidup di Malaysia','Dokumen, pendidikan, kesehatan, dan kehidupan harian.'],
] as const;
