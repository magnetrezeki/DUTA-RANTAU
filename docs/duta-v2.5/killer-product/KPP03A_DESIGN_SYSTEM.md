# KPP-03A Design System
Specification only. All sizes are CSS pixels unless rem is stated.
## Semantic palette
| Token | Value | Role |
| --- | --- | --- |
| canvas | #FAF8F3 | Warm page background |
| surface | #FFFFFF | Forms and bounded interactions |
| ink | #172E35 | Main text, brand plaque |
| muted | #52636B | Secondary text |
| brand | #B32438 | Primary action, DUTA wordmark |
| brand-hover | #921D2E | Hover/pressed |
| safety | #185B54 | Jaga Diri action with shield and label |
| safety-surface | #EAF3EF | Calm safety region |
| danger | #9C2533 | Error/destructive text, never unlabeled |
| danger-surface | #FFF0EE | Error field region |
| warning | #76520D | Caution text on #FFF3D6 |
| success | #225B3A | Confirmed success on #ECF5EE |
| line | #DADFD9 | Decorative separators, not sole control boundary |
| control-border | #718078 | Input/control edge |
| focus | #245BCC | 3px outline, 3px offset |

Brand red means action/identity; errors always include an error icon, explicit
message and field association. Destructive actions say what will be removed and
require a separate confirmation. Jaga Diri uses teal, shield and words; immediate
danger guidance uses warning framing and plain language without flashing red.
Color never establishes official status.
## Typography
Use ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif.
No new font dependency. Existing Inter name is not evidence of font delivery.

| Role | Mobile / desktop | Weight | Line height |
| --- | --- | --- | --- |
| Display | 36 / 60 | 700 | 1.08 |
| H1 | 30 / 40 | 700 | 1.15 |
| H2 | 24 / 30 | 650 or 700 fallback | 1.25 |
| H3 | 20 / 22 | 650 or 700 fallback | 1.3 |
| Body | 16 / 18 | 400 | 1.6 |
| Small | 14 / 14 | 400 | 1.5 |
| Caption | 13 / 13 | 400 | 1.5 |
| Label/button | 15 / 16 | 600 | 1.3 |
| Trust metadata | 14 / 14 | 400–600 | 1.5 |

Prose maximum 65ch; hero headline 18ch; mobile headings wrap naturally. No fixed
text heights. Navigation labels 12px minimum, other actionable text 14px minimum.
## Spacing/layout
Scale: 4, 8, 12, 16, 20, 24, 32, 48, 64, 96. Mobile gutters 20 (16 at 320px),
tablet 32, desktop 48. Content max 1200; reading 720; form 440.
Sections 40 mobile/72 desktop; list rows 16 vertical; card padding 20/24.
Bottom clearance: nav measured height + safe-area inset + 16. Sticky header
64 mobile/80 desktop. No two overlapping sticky action bars.
## Surfaces
Plain content for prose; section spacing for grouping; divided rows for repeated
results. Card only when independently actionable or self-contained. Featured
card reserved for one primary task. Action card includes verb and destination.
Trust region is an inline footer, not another nested card. Safety region uses
teal tint. Modal/sheet is for bounded interruption with visible close/back.

Radius: controls 10, cards 16, sheet 24 top corners; no arbitrary per-module
radius. Borders 1px; one soft shadow only on elevated sheets/popovers
(0 12px 36px rgba(23,46,53,.12)). Avoid shadows on every result.
## Actions and icons
Primary: solid brand, one per local decision. Secondary: ink outline. Tertiary:
quiet surface. Text links underlined in prose. Destructive: explicit danger
label; safety: teal shield action. Voice: outlined microphone circle, 52px,
state label adjacent; typing remains equally reachable.

Retain lucide-react. 20px in controls, 24px navigation, 16px metadata; stroke 2,
consistent optical centering. Icons accompany visible labels; decorative icons
are hidden from assistive technology. No emoji navigation or robot avatar.
## Motion
CTA feedback 100ms; navigation 160ms; sheet 220ms ease-out; page content fade
120ms without delaying first paint. Listening uses subtle level indicator only
while recording; processing uses honest textual states, no invented progress.
Success uses static confirmation plus optional 120ms fade. Reduced motion removes
transforms, pulses, smooth scrolling and repeated animation; text remains.
