import { beforeEach, describe, expect, it, vi } from 'vitest';

const s = vi.hoisted(() => ({
  calls: [] as string[], kind: 'L1_SIMPLE', requirement: 'NONE', quota: 'allowed',
  sources: [{ id: 's' }] as unknown[], events: [] as unknown[], enabled: true,
  authenticated: true, providerFailure: false, telemetrySucceeds: true,
}));

vi.mock('@/lib/auth/api-guard', () => ({ authorizeApi: async () => s.authenticated
  ? { user: { id: '00000000-0000-4000-8000-000000000001' }, response: null }
  : { user: null, response: new Response(JSON.stringify({ error: 'auth' }), { status: 401 }) } }));
vi.mock('@/lib/domain/duta-ai-policy', () => ({ isDutaAiEnabled: () => s.enabled }));
vi.mock('@/lib/domain/ai-routing', async importOriginal => ({ ...await importOriginal<typeof import('@/lib/domain/ai-routing')>(), aiEnabled: () => s.enabled }));
vi.mock('@/lib/rate-limit', () => ({ rateLimit: () => ({ ok: true }) }));
vi.mock('@/lib/services/ai-execution-plan', () => ({ planAiExecution: () => ({
  intent: 'GENERAL', risk: 'low', sensitivity: 'PUBLIC', modelClass: s.kind,
  provider: s.kind === 'L1_SIMPLE' ? 'gemini' : s.kind === 'L2_ECONOMY' ? 'groq' : s.kind === 'L3_ESCALATION' ? 'openai' : 'duta',
  weight: s.kind === 'L0_DETERMINISTIC' ? 0 : 1, sourceRequirement: s.requirement,
}) }));
vi.mock('@/lib/services/ai-router', () => ({ answerQuestion: async () => ({ answer: 'official', sources: s.sources }) }));
vi.mock('@/lib/services/ai-quota-repository', () => ({ consumePersistentAiQuota: async () => { s.calls.push('quota'); return { status: s.quota }; } }));
vi.mock('@/lib/services/ai-provider-execution', () => ({ executePlannedProvider: async (modelClass: string) => {
  s.calls.push(`provider:${modelClass}`);
  return s.providerFailure ? { success: false, provider: 'fallback', latencyMs: 15_000, errorCategory: 'TIMEOUT' } : { success: true, text: 'generated', provider: 'gemini', latencyMs: 1 };
} }));
vi.mock('@/lib/services/ai-telemetry-repository', () => ({ persistAiTelemetry: async (event: unknown) => { s.events.push(event); return s.telemetrySucceeds; } }));

const { POST } = await import('../app/api/ai/chat/route');
const req = (message = 'hello', extra = {}) => new Request('http://localhost/api/ai/chat', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ message, ...extra }) }) as never;

describe('production AI chat boundary', () => {
  beforeEach(() => { Object.assign(s, { calls: [], events: [], kind: 'L1_SIMPLE', requirement: 'NONE', quota: 'allowed', sources: [{ id: 's' }], enabled: true, authenticated: true, providerFailure: false, telemetrySucceeds: true }); });

  it('keeps L0 quota/provider free and emits safe telemetry', async () => {
    s.kind = 'L0_DETERMINISTIC'; expect((await POST(req())).status).toBe(200); expect(s.calls).toEqual([]); expect(s.events).toHaveLength(1); expect(JSON.stringify(s.events[0])).toContain('L0_DETERMINISTIC');
  });
  it('denies unsupported official requests before provider and keeps prompt private', async () => {
    s.requirement = 'OFFICIAL_REQUIRED'; s.sources = []; const response = await POST(req('PRIVATE_MARKER_12345'));
    expect((await response.json()).code).toBe('AUTHORITATIVE_SOURCE_REQUIRED'); expect(s.calls).toEqual([]); expect(JSON.stringify(s.events)).not.toContain('PRIVATE_MARKER_12345');
  });
  it('charges before exactly one L1/L2/L3 provider execution', async () => {
    for (const kind of ['L1_SIMPLE', 'L2_ECONOMY', 'L3_ESCALATION']) { s.kind = kind; expect((await POST(req())).status).toBe(200); expect(s.calls).toEqual(['quota', `provider:${kind}`]); s.calls = []; s.events = []; }
  });
  it('records denial and quota error without provider', async () => {
    for (const quota of ['denied', 'error']) { s.quota = quota; expect((await POST(req())).status).toBe(quota === 'denied' ? 429 : 503); expect(s.calls).toEqual(['quota']); s.calls = []; s.events = []; }
  });
  it('normalizes oversized input before quota or provider execution', async () => {
    const response = await POST(req('x'.repeat(1001), { provider: 'openai', model: 'terra', quotaWeight: 99, maxTokens: 10_000 }));
    expect((await response.json()).code).toBe('INPUT_TOO_LARGE'); expect(s.calls).toEqual([]);
  });
  it('denies flag-off and anonymous requests before quota or provider execution', async () => {
    s.enabled = false; expect((await POST(req())).status).toBe(503); expect(s.calls).toEqual([]);
    s.enabled = true; s.authenticated = false; const response = await POST(req()); expect((await response.json()).code).toBe('AUTH_REQUIRED'); expect(s.calls).toEqual([]);
  });
  it('uses a server-generated correlation ID that reaches telemetry', async () => {
    expect((await POST(req('hello', { correlationId: 'CLIENT_CONTROLLED', requestId: 'CLIENT_CONTROLLED' }))).status).toBe(200);
    const first = (s.events[0] as { correlationId?: string }).correlationId; expect(first).toBeTruthy(); expect(first).not.toBe('CLIENT_CONTROLLED');
    s.events = []; expect((await POST(req())).status).toBe(200); const second = (s.events[0] as { correlationId?: string }).correlationId; expect(second).toBeTruthy(); expect(second).not.toBe(first);
  });
  it('records measured total request latency rather than a hard-coded zero', async () => {
    const clock = vi.spyOn(performance, 'now').mockReturnValueOnce(1000).mockReturnValue(1125);
    expect((await POST(req())).status).toBe(200); expect((s.events[0] as { latencyMs: number }).latencyMs).toBe(125); clock.mockRestore();
  });
  it('does not replay provider or quota when provider or telemetry fails', async () => {
    s.kind = 'L2_ECONOMY'; s.providerFailure = true; const timedOut = await POST(req()); expect((await timedOut.json()).code).toBe('PROVIDER_UNAVAILABLE'); expect(s.calls).toEqual(['quota', 'provider:L2_ECONOMY']);
    s.calls = []; s.events = []; s.providerFailure = false; s.telemetrySucceeds = false; expect((await POST(req())).status).toBe(200); expect(s.calls).toEqual(['quota', 'provider:L2_ECONOMY']); expect(s.events).toHaveLength(1);
  });
});