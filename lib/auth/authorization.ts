import type { UserRole } from '@/types';
const hierarchy:UserRole[]=['GUEST','USER','MEMBER','VERIFIED_MEMBER','SELLER','ORG_STAFF','ORG_ADMIN','EDITOR','MODERATOR','SUPER_ADMIN'];
export function hasRole(actual:UserRole,minimum:UserRole){return hierarchy.indexOf(actual)>=hierarchy.indexOf(minimum)}
const base=['organization.view'];
export const orgRolePermissions:Record<string,string[]>={
 OWNER:[...base,'organization.edit','member.manage','event.manage','finance.view','finance.manage','document.manage','meeting.manage','letter.manage','ai.use','secretary.use','document.create','document.approve','publication.create','publication.edit','publication.approve','publication.publish','template.manage','brand.manage','subscription.manage'],
 ADMIN:[...base,'organization.edit','member.manage','event.manage','finance.view','document.manage','meeting.manage','letter.manage','ai.use','secretary.use','document.create','document.approve','publication.create','publication.edit','publication.approve','publication.publish','template.manage','brand.manage'],
 SECRETARY:[...base,'event.manage','document.manage','meeting.manage','letter.manage','ai.use','secretary.use','document.create','publication.create','publication.edit'],
 TREASURER:[...base,'finance.view','finance.manage','ai.use'],
 STAFF:[...base,'event.manage','document.manage','document.create','publication.create','publication.edit'],
 MEMBER:base
};
export function canInOrganization(role:string|undefined,permission:string){return !!role&&(orgRolePermissions[role]?.includes(permission)??false)}

