export const verificationTypes=['phone','identity','liveness','malaysia_presence','entity_registration','representative_authority','licence','official_source'] as const;
export const verificationStatuses=['not_started','pending','verified','rejected','expired','revoked','suspended'] as const;
export const verificationSources=['user_submitted','manual_review','official_registry','provider_assertion','system_check','admin_review'] as const;
export type VerificationType=typeof verificationTypes[number];export type VerificationStatus=typeof verificationStatuses[number];export type VerificationSource=typeof verificationSources[number];
export const isVerificationCurrent=(record:{status:VerificationStatus;expiresAt:Date|null},now=new Date())=>record.status==='verified'&&(!record.expiresAt||record.expiresAt>now);
