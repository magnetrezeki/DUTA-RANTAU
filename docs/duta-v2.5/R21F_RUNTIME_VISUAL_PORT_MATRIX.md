# R2.1 + R2.1-F runtime visual port matrix

Source of truth: `killer-product/visual-proof-r21f/` (R2.1 composition with final F polish). The R2 and R2.1 galleries retain earlier decisions. This matrix records the pre-edit gap at SHA `1601cef072f1e09633da7b4f6c9c06c2e0b27311`; an HTTP response or CSS token is not visual conformance.

| Surface | Approved R2.1 / F screen | Runtime route and visible composition at baseline | Required replacement and preserved behavior | Bounded state and imagery | Desktop / mobile |
| --- | --- | --- | --- | --- | --- |
| Landing Desktop | 01 / 01 | `/`: new DOM, wrong cutout portrait and compact composer | Hero, portrait framing, light composer, editorial continuation; route links | Generated two-person KL hero, prototype-only; no fake search | Two-column hero, composer under copy |
| Landing Mobile | 02 / 02 | `/`: same DOM, wrong image and stacked controls | Mobile copy, scene, composer, links in approved order | Same hero crop; no fake search | 390px scene and composer proportions |
| Hari Ini Public | 03 / 03 | `/beranda`: HomeGreeting, dark AiChat, service dashboard | Editorial lead, feature, documentary scene, next steps; public routes | Commute image; no fake updates, nearby or personalization | Two-column editorial / scene-first mobile |
| Hari Ini Member | 04 / 04 | `/beranda`: HariIniMember over legacy home | Dark continuity thread, editorial sections; real auth state | No saved/RSVP/followed data invented; same scene selectively | Thread dominant / ordered mobile |
| Tanya Text | 05 / 05 | `/tanya`: PageHeader and dark AiChat | Light composer, intent rows and explanation; preserve API text request | No simulated answer | Two columns / stacked composer |
| Tanya Answer | 06 / 06 | `/tanya`: AiChat answer | Question, sourced answer, numbered steps, next action; preserve real response | Source absent state explicit; no fake citation | Narrow reading column / full mobile |
| Tanya Voice | 07 / 07 | `/tanya`: AiChat voice row | Voice state within approved conversational world; preserve MediaRecorder/transcription and typed fallback | Permission/provider/error states truthful | Focused voice panel / mobile controls |
| Keperluan | 08 / 08 | `/layanan`: dark lead, status cards | Editorial task lead, feature and next-step rows; preserve official source lookup | No map or perwakilan invented; small generated human image if approved for Preview | Two-column task hierarchy / ordered mobile |
| Rantau | 17 / 17 | `/komunitas`: dark lead, status cards | Photographic intro, Kawan Rantau grouping and tabs | Community image; no invented people or joins | Scene and grouping / stacked mobile |
| Community/Activity | 18, 20 / 18, 20 | `/komunitas`, `/organisasi`, `/organisasi/[id]`: data cards | Editorial rows, detail context, activity state; preserve discovery data | No membership, RSVP or verification claims | Context and rows / mobile tabs |
| DUTA Belajar | 28 / 28 | `/belajar`: split lead and empty catalogue cards | Approved learning pathway and source hierarchy | No catalogue, progress or certificate invented; no image needed | Reading column / mobile path |
| Notification Inbox | 27 Saya disclosure / 27 | `/notifikasi`: generic empty panels | Personal disclosure and inbox hierarchy | No owner read or unread count; no image needed | Narrow list / mobile list |
| Saya | 27 / 27 | `/profil`: oversized split hero and anonymous panel | Personal continuity layout, tabs/disclosures and support routes | Real session only; no fake identity or continuation; no image | Narrow personal column / mobile |
| Jaga Diri Desktop | 13 / 13 | `/jaga-diri`: PageHeader, EmergencyContacts, emergency-card, safety bars/grid | Focused calm protection pathway and manual-area route | Public official contacts only, no fake SOS/location; no image | Narrow safety column |
| Jaga Diri Mobile | 13 / 13 | `/jaga-diri`: same legacy composition | Same focused pathway with persistent separate Jaga Diri entry | No precision location; no image | Single narrow column and readable contacts |

Supporting route mapping: `/kerja` → 09; `/layanan` official source section → 10–12; `/organisasi` → 21–22; `/info` → 26; `/belajar` → 28; `/notifikasi` sits under 27 Saya; `/jaga-diri` manual path → 14–16. These routes must visually belong to their world without inventing prototype-only operations.

Asset governance: `hero.png` and the three `ai-*.png` files are generated local prototype imagery. The project documents identify them as generated and explicitly leave final rights/consent/Production approval pending. Preview use must remain identifiable as illustrative AI imagery; Production promotion requires separate approval. Existing `public/arti_ikon-duta.png` is an available app asset but is not an approved substitute for the Landing scene.
