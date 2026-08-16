import { hash, verify } from '@node-rs/argon2';
export async function hashPassword(password:string){return hash(password,{memoryCost:19456,timeCost:2,parallelism:1});}
export async function verifyPassword(hashValue:string,password:string){return verify(hashValue,password);}
export function validatePassword(value:string){return value.length>=10 && /[A-Za-z]/.test(value) && /\d/.test(value);}
