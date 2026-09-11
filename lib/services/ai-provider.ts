import "server-only";
import { DUTA_AI_SYSTEM_POLICY } from '@/lib/domain/duta-ai-policy';

export type AIChannel = "text" | "voice";
export type AIErrorCategory = "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE";
export type AIProviderResult = {
  success: boolean;
  provider: "fallback" | "nvidia";
  model?: string;
  text?: string;
  latencyMs: number;
  errorCategory?: AIErrorCategory;
};
export type AIProviderInput = { message: string; channel: AIChannel };
export interface AIProvider { generate(input: AIProviderInput): Promise<AIProviderResult>; healthCheck(): Promise<boolean>; }

const DEFAULT_BASE_URL = "https://integrate.api.nvidia.com/v1";
const DEFAULT_MODEL = "meta/llama-3.1-8b-instruct";
const REQUEST_TIMEOUT_MS = 10_000;

function fallback(errorCategory: AIErrorCategory, latencyMs = 0): AIProviderResult {
  return { success: false, provider: "fallback", latencyMs, errorCategory };
}

function languageInstruction(message: string) {
  const malay = /\b(apa khabar|boleh|saya|awak|tak|dengan|untuk|di mana|kerja)\b/i.test(message);
  return malay
    ? "Balas secara ringkas dalam Bahasa Melayu. Kekalkan bahasa pengguna jika jelas. Jangan mereka-reka fakta rasmi; arahkan pengguna kepada sumber rasmi apabila fakta tidak dapat disahkan."
    : "Balas secara ringkas dalam Bahasa Indonesia. Kekalkan bahasa pengguna jika jelas. Jangan mengarang fakta resmi; arahkan pengguna ke sumber resmi bila fakta tidak dapat diverifikasi.";
}

function nvidiaProvider(apiKey: string, baseUrl: string, model: string): AIProvider {
  return {
    async generate(input) {
      if (input.channel !== "text") return fallback("UNAVAILABLE");
      const startedAt = Date.now();
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
      try {
        const response = await fetch(`${baseUrl.replace(/\/$/, "")}/chat/completions`, {
          method: "POST",
          headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
          body: JSON.stringify({ model, stream: false, temperature: 0.2, max_tokens: 300, messages: [
            { role: "system", content: `${DUTA_AI_SYSTEM_POLICY}\n${languageInstruction(input.message)}` },
            { role: "user", content: input.message },
          ] }),
          signal: controller.signal,
        });
        if (!response.ok) return fallback("UNAVAILABLE", Date.now() - startedAt);
        const body: unknown = await response.json();
        const text = typeof body === "object" && body !== null && "choices" in body && Array.isArray(body.choices)
          && typeof body.choices[0] === "object" && body.choices[0] !== null && "message" in body.choices[0]
          && typeof body.choices[0].message === "object" && body.choices[0].message !== null && "content" in body.choices[0].message
          && typeof body.choices[0].message.content === "string" ? body.choices[0].message.content.trim() : "";
        if (!text) return fallback("INVALID_RESPONSE", Date.now() - startedAt);
        return { success: true, provider: "nvidia", model, text, latencyMs: Date.now() - startedAt };
      } catch (error) {
        return fallback(error instanceof DOMException && error.name === "AbortError" ? "TIMEOUT" : "UNAVAILABLE", Date.now() - startedAt);
      } finally { clearTimeout(timeout); }
    },
    async healthCheck() { return false; },
  };
}

export function getAIProvider(): AIProvider {
  const apiKey = process.env.NVIDIA_API_KEY;
  if (!apiKey) return { generate: async () => fallback("UNAVAILABLE"), healthCheck: async () => true };
  return nvidiaProvider(apiKey, process.env.NVIDIA_BASE_URL || DEFAULT_BASE_URL, process.env.NVIDIA_MODEL || DEFAULT_MODEL);
}
