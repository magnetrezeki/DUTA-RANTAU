import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from './schema';

const url = process.env.DATABASE_URL;

export const db = url
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
