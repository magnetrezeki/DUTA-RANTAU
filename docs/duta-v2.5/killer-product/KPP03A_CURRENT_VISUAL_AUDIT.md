# KPP-03A Current Visual Audit
Date: 2026-09-18. Method: repository source/style inspection, not a rendered browser usability test.
Baseline: 11903894bed17e567476370d51e638fcc51d6a24.

| Surface/evidence | Finding | Design response |
| --- | --- | --- |
| app/globals.css | Navy #071a3b, bright red #ed1c24, many blue/green/yellow/purple tiles and gradients | Consolidate semantic palette; remove arbitrary module colors |
| app/landing.module.css | Warm #faf8f3, red #bb2434, ink #112b38 already closer to desired warmth | Extend this direction into a proposed shared system |
| Typography | Inter named before system fallbacks; package/layout has no evidenced downloaded font setup | Use existing system sans; do not assume Inter is installed |
| Shell | 244px gradient sidebar, 10 desktop items, mobile first-five slice; small labels | Apply frozen five-intent model with readable labels |
| Landing | Strong audience copy; symbolic logo/tiles instead of human image; register CTA dominates | Human scene plus Ask-first hierarchy |
| Beranda | Repeated cards and colored icon grid; demo nearby distances | Single dominant Ask surface, editorial sections and honest empty state |
| AI | Large dark gradient panel, pills and multiple nested containers | Warm conversation workspace with source footer and quiet state rail |
| Auth | Password/name/city form above Google; tiny helper text | Google first, email fallback, contextual benefit and minimal attestation |
| Jaga Diri | Red warning treatment mixed with brand; 7–10px source/contact metadata | Calm teal identity; readable source/date and clear urgency copy |
| Kerja | Repeated card, demo/trust badges, inert bookmark/create controls | List rows; evidence-backed source line; no false active actions |
| Komuniti | Gradient cover placeholders and repeated cards | Human/group content only when genuine; compact discovery rows otherwise |
| Organisasi | Pricing banners, summaries and dark permission panel compete | Free presence and restrained discovery; no public pricing |
| Profile | Preview identity, inert controls, admin link | Real-state ME hierarchy and visible privacy entry |
| Shared ui.tsx | Generic empty/loading components, badge patterns | State-specific explanation plus recovery action |
| Forms/search | Some outline:0 declarations; variable focus support | Visible focus token and labeled fields everywhere |
| Motion/mobile | Smooth scroll, spinner, hover translation; dense small app text | Reduced-motion contract; fluid layouts and minimum readable metadata |

Generic patterns: all-card layouts, icon-cover blocks, equal-weight service grids,
dashboard summaries and excessive tiny uppercase labels. Human presence and
Malaysia context are mainly copy; existing logo assets do not supply a human
photographic scene. Preserve clear source/executor disclaimers. Current-state
findings are not claims about all browser sizes or assistive technologies.
