# KPP-02 Route Strategy

Avoid route churn. Existing deep links remain stable while navigation and page
meaning are regrouped under frozen intents.

## UX route audit

Audited 22 page routes and two browser-facing Auth redirect handlers: **24**.
API routes were inspected where they determine Auth, data, permission or state
behavior.

## Retain and regroup

| Route | Target home/status |
| --- | --- |
| `/` | Public Level-0 landing |
| `/beranda` | TODAY; retain |
| `/tanya` | ASK DUTA; retain |
| `/layanan`, `/kerja`, `/info`, `/info/tempat-wisata` | ESSENTIAL; retain deep links |
| `/komunitas`, `/organisasi`, `/organisasi/[id]` | CONNECT; retain |
| `/jaga-diri` | Persistent global safety; retain |
| `/profil` | ME only after real Auth binding; retain URL |
| `/masuk` | Compatibility alias to unified Auth entry |
| `/daftar` | Later redirect/alias to unified Auth entry; preserve inbound links |
| `/auth/konfirmasi` | Retain callback; add validated intended-task return later |
| `/auth/lupa-password`, reset routes | Legacy compatibility only |
| `/pasar` | Stable contained deep link; remove primary prominence |
| `/organisasi/paket` | Remove public purchase/pricing path; later redirect to free-presence explanation or honest unavailable state |
| `/organisasi/[id]/sekretaris` | Auth/role-gated Level 4; no public promotion |
| `/admin/**` | Internal role-gated shell, outside consumer IA |

## Potential aliases

KPP-02 does not require new top-level routes for the five intents. Prefer
existing `/beranda` and `/tanya`; group ESSENTIAL/CONNECT/ME through shell
navigation and lightweight index behavior before inventing `/essential` or
`/connect`. If later evidence requires aliases, use redirects that preserve
deep links and analytics continuity.

## Route-state contract

Query/filter/scroll state survives detail-and-back transitions. Auth handoff
uses an allowlisted relative return route and action marker; it never accepts an
arbitrary external redirect. Unknown/deferred links resolve to an honest state
with parent-intent navigation. Errors do not dump users on landing. Descendant
routes inherit the correct primary intent active state.

## Legacy surfaces to retire later

Ten-item sidebar, first-five mobile slicing, direct public Preview profile/admin,
active package pricing/purchase presentation, inert create/save/filter controls
and Pasar primary links. No route or implementation was changed in KPP-02.
