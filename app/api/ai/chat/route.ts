import crypto from 'node:crypto';
import { NextRequest, NextResponse } from 'next/server';
import type { AIProviderResult } from '@/lib/services/ai-provider';
import { z } from 'zod';
import { answerQuestion } from '@/lib/services/ai-router';
import { rateLimit } from '@/lib/rate-limit';
import { consumePersistentAiQuota } from '@/lib/services/ai-quota-repository';
import { executePlannedProvider } from '@/lib/services/ai-provider-execution';
import { isDutaAiEnabled } from '@/lib/domain/duta-ai-policy';
import { authorizeApi } from '@/lib/auth/api-guard';
import { aiEnabled } from '@/lib/domain/ai-routing';
import { planAiExecution } from '@/lib/services/ai-execution-plan';
import { runAuthorizedGeneration } from '@/lib/services/authorized-ai-generation';
import { buildAiTelemetry } from '@/lib/services/ai-telemetry';
import { persistAiTelemetry } from '@/lib/services/ai-telemetry-repository';

const MAX_INPUT_CHARACTERS = 1000;
const input = z.object({
  message: z.string().trim().min(2).max(MAX_INPUT_CHARACTERS),
  location: z.string().max(100).optional(),
  channel: z.enum(['text', 'voice']).optional(),
});

export async function POST(req: NextRequest) {
  const requestStartedAt = performance.now();
  const correlationId = crypto.randomUUID();
  const auth = await authorizeApi(req);
  if (auth.response) {
    if (auth.response.status === 401) return NextResponse.json({ error: 'Silakan masuk untuk melanjutkan.', code: 'AUTH_REQUIRED' }, { status: 401 });
    return auth.response;
  }
  if (!isDutaAiEnabled() || !aiEnabled()) return NextResponse.json({ error: 'DUTA AI belum diaktifkan.', code: 'AI_DISABLED' }, { status: 503 });
  try {
    const rawBody: unknown = await req.json();
    if (typeof rawBody === 'object' && rawBody !== null && 'message' in rawBody && typeof rawBody.message === 'string' && rawBody.message.length > MAX_INPUT_CHARACTERS) {
      return NextResponse.json({ error: 'Pertanyaan melebihi had aksara.', code: 'INPUT_TOO_LARGE' }, { status: 400 });
    }
    const body = input.parse(rawBody);
    if (body.channel === 'voice') return NextResponse.json({ error: 'Input suara belum tersedia.' }, { status: 422 });
    const ip = req.headers.get('x-forwarded-for')?.split(',')[0] ?? 'local';
    if (!rateLimit(`ai:${ip}`, 15).ok) return NextResponse.json({ error: 'Terlalu banyak permintaan. Coba lagi sebentar.', code: 'RATE_LIMITED' }, { status: 429 });
    const plan = planAiExecution(body.message);
    const sourceAnswer = plan.sourceRequirement === 'OFFICIAL_REQUIRED' ? await answerQuestion(body.message, body.location) : undefined;
    const totalLatencyMs = () => {
      const elapsed = performance.now() - requestStartedAt;
      return Number.isFinite(elapsed) ? Math.max(0, elapsed) : 0;
    };
    const emit = (quotaOutcome: 'allowed' | 'denied' | 'error' | 'not_applicable', success: boolean, errorCode: string | null, provider: string | null = plan.provider === 'duta' ? null : plan.provider) =>
      void persistAiTelemetry(buildAiTelemetry({ correlationId, userRef: auth.user!.id, intent: plan.intent, risk: plan.risk, sensitivity: plan.sensitivity, modelClass: plan.modelClass, provider, model: null, sourceRequirement: plan.sourceRequirement, sourceTier: sourceAnswer?.sources?.length ? 'TIER_1' : null, quotaOutcome, weightedUnits: quotaOutcome === 'allowed' ? plan.weight : 0, input: body.message, latencyMs: totalLatencyMs(), success, errorCode, fallbackUsed: false }));
    if (plan.sourceRequirement === 'OFFICIAL_REQUIRED' && !sourceAnswer?.sources?.length) {
      emit('not_applicable', false, 'AUTHORITATIVE_SOURCE_REQUIRED', null);
      return NextResponse.json({ error: 'Maklumat ini memerlukan sumber berkuasa yang masih belum tersedia.', code: 'AUTHORITATIVE_SOURCE_REQUIRED' }, { status: 422 });
    }
    const execution = await runAuthorizedGeneration({
      modelClass: plan.modelClass,
      deterministic: async () => sourceAnswer ?? await answerQuestion(body.message, body.location),
      consume: async () => (await consumePersistentAiQuota(auth.user!, plan.weight)).status,
      generate: () => executePlannedProvider(plan.modelClass, body.message),
    });
    if (execution.status === 'quota_denied') {
      emit('denied', false, 'QUOTA_EXCEEDED');
      return NextResponse.json({ error: 'Kuota penggunaan wajar DUTA AI telah dicapai. Sila cuba semula selepas tetapan semula.', code: 'QUOTA_EXCEEDED' }, { status: 429 });
    }
    if (execution.status === 'quota_error') {
      emit('error', false, 'PROVIDER_UNAVAILABLE');
      return NextResponse.json({ error: 'DUTA AI belum tersedia.', code: 'PROVIDER_UNAVAILABLE' }, { status: 503 });
    }
    if (execution.status === 'deterministic') {
      emit('not_applicable', true, null, null);
      return NextResponse.json({ ...execution.value as object, quota: { units: 0, source: 'deterministic' } });
    }
    const generated = execution.value as AIProviderResult | undefined;
    if (!generated?.success) {
      emit('allowed', false, 'PROVIDER_UNAVAILABLE');
      return NextResponse.json({ error: 'DUTA AI belum tersedia.', code: 'PROVIDER_UNAVAILABLE' }, { status: 503 });
    }
    emit('allowed', true, null);
    return NextResponse.json({ answer: generated.text, intent: plan.intent, quota: { units: plan.weight } });
  } catch (error) {
    return NextResponse.json({ error: error instanceof z.ZodError ? 'Pertanyaan tidak valid.' : 'DUTA belum dapat memeriksa sumber saat ini. Silakan coba lagi atau gunakan pertanyaan lain.' }, { status: error instanceof z.ZodError ? 400 : 503 });
  }
}