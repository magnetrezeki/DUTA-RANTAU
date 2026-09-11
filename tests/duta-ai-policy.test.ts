import { describe, expect, it } from 'vitest';
import { blockedDutaAiAnswer, DUTA_AI_SYSTEM_POLICY, routeDutaAiIntent } from '../lib/domain/duta-ai-policy';
import { consumeDutaAiQuota } from '../lib/services/duta-ai-fair-use';

describe('DUTA AI policy foundation',()=>{
 it('routes canonical intents and excludes investment',()=>{expect(routeDutaAiIntent('lowongan SISKOP2MI')).toMatchObject({intent:'employment',risk:'high'});expect(routeDutaAiIntent('beli saham')).toMatchObject({intent:'financial',risk:'out_of_scope'});expect(blockedDutaAiAnswer('out_of_scope')).toContain('tidak menyediakan');});
 it('centralizes policy against trust, mutation, placement, and injection',()=>{expect(DUTA_AI_SYSTEM_POLICY).toContain('Never grant verification');expect(DUTA_AI_SYSTEM_POLICY).toContain('candidate placement');expect(DUTA_AI_SYSTEM_POLICY).toContain('untrusted');});
 it('uses free configurable fair-use quota without a subscription gate',()=>{const a=consumeDutaAiQuota('test-a',0);expect(a).toMatchObject({allowed:true,limit:30,remaining:29});let result=a;for(let i=0;i<29;i++)result=consumeDutaAiQuota('test-a',0);expect(result.allowed).toBe(true);expect(consumeDutaAiQuota('test-a',0).allowed).toBe(false);});
});
