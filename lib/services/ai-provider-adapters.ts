import 'server-only';
import type { AIProvider, AIProviderDiagnosticCategory, AIProviderDiagnostics, AIProviderInput, AIProviderResult } from './ai-provider';
import { DUTA_AI_SYSTEM_POLICY } from '@/lib/domain/duta-ai-policy';
import { isAllowedOpenAIModel } from '@/lib/domain/ai-routing';

type ProviderName = 'gemini' | 'groq' | 'openai';
const MAX_OUTPUT_TOKENS = 300;
const TRANSPORT_TIMEOUT_MS = 15_000;
const OPENAI_LUNA_MODEL = 'gpt-5.6-luna';
export const AUTHORIZED_GROQ_MODEL = 'openai/gpt-oss-20b';

function diagnostics(expectedModel: string, values: Partial<AIProviderDiagnostics> = {}): AIProviderDiagnostics {
  return { expectedModel, requestAttempted: false, requestLeftApplication: false, providerResponded: false, ...values };
}
function unavailable(expectedModel = ''): AIProviderResult { return { success: false, provider: 'fallback', latencyMs: 0, errorCategory: 'UNAVAILABLE', diagnostics: diagnostics(expectedModel) }; }
function safeProviderErrorCode(payload: unknown): string | undefined {
  if (typeof payload !== 'object' || payload === null || !('error' in payload) || typeof payload.error !== 'object' || payload.error === null || !('code' in payload.error)) return undefined;
  const code = (payload.error as { code?: unknown }).code;
  return typeof code === 'string' && /^[A-Za-z0-9_.-]{1,80}$/.test(code) ? code : undefined;
}
function authorizedMax(input: AIProviderInput) { return Math.min(Math.max(1, input.maxOutputTokens ?? MAX_OUTPUT_TOKENS), MAX_OUTPUT_TOKENS); }
function systemMessage() { return DUTA_AI_SYSTEM_POLICY; }

function httpStatusCategory(status: number): AIProviderDiagnosticCategory {
  if (status === 400) return 'REQUEST_CONTRACT_FAILURE';
  if (status === 401) return 'AUTHENTICATION_FAILURE';
  if (status === 403) return 'PERMISSION_OR_ENTITLEMENT_FAILURE';
  if (status === 404) return 'MODEL_OR_ENDPOINT_NOT_FOUND';
  if (status === 429) return 'RATE_LIMIT_OR_QUOTA_FAILURE';
  if (status >= 500 && status <= 599) return 'PROVIDER_SERVER_FAILURE';
  return 'UNKNOWN_FAILURE';
}

function transport(name: ProviderName, key: string, model: string): AIProvider {
  return {
    async generate(input) {
      if (input.channel !== 'text') return unavailable(model);
      const startedAt = Date.now(); const controller = new AbortController(); const timeout = setTimeout(() => controller.abort(), TRANSPORT_TIMEOUT_MS);
      const maxOutputTokens = authorizedMax(input);
      let diagnosticCategory: AIProviderDiagnosticCategory = 'UNKNOWN_FAILURE';
      try {
        let url: string; let headers: Record<string, string>; let body: unknown;
        if (name === 'gemini') {
          url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(key)}`;
          headers = { 'Content-Type': 'application/json' };
          body = { system_instruction: { parts: [{ text: systemMessage() }] }, contents: [{ role: 'user', parts: [{ text: input.message }] }], generationConfig: { maxOutputTokens } };
        } else {
          url = name === 'groq' ? 'https://api.groq.com/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions';
          headers = { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' };
          body = name === 'openai'
            ? { model, max_completion_tokens: maxOutputTokens, messages: [{ role: 'developer', content: systemMessage() }, { role: 'user', content: input.message }] }
            : { model, max_tokens: maxOutputTokens, messages: [{ role: 'system', content: systemMessage() }, { role: 'user', content: input.message }] };
        }
        const response = await fetch(url, { method: 'POST', headers, body: JSON.stringify(body), signal: controller.signal });
        if (!response.ok) {
          diagnosticCategory = httpStatusCategory(response.status);
          let providerErrorCode: string | undefined;
          try { providerErrorCode = safeProviderErrorCode(await response.json()); } catch { /* Raw response is intentionally discarded. */ }
          return { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: 'UNAVAILABLE', diagnostics: diagnostics(model, { httpStatus: response.status, providerErrorCode, normalizedFailureClass: diagnosticCategory, requestAttempted: true, requestLeftApplication: true, providerResponded: true }), _diagnosticCategory: diagnosticCategory };
        }
        let payload: unknown;
        try { payload = await response.json(); }
        catch {
          return { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: 'UNAVAILABLE', diagnostics: diagnostics(model, { httpStatus: response.status, normalizedFailureClass: 'RESPONSE_PARSE_FAILURE', requestAttempted: true, requestLeftApplication: true, providerResponded: true }), _diagnosticCategory: 'RESPONSE_PARSE_FAILURE' };
        }
        const text = name === 'gemini'
          ? (payload as { candidates?: Array<{ content?: { parts?: Array<{ text?: unknown }> } }> }).candidates?.[0]?.content?.parts?.[0]?.text
          : (payload as { choices?: Array<{ message?: { content?: unknown } }> }).choices?.[0]?.message?.content;
        if (typeof text !== 'string' || !text.trim()) {
          return { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: 'UNAVAILABLE', diagnostics: diagnostics(model, { httpStatus: response.status, normalizedFailureClass: 'RESPONSE_SCHEMA_FAILURE', requestAttempted: true, requestLeftApplication: true, providerResponded: true }), _diagnosticCategory: 'RESPONSE_SCHEMA_FAILURE' };
        }
        const returnedModel = typeof payload === 'object' && payload !== null
          ? name === 'gemini' && 'modelVersion' in payload && typeof payload.modelVersion === 'string' ? payload.modelVersion
            : 'model' in payload && typeof payload.model === 'string' ? payload.model : undefined
          : undefined;
        return { success: true, provider: name, model, text: text.trim(), latencyMs: Date.now() - startedAt, diagnostics: diagnostics(model, { effectiveModel: returnedModel, httpStatus: response.status, requestAttempted: true, requestLeftApplication: true, providerResponded: true }) };
      } catch (error) {
        if (error instanceof DOMException && error.name === 'AbortError') {
          diagnosticCategory = 'TIMEOUT_FAILURE';
        } else {
          diagnosticCategory = 'NETWORK_FAILURE';
        }
        return { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: 'UNAVAILABLE', diagnostics: diagnostics(model, { normalizedFailureClass: diagnosticCategory, requestAttempted: true, requestLeftApplication: null, providerResponded: false }), _diagnosticCategory: diagnosticCategory };
      } finally { clearTimeout(timeout); }
    },
    async healthCheck() { return false; },
  };
}

export function getConfiguredProvider(name: ProviderName): AIProvider {
  const key = process.env[`${name.toUpperCase()}_API_KEY`];
  const configuredModel = process.env[`${name.toUpperCase()}_MODEL`];
  const model = name === 'openai' ? OPENAI_LUNA_MODEL : name === 'groq' ? AUTHORIZED_GROQ_MODEL : configuredModel;
  const validModel = name === 'groq' ? (!configuredModel?.trim() || configuredModel === AUTHORIZED_GROQ_MODEL) : name === 'openai' ? isAllowedOpenAIModel(configuredModel ?? OPENAI_LUNA_MODEL) : Boolean(model?.trim());
  if (!key?.trim() || !model?.trim() || !validModel) return { generate: async () => unavailable(model ?? ''), healthCheck: async () => false };
  return transport(name, key, model);
}
