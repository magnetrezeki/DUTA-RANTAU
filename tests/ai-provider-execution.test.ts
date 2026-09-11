import { afterEach, describe, expect, it, vi } from 'vitest';

const state = vi.hoisted(() => ({ calls: 0, input: undefined as { maxOutputTokens?: number } | undefined, generate: undefined as (() => Promise<unknown>) | undefined }));
vi.mock('@/lib/services/ai-provider-adapters', () => ({ getConfiguredProvider: () => ({
  generate: async (input: { maxOutputTokens?: number }) => { state.calls += 1; state.input = input; return state.generate ? state.generate() : { success: true, text: 'ok', provider: 'fallback', latencyMs: 1 }; },
  healthCheck: async () => true,
}) }));

const { executePlannedProvider, AI_PROVIDER_TIMEOUT_MS, MAX_AI_OUTPUT_TOKENS } = await import('../lib/services/ai-provider-execution');

describe('planned provider execution hardening', () => {
  afterEach(() => { state.calls = 0; state.input = undefined; state.generate = undefined; vi.useRealTimers(); });
  it('passes only the server-owned 300 token ceiling to the provider boundary', async () => {
    await executePlannedProvider('L3_ESCALATION', 'hello'); expect(state.calls).toBe(1); expect(state.input?.maxOutputTokens).toBeLessThanOrEqual(MAX_AI_OUTPUT_TOKENS); expect(state.input?.maxOutputTokens).toBe(300);
  });
  it('times out one selected provider invocation without retry or fallback', async () => {
    vi.useFakeTimers(); state.generate = () => new Promise(() => undefined);
    const pending = executePlannedProvider('L2_ECONOMY', 'hello'); await vi.advanceTimersByTimeAsync(AI_PROVIDER_TIMEOUT_MS);
    await expect(pending).resolves.toMatchObject({ success: false, errorCategory: 'TIMEOUT' }); expect(state.calls).toBe(1);
  });
});