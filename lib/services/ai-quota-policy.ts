import 'server-only';

/** The sole production fair-use policy: weighted units per user per UTC day. */
export const AI_DAILY_QUOTA_LIMIT = 30;

export function utcDayStartMs(now = Date.now()) {
  const instant = new Date(now);
  return Date.UTC(instant.getUTCFullYear(), instant.getUTCMonth(), instant.getUTCDate());
}

export function nextUtcDayStartMs(now = Date.now()) {
  return utcDayStartMs(now) + 24 * 60 * 60 * 1000;
}
