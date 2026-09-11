import 'server-only';
import type { ModelClass, Sensitivity } from '@/lib/domain/ai-routing';
import type { SourceRequirement, SourceTier } from './ai-source-ranking';

export type AiTelemetryEvent = { userRef: string; intent: string; risk: string; sensitivity: Sensitivity; modelClass: ModelClass; provider: string | null; model: string | null; sourceRequirement: SourceRequirement; sourceTier: SourceTier | null; quotaOutcome: 'allowed'|'denied'|'error'|'not_applicable'; weightedUnits: number; inputTokens: number; outputTokens: number; estimatedCostUsd: number; latencyMs: number; success: boolean; errorCode: string | null; fallbackUsed: boolean };
const rate: Record<Exclude<ModelClass,'L0_DETERMINISTIC'>, number> = { L1_SIMPLE: 0.0002, L2_ECONOMY: 0.0005, L3_ESCALATION: 0.003 };
export function buildAiTelemetry(event: Omit<AiTelemetryEvent,'inputTokens'|'outputTokens'|'estimatedCostUsd'> & { input: string; outputTokens?: number }): AiTelemetryEvent {
  const { input, outputTokens: requestedOutputTokens, ...metadata } = event;
  const inputTokens = Math.ceil(input.length / 4); const outputTokens = Math.min(requestedOutputTokens ?? 0, 300);
  const estimatedCostUsd = event.modelClass === 'L0_DETERMINISTIC' ? 0 : rate[event.modelClass] * (inputTokens + outputTokens) / 1000;
  return { ...metadata, inputTokens, outputTokens, estimatedCostUsd };
}
