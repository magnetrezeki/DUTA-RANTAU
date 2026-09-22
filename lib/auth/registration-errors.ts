export type RegistrationError = {
  code:
    | 'ACCOUNT_EXISTS'
    | 'EMAIL_DELIVERY_UNAVAILABLE'
    | 'PASSWORD_POLICY'
    | 'RATE_LIMITED'
    | 'REGISTRATION_UNAVAILABLE';
  message: string;
  status: number;
};

type AuthErrorLike = { code?: string; message?: string; status?: number };

export function classifyRegistrationError(error: AuthErrorLike): RegistrationError {
  const code = (error.code ?? '').toLowerCase();
  const message = (error.message ?? '').toLowerCase();
  const text = `${code} ${message}`;

  if (error.status === 429 || /rate.limit|too.many|over_email_send_rate_limit/.test(text)) {
    return { code: 'RATE_LIMITED', message: 'Terlalu banyak percobaan pendaftaran. Coba lagi nanti.', status: 429 };
  }
  if (/already|registered|exists|user_already_exists/.test(text)) {
    return { code: 'ACCOUNT_EXISTS', message: 'Email sudah terdaftar. Silakan masuk atau pulihkan kata sandi.', status: 409 };
  }
  if (/password|weak_password/.test(text)) {
    return { code: 'PASSWORD_POLICY', message: 'Kata sandi belum memenuhi persyaratan keamanan.', status: 400 };
  }
  if (/smtp|sending confirmation|send.*email|email.*delivery|mailer/.test(text)) {
    return { code: 'EMAIL_DELIVERY_UNAVAILABLE', message: 'Email konfirmasi belum dapat dikirim. Pendaftaran sedang tidak tersedia.', status: 503 };
  }
  return { code: 'REGISTRATION_UNAVAILABLE', message: 'Pendaftaran sedang tidak tersedia. Silakan coba lagi setelah layanan akun dipulihkan.', status: 503 };
}
