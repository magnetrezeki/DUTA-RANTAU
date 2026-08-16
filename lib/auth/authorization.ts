import type { UserRole } from '@/types';
const hierarchy:UserRole[]=['GUEST','USER','MEMBER','VERIFIED_MEMBER','SELLER','ORG_STAFF','ORG_ADMIN','EDITOR','MODERATOR','SUPER_ADMIN'];
export function hasRole(actual:UserRole,minimum:UserRole){return hierarchy.indexOf(actual)>=hierarchy.indexOf(minimum);}
export const orgRolePermissions:Record<string,string[]>={
 OWNER:['organization.view','organization.edit','member.manage','event.manage','finance.view','finance.manage','document.manage','meeting.manage','letter.manage','ai.use'],
 ADMIN:['organization.view','organization.edit','member.manage','event.manage','finance.view','document.manage','meeting.manage','letter.manage','ai.use'],
 SECRETARY:['organization.view','event.manage','document.manage','meeting.manage','letter.manage','ai.use'],
 TREASURER:['organization.view','finance.view','finance.manage','ai.use'],
 STAFF:['organization.view','event.manage','document.manage'], MEMBER:['organization.view']
};
export function canInOrganization(role:string|undefined,permission:string){return !!role && (orgRolePermissions[role]?.includes(permission)??false);}
