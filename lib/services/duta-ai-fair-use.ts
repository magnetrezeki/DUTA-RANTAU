const limit=30; const periodMs=60*60*1000; const entries=new Map<string,{count:number;resetAt:number}>();
export function consumeDutaAiQuota(subject:string,now=Date.now()){const current=entries.get(subject);const state=!current||current.resetAt<=now?{count:0,resetAt:now+periodMs}:current;if(state.count>=limit)return{allowed:false,limit,remaining:0,resetAt:new Date(state.resetAt).toISOString()};state.count++;entries.set(subject,state);return{allowed:true,limit,remaining:limit-state.count,resetAt:new Date(state.resetAt).toISOString()};}
export const dutaAiFairUse={limit,periodMs};
