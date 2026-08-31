import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from './schema';

const url = process.env.DATABASE_URL;

const validDatabaseUrl =
  typeof url === 'string' &&
  url.length > 0 &&
  url !== '[SENSITIVE]' &&
  !url.includes('[SENSITIVE]') &&
  url.startsWith('postgres');

export const db = validDatabaseUrl
  ? drizzle(
      postgres(url, {
        max: 10,
        prepare: false,
      }),
      { schema }
    )
  : null;

// Compatibility exports
export const appDb = db;
export const systemDb = db;

export type AppTransaction = any;