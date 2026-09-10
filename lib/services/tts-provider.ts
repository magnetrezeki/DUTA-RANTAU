import "server-only";

export type TTSResult = { success: false; provider: "fallback"; latencyMs: number; errorCategory: "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE" };
export interface TTSProvider { synthesize(input: { text: string; language: "id" | "ms" }): Promise<TTSResult>; }

// NVIDIA TTS is deliberately not called until a compatible model and endpoint are validated.
export function getTTSProvider(): TTSProvider {
  return { synthesize: async () => ({ success: false, provider: "fallback", latencyMs: 0, errorCategory: "UNAVAILABLE" }) };
}
