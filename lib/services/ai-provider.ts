import "server-only";

export type AIChannel = "text" | "voice";
export type AIProviderResult = { success: boolean; provider: string; model?: string; text?: string; errorCategory?: "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE" };
export interface AIProvider { generate(input: { message: string; channel: AIChannel }): Promise<AIProviderResult>; healthCheck(): Promise<boolean>; }

const fallback: AIProvider = { async generate(input) { return input.channel === "voice" ? { success:false, provider:"fallback", errorCategory:"UNAVAILABLE" } : { success:false, provider:"fallback", errorCategory:"UNAVAILABLE" }; }, async healthCheck(){ return true; } };

export function getAIProvider(): AIProvider {
  if (!process.env.NVIDIA_API_KEY) return fallback;
  return { async generate() { return { success:false, provider:"nvidia", model:process.env.NVIDIA_MODEL, errorCategory:"UNAVAILABLE" }; }, async healthCheck(){ return false; } };
}
