# Synthetic Staging Identity Checklist

Use this checklist only in the confirmed isolated staging project,
DUTA-RANTAU-V25-STAGING (bftdfvihtewjwotrzwwe). Do not use production
accounts, identities, or data.

## Create two synthetic Auth users

Create two new, distinct, staging-only Supabase Auth users:

| Label | Fixture role |
| --- | --- |
| User A | Owner of Organization A; owner of Job A; actor for the allowed Audit A action. |
| User B | Owner of Organization B and a MEMBER of Organization A; target for cross-user and privilege-escalation denials. |

Use unique staging-only email addresses. The SQL files do not use email
addresses, so do not put email values into the SQL templates.

Ensure both accounts are confirmed and can obtain ordinary authenticated
sessions. Auto-confirmation is acceptable if it is the staging project’s normal
user-creation option. No Auth metadata, app metadata, or user metadata is
required.

## Keep credentials out of chat

Never paste into Codex or any chat:

- passwords;
- access or session tokens;
- refresh tokens;
- service-role keys;
- secret keys.

The only Auth identity values required for the next substitution step are the
two non-secret account identifiers:

- User A UUID;
- User B UUID.

The UUIDs must be different. They are now recorded below with the approved
synthetic fixture mapping; do not substitute any other identities.

## Placeholder mapping

profiles.id is a foreign key to auth.users.id. Therefore each profile UUID
must be the UUID of its corresponding Auth user.

| Placeholder | Value source | Used by |
| --- | --- | --- |
| User A / Profile A | 128d19d8-fe70-4847-8b2e-e1c2d124539e | 003, 005 |
| User B / Profile B | ead4dbce-c4a1-4241-a244-66448e264b79 | 003, 005 |
| Organization A | 4c4b86fc-447d-4cf9-89e3-7c55f412a0a7 | 003, 005 |
| Organization B | a7e3c2dc-6f9e-4a70-a17c-c52002abfbe0 | 003, 005 |
| Job A | c3a31ab8-b2cc-440b-bacd-479205f01de2 | 003, 005 |
| Job B | f9e2eb86-4e57-4141-b2bc-62a16a879cc9 | 003, 005 |
| Seeded Audit A | 1c4d3f78-1fe7-447a-a9dc-847daaa0193a | 003 |
| Seeded Audit B | bd6c4ffb-dc63-49ef-9e2f-e1b0ad00c6aa | 003 |
| Allowed audit test | 6ed26cbd-23a5-4ff4-9432-0709e216447a | 005 |
| Spoofed audit test | fa6a77f7-589e-44fe-8c22-7b2f4e89a1d2 | 005 |
| Cross-organization audit test | 2a365a5d-0bd3-4819-8d80-e75c0fd70fe5 | 005 |

There are no separate profile UUID placeholders: Profile A equals User A, and
Profile B equals User B. There are no membership UUID placeholders because
organization_members has a composite (organization_id, user_id) key. File 004
has no synthetic UUID placeholders.

## Before the next phase

1. Confirm both Auth users are new, staging-only, distinct, and confirmed.
2. Keep credentials private; retain only the two Auth UUIDs for controlled
   substitution.
3. Verify that the concrete mapping below is used consistently without adding
   any other identity values.
4. Do not apply 003, 004, or 005 until their respective execution phase is
   explicitly authorized.
