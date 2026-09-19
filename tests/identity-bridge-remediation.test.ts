import { beforeEach, describe, expect, it, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { auditLogs, meetingTranscripts, organizationDocuments, publicationProjects, aiTelemetryEvents } from '../db/schema';
import { publicationTypes, secretaryDocuments } from '../lib/domain/secretary-templates';
import { createVerifiedAppUser } from '../lib/auth/verified-user';

const ORG_ID = '20000000-0000-4000-8000-000000000001';
const MEETING_ID = '30000000-0000-4000-8000-000000000001';
const ROW_ID = '40000000-0000-4000-8000-000000000001';

const SAFE_ROLE = { role_name: 'duta_app', superuser: false, bypass_rls: false, create_role: false, create_db: false, replication: false, owned_tables: 0 };

const h = vi.hoisted(() => {
  const state = {
    txSteps: [] as string[],
    insertedTables: [] as unknown[],
    insertedValues: [] as Record<string, unknown>[],
    bareInserts: 0,
    readbackId: '00000000-0000-4000-8000-0000000000a1',
    authId: '00000000-0000-4000-8000-0000000000a1',
    roleRow: { role_name: 'duta_app', superuser: false, bypass_rls: false, create_role: false, create_db: false, replication: false, owned_tables: 0 } as unknown,
    providerCalls: 0,
  };
  // The transaction handed to the caller only wires up what the bridge and the
  // routes actually use, and records the exact order of statements.
  const tx = () => {
    let step = 0;
    const rows = (value: unknown) => {
      const q: Record<string, unknown> = {};
      q.from = () => q;
      q.where = () => q;
      q.limit = async () => value;
      return q;
    };
    return {
      execute: async () => {
        step += 1;
        if (step === 1) { state.txSteps.push('set_config'); return []; }
        state.txSteps.push('readback');
        return [{ id: state.readbackId }];
      },
      select: () => {
        state.txSteps.push('select_profile');
        return rows([{ id: state.authId, role: 'USER', name: 'A', suspendedAt: null }]);
      },
      insert: (table: unknown) => {
        state.txSteps.push('insert');
        state.insertedTables.push(table);
        return {
          values: (values: Record<string, unknown>) => {
            state.insertedValues.push(values);
            return { returning: async () => [{ id: ROW_ID }] };
          },
        };
      },
    };
  };
  return { state, tx };
});

vi.mock('@/db/client', () => ({
  appDb: {
    execute: async () => [h.state.roleRow],
    transaction: async (work: (transaction: unknown) => Promise<unknown>) => work(h.tx()),
    // A bare insert outside the identity bridge must never happen again.
    insert: () => { h.state.bareInserts += 1; throw new Error('BARE_APP_DB_INSERT'); },
  },
  systemDb: null,
  db: null,
}));

vi.mock('@/lib/auth/api-guard', async () => {
  const { createVerifiedAppUser } = await import('@/lib/auth/verified-user');
  return {
    authorizeApi: async () => ({
      user: createVerifiedAppUser({ id: h.state.authId, name: 'A', email: 'a@example.test', role: 'USER', city: null, state: null }),
      response: null,
    }),
    verifySameOrigin: () => true,
  };
});

vi.mock('@/lib/services/organization-access', () => ({ getOrganizationAccess: async () => ({ allowed: true, role: 'OWNER', plan: 'PRO' }) }));
vi.mock('@/lib/services/communication-ai', () => ({ generateCommunicationDraft: async () => ({ body: 'draft body' }) }));
vi.mock('@/lib/services/meeting-transcription', () => ({ transcribeMeetingEphemeral: async () => { h.state.providerCalls += 1; return { transcript: 't', summary: 's', actionItems: [] }; } }));

const { POST: generateDraft } = await import('../app/api/organizations/[id]/secretary/generate/route');
const { POST: transcribeMeeting } = await import('../app/api/organizations/[id]/meetings/transcribe/route');
const { persistAiTelemetry } = await import('../lib/services/ai-telemetry-repository');

const params = { params: Promise.resolve({ id: ORG_ID }) };
const jsonRequest = (body: unknown) => new Request('http://localhost/api/x', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(body) }) as never;
const audioRequest = () => {
  const form = new FormData();
  form.set('meetingId', MEETING_ID);
  form.set('language', 'id');
  form.set('consent', 'true');
  form.set('audio', new File([new Uint8Array([1, 2, 3])], 'meeting.mp3', { type: 'audio/mpeg' }));
  return new Request('http://localhost/api/x', { method: 'POST', body: form }) as never;
};
const verifiedUser = createVerifiedAppUser({ id: '00000000-0000-4000-8000-0000000000a1', name: 'A', email: 'a@example.test', role: 'USER', city: null, state: null });
const event = { correlationId: 'c1', userRef: h.state.authId, intent: 'GENERAL', risk: 'low', sensitivity: 'PUBLIC' as const, modelClass: 'L1_SIMPLE' as const, provider: 'gemini', model: null, sourceRequirement: 'NONE' as const, sourceTier: null, quotaOutcome: 'allowed' as const, weightedUnits: 1, inputTokens: 1, outputTokens: 0, estimatedCostUsd: 0, latencyMs: 1, success: true, errorCode: null, fallbackUsed: false };

