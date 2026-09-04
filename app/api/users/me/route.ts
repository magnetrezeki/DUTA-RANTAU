import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { appDb } from '@/db/client';
import { auditLogs, users } from '@/db/schema';
import { authorizeApi } from '@/lib/auth/api-guard';
import { destroySession } from '@/lib/auth/session';
import { withUserTransaction } from '@/lib/db/identity-bridge';

const patch = z.object({
  name: z.string().trim().min(2).max(100).optional(),
  city: z.string().trim().max(100).nullable().optional(),
  state: z.string().trim().max(100).nullable().optional(),
  hometown: z.string().trim().max(100).nullable().optional(),
  profession: z.string().trim().max(100).nullable().optional(),
  interests: z.array(z.string().max(60)).max(20).optional(),
  profileVisibility: z.enum([
    'PUBLIC',
    'COMMUNITY_ONLY',
    'CONNECTIONS_ONLY',
    'PRIVATE',
  ]).optional(),
  locationVisibility: z.enum([
    'CITY',
    'STATE',
    'PRIVATE',
  ]).optional(),
}).strict();

export async function GET(req: NextRequest) {
  if (!appDb) {
    return NextResponse.json(
      { error: 'Database belum dikonfigurasi.' },
      { status: 503 },
    );
  }

  const auth = await authorizeApi(req);

  if (auth.response) {
    return auth.response;
  }

  const user = await withUserTransaction(auth.user!, async (tx) => {
    const [row] = await tx
      .select({
        id: users.id,
        email: users.email,
        name: users.name,
        phone: users.phone,
        avatarUrl: users.avatarUrl,
        city: users.city,
        state: users.state,
        hometown: users.hometown,
        profession: users.profession,
        interests: users.interests,
        role: users.role,
        emailVerifiedAt: users.emailVerifiedAt,
        profileVisibility: users.profileVisibility,
        locationVisibility: users.locationVisibility,
        suspendedAt: users.suspendedAt,
        createdAt: users.createdAt,
        updatedAt: users.updatedAt,
      })
      .from(users)
      .where(eq(users.id, auth.user!.id))
      .limit(1);

    return row ?? null;
  });

  return NextResponse.json({ user });
}

export async function PATCH(req: NextRequest) {
  if (!appDb) {
    return NextResponse.json(
      { error: 'Database belum dikonfigurasi.' },
      { status: 503 },
    );
  }

  const auth = await authorizeApi(req);

  if (auth.response) {
    return auth.response;
  }

  try {
    const data = patch.parse(await req.json());

    const updated = await withUserTransaction(auth.user!, async (tx) => {
      const [row] = await tx
        .update(users)
        .set({
          ...data,
          updatedAt: new Date(),
        })
        .where(eq(users.id, auth.user!.id))
        .returning({
          id: users.id,
          name: users.name,
          email: users.email,
          city: users.city,
          state: users.state,
          hometown: users.hometown,
          profession: users.profession,
          interests: users.interests,
          profileVisibility: users.profileVisibility,
          locationVisibility: users.locationVisibility,
        });

      if (!row) {
        throw new Error('PROFILE_NOT_FOUND');
      }

      await tx.insert(auditLogs).values({
        actorId: auth.user!.id,
        action: 'profile_update',
        entityType: 'user',
        entityId: auth.user!.id,
        metadata: {
          fields: Object.keys(data),
        },
      });

      return row;
    });

    return NextResponse.json({ user: updated });
  } catch {
    return NextResponse.json(
      { error: 'Data profil tidak valid.' },
      { status: 400 },
    );
  }
}

export async function DELETE(req: NextRequest) {
  if (!appDb) {
    return NextResponse.json(
      { error: 'Database belum dikonfigurasi.' },
      { status: 503 },
    );
  }

  const auth = await authorizeApi(req);

  if (auth.response) {
    return auth.response;
  }

  try {
    await withUserTransaction(auth.user!, async (tx) => {
      await tx.insert(auditLogs).values({
        actorId: auth.user!.id,
        action: 'account_deletion',
        entityType: 'user',
        entityId: auth.user!.id,
      });

      await tx
        .delete(users)
        .where(eq(users.id, auth.user!.id));
    });

    await destroySession();

    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json(
      { error: 'Gagal menghapus akun.' },
      { status: 500 },
    );
  }
}
