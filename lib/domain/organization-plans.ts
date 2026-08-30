export type OrganizationPlanId='FREE'|'PLUS'|'PRO';
export type OrganizationEntitlement=
|'organization.page'|'announcement.manage'|'event.basic'|'member.view'|'officer.view'
|'member.manage'|'dues.manage'|'finance.manage'|'meeting.manage'|'letter.manage'|'archive.manage'|'attendance.manage'|'report.basic'|'ai.secretary'|'ai.treasurer'|'event.manage'|'publication.create'
|'admin.multiple'|'branch.multiple'|'report.advanced'|'brand.manage'|'promotion.manage'|'marketplace.manage'|'payment.integration'|'analytics.view'|'meeting.audio_summary';
export interface OrganizationPlan {id:OrganizationPlanId;name:string;priceMyr:number;period:'forever'|'month';description:string;featured?:boolean;features:string[];entitlements:OrganizationEntitlement[]}
const free:OrganizationEntitlement[]=['organization.page','announcement.manage','event.basic','member.view','officer.view'];
const plus:OrganizationEntitlement[]=[...free,'member.manage','dues.manage','finance.manage','meeting.manage','letter.manage','archive.manage','attendance.manage','report.basic','ai.secretary','ai.treasurer','event.manage','publication.create'];
export const organizationPlans:OrganizationPlan[]=[
{id:'FREE',name:'DUTA ORGANISASI',priceMyr:0,period:'forever',description:'Fondasi digital untuk setiap organisasi.',features:['Halaman organisasi','Pengumuman','Acara','Anggota','Pengurus'],entitlements:free},
{id:'PLUS',name:'DUTA ORGANISASI+',priceMyr:49.90,period:'month',description:'Administrasi dan staf virtual untuk organisasi aktif.',featured:true,features:['Administrasi anggota','Iuran dan kas','Rapat dan surat','Arsip dan absensi','Laporan','AI Sekretaris','AI Bendahara','Event management','Publikasi visual'],entitlements:plus},
{id:'PRO',name:'DUTA ORGANISASI PRO',priceMyr:99.90,period:'month',description:'Operasional, komunikasi, dan pertumbuhan skala lanjut.',features:['Semua fitur Organisasi+','Multi-admin','Multi-cabang','Laporan lanjutan','Branding organisasi','Promosi','Marketplace','Integrasi pembayaran','Analytics','Audio rapat ke transkrip dan ringkasan'],entitlements:[...plus,'admin.multiple','branch.multiple','report.advanced','brand.manage','promotion.manage','marketplace.manage','payment.integration','analytics.view','meeting.audio_summary']}
];
export function getOrganizationPlan(id:OrganizationPlanId){return organizationPlans.find(p=>p.id===id)!}
export function hasOrganizationEntitlement(plan:OrganizationPlanId,entitlement:OrganizationEntitlement){return getOrganizationPlan(plan).entitlements.includes(entitlement)}

