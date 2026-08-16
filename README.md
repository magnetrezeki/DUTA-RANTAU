# DUTA RANTAU

Production-oriented foundation for **Rumah Digital Orang Indonesia di Malaysia**, built from Master PRD v1.0 (16 August 2026).

## Stack
- Next.js 16 / React 19 / TypeScript
- PostgreSQL + Drizzle ORM
- Argon2id password hashing, opaque server sessions, HTTP-only cookies
- Zod validation, per-IP in-process rate-limit adapter
- Provider-agnostic, source-first AI router
- Responsive PWA shell

## Run locally
```bash
npm install
cp .env.example .env.local
npm run dev
```
Without `DATABASE_URL`, the product runs in **preview/demo mode**: discovery, official sources, AI routing and module UI work, while persistent login/registration and mutations respond safely with HTTP 503.

Configure PostgreSQL and initialize it:
```bash
npm run db:migrate
psql "$DATABASE_URL" -f db/rls.sql
psql "$DATABASE_URL" -f db/supabase-auth.sql
npm run db:seed:sources
```
The seed is idempotent and imports exactly the 27 approved official channels.

If the original bootstrap has already been applied, deploy the organization-package expansion separately in Supabase SQL Editor:
```text
db/organization-packages.sql
```
This adds DUTA ORGANISASI Free/Plus/Pro persistence, branches, attendance, tasks, publication projects/templates, and ephemeral meeting-transcript records.

For an existing database, deploy the official emergency directory separately:
```text
db/official-emergency-records.sql
```
It records six missions, 14 source-backed contacts, and metadata for all 28 supplied evidence images. The full `supabase-bootstrap.sql` already includes this data for a fresh database.

If database installation status is uncertain or partially applied, use the safe repeatable deployment instead:
```text
db/official-emergency-upsert.sql
```
This script uses `CREATE TABLE/INDEX IF NOT EXISTS`, conditionally creates RLS policies, and upserts records without dropping existing objects.

## Safety and data
- The 27 official channels are sourced only from the provided `data KBRI KJRI.pdf`.
- Last-checked date is 16 Aug 2026, matching that supplied source document.
- No addresses, phone numbers, hours, fees or procedures were invented.
- Community, jobs, products, events and organizations are visibly marked `DEMO DATA`.
- DUTA RANTAU is not a government portal, employment agency, legal provider or medical provider.

## Verification
```bash
npm run typecheck
npm test
npm run build
```

See `IMPLEMENTATION_STATUS.md` for the phased product status and production blockers.
