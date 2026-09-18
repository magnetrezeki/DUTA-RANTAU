# KPP-01 Master Product Contract Reconciliation

Date: 2026-09-18  
Mode: audit, reconciliation and design-decision preparation only.

## 1. Authority and method

**FACT:** Technical foundation entered as
`CLOSED_WITH_AUTH_PRODUCT_DEFERMENT`; application baseline candidate is
`cccb6a95eafbafda12165e160f8a38a064380847`; staging is
`bftdfvihtewjwotrzwwe`; 0039/0040 security reconciliation is satisfied;
Production is hard locked.

**REPOSITORY EVIDENCE:** route and component inspection covered every `app/`
page/API, the shared shell, Auth forms, AI/voice/provider services, source and
safety services, domain permissions, and the current v2.5 readiness/privacy/
regulatory records. Filenames were not treated as proof: rendered copy, server
handlers and launch-denial responses were inspected.

The canonical capability contract is
`KPP01_CAPABILITY_MATRIX.md`. It distinguishes historical promise, current code,
governed launch boundary and target role.

## 2. Product inventory summary

Twenty-eight capabilities were audited: 2 implemented, 14 partial, 7
placeholders and 5 not implemented. Only the landing is unqualified
`LAUNCH_ALLOWED`; 13 capabilities are allowed with boundaries, 2 are launch
locked, 11 deferred and 1 internal-only.

There are no job-detail, map or Citizen Report user routes. Pasar is an explicit
placeholder. Profile/settings/notifications visually exist without equivalent
working controls. Admin routes are hidden from the main navigation but the
profile exposes an admin Preview link. No separate notification or general
search results route exists.

## 3. Authentication and onboarding target proposal

**CURRENT IMPLEMENTATION:** email/password register/login/recovery, Supabase
session cookies and callback routes exist. A Google OAuth button calls Supabase,
but the staging provider is disabled. Positive email/password lifecycle evidence
was deferred by owner product decision. Phone/WhatsApp Auth is absent.

**PROPOSAL:** Google OAuth primary; passwordless email magic-link fallback;
temporarily preserve password login only for compatible existing accounts until
a deliberate migration/retirement decision. Do not select phone or WhatsApp OTP
for initial launch without provider cost, delivery, number recycling, recovery,
privacy and abuse evidence. Account linking must be explicit, collision-tested
and recoverable; email/phone equality alone must not silently merge accounts.

Google one-tap may be evaluated as progressive enhancement after ordinary OAuth
is proven. It must not obscure provider disclosure, silently create accounts or
be the only route. Rate limiting, generic recovery responses and session
invalidation remain mandatory.

### Onboarding data minimization

| Field/context | Current request | Target classification | Rationale |
| --- | --- | --- | --- |
| Provider identifier/email | Email required | REQUIRED_AT_IDENTITY_CREATION for chosen provider | Identity and recovery; disclose provider use |
| Password | Required for email path | UNNECESSARY_FOR_V2_5 if passwordless fallback accepted; otherwise provider-specific | Avoid retained cognitive burden |
| Full name | Required | REQUIRED_AFTER_FIRST_LOGIN or OPTIONAL | Not needed to demonstrate public value |
| City in Malaysia | Optional registration field | REQUIRED_AFTER_FIRST_LOGIN, skippable | Enables coarse relevance without precise location |
| Current intent/need | Not requested | JUST_IN_TIME | Ask only when routing a task |
| Precise location | Browser permission in safety UI | SENSITIVE_REQUIRES_EXPLICIT_REASON | Device-local, action-specific, default off |
| Profession, origin, interests | Profile copy implies future use | OPTIONAL / JUST_IN_TIME | Collect only for a chosen feature |
| Full birth date | Absent | UNNECESSARY_FOR_V2_5 | Prefer proportionate 18+ attestation if accepted |
| 18+ attestation | Absent | REQUIRED_AT_ACCOUNT_OR_USER_CONTENT_ACTION pending FD-05 | Current launch policy |

Onboarding minimization is **DECISIONS_REQUIRED** until FD-01 and FD-05.

## 4. Public versus authenticated contract

**PROPOSAL:** before login, provide landing, official services, Jaga Diri,
source-backed work/community/organization discovery, living guides and a bounded
DUTA demonstration. After login, allow saving, joining, creating, continuation,
coarse personalization and profile/privacy controls. After explicit context or
permission, allow browser-local proximity, microphone and organization-role
tools. Restricted/unavailable: marketplace execution, finance execution, health,
e-voting, CCTV, MyDigital ID and uncontrolled Citizen Report publishing.

The contract is **DECISIONS_REQUIRED** only for the public DUTA limit and the
exact Auth entry; its safety boundaries are already governed.

## 5. Information architecture baseline

Desktop navigation has ten module items. Mobile takes the first five, omitting
Kerja, Pasar, Organisasi, Info and Profile despite showing a separate header
avatar. The landing has a second anchor navigation. Beranda repeats module cards.
Search icons route to DUTA AI, while page-level filters are fragmented and not
evidenced as functional. Locked Pasar receives equal prominence; Jaga Diri is
high value but competes with modules.

**PROPOSAL:** freeze intent-led architecture around Today, Ask DUTA, Essential,
Connect and Me, with a persistent Jaga Diri shortcut. Do not freeze visual design
yet. Navigation evidence is **READY_FOR_KPP02**, subject to FD-03.

## 6. Magic Moment readiness

