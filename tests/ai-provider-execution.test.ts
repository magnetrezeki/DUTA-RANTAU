import { afterEach, describe, expect, it, vi } from 'vitest';

const state = vi.hoisted(() => ({
  calls: [] as string[],
  inputs: [] as Array<{ maxOutputTokens?: number }>,
  queues: {
    gemini: [] as unknown[],
    groq: [] as unknown[],
    openai: [] as unknown[],
  },
}));

vi.mock('@/lib/services/ai-provider-adapters', () => ({
  getConfiguredProvider: (name: 'gemini' | 'groq' | 'openai') => ({
    generate: async (input: { maxOutputTokens?: number }) => {
      state.calls.push(name);
      state.inputs.push(input);

      const next = state.queues[name].shift();

      if (next instanceof Error) throw next;

      return next ?? {
        success: true,
        text: `${name}-ok`,
        provider: name,
        latencyMs: 1,
      };
    },
    healthCheck: async () => true,
  }),
}));

const {
  executePlannedProvider,
  MAX_AI_OUTPUT_TOKENS,
} = await import('../lib/services/ai-provider-execution');

const failure = (
  category:
    | 'NETWORK_FAILURE'
    | 'PROVIDER_SERVER_FAILURE'
    | 'RATE_LIMIT_OR_QUOTA_FAILURE'
    | 'AUTHENTICATION_FAILURE'
    | 'TIMEOUT_FAILURE',
) => ({
  success: false,
  provider: 'fallback' as const,
  latencyMs: 1,
  errorCategory: category === 'TIMEOUT_FAILURE' ? 'TIMEOUT' as const : 'UNAVAILABLE' as const,
  _diagnosticCategory: category,
});

describe('planned provider resilient execution', () => {
  afterEach(() => {
    state.calls.length = 0;
    state.inputs.length = 0;
    state.queues.gemini.length = 0;
    state.queues.groq.length = 0;
    state.queues.openai.length = 0;
  });

  it('passes only the server-owned 300 token ceiling to the provider boundary', async () => {
    await executePlannedProvider('L1_SIMPLE', 'hello');

    expect(state.inputs[0]?.maxOutputTokens).toBeLessThanOrEqual(
      MAX_AI_OUTPUT_TOKENS,
    );
    expect(state.inputs[0]?.maxOutputTokens).toBe(300);
  });

  it('retries the PUBLIC primary once after a provider 5xx then succeeds', async () => {
    state.queues.gemini.push(
      failure('PROVIDER_SERVER_FAILURE'),
      {
        success: true,
        text: 'gemini-recovered',
        provider: 'gemini',
        latencyMs: 1,
      },
    );

    const result = await executePlannedProvider('L1_SIMPLE', 'hello');

    expect(result).toMatchObject({
      success: true,
      provider: 'gemini',
      text: 'gemini-recovered',
    });
    expect(state.calls).toEqual(['gemini', 'gemini']);
  });

  it('fails over immediately after PUBLIC rate limiting without retrying the primary', async () => {
    state.queues.gemini.push(
      failure('RATE_LIMIT_OR_QUOTA_FAILURE'),
    );
    state.queues.groq.push({
      success: true,
      text: 'groq-fallback',
      provider: 'groq',
      latencyMs: 1,
    });

    const result = await executePlannedProvider('L1_SIMPLE', 'hello');

    expect(result).toMatchObject({
      success: true,
      provider: 'groq',
      text: 'groq-fallback',
    });
    expect(state.calls).toEqual(['gemini', 'groq']);
  });

  it('fails over immediately after PUBLIC timeout without retrying the timed-out primary', async () => {
    state.queues.gemini.push(
      failure('TIMEOUT_FAILURE'),
    );
    state.queues.groq.push({
      success: true,
      text: 'groq-after-timeout',
      provider: 'groq',
      latencyMs: 1,
    });

    const result = await executePlannedProvider('L1_SIMPLE', 'hello');

    expect(result).toMatchObject({
      success: true,
      provider: 'groq',
      text: 'groq-after-timeout',
    });
    expect(state.calls).toEqual(['gemini', 'groq']);
  });

  it('can traverse the PUBLIC provider chain without repeating non-retryable failures', async () => {
    state.queues.gemini.push(
      failure('AUTHENTICATION_FAILURE'),
    );
    state.queues.groq.push(
      failure('RATE_LIMIT_OR_QUOTA_FAILURE'),
    );
    state.queues.openai.push({
      success: true,
      text: 'openai-final',
      provider: 'openai',
      latencyMs: 1,
    });

    const result = await executePlannedProvider('L1_SIMPLE', 'hello');

    expect(result).toMatchObject({
      success: true,
      provider: 'openai',
      text: 'openai-final',
    });
    expect(state.calls).toEqual(['gemini', 'groq', 'openai']);
  });

  it('never sends L3 sensitive or restricted content to Gemini or Groq', async () => {
    state.queues.openai.push(
      failure('AUTHENTICATION_FAILURE'),
    );

    const result = await executePlannedProvider(
      'L3_ESCALATION',
      'private document',
    );

    expect(result?.success).toBe(false);
    expect(state.calls).toEqual(['openai']);
    expect(state.calls).not.toContain('gemini');
    expect(state.calls).not.toContain('groq');
  });

  it('allows one bounded OpenAI retry for an eligible L3 server failure but no cross-provider fallback', async () => {
    state.queues.openai.push(
      failure('PROVIDER_SERVER_FAILURE'),
      failure('PROVIDER_SERVER_FAILURE'),
    );

    const result = await executePlannedProvider(
      'L3_ESCALATION',
      'private document',
    );

    expect(result?.success).toBe(false);
    expect(state.calls).toEqual(['openai', 'openai']);
    expect(state.calls).not.toContain('gemini');
    expect(state.calls).not.toContain('groq');
  });
});
