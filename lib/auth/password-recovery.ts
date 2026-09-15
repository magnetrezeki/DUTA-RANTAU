export const passwordRecoveryPath = '/auth/reset-password';

export type RecoveryRequestOutcome =
  | 'RECOVERY_REQUEST_ACCEPTED'
  | 'RECOVERY_PROVIDER_ERROR'
  | 'RECOVERY_NETWORK_ERROR';

type RecoverySender = (
  email: string,
  options: { redirectTo: string },
) => Promise<{ error: unknown | null }>;

export function isValidRecoveryEmail(value: string) {
  return /^\S+@\S+\.\S+$/.test(value.trim());
}

export function buildPasswordRecoveryRedirect(origin: string) {
  const url = new URL(origin);

  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    throw new Error('Unsupported application origin');
  }

  // Next dev may bind to 0.0.0.0, but the configured local Auth redirect
  // uses localhost. Production origins remain unchanged.
  if (url.hostname === '0.0.0.0') {
    url.hostname = 'localhost';
  }

  url.pathname = passwordRecoveryPath;
  url.search = '';
  url.hash = '';
  return url.toString();
}

export async function requestPasswordRecovery(
  email: string,
  origin: string,
  send: RecoverySender,
): Promise<RecoveryRequestOutcome> {
  try {
    const result = await send(email, {
      redirectTo: buildPasswordRecoveryRedirect(origin),
    });
    return result.error ? 'RECOVERY_PROVIDER_ERROR' : 'RECOVERY_REQUEST_ACCEPTED';
  } catch {
    return 'RECOVERY_NETWORK_ERROR';
  }
}