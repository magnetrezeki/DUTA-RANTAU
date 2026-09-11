import 'server-only';
import type { AIProvider, AIProviderInput, AIProviderResult } from './ai-provider';
import { DUTA_AI_SYSTEM_POLICY } from '@/lib/domain/duta-ai-policy';
import { isAllowedOpenAIModel } from '@/lib/domain/ai-routing';

type ProviderName = 'gemini' | 'groq' | 'openai';
const MAX_OUTPUT_TOKENS = 300;
const TRANSPORT_TIMEOUT_MS = 15_000;
const OPENAI_LUNA_MODEL = 'gpt-5.6-luna';

function unavailable(): AIProviderResult { return { success: false, provider: 'fallback', latencyMs: 0, errorCategory: 'UNAVAILABLE' }; }
function textResult(provider: 'gemini' | 'groq' | 'openai', model: string, text: unknown, startedAt: number): AIProviderResult {
  return typeof text === 'string' && text.trim() ? { success: true, provider, model, text: text.trim(), latencyMs: Date.now() - startedAt } : { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: 'INVALID_RESPONSE' };
}
function authorizedMax(input: AIProviderInput) { return Math.min(Math.max(1, input.maxOutputTokens ?? MAX_OUTPUT_TOKENS), MAX_OUTPUT_TOKENS); }
function systemMessage() { return DUTA_AI_SYSTEM_POLICY; }

function transport(name: ProviderName, key: string, model: string): AIProvider {
  return {
    async generate(input) {
      if (input.channel !== 'text') return unavailable();
      const startedAt = Date.now(); const controller = new AbortController(); const timeout = setTimeout(() => controller.abort(), TRANSPORT_TIMEOUT_MS);
      const maxOutputTokens = authorizedMax(input);
      try {
        let url: string; let headers: Record<string, string>; let body: unknown;
        if (name === 'gemini') {
          url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(key)}`;
          headers = { 'Content-Type': 'application/json' };
          body = { system_instruction: { parts: [{ text: systemMessage() }] }, contents: [{ role: 'user', parts: [{ text: input.message }] }], generationConfig: { maxOutputTokens } };
        } else {
          url = name === 'groq' ? 'https://api.groq.com/openai/v1/chat/completions' : 'https://api.openai.com/v1/chat/completions';
          headers = { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' };
          body = { model, max_tokens: maxOutputTokens, messages: [{ role: 'system', content: systemMessage() }, { role: 'user', content: input.message }] };
        }
        const response = await fetch(url, { method: 'POST', headers, body: JSON.stringify(body), signal: controller.signal });
        if (!response.ok) return unavailable();
        const payload: unknown = await response.json();
        const text = name === 'gemini'
          ? (payload as { candidates?: Array<{ content?: { parts?: Array<{ text?: unknown }> } }> }).candidates?.[0]?.content?.parts?.[0]?.text
          : (payload as { choices?: Array<{ message?: { content?: unknown } }> }).choices?.[0]?.message?.content;
        return textResult(name, model, text, startedAt);
      } catch (error) {
        return { success: false, provider: 'fallback', latencyMs: Date.now() - startedAt, errorCategory: error instanceof DOMException && error.name === 'AbortError' ? 'TIMEOUT' : 'UNAVAILABLE' };
      } finally { clearTimeout(timeout); }
    },
    async healthCheck() { return false; },
  };
}

export function getConfiguredProvider(name: ProviderName): AIProvider {
  const key = process.env[`${name.toUpperCase()}_API_KEY`];
  const configuredModel = process.env[`${name.toUpperCase()}_MODEL`];
  const model = name === 'openai' ? OPENAI_LUNA_MODEL : configuredModel;
  if (!key?.trim() || !model?.trim() || (name === 'openai' && !isAllowedOpenAIModel(configuredModel ?? OPENAI_LUNA_MODEL))) return { generate: async () => unavailable(), healthCheck: async () => false };
  return transport(name, key, model);
}