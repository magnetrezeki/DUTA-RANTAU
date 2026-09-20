import { NextRequest, NextResponse } from 'next/server';
import { authorizePlatformApi } from '@/lib/auth/api-guard';

// Configuration posture is platform-administration information, not public
// information. This handler reuses the same capability contract as the other
// /api/admin routes so that an anonymous visitor or an ordinary Member cannot
// read deployment configuration state. No new privilege is invented here.
export async function GET(req: NextRequest) {
  const auth = await authorizePlatformApi(req, 'platform.config.manage');
  if (auth.response) return auth.response;

  return NextResponse.json({
    status: 'ok',
    database: process.env.APP_DATABASE_URL ? 'configured' : 'pending-connection-string',
    auth: process.env.NEXT_PUBLIC_SUPABASE_URL ? 'supabase-configured' : 'not-configured',
    aiProvider: process.env.AI_PROVIDER ?? 'disabled',
    timestamp: new Date().toISOString(),
  });
}
