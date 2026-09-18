# KPP-02R.2 Supersession Repository Audit

Status: evidence audit only. Classifications concern repository state, not a
change to current Founder authority.

| ID | Old decision | Current authority | Repository remnant / runtime impact | Classification | Evidence |
| --- | --- | --- | --- | --- | --- |
| S-01 | Paid/RM9.90 consumer membership | Free Member, no consumer paywall | Membership and payment schema retain price fields; landing says free; no proven consumer payment flow. | LEGACY | `db/schema.ts:49,79`; `app/page.tsx` |
| S-02 | Pasar blanket launch lock | Conditional discovery/connect, legal review | Pasar UI says being prepared; public GET returns 503. No discovery/connect runtime. | LEGACY | `app/pasar/page.tsx`; `app/api/marketplace/route.ts` |
| S-03 | Voice-centric Tanya | Text + optional voice | Text is primary; microphone is optional. Chat endpoint rejects `channel: voice` directly, while UI transcribes first. | MATCH | `components/ai-chat.tsx`; `app/api/ai/chat/route.ts` |
| S-04 | Top-level Komuniti | Kawan Rantau umbrella | `/komunitas` is labeled Kawan Rantau but no Orang/Aktiviti hierarchy exists. | PARTIAL | `components/app-shell.tsx`; `app/komunitas/page.tsx` |
| S-05 | Info as mandatory primary menu | Content layer | Info is still a top-level desktop item and not evidenced as feeding Hari Ini/Tanya. | LEGACY | `components/app-shell.tsx`; `app/info/page.tsx` |
| S-06 | Ordinary e-learning | Secondary DUTA Belajar | No DUTA Belajar route/capability found. | MISSING | `app/`, `components/`, `lib/` inventory |
| S-07 | Fictional partner benefits | Hidden until real approved partner/offer | No partner-benefit runtime found. No fictional benefit was evidenced. | MATCH | inventory search; `app/page.tsx` |
| S-08 | RI links behind Member auth | Public | Layanan/Jaga Diri routes are public; source cards render links. | MATCH | `app/layanan/page.tsx`; `app/jaga-diri/page.tsx` |
| S-09 | Pelindungan behind Member auth | Public, AI-independent | Public safety route/contact component has direct links/fallback. | MATCH | `app/jaga-diri/page.tsx`; `components/emergency-contacts.tsx` |
| S-10 | Blanket age authority | Proposed/legal review | No current DOB/passport default flow found; legacy assumptions cannot be ruled out across historical docs. | PARTIAL | `app/api/auth/register/route.ts`; `db/schema.ts` |
| S-11 | Raw KBRI/KJRI feed equals Hari Ini | Curated engine + archive | Hari Ini is static/demo, not raw feed; shared engine is absent. | PARTIAL | `app/beranda/page.tsx`; `lib/services/sources.ts` |
| S-12 | Voice-primary Tanya | Text + optional voice | Same runtime evidence as S-03. | MATCH | `components/ai-chat.tsx` |
| S-13 | Cinematic means heavy media | Lightweight/mobile-first | Landing uses Next Image and no hero video, but current runtime is not human-cinematic and no measured performance evidence exists. | PARTIAL | `app/page.tsx`; `next.config.ts` |
