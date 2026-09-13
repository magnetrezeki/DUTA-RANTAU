import { AI_DAILY_QUOTA_LIMIT, nextUtcDayStartMs, utcDayStartMs } from './ai-quota-policy';

/** @deprecated Compatibility-only test meter. Production uses consume_ai_usage for weighted UTC-day accounting. */
const limit = AI_DAILY_QUOTA_LIMIT;
const entries = new Map<string, { count: number; periodStart: number }>();

export function consumeDutaAiQuota(subject: string, now = Date.now()) {
  const periodStart = utcDayStartMs(now);
  const current = entries.get(subject);
  const state = !current || current.periodStart !== periodStart ? { count: 0, periodStart } : current;
  const resetAt = nextUtcDayStartMs(now);
  if (state.count >= limit) return { allowed: false, limit, remaining: 0, resetAt: new Date(resetAt).toISOString() };
  state.count++;
  entries.set(subject, state);
  return { allowed: true, limit, remaining: limit - state.count, resetAt: new Date(resetAt).toISOString() };
}

export const dutaAiFairUse = { limit, period: 'UTC_DAY' as const };
