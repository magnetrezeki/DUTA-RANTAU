'use client';

import { FormEvent, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createSupabaseBrowserClient } from '@/lib/supabase/client';

function isValidPassword(value: string) {
  return value.length >= 10 && /[A-Za-z]/.test(value) && /\d/.test(value);
}

export function ResetPasswordForm() {
  const router = useRouter();

  const [password, setPassword] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage('');

    if (!isValidPassword(password)) {
      setErrorMessage(
        'Kata sandi minimal 10 karakter dan harus memuat huruf serta angka.',
      );
      return;
    }

    if (password !== confirmation) {
      setErrorMessage('Konfirmasi kata sandi tidak sama.');
      return;
    }

    setSubmitting(true);

    try {
      const supabase = createSupabaseBrowserClient();

      const {
        data: { user },
        error: sessionError,
      } = await supabase.auth.getUser();

      if (sessionError || !user) {
        setErrorMessage(
          'Sesi pemulihan tidak sah atau sudah berakhir. Minta tautan pemulihan baru.',
        );
        return;
      }

      const { error } = await supabase.auth.updateUser({
        password,
      });

      if (error) {
        setErrorMessage('Kata sandi tidak dapat diperbarui. Silakan coba lagi.');
        return;
      }

      await supabase.auth.signOut();

      router.replace('/masuk?reset=success');
      router.refresh();
    } catch {
      setErrorMessage('Terjadi kesalahan saat memperbarui kata sandi.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="auth-form">
      <label>
        Kata sandi baru
        <input
          type="password"
          autoComplete="new-password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          disabled={submitting}
          required
          minLength={10}
        />
      </label>

      <label>
        Ulangi kata sandi baru
        <input
          type="password"
          autoComplete="new-password"
          value={confirmation}
          onChange={(event) => setConfirmation(event.target.value)}
          disabled={submitting}
          required
          minLength={10}
        />
      </label>

      <p>
        Minimal 10 karakter, dengan sekurang-kurangnya satu huruf dan satu angka.
      </p>

      {errorMessage ? (
        <p role="alert">{errorMessage}</p>
      ) : null}

      <button type="submit" disabled={submitting}>
        {submitting ? 'Menyimpan...' : 'Simpan kata sandi baru'}
      </button>
    </form>
  );
}
