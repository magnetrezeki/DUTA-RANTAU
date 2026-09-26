import { malaysiaAppointmentEndpoints, type MalaysiaMissionInstitution } from '@/lib/official-source-registry';

export type MissionVerification = 'VERIFIED_CURRENT' | 'FOUNDER_CONFIRMED_PENDING_CURRENT_REVERIFY' | 'OFFICIAL_BUT_CURRENT_STATUS_UNCLEAR' | 'UNAVAILABLE';

export type MissionRecord = {
  id: string;
  name: string;
  city: string;
  state: string;
  serviceUrl: string;
  serviceType: string;
  servicePurpose: 'CONSULAR_SERVICE';
  serviceStatus: MissionVerification;
  founderApproval: 'APPROVED';
  runtimeEnabled: boolean;
  website: string;
  newsUrl: string;
  socials: Partial<Record<'facebook'|'instagram'|'x'|'youtube'|'tiktok', string>>;
  lastVerified: string;
};

const consularServiceEndpoints = new Map(malaysiaAppointmentEndpoints);
const consularServiceUrl = (institution: MalaysiaMissionInstitution) => {
  const url = consularServiceEndpoints.get(institution);
  if (!url) throw new Error(`Missing approved consular service endpoint for ${institution}`);
  return url;
};

// Founder/project associations are retained as the baseline. Status is kept
// separate from the URL so a reachable link is never presented as a fresh
// official verification without evidence.
export const malaysiaMissions: MissionRecord[] = [
  {id:'kbri-kl',name:'KBRI Kuala Lumpur',city:'Kuala Lumpur',state:'Wilayah Persekutuan',serviceUrl:consularServiceUrl('KBRI Kuala Lumpur'),serviceType:'Layanan konsuler / antrean',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/kualalumpur',newsUrl:'https://kemlu.go.id/kualalumpur/berita',socials:{instagram:'https://www.instagram.com/indonesiainkualalumpur/',facebook:'https://www.facebook.com/IndonesianEmbassyKualaLumpur',x:'https://x.com/kbrikualalumpur',youtube:'https://www.youtube.com/@kbrikualalumpur'},lastVerified:'2026-09-25'},
  {id:'kjri-jb',name:'KJRI Johor Bahru',city:'Johor Bahru',state:'Johor',serviceUrl:consularServiceUrl('KJRI Johor Bahru'),serviceType:'Pendaftaran layanan daring',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/johorbahru',newsUrl:'https://kemlu.go.id/johorbahru/berita',socials:{instagram:'https://www.instagram.com/indonesiainjb/',facebook:'https://www.facebook.com/IndonesianInJohorBahru'},lastVerified:'2026-09-25'},
  {id:'kjri-penang',name:'KJRI Penang',city:'George Town',state:'Pulau Pinang',serviceUrl:consularServiceUrl('KJRI Penang'),serviceType:'Layanan konsuler daring',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/penang',newsUrl:'https://kemlu.go.id/penang/berita',socials:{instagram:'https://www.instagram.com/indonesiainpenang/',facebook:'https://www.facebook.com/indonesiainpenang',x:'https://x.com/IndonesiaPenang',youtube:'https://www.youtube.com/@KJRIPenang',tiktok:'https://www.tiktok.com/@indonesiainpenang'},lastVerified:'2026-09-25'},
  {id:'kjri-kuching',name:'KJRI Kuching',city:'Kuching',state:'Sarawak',serviceUrl:consularServiceUrl('KJRI Kuching'),serviceType:'Layanan imigrasi',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/kuching',newsUrl:'https://kemlu.go.id/kuching/berita',socials:{instagram:'https://www.instagram.com/indonesiainkuching/',facebook:'https://www.facebook.com/kjrikuching'},lastVerified:'2026-09-25'},
  {id:'kjri-kk',name:'KJRI Kota Kinabalu',city:'Kota Kinabalu',state:'Sabah',serviceUrl:consularServiceUrl('KJRI Kota Kinabalu'),serviceType:'TEMAN BAIK / temu janji',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/kotakinabalu',newsUrl:'https://kemlu.go.id/kotakinabalu/berita',socials:{instagram:'https://www.instagram.com/indonesiainkotakinabalu/'},lastVerified:'2026-09-25'},
  {id:'kri-tawau',name:'KRI Tawau',city:'Tawau',state:'Sabah',serviceUrl:consularServiceUrl('KRI Tawau'),serviceType:'Temu janji / antrean layanan',servicePurpose:'CONSULAR_SERVICE',serviceStatus:'VERIFIED_CURRENT',founderApproval:'APPROVED',runtimeEnabled:true,website:'https://kemlu.go.id/tawau',newsUrl:'https://kemlu.go.id/tawau/berita',socials:{instagram:'https://www.instagram.com/indonesiaintawau/',facebook:'https://www.facebook.com/konsulatritawau',x:'https://x.com/indonesiaintwu'},lastVerified:'2026-09-25'},
];

export const infoCategories = [
  ['Pelayanan Perwakilan','Layanan, jadwal, dan pengumuman resmi dari enam misi RI.'],
  ['Pelindungan WNI','Kanal bantuan dan informasi keselamatan bersumber resmi.'],
  ['Kerja Aman','Panduan dan lowongan yang menunjuk sumber berwenang.'],
  ['Hidup di Malaysia','Dokumen, pendidikan, kesehatan, dan kehidupan harian.'],
] as const;
