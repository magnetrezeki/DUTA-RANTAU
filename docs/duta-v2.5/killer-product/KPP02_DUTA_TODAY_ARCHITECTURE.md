# KPP-02 DUTA TODAY Architecture

`/beranda` remains the compatible route and becomes **DUTA TODAY**, not a
module dashboard.

## Section order and data contract

1. **Greeting:** time-appropriate, generic when anonymous; never invent a name
   or location.
2. **Cakap ke DUTA:** compact ASK DUTA entry with text/tap and optional voice.
3. **Penting Hari Ini:** only time-sensitive items with trusted source,
   currentness and relevance rationale. Hide the section when no contract-backed
   item exists.
4. **Untuk Anda:** authenticated and explainable only. New/minimal-context users
   see a prompt to choose an interest or a non-personalized essential shortcut,
   never fake personalization.
5. **Sekitar Anda:** coarse/manual public context first; precise device location
   only after an explicit request. No fixed Kuala Lumpur or demo distances.
6. **Lanjutkan:** authenticated persisted tasks only. Anonymous users may retain
   safe in-session context but are not told it is saved.

## Audience states

| User | Architecture |
| --- | --- |
| Anonymous | Generic greeting, ASK DUTA, sourced public important items, coarse/manual nearby, no fake For You/Continue |
| New authenticated | Greeting, first useful task, optional coarse context; empty-safe personalization |
| Returning | Explainable For You and Continue from real persisted state |
| Minimal context | Broad sourced items plus a voluntary context prompt |
| Location denied | Manual area selector and non-location essentials |
| No relevant content | Hide optional section or show one honest empty state with Essential/Ask action |
| Offline/degraded | Cached non-sensitive items with freshness; text navigation; no false live status |

Every section implements loading, empty, error, offline/degraded and success.
Location permission is section-local. Auth is requested only for persistence or
personalization. The current service icon grid and hard-coded “Dekat Anda”
cards are legacy surfaces to retire during implementation.
