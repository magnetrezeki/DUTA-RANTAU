import 'server-only';
import { appDb } from '@/db/client';
import { aiTelemetryEvents } from '@/db/schema';
import type { AiTelemetryEvent } from './ai-telemetry';

/** Best-effort operational metadata persistence. It never receives content. */
export async function persistAiTelemetry(event: AiTelemetryEvent): Promise<boolean> {
  try {
    if (!appDb) return false;
    await appDb.insert(aiTelemetryEvents).values({ userRef:event.userRef,intent:event.intent,risk:event.risk,sensitivity:event.sensitivity,modelClass:event.modelClass,provider:event.provider,model:event.model,sourceRequirement:event.sourceRequirement,sourceTier:event.sourceTier,quotaOutcome:event.quotaOutcome,weightedUnits:event.weightedUnits,inputTokens:event.inputTokens,outputTokens:event.outputTokens,estimatedCost:String(event.estimatedCostUsd),latencyMs:event.latencyMs,success:event.success,errorCode:event.errorCode,fallbackUsed:event.fallbackUsed });
    return true;
  } catch { return false; }
}