| Layer | State | Evidence / gap |
| --- | --- | --- |
| Text intent handling | PARTIAL | Deterministic routing, source requirement and risk classes exist |
| Voice capture | PARTIAL | Explicit browser recording and permission fallback exist |
| ASR provider | BLOCKED | Endpoint exists; provider unavailable in baseline |
| Trusted retrieval | PARTIAL | Source ranking/contracts exist; staging source data is empty |
| Provider generation | BLOCKED | Adapters exist; live provider disabled |
| Relevant actions | MISSING | Tool router is incomplete; map/news unavailable |
| Provenance | PARTIAL | Result sources/date/disclaimer exist, with a hard-coded display date in UI |
| Progress/fallback | PARTIAL | Recording/transcribing/loading/error states exist; no task continuation |
| Continue task | MISSING | No durable cross-module continuation contract |

Overall Magic Moment readiness: **PARTIAL**. Voice must remain optional; the
magic is trusted completion, not transcription.

## 7. DUTA Today readiness

- Greeting: PARTIAL; client greeting exists, generic identity fallback.
- Cakap ke DUTA: PARTIAL as above.
- Important Today: MISSING; news tool unavailable and no governed feed.
- For You: BLOCKED until Auth/context and real preference data.
- Nearby: PLACEHOLDER; current cards and distances are demo/fixed.
- Continue: MISSING; no continuation model.

Existing service shortcuts and the Jaga Diri CTA are reusable. No section may
pretend to personalize. Overall readiness: **PARTIAL**.

## 8. Trust and privacy readiness

**BACKEND GOVERNANCE READY:** source registry governance/evidence schema and
least-privilege contract are reconciled; sensitive governance/evidence is not
readable by ordinary runtime roles. Official source records carry channel,
trust level, checked date and URL.

**USER-FACING TRUST UX PARTIAL:** `TrustBadge`, `SourceMeta`, disclaimers and
official links exist, but use is uneven and some display facts are hard-coded.
Supported label candidates are:

- `RESMI`: only an official institution/channel record with checked URL/date;
- `TERVERIFIKASI`: only a separately defined completed verification workflow;
- `KOMUNITI`: community-origin content, never equivalent to official;
- `USER REPORT`: only in a future private/moderated workflow;
- `AI GUIDANCE`: generated or routed assistance with source/authority boundary.

The labels are proposals until evidence predicates and copy are frozen. Precise
location is device-local/default off in current safety behavior. Privacy notice,
retention, processor, deletion and consent frameworks remain incomplete for
activation. Overall readiness: **PARTIAL**.

## 9. Jaga Diri readiness

Official contact directory, verified bundled fallback, telephone/WhatsApp
actions, source dates, safety guidance and device-local optional geolocation are
present. The product must say “appropriate official contact,” not imply that
geographic nearest equals jurisdiction. Clinic/hospital discovery remains absent
and health stays deferred. Citizen Report remains private/moderator-first and is
not implemented. Overall readiness: **PARTIAL**, suitable for focused refinement
without reactivating deferred scopes.

## 10. Page-by-page UX baseline

| Page/surface | Visual system | Hierarchy | Primary action | Trust signal | Mobile readiness | State coverage |
| --- | --- | --- | --- | --- | --- | --- |
| Landing | CONSISTENT | CLEAR | CLEAR | ADEQUATE | GOOD | Mostly static; no offline state |
| Register/login | CONSISTENT | CLEAR | CLEAR | WEAK | GOOD | loading/error/success; provider-disabled detail weak |
| Beranda | CONSISTENT | CLEAR | UNCLEAR | WEAK | GOOD | demo and empty risks; no offline/permission states |
| Tanya DUTA | CONSISTENT | CLEAR | CLEAR | ADEQUATE | GOOD | loading/error/success/voice permission; empty/provider states partial |
| Kerja | CONSISTENT | CLEAR | UNCLEAR | WEAK | PARTIAL | empty silently blank; locked create CTA |
| Komuniti | CONSISTENT | CLEAR | UNCLEAR | WEAK | PARTIAL | empty silently blank; create not wired |
| Organisasi | CONSISTENT | CLEAR | UNCLEAR | WEAK | PARTIAL | empty handled weakly; pricing/provider mismatch |
| Pasar | CONSISTENT | CLEAR | MISSING | ADEQUATE | GOOD | honest unavailable state |
| Layanan RI | CONSISTENT | CLEAR | CLEAR | ADEQUATE | GOOD | empty silently blank; source cards strong |
| Jaga Diri | CONSISTENT | CLEAR | CLEAR | ADEQUATE | GOOD | permission/fallback/error covered; offline not explicit |
| Info Rantau/tourism | CONSISTENT | CLEAR | MISSING | ADEQUATE | GOOD | explicit empty/disabled states |
| Profile/settings | CONSISTENT | CLEAR | UNCLEAR | WEAK | PARTIAL | mostly placeholder; no save/error/success states |
| Admin | INCONSISTENT | CLEAR | UNCLEAR | WEAK | PARTIAL | static status may contradict runtime |

## 11. Regulatory reconciliation

The target contract preserves: DUTA AI as guidance; Kerja as discovery;
KBRI/KJRI as official-channel referral; finance as inform/connect/authorised-party
execution; Citizen Report as private/moderator-first; Pasar withheld; health,
e-voting, CCTV and MyDigital ID deferred; precise location restricted; initial
public launch 18+ with enforcement still requiring FD-05.

Fourteen material conflicts are recorded in `KPP01_CONFLICT_REGISTER.md`. Five
founder decisions are isolated in `KPP01_FOUNDER_DECISIONS.md`.

## 12. Exit decision

KPP-01 documentation is complete. No critical technical blocker prevents founder
decisions or KPP-02 preparation. Because FD-01–FD-05 materially shape the frozen
architecture, classification is `KPP01_COMPLETE_READY_FOR_FOUNDER_DECISIONS`, not
automatic entry into KPP-02.

No application behavior, database, migration, provider, Supabase/Vercel setting,
Production system or deployment was changed.
