import { officialSources } from '@/lib/demo-data';
export type Intent='OFFICIAL_SERVICE'|'JOB_SEARCH'|'COMMUNITY_SEARCH'|'MARKETPLACE_SEARCH'|'ORGANIZATION'|'SAFETY'|'GENERAL';
export function detectIntent(message:string):Intent {
 const q=message.toLowerCase();
 if(/darurat|kekerasan|kecelakaan|hilang|ditipu|bantuan sekarang/.test(q)) return 'SAFETY';
 if(/paspor|konsuler|imigrasi|kjri|kbri|kri|dokumen|legalisasi|atase/.test(q)) return 'OFFICIAL_SERVICE';
 if(/kerja|lowongan|freelance|part.?time/.test(q)) return 'JOB_SEARCH';
 if(/komunitas|kawan|paguyuban|orang indonesia/.test(q)) return 'COMMUNITY_SEARCH';
 if(/produk|pasar|beli|penjual|jasa/.test(q)) return 'MARKETPLACE_SEARCH';
 if(/organisasi|rapat|anggota|surat undangan|kas/.test(q)) return 'ORGANIZATION';
 return 'GENERAL';
}
export function answerQuestion(message:string, location='Malaysia') {
 const intent=detectIntent(message);
 if(intent==='OFFICIAL_SERVICE'){
  const q=message.toLowerCase();
  let institution='KBRI Kuala Lumpur';
  if(q.includes('johor')) institution='KJRI Johor Bahru'; else if(q.includes('penang')) institution='KJRI Penang'; else if(q.includes('kuching')) institution='KJRI Kuching'; else if(q.includes('kinabalu')||q.includes('sabah')) institution='KJRI Kota Kinabalu'; else if(q.includes('tawau')) institution='KRI Tawau';
  const sources=officialSources.filter(s=>s.institution===institution && s.priority==='P0').slice(0,2);
  return {intent,confidence:'sedang',answer:`Untuk informasi resmi terkait pertanyaan Anda, silakan periksa kanal resmi ${institution}. Basis sumber yang tersedia belum memuat persyaratan, biaya, jam layanan, atau prosedur rinci yang telah divalidasi, jadi DUTA tidak akan menebaknya.`,steps:['Buka sumber resmi di bawah.','Cari pengumuman atau halaman layanan yang sesuai.','Pastikan tanggal, wilayah layanan, dan persyaratan langsung pada sumber resmi.'],sources,disclaimer:'DUTA RANTAU bukan institusi pemerintah dan tidak menggantikan keterangan resmi.'};
 }
 const responses:Record<Exclude<Intent,'OFFICIAL_SERVICE'>,string>={
  JOB_SEARCH:`Saya dapat membantu mencari lowongan di sekitar ${location}. Semua lowongan demo harus diperiksa langsung; DUTA RANTAU bukan agen pekerjaan.`,
  COMMUNITY_SEARCH:`Saya dapat membantu menemukan komunitas berdasarkan lokasi dan minat. Lokasi presisi anggota selalu disembunyikan secara default.`,
  MARKETPLACE_SEARCH:'Saya dapat membantu menjelajahi produk dan jasa komunitas. Periksa status penjual sebelum bertransaksi.',
  ORGANIZATION:'Permintaan ini terkait Kantor Digital. Data organisasi hanya dapat diakses sesuai peran dan izin anggota.',
  SAFETY:'Jika Anda dalam bahaya langsung, utamakan keselamatan dan hubungi layanan darurat atau perwakilan resmi yang relevan melalui kanal resminya. DUTA tidak memberikan diagnosis hukum atau medis.',
  GENERAL:'Saya belum menemukan informasi yang cukup terpercaya untuk menjawab pertanyaan ini. Coba sebutkan topik dan lokasi dengan lebih spesifik.'
 };
 return {intent,confidence:intent==='GENERAL'?'rendah':'sedang',answer:responses[intent],steps:[],sources:[],disclaimer:intent==='SAFETY'?'Panduan ini bukan keputusan medis atau hukum.':undefined};
}

