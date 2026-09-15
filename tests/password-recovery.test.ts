import { describe, expect, it, vi } from 'vitest';
import {
  buildPasswordRecoveryRedirect,
  isValidRecoveryEmail,
  requestPasswordRecovery,
} from '@/lib/auth/password-recovery';

describe('password recovery redirect', () => {
  it('uses the configured localhost callback when Next dev is bound to 0.0.0.0', () => {
    expect(buildPasswordRecoveryRedirect('http://0.0.0.0:3001')).toBe(
      'http://localhost:3001/auth/reset-password',
    );
  });

  it('keeps a deployed application origin and strips caller-controlled path data', () => {
    expect(buildPasswordRecoveryRedirect('https://staging.example.test/untrusted?next=https://evil.test#hash')).toBe(
      'https://staging.example.test/auth/reset-password',
    );
  });

  it('rejects non-web origins', () => {
    expect(() => buildPasswordRecoveryRedirect('javascript:alert(1)')).toThrow(
      'Unsupported application origin',
    );
  });

  it('rejects an invalid email before an Auth recovery request can be made', () => {
    expect(isValidRecoveryEmail('not-an-email')).toBe(false);
    expect(isValidRecoveryEmail(' user@example.test ')).toBe(true);
  });
});

describe('password recovery request', () => {
  it('calls Supabase once with the trusted callback and reports acceptance', async () => {
    const send = vi.fn().mockResolvedValue({ error: null });

    await expect(
      requestPasswordRecovery('user@example.test', 'http://0.0.0.0:3001', send),
    ).resolves.toBe('RECOVERY_REQUEST_ACCEPTED');

    expect(send).toHaveBeenCalledTimes(1);
    expect(send).toHaveBeenCalledWith('user@example.test', {
      redirectTo: 'http://localhost:3001/auth/reset-password',
    });
  });

  it('distinguishes a provider error while preserving the caller-safe outcome', async () => {
    const send = vi.fn().mockResolvedValue({ error: new Error('provider') });

    await expect(
      requestPasswordRecovery('user@example.test', 'http://localhost:3001', send),
    ).resolves.toBe('RECOVERY_PROVIDER_ERROR');
    expect(send).toHaveBeenCalledTimes(1);
  });

  it('distinguishes a network error without retrying', async () => {
    const send = vi.fn().mockRejectedValue(new Error('network'));

    await expect(
      requestPasswordRecovery('user@example.test', 'http://localhost:3001', send),
    ).resolves.toBe('RECOVERY_NETWORK_ERROR');
    expect(send).toHaveBeenCalledTimes(1);
  });
});