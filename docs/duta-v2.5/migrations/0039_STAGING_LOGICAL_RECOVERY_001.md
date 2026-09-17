# Migration 0039 — Staging Logical Recovery 001

| Field | Value |
| --- | --- |
| Evidence date | `2026-09-17T21:04:47.5516663Z` |
| Candidate | `cccb6a95eafbafda12165e160f8a38a064380847` |
| Source environment | `STAGING` |
| Source project ref | `bftdfvihtewjwotrzwwe` |
| Source database | `postgres` |
| Source PostgreSQL | `17.6` |
| Migration 0039 executed | `NO` |
| Production action | `NONE` |
| Backup method | `pg_dump` consistent logical archive |
| Backup format | PostgreSQL custom archive |
| Backup reference | `pre0039-20260917T210413Z/staging-pre0039.dump` |
| Backup size | `545194` bytes |
| Backup SHA-256 | `4fd84716c3ad02fa354c58008c1ea99d98d5d38c2d172663556606ad4f335906` |
| Backup location class | Git-ignored local `.local-backups/staging-0039/` |
| Dump/restore tool | PostgreSQL `17.6` |
| Tool image | `public.ecr.aws/supabase/postgres:17.6.1.165` |
| Tool image ID | `sha256:28f0e16a019e648089fc1a6d333549a55548f6019c15ae4bd7cd58b989027518` |
| Recovery owner | `DUTA RANTAU PROJECT OWNER` |
| Backup recovery | `READY` |

## Source identity and credential boundary

The authenticated provider dashboard and the database connection independently
identified the staging target as project `bftdfvihtewjwotrzwwe`, database
`postgres`, in the Supabase Singapore region. The database session reported
PostgreSQL `17.6` and current user `postgres`. The production ref
`uokljxqqvpujwmubildy` was not selected, connected, or used.

The staging owner URI remains only in an ignored local secret file. No password,
URI, token, or key is present in this evidence. Generic `DATABASE_URL` and
`DIRECT_URL` were not used.

## Backup creation

The dump used the existing local PostgreSQL 17.6 client image with no image
pull. It used custom format, no owner commands, a serializable-deferrable
snapshot, and a bounded lock wait. The resulting archive is preserved outside
Git tracking. Archive inspection succeeded with 1,080 TOC entries, including
230 ACL entries.

## Local restore proof

A new disposable PostgreSQL 17.6 container was created with tmpfs database
storage, no published host port, and the backup mounted read-only. It did not
reuse, stop, or modify the existing `duta-local-test-db` forensic container.

The initial clean restore stopped because database policies reference the
repository-declared `duta_app` role. The proof target was reset to a clean
database. Only the four declared policy roles (`duta_app`, `duta_system`,
`anon`, and `authenticated`) were then created as restricted NOLOGIN local
placeholders. The archive restored successfully with `--no-owner --no-acl`.
The archive retains its ACL entries; ownership and ACL application were
suppressed only for this isolated proof because Supabase provider roles are not
portable cluster globals.

Structural verification returned:

- restored database identity `duta_recovery_proof`, PostgreSQL `17.6`;
- 12 schemas;
- 89 non-system user tables;
- 51 public tables;
- `public.users` present;
- `public.official_sources` present;
- five extensions readable;
- all four declared local placeholder roles restricted;
- no `drizzle.__drizzle_migrations` table in the source backup.

The disposable proof container was removed after verification. The forensic
container remained running. The backup archive remains preserved.

## Deterministic recovery procedure

1. Positively identify the intended recovery target as staging project
   `bftdfvihtewjwotrzwwe`; reject production and ambiguous targets.
2. Retrieve the archive only from the ignored backup reference above and verify
   its exact SHA-256 before use.
3. Use PostgreSQL 17.6 `pg_restore` or a compatible newer client and a clean
   PostgreSQL 17.6 recovery target.
4. Establish the required target roles through the owning environment's
   approved role procedure. For isolated proof only, the four policy roles may
   be restricted NOLOGIN placeholders.
5. Restore the custom archive with stop-on-error. Use `--no-owner --no-acl` for
   an isolated structural proof. A real staging recovery must separately map
   provider ownership and ACLs before applying them.
6. Verify database/server identity, archive checksum, schemas, structural table
   counts, required `users` and `official_sources` objects, extensions, role
   restrictions, policies, RLS, and relevant non-sensitive invariants.
7. Stop on checksum mismatch, restore error, missing role, object conflict, or
   verification mismatch. Do not repair or overwrite staging under this
   procedure without separate explicit recovery authorization.

Credentials remain in approved ignored secret stores only. Never place a
credential in Git, documentation, logs, chat, filenames, or command output.
This recovery evidence authorizes no production restore and no staging restore.

## Continued pre-migration result

The protocol-defined staging read-only precheck passed:

- `pgcrypto`, restricted runtime roles, public roles, `users(id uuid)`, all 12
  legacy `official_sources` columns, both required indexes, RLS, both policies,
  the identity function, and legacy duta_app table privileges were present;
- all five migration 0039 object markers were absent;
- the staging migration-owner role owns `official_sources` and has CREATE on
  schema `public`;
- migration 0039 applied state is `KNOWN_NOT_APPLIED`;
- staging prestate is `PASS`.

The existing `duta_app` role was confirmed restricted. A staging-only generated
credential was configured and verified through the staging transaction pooler.
Vercel received `APP_DATABASE_URL` as a secret scoped only to Preview branch
`duta-v2.5`. Production environment variables were not changed. Vercel reports
that a new deployment is required for the variable to take effect; no
redeployment was performed.

This record establishes readiness for a separate migration 0039 staging
execution decision. It does not authorize or execute the migration.
