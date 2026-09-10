export const presenceStatuses=['pending','verified','failed','expired','revoked'] as const;
export const presenceMethods=['malaysian_phone','device_location','manual_review','provider_assertion'] as const;
export const responsiblePersonStatuses=['pending','active','inactive','revoked'] as const;
export type PresenceStatus=typeof presenceStatuses[number];
export type PresenceMethod=typeof presenceMethods[number];
export type ResponsiblePersonStatus=typeof responsiblePersonStatuses[number];
export const isMalaysiaPresenceCurrent=(check:{countryCode:string;status:PresenceStatus;expiresAt:Date|null},now=new Date())=>check.countryCode==='MY'&&check.status==='verified'&&(!check.expiresAt||check.expiresAt>now);