describe('identity bridge remediation', () => {
  beforeEach(() => {
    Object.assign(h.state, {
      txSteps: [], insertedTables: [], insertedValues: [], bareInserts: 0, providerCalls: 0,
      authId: '00000000-0000-4000-8000-0000000000a1', readbackId: '00000000-0000-4000-8000-0000000000a1', roleRow: { ...SAFE_ROLE },
    });
  });

  // ORDER MATTERS: the bridge memoises a successful role verification for the
  // process, so the unsafe-role case must be observed before any success. A
  // failed verification is never cached, so later cases still verify normally.
  it('inherits assertRestrictedRole through the standard transaction primitive', async () => {
    h.state.roleRow = { ...SAFE_ROLE, superuser: true };

    await expect(generateDraft(jsonRequest({ type: secretaryDocuments[0][0], prompt: 'tulis draf ringkas' }), params)).rejects.toThrow(/Unsafe runtime database role/);
    expect(h.state.insertedTables).toHaveLength(0);

    const transcript = await transcribeMeeting(audioRequest(), params);
    expect(transcript.status).toBe(500);
    expect(h.state.insertedTables).toHaveLength(0);

    expect(await persistAiTelemetry({ id: h.state.authId } as never, event)).toBe(false);
    expect(h.state.insertedTables).toHaveLength(0);
    expect(h.state.bareInserts).toBe(0);
  });

  it('writes secretary drafts inside the authenticated transaction that established app.user_id', async () => {
    const response = await generateDraft(jsonRequest({ type: secretaryDocuments[0][0], prompt: 'tulis draf ringkas' }), params);

    expect(response.status).toBe(201);
    expect(h.state.txSteps).toEqual(['set_config', 'readback', 'select_profile', 'insert', 'insert']);
    expect(h.state.insertedTables).toEqual([organizationDocuments, auditLogs]);
    expect(h.state.insertedValues[0]).toMatchObject({ organizationId: ORG_ID, authorId: h.state.authId });
    expect(h.state.bareInserts).toBe(0);
  });

  it('writes visual publications and their audit row in the same authenticated transaction', async () => {
    const response = await generateDraft(jsonRequest({ type: publicationTypes[0][0], prompt: 'tulis draf publikasi' }), params);

    expect(response.status).toBe(201);
    expect(h.state.txSteps).toEqual(['set_config', 'readback', 'select_profile', 'insert', 'insert']);
    expect(h.state.insertedTables).toEqual([publicationProjects, auditLogs]);
    expect(h.state.insertedValues[1]).toMatchObject({ actorId: h.state.authId, action: 'publication.create_draft' });
  });

  it('fails closed and writes nothing when the transaction identity does not match the session', async () => {
    h.state.readbackId = '00000000-0000-4000-8000-0000000000ff';

    await expect(generateDraft(jsonRequest({ type: secretaryDocuments[0][0], prompt: 'tulis draf ringkas' }), params)).rejects.toThrow(/Transaction identity mismatch/);
    expect(h.state.insertedTables).toHaveLength(0);
    expect(h.state.bareInserts).toBe(0);
  });

  it('writes transcripts and their audit row inside the authenticated transaction', async () => {
    const response = await transcribeMeeting(audioRequest(), params);
    const body = await response.json();

    expect(response.status).toBe(201);
    expect(body).toMatchObject({ audioStored: false, requiresReview: true });
    expect(h.state.providerCalls).toBe(1);
    expect(h.state.txSteps).toEqual(['set_config', 'readback', 'select_profile', 'insert', 'insert']);
    expect(h.state.insertedTables).toEqual([meetingTranscripts, auditLogs]);
    expect(h.state.insertedValues[0]).toMatchObject({ organizationId: ORG_ID, meetingId: MEETING_ID, createdBy: h.state.authId, consentConfirmed: true });
    expect(h.state.insertedValues[1]).toMatchObject({ actorId: h.state.authId, action: 'meeting.audio_transcribed' });
    expect(h.state.bareInserts).toBe(0);
  });

  it('fails the transcript closed without persisting and without storing audio on identity mismatch', async () => {
    h.state.readbackId = '00000000-0000-4000-8000-0000000000ff';
    const response = await transcribeMeeting(audioRequest(), params);

    expect(response.status).toBe(500);
    await expect(response.json()).resolves.toMatchObject({ error: 'Transkripsi gagal. Audio tidak disimpan.' });
    expect(h.state.insertedTables).toHaveLength(0);
  });

  it('persists AI telemetry through the authenticated identity bridge instead of a bare insert', async () => {
    expect(await persistAiTelemetry(verifiedUser, event)).toBe(true);
    expect(h.state.txSteps).toEqual(['set_config', 'readback', 'select_profile', 'insert']);
    expect(h.state.insertedTables).toEqual([aiTelemetryEvents]);
    expect(h.state.insertedValues[0]).toMatchObject({ userRef: h.state.authId, correlationId: 'c1' });
    expect(h.state.bareInserts).toBe(0);
  });

  it('fails telemetry closed and writes nothing when the transaction identity does not match', async () => {
    h.state.readbackId = '00000000-0000-4000-8000-0000000000ff';
    expect(await persistAiTelemetry(verifiedUser, event)).toBe(false);
    expect(h.state.insertedTables).toHaveLength(0);
    expect(h.state.bareInserts).toBe(0);
  });

  it('rejects an unverified identity object without reaching the database', async () => {
    expect(await persistAiTelemetry({ id: h.state.authId, role: 'USER' } as never, event)).toBe(false);
    expect(h.state.txSteps).toEqual([]);
    expect(h.state.insertedTables).toHaveLength(0);
    expect(h.state.bareInserts).toBe(0);
  });

  it('would not accept a raw transaction path that never establishes the identity', async () => {
    const { appDb } = await import('@/db/client');
    const raw = appDb as unknown as { transaction: (work: (tx: unknown) => Promise<unknown>) => Promise<unknown> };

    await raw.transaction(async (tx) => (tx as { insert: (table: unknown) => { values: (values: Record<string, unknown>) => Promise<unknown> } }).insert(organizationDocuments).values({}));

    // Negative control: the pre-remediation shape records only the write, so the
    // ordering asserted above genuinely discriminates it from the bridge path.
    expect(h.state.txSteps).toEqual(['insert']);
    expect(h.state.txSteps).not.toContain('set_config');
  });

  it('keeps raw protected writes out of the remediated sources', () => {
    for (const path of ['app/api/organizations/[id]/secretary/generate/route.ts', 'app/api/organizations/[id]/meetings/transcribe/route.ts']) {
      const source = readFileSync(path, 'utf8');
      expect(source).toContain('withUserTransaction(auth.user!');
      expect(source).not.toContain('appDb.transaction');
      expect(source).not.toContain('appDb.insert');
    }
    const repository = readFileSync('lib/services/ai-telemetry-repository.ts', 'utf8');
    expect(repository).toContain('withUserTransaction(identity');
    expect(repository).not.toContain('appDb.insert');
  });
});
