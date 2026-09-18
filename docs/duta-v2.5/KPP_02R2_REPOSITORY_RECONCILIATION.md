# DUTA RANTAU v2.5 — KPP-02R.2 Repository Reconciliation

Status: read-only authoritative implementation-gap audit, 2026-09-19.

## Method and boundaries

Controlling inputs are `KPP_02R1_MASTER_PRODUCT_GOVERNANCE_AUTHORITY.md` and
`KPP_02R1_SUPERSESSION_REGISTER.md`. This audit read code, schema, migrations,
tests and governance evidence only. It made no runtime, database, provider,
deployment, Git, or product-authority changes.

## Reconciliation summary

The repository contains substantial technical foundations: Supabase/RLS
migrations, scoped entity/organization data, official-source storage, safety
contacts, authentication, AI routing/quota/telemetry, and focused tests. It is
not yet a material implementation of the full KPP-02R.1 product contract.

Strongest matches are public Layanan RI/Jaga Diri access, text-plus-optional
voice Tanya UX, no observed default Member passport collection, and the absence
of fictional partner benefits. Largest gaps are proactive Hari Ini, the shared
Trusted Information Engine, complete Kawan Rantau, DUTA Belajar, partner
governance, Shariah governance, Trust Center, broadcast governance, and the
required information architecture.

## Material findings

1. **Hari Ini is static/demo, not proactive intelligence.**
   `app/beranda/page.tsx` renders service cards and two hard-coded demo nearby
   cards. It has no evidence of curated priorities, official updates,
   personalization, continuation, or source pipeline consumption.
2. **Tanya DUTA has a credible technical base but remains product-partial.**
   `components/ai-chat.tsx` offers typed input and optional microphone flow;
   `app/api/ai/chat/route.ts` plans AI execution and requires official sources
   for certain intents. The API is authenticated, contrary to the authority's
   bounded public-value direction, and no correction/report/action contract is
   proven end to end.
3. **Safety access is materially public and AI-independent, but presentation
   needs later authority reconciliation.** Public `/layanan` and `/jaga-diri`
   use official data and direct contact navigation/fallback. Completeness,
   verification/freshness across all six missions is not runtime-proven.
4. **Kerja technical controls exist but UI/product wiring is incomplete.** The
   official-job endpoint protects source identity/freshness. `/kerja` instead
   reads the generic jobs table, and the “Pasang lowongan” action is not proven.
5. **Pasar remains a legacy containment state.** Current UI/API withhold it,
   rather than the newly authorized conditional public discovery/connect model.
   No checkout/wallet/escrow/payment execution was found in audited public paths.
6. **The navigation conflicts with current IA.** The flat app-shell structure
   retains Info primary and lacks KEPERLUAN/RANTAU grouping, Orang, Aktiviti and
   Map/Sekitar. This is an implementation conflict, not authority ambiguity.
7. **Admin/moderation is foundation/schema heavy, operation light.** RBAC has
   four platform roles; moderation has cases/actions/evidence. The broader
   scoped Control Center, appeals, human review workflows, dual approval and
   broadcast controls are unproven.
8. **Founder visual lock is documented but not runtime-bound.** KPP-03A.1
   prototype evidence exists; no runtime use or explicit identity-preservation
   manifest for two visual anchors was found. No image was generated/altered.

## Non-conclusions

- No Malaysian legal compliance conclusion is made.
- `AGE_CONTRACT = PROPOSED / LEGAL_CLASSIFICATION_REQUIRED`; no age change or
  default passport requirement was introduced.
- Source links/data, API files, schemas and tests are not treated as proof of
  live provider operation, source verification, RLS deployment, or production
  behavior.
- No remediation or implementation order is proposed in this audit.

See the companion inventory, implementation matrix and supersession audit for
file-level evidence and each mandatory supersession.
