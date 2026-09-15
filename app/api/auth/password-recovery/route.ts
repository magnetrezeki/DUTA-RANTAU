import { NextRequest, NextResponse } from 'next/server';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import {
  isValidRecoveryEmail,
  requestPasswordRecovery,
} from '@/lib/auth/password-recovery';

const genericMessage =
  'Jika akun tersedia untuk email tersebut, instruksi pemulihan telah dikirim.';

export async function POST(req: NextRequest) {
  let email = '';

  try {
    const body = await req.json();
    email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  } catch {
    return NextResponse.json({ message: genericMessage });
  }

  if (!isValidRecoveryEmail(email)) {
    return NextResponse.json(
      { error: 'Masukkan alamat email yang valid.' },
      { status: 400 },
    );
  }

  const outcome = await requestPasswordRecovery(
    email,
    req.nextUrl.origin,
    async (targetEmail, options) => {
      const supabase = await createSupabaseServerClient();
      return supabase.auth.resetPasswordForEmail(targetEmail, options);
    },
  );

  // Operational state only: no email address, token, URL, or provider payload.
  console.info('[auth.password-recovery]', { outcome });
  return NextResponse.json({ message: genericMessage });
}