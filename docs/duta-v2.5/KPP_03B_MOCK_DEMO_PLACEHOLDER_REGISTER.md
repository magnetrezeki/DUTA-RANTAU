# KPP-03B Mock / Demo / Placeholder Register — Initial Evidence

| Path | Surface | Type | Public-beta impact | Action |
|---|---|---|---|---|
| `app/beranda/page.tsx` | Hari Ini “Dekat Anda” | static demo activities | Misleading continuity/activity data | Removed; replaced by honest discovery state in this pass |
| `app/komunitas/page.tsx` | Community cards | `DemoBadge` over DB rows | Mislabels or normalizes demo state; create button unwired | Remove/reconcile only after real data contract and create flow validation |
| `app/kerja/page.tsx` | Jobs | `DemoBadge`, unwired post/save | Could imply live jobs/actions | Block public-beta job interaction until source-backed listing and actions exist |
| `app/profil/page.tsx` | Saya | fixed preview identity and controls | False member state / dead actions | P0 to replace with authenticated state or unavailable surface |
| `components/search-filter.tsx` | Search/filter | no-op controls | Fake discovery affordance | P0 to wire or remove/disable honestly |
| `app/api/marketplace/[id]/route.ts` | Marketplace item endpoints | placeholder success response | Silent fake working endpoint | P0: do not expose; replace with 501/unavailable or real authorized flow |
| `app/admin/page.tsx` | Admin | preview statistics/buttons | Restricted preview surface and false operational state | Keep non-public and RBAC-gate before beta |
| `components/secretary-workspace.tsx` | Organization AI tools | local draft/no-op action controls | Not public-beta real functionality | Defer / clearly mark unavailable |

Test fixtures under `tests/` and `tests/hosted-staging/` are excluded: they are not public UI paths.
