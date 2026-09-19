# KPP-03B-R4 — Shell Trust Residuals & Platform Admin Containment

Base checkpoint: `057c134f4919ecfff215d94b69d3c31e2f9c0f5d`
Pass type: narrow remediation / ceremony-readiness. No product scope added.

## Registered residuals and remediation

| ID | Residual found in the Preview RC | Remediation |
|---|---|---|
| R1 | Topbar notification `<button aria-label="Notifikasi">` had no handler, and `.top-actions i` was an unconditional 7×7 red "unread" dot shown to every visitor including anonymous ones. | Bell button and the unread dot element removed. The now-dead `.top-actions i` rule removed from `app/globals.css`. No notification inbox was invented. |
| R2 | Topbar rendered hardcoded personal initials `AR` and a hardcoded `Kuala Lumpur` control with no handler, implying both a real account identity and a real user location. | Both removed. The account affordance is now a neutral `UserRound` icon linking to the real `/profil` destination with `aria-label="Saya"`. No geolocation was introduced and precise location remains disabled. |
| R3 | `/admin` (and `/admin/sumber`, `/admin/content`) were publicly reachable and ungated. | New `app/admin/layout.tsx` gates the whole `/admin` tree server-side via the **existing** platform contract: `getCurrentUser()` → `canUsePlatformCapability(legacyPlatformRoles(user.role), 'platform.config.manage')`. Anonymous → `/masuk`; any role without that capability → `/profil`. |
| R4 (new finding) | `GET /api/admin/health` was unauthenticated and returned deployment configuration posture (`database`, `auth`, `aiProvider`). | Guarded with the same primitive already used by `/api/admin/organizations`: `authorizePlatformApi(req, 'platform.config.manage')`. Verified by grep that nothing consumed this endpoint, so no caller breaks. |

Explicitly **not** introduced: boolean admin flag shortcut, client-only check,
hardcoded Founder identity, universal super-admin assumption, new capability,
new role, or a fake notification inbox.

The admin dashboard's static operational figures (`StatsGrid`, "System health OK")
were **not** changed in this pass — they remain behind the new authorization gate
and are already covered by the existing "false operational state / RBAC-gate
before beta" register entry.

## Tests

`tests/shell-and-admin-containment.test.tsx` — 14 deterministic tests, no DB,
provider, or network dependency. Covers: no fake unread state, no fake `AR`
identity, no implied `Kuala Lumpur` location, exactly five bottom-nav items,
anonymous landing without app chrome, admin gate for anonymous/ordinary
Member/all legacy roles/authorized role, configuration posture not returned to
an unauthenticated caller, no URL/connection-string/key material in the response,
and source pins that prevent the residuals from being reintroduced.

## Validation (recorded environment)

- TypeScript `tsc --noEmit`: exit 0
- ESLint: exit 0
- `next build`: exit 0; `/admin`, `/admin/content`, `/admin/sumber`, `/api/admin/health` resolve as **Dynamic (ƒ)**, not prerendered
- Full Vitest: 22 failed / 278 passed (300) vs pre-change baseline 22 failed / 264 passed (286) — same 22 pre-existing failures, +14 new passing

The 22 pre-existing failures are environmental, not regressions: this review
checkout is a **shallow clone**, so tests pinning historical baseline commits
(`tests/landing-page.test.tsx` baseline `c26fa221…`, migration provenance tests)
cannot resolve their objects, and DB-backed tests (`tests/source-integrity.test.ts`)
have no `APP_DATABASE_URL`.

## Ceremony readiness evidence

`GET /api/admin/health` on Preview deployment `057c134f…` returned, unauthenticated
at the time of measurement:

```json
{"status":"ok","database":"configured","auth":"supabase-configured","aiProvider":"disabled"}
```

This is real runtime evidence and supersedes the static strings previously observed
on `/masuk` and `/admin`: the Preview database **is** configured, and Supabase auth
configuration is present.

**Precision on `aiProvider`.** That field reports `process.env.AI_PROVIDER`, but a
repository search shows `AI_PROVIDER` is read **only** by this health route, and it
does not appear in `.env.example`. The real provider layer reads `DUTA_AI_ENABLED`
plus `NVIDIA_*`, and maps model classes to gemini / groq / openai in
`lib/services/ai-provider-execution.ts`. The reported `disabled` therefore does
**not** establish that Tanya DUTA is disabled on Preview, and it is not evidence of
provider readiness either. Actual provider configuration remains UNKNOWN from
outside the deployment. This admin health field is a misleading indicator and is
recorded here as an open finding; its semantics were not changed in this pass.

## Governance

No migration. No database mutation. No provider configuration change.
Production unchanged. Public beta not authorized.
