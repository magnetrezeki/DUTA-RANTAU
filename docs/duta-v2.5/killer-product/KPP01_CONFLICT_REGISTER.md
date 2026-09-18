# KPP-01 Conflict Register

Date: 2026-09-18.

| ID | Historical or visible promise | Current evidence / governed contract | Conflict | KPP-01A status | Authoritative disposition |
| --- | --- | --- | --- | --- | --- |
| C-01 | Pasar is prominent on landing, desktop navigation and Beranda | Marketplace page is withheld; read/create APIs return 503/410 | Navigation promises an active module that is launch-locked | RESOLVED_BY_FOUNDER_DECISION | FD-03: no misleading primary prominence; preserve only through honest progressive disclosure |
| C-02 | Registration says one account unlocks work, market and organizations | Market is locked and multiple modules are empty/partial | Account value proposition overstates current benefit | RESOLVED_BY_FOUNDER_DECISION | FD-02: demonstrate bounded public value first; identity only where necessary |
| C-03 | Email/password is the complete visible Auth path; Google button exists | Email lifecycle proof is deferred; Google provider is disabled | UI suggests two working routes while neither has complete operational proof | RESOLVED_BY_FOUNDER_DECISION | FD-01: Google primary, magic-link fallback, compatible legacy password only |
| C-04 | Beranda says “Dekat Anda” and shows distances/events | Cards are hard-coded demo data and location is fixed to Kuala Lumpur | Apparent personalization is fabricated | STILL_OPEN | Replace with honest empty/value state until real consented data exists |
| C-05 | Kerja exposes “Pasang lowongan” | Direct submission API is deliberately 410 | Visible CTA conflicts with regulatory lock | STILL_OPEN | Remove/hide launch CTA; keep public discovery/referral |
| C-06 | Komuniti exposes “Buat komunitas” | No evidenced working creation path in current public UI | CTA implies mutation readiness | STILL_OPEN | FD-02 fixes the boundary, but UI must hide creation until authenticated moderated flow exists |
| C-07 | Organization packages advertise paid tiers and payment partner tools | Preview states no payment is processed; finance execution is contained | Commercial promise precedes activation authority | RESOLVED_BY_FOUNDER_DECISION | FD-04: free presence; paid CTAs hidden and public pricing deferred |
| C-08 | DUTA AI page promises agents and relevant sources | Hosted provider is disabled; staging official sources are empty; action tools are incomplete | Magic-moment promise exceeds operational readiness | STILL_OPEN | Preserve bounded deterministic safe core; gate unavailable generation/action claims |
| C-09 | Jaga Diri offers nearest official help and a location action | Proximity is browser-local and not official jurisdiction; health/reporting are deferred | “Nearest” can be mistaken for competent authority | STILL_OPEN | Use appropriate-official-contact wording and explicit location permission |
| C-10 | Info Rantau presents a broad living guide taxonomy | Only tourism route exists and is empty; other categories disabled | Broad navigation creates empty expectations | DEFERRED | Progressive category release only as verified content becomes ready |
| C-11 | Profile/settings imply editable profile, privacy, notifications, activity and security | Static preview identity and mostly inert buttons | Control surface overstates user agency | STILL_OPEN | Show only working ME controls; prioritize privacy/account lifecycle |
| C-12 | “Rumah digital” navigation is module-centric with ten desktop items | FD-03 locks TODAY / ASK DUTA / ESSENTIAL / CONNECT / ME | Information architecture mirrors repository modules, not user needs | RESOLVED_BY_FOUNDER_DECISION | KPP-02 must apply the locked intent model and progressive disclosure |
| C-13 | TrustBadge can visually imply verification | 0039/0040 governance exists but sensitive governance/evidence is intentionally unavailable to `duta_app` | Backend governance readiness does not automatically support every user label | STILL_OPEN | Define label evidence rules and safe publication/read model before expanding badges |
| C-14 | Initial launch is founder policy 18+ | No technical age gate is implemented | Governed launch rule is not enforced by product | LEGAL_REVIEW_REQUIRED | FD-05 locks lightweight attestation/no default full DOB, subject to legal review before release |

KPP-01A totals: **5 RESOLVED_BY_FOUNDER_DECISION**, **7 STILL_OPEN**,
**1 DEFERRED**, **1 LEGAL_REVIEW_REQUIRED**.

No conflict above authorizes implementation or reactivation.
