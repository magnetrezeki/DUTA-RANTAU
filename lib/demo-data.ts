import type { Community, DemoJob, OfficialSource, Organization, Product } from '@/types';

const checked='2026-08-16';
const raw:[string,string,string,string,'P0'|'P1'][]=[
['KBRI Kuala Lumpur','Situs resmi','https://kemlu.go.id/kualalumpur','kantor, konsuler, perlindungan, imigrasi','P0'],
['KBRI Kuala Lumpur','Instagram','https://www.instagram.com/indonesiainkualalumpur/','pengumuman, konsuler, perlindungan, imigrasi','P0'],
['KBRI Kuala Lumpur','Facebook','https://www.facebook.com/IndonesianEmbassyKualaLumpur/','pengumuman, konsuler, perlindungan','P0'],
['KBRI Kuala Lumpur','X','https://x.com/kbrikualalumpur','informasi resmi dan konsuler','P1'],
['KBRI Kuala Lumpur','YouTube','https://www.youtube.com/@kbrikualalumpur','informasi resmi dan konsuler','P1'],
['KJRI Johor Bahru','Situs resmi','https://kemlu.go.id/johorbahru','kantor, konsuler, imigrasi, perlindungan, komunitas','P0'],
['KJRI Johor Bahru','Instagram','https://www.instagram.com/indonesiainjb/','layanan dan pengumuman resmi','P0'],
['KJRI Johor Bahru','Facebook','https://www.facebook.com/IndonesianInJohorBahru/','layanan, perlindungan, komunitas','P0'],
['KJRI Penang','Situs resmi','https://kemlu.go.id/penang','kantor, konsuler, imigrasi, perlindungan, komunitas','P0'],
['KJRI Penang','Instagram','https://www.instagram.com/indonesiainpenang/','pengumuman dan layanan resmi','P0'],
['KJRI Penang','Facebook','https://www.facebook.com/indonesiainpenang/','layanan, perlindungan, komunitas','P0'],
['KJRI Penang','X','https://x.com/IndonesiaPenang','informasi konsuler dan peringatan lokal','P1'],
['KJRI Penang','YouTube','https://www.youtube.com/channel/UCQ6aLdnF6UFNDjP-1_QqHpw','publikasi layanan dan informasi resmi','P1'],
['KJRI Kota Kinabalu','Situs resmi','https://kemlu.go.id/kotakinabalu','kantor, konsuler, imigrasi, perlindungan, komunitas','P0'],
['KJRI Kota Kinabalu','Instagram','https://www.instagram.com/indonesiainkotakinabalu/','layanan dan pengumuman resmi','P0'],
['KJRI Kuching','Situs resmi','https://kemlu.go.id/kuching','kantor, konsuler, imigrasi, perlindungan, komunitas','P0'],
['KJRI Kuching','Instagram','https://www.instagram.com/indonesiainkuching/','layanan dan pengumuman resmi','P0'],
['KJRI Kuching','Facebook','https://www.facebook.com/kjrikuching/','layanan, perlindungan, komunitas','P0'],
['KRI Tawau','Situs resmi','https://kemlu.go.id/tawau','kantor, konsuler, imigrasi, perlindungan, komunitas','P0'],
['KRI Tawau','Instagram','https://www.instagram.com/indonesiaintawau/','layanan dan pengumuman resmi','P0'],
['KRI Tawau','Facebook','https://www.facebook.com/konsulatritawau/','layanan, perlindungan, komunitas','P0'],
['KRI Tawau','X','https://x.com/indonesiaintwu','konsuler, imigrasi, perlindungan, komunitas','P1'],
['Atase Tenaga Kerja','Instagram','https://www.instagram.com/atnaker.kl/','pekerja migran, ketenagakerjaan, perlindungan, repatriasi','P0'],
['Atase Hukum','Instagram','https://www.instagram.com/atkum.kualalumpur/','hukum, perlindungan, bantuan hukum','P0'],
['Atase Pendidikan dan Kebudayaan','Instagram','https://www.instagram.com/atdikbud_kualalumpur/','pendidikan, pelajar, beasiswa, kebudayaan','P0'],
['Atase Perhubungan','Instagram','https://www.instagram.com/ataseperhubungan.kl/','transportasi, pelaut, perjalanan','P0'],
['Atase Perdagangan','Instagram','https://www.instagram.com/atdag.kualalumpur/','perdagangan, bisnis, ekspor, ekonomi','P1'],
];
export const officialSources:OfficialSource[]=raw.map((r,i)=>({id:`src-${i+1}`,institution:r[0],channel:r[1],url:r[2],category:r[3],priority:r[4],status:'VERIFIED',lastChecked:checked}));
export const demoJobs:DemoJob[]=[
{id:'job-1',title:'Staf Operasional Restoran',employer:'Kedai Nusantara (DEMO)',location:'Shah Alam, Selangor',type:'Penuh waktu',salary:'Tidak dicantumkan',verification:'UNVERIFIED',posted:'Hari ini',demo:true},
{id:'job-2',title:'Desainer Konten Lepas',employer:'Studio Komunitas (DEMO)',location:'Remote · Malaysia',type:'Freelance',verification:'COMMUNITY_VERIFIED',posted:'2 hari lalu',demo:true},
{id:'job-3',title:'Asisten Acara Akhir Pekan',employer:'Rantau Event (DEMO)',location:'Kuala Lumpur',type:'Paruh waktu',salary:'Tidak dicantumkan',verification:'UNVERIFIED',posted:'4 hari lalu',demo:true},
];
export const demoCommunities:Community[]=[
{id:'com-1',name:'Komunitas Pelajar Indonesia KL (DEMO)',category:'Pelajar',location:'Kuala Lumpur',members:128,visibility:'PUBLIC',demo:true},
{id:'com-2',name:'Rantau Kuliner Nusantara (DEMO)',category:'Kuliner',location:'Selangor',members:84,visibility:'PUBLIC',demo:true},
{id:'com-3',name:'Profesional Indonesia Malaysia (DEMO)',category:'Profesi',location:'Malaysia',members:214,visibility:'COMMUNITY_ONLY',demo:true},
];
export const demoProducts:Product[]=[
{id:'prd-1',name:'Katering Nasi Kotak (DEMO)',seller:'Dapur Rantau (DEMO)',category:'Makanan',location:'Kuala Lumpur',price:'Harga hubungi penjual',trust:'NEW_SELLER',demo:true},
{id:'prd-2',name:'Jasa Desain Poster (DEMO)',seller:'Kreasi Kita (DEMO)',category:'Jasa digital',location:'Remote',price:'Harga hubungi penjual',trust:'MEMBER_SELLER',demo:true},
{id:'prd-3',name:'Produk Nusantara (DEMO)',seller:'Warung Kita (DEMO)',category:'Produk Indonesia',location:'Petaling Jaya',price:'Harga hubungi penjual',trust:'NEW_SELLER',demo:true},
];
export const demoOrganizations:Organization[]=[
{id:'org-1',name:'Paguyuban Rantau Bersama (DEMO)',type:'Paguyuban',location:'Kuala Lumpur',members:46,role:'Sekretaris',demo:true},
{id:'org-2',name:'Jejaring Wirausaha Indonesia (DEMO)',type:'Komunitas bisnis',location:'Selangor',members:72,role:'Anggota',demo:true},
];

