import Link from 'next/link';
import { Shield } from 'lucide-react';
import { ResetPasswordForm } from './reset-password-form';

export const metadata = {
  title: 'Tetapkan Kata Sandi Baru',
};

export default function Page() {
  return (
    <div className="page auth-page">
      <section>
        <span className="eyebrow">PEMULIHAN AKAUN</span>
        <h1>Tetapkan kata sandi baru</h1>
        <p>
          Gunakan kata sandi baru untuk kembali masuk ke akaun DUTA RANTAU Anda.
        </p>

        <ResetPasswordForm />

        <p className="auth-switch">
          Sudah ingat kata sandi? <Link href="/masuk">Kembali ke halaman masuk</Link>
        </p>

        <div className="notice">
          <Shield />
          <span>Kata sandi baru diproses melalui sesi pemulihan Supabase yang sah.</span>
        </div>
      </section>
    </div>
  );
}
