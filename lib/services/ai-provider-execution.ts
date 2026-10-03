import { getConfiguredProvider } from './ai-provider-adapters';

type ProviderName = 'gemini' | 'groq' | 'openai';
import type { ModelClass } from '@/lib/domain/ai-routing';
import type { AIProviderResult } from './ai-provider';

export const MAX_AI_OUTPUT_TOKENS = 300;
export const AI_PROVIDER_TIMEOUT_MS = 15_000;

const RETRYABLE_FAILURES = new Set([
  'NETWORK_FAILURE',
  'PROVIDER_SERVER_FAILURE',
]);

function primaryProvider(modelClass: ModelClass): ProviderName | undefined {
  if (modelClass === 'L1_SIMPLE') return 'gemini';
  if (modelClass === 'L2_ECONOMY') return 'groq';
  if (modelClass === 'L3_ESCALATION') return 'openai';
  return undefined;
}

function providerSequence(modelClass: ModelClass): ProviderName[] {
  if (modelClass === 'L1_SIMPLE') return ['gemini', 'groq', 'openai'];
  if (modelClass === 'L2_ECONOMY') return ['groq', 'gemini', 'openai'];

  // L3 is used for SENSITIVE / RESTRICTED content.
  // Never transmit it to Gemini or Groq as a fallback.
  if (modelClass === 'L3_ESCALATION') return ['openai'];

  return [];
}

async function invokeProvider(
  name: ProviderName,
  message: string,
): Promise<AIProviderResult> {
  let timeoutHandle: ReturnType<typeof setTimeout> | undefined;

  const timeout = new Promise<AIProviderResult>((resolve) => {
    timeoutHandle = setTimeout(
      () =>
        resolve({
          success: false,
          provider: 'fallback',
          latencyMs: AI_PROVIDER_TIMEOUT_MS,
          errorCategory: 'TIMEOUT',
          _diagnosticCategory: 'TIMEOUT_FAILURE',
        }),
      AI_PROVIDER_TIMEOUT_MS,
    );
  });

  try {
    return await Promise.race([
      getConfiguredProvider(name).generate({
        message,
        channel: 'text',
        maxOutputTokens: MAX_AI_OUTPUT_TOKENS,
      }),
      timeout,
    ]);
  } catch {
    return {
      success: false,
      provider: 'fallback',
      latencyMs: 0,
      errorCategory: 'UNAVAILABLE',
      _diagnosticCategory: 'NETWORK_FAILURE',
    };
  } finally {
    if (timeoutHandle) clearTimeout(timeoutHandle);
  }
}

function shouldRetrySameProvider(result: AIProviderResult): boolean {
  const failureClass =
    result.diagnostics?.normalizedFailureClass ??
    result._diagnosticCategory;

  return failureClass ? RETRYABLE_FAILURES.has(failureClass) : false;
}

export async function executePlannedProvider(
  modelClass: ModelClass,
  message: string,
): Promise<AIProviderResult | undefined> {
  const primary = primaryProvider(modelClass);
  if (!primary) return undefined;

  const providers = providerSequence(modelClass);
  let lastFailure: AIProviderResult | undefined;

  for (const provider of providers) {
    const firstAttempt = await invokeProvider(provider, message);

    if (firstAttempt.success) return firstAttempt;
    lastFailure = firstAttempt;

    // Only the primary provider receives one bounded same-provider retry,
    // and only for network/server failures. 429, timeout, auth,
    // entitlement, model and request-contract failures fail over directly.
    if (provider === primary && shouldRetrySameProvider(firstAttempt)) {
      const retry = await invokeProvider(provider, message);

      if (retry.success) return retry;
      lastFailure = retry;
    }
  }

  return (
    lastFailure ?? {
      success: false,
      provider: 'fallback',
      latencyMs: 0,
      errorCategory: 'UNAVAILABLE',
    }
  );
}
