# Module and tool readiness

WORKING would require runtime evidence; no module is certified end-to-end because validation could not start. PARTIAL means real implementation plus identifiable gaps. PLACEHOLDER means presentation/schema without connected workflow. NOT FOUND means no corresponding product flow discovered.

| Module | Status | Frontend / backend | Data/auth | Limitations and tool suitability |
|---|---|---|---|---|
| DUTA AI | PARTIAL | /tanya, homepage; /api/ai/chat | Public; official_sources | Deterministic routing, no hosted inference or executable tools |
| Jobs | PARTIAL | /kerja; GET /api/jobs, POST /api/admin/jobs | jobs; public RLS reads, EDITOR API writes | Search/filter/save/post buttons unwired, no pagination; extract validated read service |
| Community | PARTIAL | /komunitas; GET /api/community, POST /api/admin/community | communities/community_members; public RLS reads | UI expects location/members absent from queried shape; no join flow; explicit public projection needed |
| Organisations | PARTIAL | /organisasi and detail/secretary/plans; discovery/admin/secretary/transcribe APIs | Many organization tables, roles/plans | Public policy mismatch, local-only drafts, raw DB paths and inactive provider; repair boundaries before private tools |
| DUTA Map | NOT FOUND | No dedicated route/API | Mission coordinates exist | Emergency nearest-office UI is not a general map/search module |
| Info Rantau / News | PLACEHOLDER | /info | contents schema incl sourceId/publishedAt | Category buttons/empty state; no connected article/search API |
| Marketplace | PARTIAL | /pasar; discovery/admin APIs plus public placeholders | products/sellers, public RLS reads | UI expects seller/location/price/trust rather than actual schema fields; no purchase flow; safe read service needed |
| Learning / E-learning | NOT FOUND | No course route/API | No course/enrollment schema found | Education category alone does not implement learning |
| Consular/KBRI/KJRI | PARTIAL | /layanan, /jaga-diri; /api/sources, /api/safety/contacts | official sources/offices/contacts/evidence; public | Directory and bundled fallback implemented; live freshness unverified; no consular transaction workflow |
| Notifications | PLACEHOLDER | Shell bell/profile setting only | notifications schema; owner policies | No delivery, list, read-state or API implementation |
| User profile | PARTIAL | /profil preview; GET/PATCH /api/users/me | users, verified auth + scoped transaction | API real, UI static with unwired edit/settings |
| Account management | PARTIAL | /masuk,/daftar,/auth/konfirmasi; auth endpoints and DELETE /api/users/me | Supabase Auth + users | No wired delete UI/recovery screen; deletion cross-system recovery risk |
| Admin | PARTIAL | /admin,/admin/content,/admin/sumber | Guarded mutation APIs, runtime roles/RLS | Public page shells; preview metrics; role/policy mismatch; incomplete mutation coverage |

## Candidate tools — none implemented

READY would mean a bounded, validated, authorized contract suitable for direct orchestration. Existing endpoints are not automatically safe tools.

| Proposed tool | Readiness | Reason |
|---|---|---|
| search_official_information() | NEEDS REFACTOR | Source service exists; it locates channels, not verified procedural knowledge; add query/freshness/provenance contract |
| find_consulate() | NEEDS REFACTOR | Emergency directory and coordinates reusable; extract pure validated lookup, preserve source date and distinguish nearest from jurisdiction |
| search_jobs() | NEEDS REFACTOR | Real list data; need filters, expiry/status rules, pagination and DTO |
| find_community() | NEEDS REFACTOR | Public list exists; enforce visibility and explicit fields, not member/private data |
| find_organisation() | NEEDS REFACTOR | Directory service exists; resolve public runtime RLS policy; separate public lookup from private office tools |
| search_duta_map() | NOT READY | No generalized map dataset/API |
| search_news() | NOT READY | Contents schema only, no connected news service |
| search_courses() | NOT READY | No course implementation |
| search_marketplace() | NEEDS REFACTOR | Discovery query exists; join seller/trust metadata and remove placeholder mutation contracts |
| get_user_notifications() | NOT READY | Schema only; implement authenticated owner-scoped read before exposing |

Future tools must accept server-verified identity context independently from model arguments, validate input/output, bound results, record source IDs/authorization outcome, and enforce organization scope. Initial scope should be read-only. Never let a model choose a user ID, role, raw SQL, arbitrary URL or secret. Mutations need explicit human intent and idempotency.

## Trusted knowledge / RAG

official_sources has unique URL, institution/channel/category/priority/trustLevel, lastChecked, optional checksum, active and timestamps. contents has unique slug, body, type/category/location, sourceId, trustLevel, recordStatus and publishedAt. official_evidence tracks filePath (unique), capturedAt/effectiveDate and verificationStatus; source-backed emergency data has dates. These are useful foundations, not an existing RAG pipeline.

URL/slug uniqueness is basic deduplication; no normalized URL/content-hash ingestion pipeline, chunk records, embedding model/version/dimension, pgvector extension/index, retrieval evaluation or deletion propagation was found. Article-specific last-verified timestamps and link between exact source revision and quoted claim are missing. Optional checksum is not proof of active content hashing. Public screenshots are evidence assets, not automatically parsed trusted knowledge.

Proposed trust levels: A Official Government; B Verified Organisation; C Verified DUTA Partner; D Community Information; E General AI Knowledge. Existing OFFICIAL_VERIFIED/INSTITUTION_VERIFIED/DUTA_VERIFIED/COMMUNITY_VERIFIED/USER_GENERATED require reviewed mapping, not blind conversion. E must never impersonate a sourced A claim. Official domain alone does not prove that a specific procedure is current.

Future additive source-document-revision-chunk model should carry canonical URL, publisher, jurisdiction, language, published/effective/retrieved/verified dates, verification actor, content hash, allowed use, access scope and embedding version. Retrieval must enforce access and freshness before generation, preserve citations, resist embedded instructions, support revocation/reindexing, and abstain on unsupported high-impact facts. No RAG or schema changes made.
