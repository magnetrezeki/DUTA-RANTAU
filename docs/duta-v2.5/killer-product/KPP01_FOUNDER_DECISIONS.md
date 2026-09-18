# KPP-01 Founder Decision Register

Date: 2026-09-18. Only material product choices are included.

## FD-01 — Authentication and onboarding contract

- **Question:** Which low-friction primary identity path and fallback should v2.5 launch with?
- **Options:** (A) Google OAuth primary + email magic-link fallback; (B) Google
  OAuth primary + email/password fallback; (C) phone OTP primary; (D) WhatsApp
  OTP primary; (E) staged combination.
- **Repository evidence:** Supabase browser/server clients and OAuth callback already
  exist; Google button exists but provider is disabled. Email/password and recovery
  routes exist but positive lifecycle proof is deferred. Phone/WhatsApp flows do not
  exist.
- **Regulatory impact:** provider processor/data inventory, recovery, consent,
  identity linking, number recycling and cross-border messaging must be addressed.
- **UX impact:** this determines the first-run cognitive load and recovery story.
- **Technical impact:** Supabase provider configuration, callback/linking rules,
  duplicate-account prevention and rate limiting.
- **Recommended direction:** Google OAuth as primary; passwordless email magic-link
  as fallback during v2.5; keep password sign-in temporarily only for existing
  compatible accounts until migration/retirement is decided. Do not select phone or
  WhatsApp OTP for initial launch without cost, recycling, delivery and privacy
  evidence. Use Supabase native linking only after collision tests.
- **Why:** maximizes mobile familiarity with the smallest new surface while retaining
  provider-independent recovery. It reuses current Supabase architecture.
- **Must decide before:** KPP-02 navigation/account entry freeze and KPP-05.

## FD-02 — Public value versus authenticated value

- **Question:** Which capabilities must work before login?
- **Options:** public discovery/guidance with login only for save/create/continue;
  or account-first product.
- **Repository evidence:** most pages are already publicly reachable, while DUTA AI
  API requires Auth; public landing promises discovery.
- **Regulatory impact:** public official guidance is lower data risk; mutations and
  personal context require identity/authorization.
- **UX impact:** account-first adds friction before value is demonstrated.
- **Technical impact:** public deterministic AI/source limits versus authenticated
  quota and persistence.
- **Recommended direction:** public official services, Jaga Diri, jobs/community/
  organization discovery and a bounded DUTA demo; login for saving, joining,
  creating, personalization and continuation.
- **Why:** fulfills the “value before registration” objective without weakening
  mutation controls.
- **Must decide before:** KPP-02 and KPP-04.

## FD-03 — Primary intent architecture

- **Question:** Which three to five intents replace the ten-item module-first shell?
- **Options:** (A) Ask DUTA / Essential services / Safety / Connect / Me; (B) Today /
  Explore / Ask / Safety / Me; (C) preserve modules.
- **Repository evidence:** desktop has ten items; mobile arbitrarily shows the first
  five; search and actions are fragmented.
- **Regulatory impact:** locked modules must not receive primary prominence.
- **UX impact:** determines five-second comprehension and mobile navigation.
- **Technical impact:** route grouping and deep links; no schema dependency.
- **Recommended direction:** Today, Ask DUTA, Essential, Connect, Me, with persistent
  Jaga Diri shortcut and progressive module disclosure.
- **Why:** maps to user intent while preserving discoverability and safety.
- **Must decide before:** KPP-02 UX architecture freeze.

## FD-04 — Organization commercialization timing

- **Question:** Should package prices and paid capability promises remain visible at
  v2.5 launch before payment/provider activation?
- **Options:** hide commercial tiers; show “coming later” without prices; retain
  transparent preview pricing.
- **Repository evidence:** pricing and entitlements are implemented in UI/domain,
  while payment is explicitly disabled and advanced providers are unavailable.
- **Regulatory impact:** avoid misleading commercial claims and unauthorized finance.
- **UX impact:** pricing may distract from the core diaspora value proposition.
- **Technical impact:** entitlement and payment activation sequencing.
- **Recommended direction:** launch a free verified organization presence; hide paid
  purchase CTAs and defer public prices until provider, terms and service evidence
  are ready.
- **Why:** keeps useful discovery without implying unavailable execution.
- **Must decide before:** KPP-02 and any KPP-10 organization redesign.

## FD-05 — 18+ launch enforcement

- **Question:** What proportionate mechanism enforces the current 18+ decision?
- **Options:** self-attestation at account creation; birth-year collection; defer
  accounts and keep public informational access only.
- **Repository evidence:** policy says 18+; no technical gate exists.
- **Regulatory impact:** age assurance and minimization must be balanced; birth date
  is additional personal data.
- **UX impact:** added onboarding friction.
- **Technical impact:** assertion storage/audit or schema work if persisted.
- **Recommended direction:** public information without age collection; lightweight
  18+ self-attestation only when creating an account or submitting user content,
  pending legal review. Do not collect full birth date by default.
- **Why:** meets the current policy with less data and friction.
- **Must decide before:** KPP-05 and release readiness.

