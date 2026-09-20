import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/lib/auth/session';
import { canUsePlatformCapability, legacyPlatformRoles } from '@/lib/domain/rbac';

// The platform administration experience is NOT part of the initial public beta.
// Access is gated server-side against the existing platform capability contract
// (`canUsePlatformCapability` + `legacyPlatformRoles`, the same primitives the
// platform API guard already uses). No new privilege is invented here: there is
// no boolean admin flag shortcut, no client-only check, no hardcoded Founder
// identity, and no universal super-admin assumption. The legacy global role is
// only a transitional input and must still hold the explicit platform capability.
export const dynamic = 'force-dynamic';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser();

  // Anonymous visitor: never receives the admin surface.
  if (!user) redirect('/masuk');

  // Ordinary Member (and any role without the admin capability) is denied.
  if (!canUsePlatformCapability(legacyPlatformRoles(user.role), 'platform.config.manage')) {
    redirect('/profil');
  }

  return <>{children}</>;
}
