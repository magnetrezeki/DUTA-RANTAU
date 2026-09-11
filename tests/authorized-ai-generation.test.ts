import { describe, expect, it, vi } from 'vitest';
import { runAuthorizedGeneration } from '../lib/services/authorized-ai-generation';

describe('authorized AI generation ordering', () => {
  it('calls a provider only after an allowed quota decision for every non-L0 class', async () => {
    for (const modelClass of ['L1_SIMPLE', 'L2_ECONOMY', 'L3_ESCALATION'] as const) {
      const calls: string[] = [];
      const result = await runAuthorizedGeneration({ modelClass, deterministic: async () => 0, consume: async () => { calls.push('quota'); return 'allowed'; }, generate: async () => { calls.push('provider'); return 1; } });
      expect(result).toEqual({ status: 'generated', value: 1 });
      expect(calls).toEqual(['quota', 'provider']);
    }
  });
  it('fails closed without invoking a provider on quota denial or error', async () => {
    for (const quota of ['denied', 'error'] as const) {
      const provider = vi.fn();
      const result = await runAuthorizedGeneration({ modelClass: 'L2_ECONOMY', deterministic: async () => 0, consume: async () => quota, generate: provider });
      expect(result.status).toBe(quota === 'denied' ? 'quota_denied' : 'quota_error'); expect(provider).not.toHaveBeenCalled();
    }
  });
  it('keeps L0 deterministic and zero-provider', async () => {
    const provider = vi.fn(); const consume = vi.fn();
    const result = await runAuthorizedGeneration({ modelClass: 'L0_DETERMINISTIC', deterministic: async () => 1, consume, generate: provider });
    expect(result).toEqual({ status: 'deterministic', value: 1 }); expect(consume).not.toHaveBeenCalled(); expect(provider).not.toHaveBeenCalled();
  });
});
