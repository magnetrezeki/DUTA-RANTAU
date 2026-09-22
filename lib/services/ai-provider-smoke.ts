import 'server-only';
import { getConfiguredProvider } from './ai-provider-adapters';

export type TextProviderName = 'gemini' | 'groq' | 'openai';
export const PROVIDER_SMOKE_PROMPT = 'Reply with exactly: DUTA_PROVIDER_SMOKE_OK';

export type ProviderSmokeResult = {
  provider: TextProviderName;
  requestAttempted: boolean;
  requestLeftApplication: boolean | null;
  providerResponded: boolean;
  expectedModel: string | null;
  effectiveModel: string | null;
  modelMatch: boolean | null;
  httpStatus: number | null;
  latencyMs: number;
  normalizedFailureClass: string | null;
  providerErrorCode: string | null;
  result: 'PASS' | 'CONTROLLED_UNAVAILABLE' | 'FAIL' | 'NOT_CONFIGURED';
};

export async function runTextProviderSmoke(provider: TextProviderName): Promise<ProviderSmokeResult> {
  const response = await getConfiguredProvider(provider).generate({ message: PROVIDER_SMOKE_PROMPT, channel: 'text', maxOutputTokens: 300 });
  const detail = response.diagnostics;
  const expectedModel = detail?.expectedModel || null;
  const effectiveModel = detail?.effectiveModel || null;
  const configured = detail?.requestAttempted === true;
  const exactSyntheticReply = response.success && response.text?.trim() === 'DUTA_PROVIDER_SMOKE_OK';
  return {
    provider,
    requestAttempted: detail?.requestAttempted ?? false,
    requestLeftApplication: detail?.requestLeftApplication ?? false,
    providerResponded: detail?.providerResponded ?? false,
    expectedModel,
    effectiveModel,
    modelMatch: expectedModel && effectiveModel ? expectedModel === effectiveModel : null,
    httpStatus: detail?.httpStatus ?? null,
    latencyMs: response.latencyMs,
    normalizedFailureClass: detail?.normalizedFailureClass ?? null,
    providerErrorCode: detail?.providerErrorCode ?? null,
    result: response.success ? exactSyntheticReply ? 'PASS' : 'FAIL' : configured ? 'CONTROLLED_UNAVAILABLE' : 'NOT_CONFIGURED',
  };
}
