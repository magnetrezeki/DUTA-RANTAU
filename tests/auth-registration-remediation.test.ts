import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { classifyRegistrationError } from '@/lib/auth/registration-errors';

const root = process.cwd();
const form = readFileSync(join(root, 'components/auth-form.tsx'), 'utf8');
const callback = readFileSync(join(root, 'app/auth/konfirmasi/route.ts'), 'utf8');
const chat = readFileSync(join(root, 'components/ai-chat.tsx'), 'utf8');

describe('A01 auth registration remediation', () => {
  it('does not advertise disabled external providers by default', () => {
    expect(form).toContain("NEXT_PUBLIC_GOOGLE_AUTH_ENABLED==='true'");
    expect(form).toContain("NEXT_PUBLIC_MAGIC_LINK_ENABLED==='true'");
    expect(form).toContain('{googleEnabled&&');
    expect(form).toContain('{magicLinkEnabled&&');
  });

  it('maps provider failures to safe actionable categories', () => {
    expect(classifyRegistrationError({ status: 429, code: 'over_email_send_rate_limit' }).code).toBe('RATE_LIMITED');
    expect(classifyRegistrationError({ message: 'Error sending confirmation email' })).toMatchObject({ code: 'EMAIL_DELIVERY_UNAVAILABLE', status: 503 });
    expect(classifyRegistrationError({ code: 'user_already_exists' }).code).toBe('ACCOUNT_EXISTS');
    expect(classifyRegistrationError({ message: 'Database error saving new user' }).code).toBe('REGISTRATION_UNAVAILABLE');
  });

  it('keeps callbacks on the current request/browser origin', () => {
    expect(form).toContain('window.location.origin');
    expect(callback).toContain("new URL('/profil',url.origin)");
    expect(callback).toContain("new URL('/masuk',url.origin)");
  });

  it('keeps AUTH_REQUIRED non-retryable with account actions', () => {
    expect(chat).toContain("errorCode==='AUTH_REQUIRED'");
    expect(chat).toContain('/masuk?next=/tanya');
    expect(chat).toContain('/daftar?next=/tanya');
    expect(chat).toContain("errorCode!=='AUTH_REQUIRED'");
  });
});
