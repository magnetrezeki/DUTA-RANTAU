import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from './schema';

function requireDatabaseUrl(name: 'APP_DATABASE_URL' | 'SYSTEM_DATABASE_URL') {
  const value = process.env[name];

  if (
    typeof value !== 'string' ||
    value.length === 0 ||
    value === '[SENSITIVE]' ||
    value.includes('[SENSITIVE]') ||
    !value.startsWith('postgres')
  ) {
    return null;
  }

  return value;
}

const appUrl = requireDatabaseUrl('APP_DATABASE_URL');
const systemUrl = requireDatabaseUrl('SYSTEM_DATABASE_URL');

export const appDb = appUrl
  ? drizzle(
      postgres(appUrl, {
        max: 10,
        prepare: false,
      }),
      { schema }
    )
  : null;

export const systemDb = systemUrl
  ? drizzle(
      postgres(systemUrl, {
        max: 5,
        prepare: false,
      }),
      { schema }
    )
  : null;

// Compatibility export.
// Deliberately does NOT fall back to DATABASE_URL.
export const db = appDb;

export type AppTransaction = any;
