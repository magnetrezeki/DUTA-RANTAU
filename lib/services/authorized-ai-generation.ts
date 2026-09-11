import { usageWeight, type ModelClass } from '@/lib/domain/ai-routing';

export type AuthorizedGenerationResult =
  | { status: 'deterministic'; value: unknown }
  | { status: 'generated'; value: unknown }
  | { status: 'quota_denied' }
  | { status: 'quota_error' };

/** The production boundary that proves quota authorization precedes an LLM. */
export async function runAuthorizedGeneration(input: {
  modelClass: ModelClass;
  deterministic: () => Promise<unknown>;
  consume: (units: number) => Promise<'allowed' | 'denied' | 'error'>;
  generate: () => Promise<unknown>;
}): Promise<AuthorizedGenerationResult> {
  if (input.modelClass === 'L0_DETERMINISTIC') return { status: 'deterministic', value: await input.deterministic() };
  const quota = await input.consume(usageWeight[input.modelClass]);
  if (quota === 'denied') return { status: 'quota_denied' };
  if (quota === 'error') return { status: 'quota_error' };
  return { status: 'generated', value: await input.generate() };
}
