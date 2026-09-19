import 'server-only';
import { withUserTransaction } from '@/lib/db/identity-bridge';
import type { VerifiedAppUser } from '@/lib/auth/verified-user';
import { aiTelemetryEvents } from '@/db/schema';
import type { AiTelemetryEvent } from './ai-telemetry';

/**
 * Best-effort operational metadata persistence. It never receives content.
 *
 * The identity is the server-verified actor supplied by the caller; the insert
 * runs inside that actor's transaction so `ai_telemetry_insert_self`
 * (user_ref = current_app_user_id()) is satisfied by the database rather than by
 * trusting the event payload. A spoofed or mismatched user_ref still fails closed.
 */
export async function persistAiTelemetry(identity: VerifiedAppUser, event: AiTelemetryEvent): Promise<boolean> {
  try {
    await withUserTransaction(identity, async (tx) => {
      await tx.insert(aiTelemetryEvents).values({ correlationId:event.correlationId,userRef:event.userRef,intent:event.intent,risk:event.risk,sensitivity:event.sensitivity,modelClass:event.modelClass,provider:event.provider,model:event.model,sourceRequirement:event.sourceRequirement,sourceTier:event.sourceTier,quotaOutcome:event.quotaOutcome,weightedUnits:event.weightedUnits,inputTokens:event.inputTokens,outputTokens:event.outputTokens,estimatedCost:String(event.estimatedCostUsd),latencyMs:event.latencyMs,success:event.success,errorCode:event.errorCode,fallbackUsed:event.fallbackUsed });
    });
    return true;
  } catch { return false; }
}
