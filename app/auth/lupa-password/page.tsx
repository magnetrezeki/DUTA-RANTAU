'use client';

import { FormEvent, useState } from 'react';
import Link from 'next/link';
import { isValidRecoveryEmail } from '@/lib/auth/password-recovery';

const genericSuccess =
  'Jika akun tersedia untuk email tersebut, instruksi pemulihan telah dikirim.';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [submitting, setSubmitting] = useState(false);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSuccess('');

    const normalizedEmail = email.trim().toLowerCase();
    if (!isValidRecoveryEmail(normalizedEmail)) {
      setError('Masukkan alamat email yang valid.');
      return;
    }

    setSubmitting(true);
    try {
      await fetch('/api/auth/password-recovery', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ email: normalizedEmail }),
      });
      setSuccess(genericSuccess);
    } catch {
      // Keep the result generic so recovery cannot reveal account existence.
      setSuccess(genericSuccess);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="page auth-page">
      <section>
        <span className="eyebrow">PEMULIHAN AKAUN</span>
        <h1>Lupa kata sandi?</h1>
        <p>Masukkan email Anda untuk menerima arahan pemulihan akun.</p>

        <form className="auth-form" onSubmit={submit}>
          <label>
            Email
            <input
              type="email"
              autoComplete="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              disabled={submitting}
              required
            />
          </label>

          {error ? <p role="alert">{error}</p> : null}
          {success ? <p role="status">{success}</p> : null}

          <button className="primary wide" disabled={submitting}>
            {submitting ? 'Mohon tunggu…' : 'Kirim arahan pemulihan'}
          </button>
        </form>

        <p className="auth-switch">
          Ingat kata sandi? <Link href="/masuk">Kembali ke halaman masuk</Link>
        </p>
      </section>
    </div>
  );
}