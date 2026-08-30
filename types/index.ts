export type TrustLevel = 'OFFICIAL_VERIFIED' | 'INSTITUTION_VERIFIED' | 'DUTA_VERIFIED' | 'COMMUNITY_VERIFIED' | 'USER_GENERATED';
export type UserRole = 'GUEST' | 'USER' | 'MEMBER' | 'VERIFIED_MEMBER' | 'SELLER' | 'ORG_ADMIN' | 'ORG_STAFF' | 'MODERATOR' | 'EDITOR' | 'SUPER_ADMIN';
export interface OfficialSource { id: string; institution: string; channel: string; url: string; category: string; priority: 'P0'|'P1'; status: 'VERIFIED'|'DISABLED'; lastChecked: string; }
export interface DemoJob { id:string; title:string; employer:string; location:string; type:string; salary?:string; verification:'COMMUNITY_VERIFIED'|'UNVERIFIED'; posted:string; demo:true; }
export interface Community { id:string; name:string; category:string; location:string; members:number; visibility:'PUBLIC'|'COMMUNITY_ONLY'; demo:true; }
export interface Product { id:string; name:string; seller:string; category:string; location:string; price:string; trust:string; demo:true; }
export interface Organization { id:string; name:string; type:string; location:string; members:number; role?:string; demo:true; }

