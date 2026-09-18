# KPP-01 Founder Decision Register

Date: 2026-09-18. Only material product choices are included.
Decision context: KPP-01A founder decision lock. These locked decisions supersede
the proposed recommendations while preserving their evidence and analysis.

## FD-01 — Authentication and onboarding contract

- **Decision status:** LOCKED.
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
- **Recommended direction (historical proposal):** Google OAuth as primary;
  passwordless email magic-link as fallback during v2.5; keep password sign-in
  temporarily only for existing compatible accounts until migration/retirement is
  decided. Do not select phone or WhatsApp OTP for initial launch without cost,
  recycling, delivery and privacy evidence. Use Supabase native linking only after
  collision tests.
- **Why:** maximizes mobile familiarity with the smallest new surface while retaining
  provider-independent recovery. It reuses current Supabase architecture.
- **Founder decision:** Google OAuth is primary and passwordless email magic link is
  the fallback. Existing email/password sign-in may remain temporarily only for
  compatible existing accounts and is not the primary new-user experience. Phone
  OTP, WhatsApp OTP and Google One Tap are deferred.
- **Implementation constraints:** minimize identity friction and data collection;
  preserve safe recovery; prove ordinary Google OAuth before One Tap; use
  Supabase-native linking only after collision and duplicate-account tests. Phone or
  WhatsApp requires evidence for cost, delivery, number recycling, privacy, abuse,
  rate limiting, recovery, provider dependency and cross-border messaging.
- **Reopen conditions:** material provider, security, recovery, accessibility,
  regulatory or operational evidence invalidates the locked primary/fallback model.
- **Must decide before:** DECIDED before KPP-02 navigation/account entry freeze and KPP-05.

## FD-02 — Public value versus authenticated value

- **Decision status:** LOCKED.
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
- **Recommended direction (historical proposal):** public official services, Jaga
  Diri, jobs/community/organization discovery and a bounded DUTA demo; login for
  saving, joining, creating, personalization and continuation.
- **Why:** fulfills the “value before registration” objective without weakening
  mutation controls.
- **Founder decision:** VALUE BEFORE LOGIN. Public access targets official-service
  navigation, Jaga Diri information/safety, Kerja, Komuniti, Organisasi and suitable
  place/service discovery, plus a bounded non-persistent DUTA experience. Require
  authentication when identity or persistence is necessary.
- **Implementation constraints:** save, join, create, submit, personalize, persisted
  continuation, profile/organization management, user-generated content and other
  identity-bound actions retain authorization. Public DUTA remains bounded by the
  current AI, source and security contracts; mutation controls must not be weakened.
- **Reopen conditions:** a capability's risk, legal basis or abuse model requires a
  narrower public boundary through governed contract change.
- **Must decide before:** DECIDED before KPP-02 and KPP-04.

## FD-03 — Primary intent architecture

- **Decision status:** LOCKED.
- **Question:** Which three to five intents replace the ten-item module-first shell?
- **Options:** (A) Ask DUTA / Essential services / Safety / Connect / Me; (B) Today /
  Explore / Ask / Safety / Me; (C) preserve modules.
- **Repository evidence:** desktop has ten items; mobile arbitrarily shows the first
  five; search and actions are fragmented.
- **Regulatory impact:** locked modules must not receive primary prominence.
- **UX impact:** determines five-second comprehension and mobile navigation.
- **Technical impact:** route grouping and deep links; no schema dependency.
- **Recommended direction (historical proposal):** Today, Ask DUTA, Essential,
  Connect, Me, with persistent Jaga Diri shortcut and progressive module disclosure.
- **Why:** maps to user intent while preserving discoverability and safety.
- **Founder decision:** the primary intent model is TODAY / ASK DUTA / ESSENTIAL /
  CONNECT / ME. Jaga Diri remains a persistent safety shortcut and trust anchor.
- **Implementation constraints:** preserve valid modules through progressive
  disclosure; do not bury urgent/safety access; do not give locked or deferred
  modules misleading primary prominence. KPP-02 determines the exact mobile and
  desktop representation; this decision does not authorize visual redesign.
- **Reopen conditions:** KPP-02 evidence shows the grouping fails zero-training,
  accessibility or five-second comprehension objectives.
- **Must decide before:** DECIDED before KPP-02 UX architecture freeze.

## FD-04 — Organization commercialization timing

- **Decision status:** LOCKED.
- **Question:** Should package prices and paid capability promises remain visible at
  v2.5 launch before payment/provider activation?
- **Options:** hide commercial tiers; show “coming later” without prices; retain
  transparent preview pricing.
- **Repository evidence:** pricing and entitlements are implemented in UI/domain,
  while payment is explicitly disabled and advanced providers are unavailable.
- **Regulatory impact:** avoid misleading commercial claims and unauthorized finance.
- **UX impact:** pricing may distract from the core diaspora value proposition.
- **Technical impact:** entitlement and payment activation sequencing.
- **Recommended direction (historical proposal):** launch a free verified
  organization presence; hide paid purchase CTAs and defer public prices until
  provider, terms and service evidence are ready.
- **Why:** keeps useful discovery without implying unavailable execution.
- **Founder decision:** initial v2.5 launch targets a FREE ORGANIZATION PRESENCE.
  Paid purchase CTAs are hidden/not launch-active and public paid package pricing is
  deferred.
- **Implementation constraints:** internal/domain pricing logic is not public
  activation authority. Commercial tiers require evidence for payment/provider
  readiness, terms, service definition, entitlements, delivery capability,
  regulatory boundary and operational support.
- **Reopen conditions:** all commercial activation evidence is approved in a
  separate governed gate.
- **Must decide before:** DECIDED before KPP-02 and any KPP-10 organization redesign.

## FD-05 — 18+ launch enforcement

- **Decision status:** LOCKED_WITH_LEGAL_REVIEW.
- **Question:** What proportionate mechanism enforces the current 18+ decision?
- **Options:** self-attestation at account creation; birth-year collection; defer
  accounts and keep public informational access only.
- **Repository evidence:** policy says 18+; no technical gate exists.
- **Regulatory impact:** age assurance and minimization must be balanced; birth date
  is additional personal data.
- **UX impact:** added onboarding friction.
- **Technical impact:** assertion storage/audit or schema work if persisted.
- **Recommended direction (historical proposal):** public information without age
  collection; lightweight 18+ self-attestation only when creating an account or
  submitting user content, pending legal review. Do not collect full birth date by
  default.
- **Why:** meets the current policy with less data and friction.
- **Founder decision:** public informational access requires no age collection by
  default. Apply lightweight 18+ self-attestation for account creation and
  identity-bound user action, including user-generated content, where required by
  current launch policy. Do not collect full date of birth or unnecessary birth-year
  data by default.
- **Implementation constraints:** legal review is required before release. This
  direction does not replace legal review, and any persistence must remain
  proportionate, minimal and auditable.
- **Reopen conditions:** legal review requires a different age-assurance mechanism;
  any change must enter a governed contract change.
- **Must decide before:** PRODUCT DIRECTION DECIDED; legal review remains required
  before release and KPP-05 implementation acceptance.
