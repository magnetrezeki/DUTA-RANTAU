import { afterEach, describe, expect, it, vi } from 'vitest';

const generate = vi.fn();
vi.mock('@/lib/services/ai-provider-adapters', () => ({ getConfiguredProvider: () => ({ generate, healthCheck: async () => false }) }));

const { PROVIDER_SMOKE_PROMPT, runTextProviderSmoke } = await import('../lib/services/ai-provider-smoke');

afterEach(() => generate.mockReset());

describe('controlled provider smoke normalization', () => {
  it('uses only the fixed synthetic prompt and invokes the selected adapter once', async () => {
    generate.mockResolvedValue({ success: true, provider: 'openai', model: 'gpt-5.6-luna', text: 'DUTA_PROVIDER_SMOKE_OK', latencyMs: 12, diagnostics: { expectedModel: 'gpt-5.6-luna', effectiveModel: 'gpt-5.6-luna', httpStatus: 200, requestAttempted: true, requestLeftApplication: true, providerResponded: true } });
    await expect(runTextProviderSmoke('openai')).resolves.toMatchObject({ provider: 'openai', result: 'PASS', modelMatch: true, httpStatus: 200 });
    expect(generate).toHaveBeenCalledTimes(1);
    expect(generate).toHaveBeenCalledWith({ message: PROVIDER_SMOKE_PROMPT, channel: 'text', maxOutputTokens: 300 });
    expect(PROVIDER_SMOKE_PROMPT).toBe('Reply with exactly: DUTA_PROVIDER_SMOKE_OK');
  });

  it('returns safe normalized failure fields without response text', async () => {
    generate.mockResolvedValue({ success: false, provider: 'fallback', latencyMs: 9, errorCategory: 'UNAVAILABLE', diagnostics: { expectedModel: 'gpt-5.6-luna', httpStatus: 401, providerErrorCode: 'invalid_api_key', normalizedFailureClass: 'AUTHENTICATION_FAILURE', requestAttempted: true, requestLeftApplication: true, providerResponded: true } });
    const result = await runTextProviderSmoke('openai');
    expect(result).toMatchObject({ result: 'CONTROLLED_UNAVAILABLE', httpStatus: 401, providerErrorCode: 'invalid_api_key', normalizedFailureClass: 'AUTHENTICATION_FAILURE' });
    expect(JSON.stringify(result)).not.toContain('text');
  });

  it('distinguishes missing configuration before a request', async () => {
    generate.mockResolvedValue({ success: false, provider: 'fallback', latencyMs: 0, errorCategory: 'UNAVAILABLE', diagnostics: { expectedModel: 'gpt-5.6-luna', requestAttempted: false, requestLeftApplication: false, providerResponded: false } });
    await expect(runTextProviderSmoke('openai')).resolves.toMatchObject({ result: 'NOT_CONFIGURED', requestAttempted: false });
  });
  it('fails a successful transport that does not follow the synthetic response contract', async () => {
    generate.mockResolvedValue({ success: true, provider: 'gemini', model: 'gemini-test', text: 'different output', latencyMs: 5, diagnostics: { expectedModel: 'gemini-test', httpStatus: 200, requestAttempted: true, requestLeftApplication: true, providerResponded: true } });
    await expect(runTextProviderSmoke('gemini')).resolves.toMatchObject({ result: 'FAIL', httpStatus: 200 });
  });
});
