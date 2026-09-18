# KPP-03A Founder Review Specimens A–F

Deliverable type: high-detail design specifications, permitted by phase 18.
These are not rendered images, interactive prototypes or operational pages.
All measurements reference the shared design system. Copy below is proposed
product copy, not evidence of live data. Architecture remains KPP-02.

## A — Public landing, desktop (1440 × 900)

Canvas warm paper. Header 80 high; 1200-wide centered content starts x120.
Deep-ink brand plaque at left: DUTA red, RANTAU white. Quiet Masuk and teal
Jaga Diri actions right. Header has no pricing/register promotion.
Hero starts y136, 576px text + 48 gap + 576 image. Audience eyebrow 14/600;
headline 60/700/1.08 at 18ch: “Teman menjalani hidup di Malaysia.” Supporting
copy 18/1.6, 45ch. Primary red “Tanya DUTA” 160×52, secondary ink-outline
“Jelajahi kebutuhan” alongside, gap 12. Trust line 14px below with 16 gap.
Image occupies 576×600; warm natural human scene, right-center focal subject,
16 radius, no text overlay. Below hero, one editorial essential-services row
begins the next section; no six-card feature wall. On image failure, reserved
space and neutral caption preserve layout; text and actions remain available.

## B — Public landing, mobile (390 × 844)

20px gutters, content width 350. Header 64: brand left, labeled Jaga Diri right;
Masuk as quiet returning-user link below header if needed, not a competing CTA.
Hero top gap 24. Eyebrow wraps at 14px; title 36/1.08, approximately three lines.
Supporting copy 16/1.6, max four lines; primary “Tanya DUTA” full-width 48 high;
secondary “Jelajahi kebutuhan” full-width 48 with 8 gap. Trust cue 14px, 12 gap.
Then 350×263 human image, face/hands preserved with mobile art direction.
No background image behind text, no forced viewport-height hero. At 320px or
large text, content naturally pushes imagery lower. Public value is accessible
without authentication; the hero CTA uses /tanya.

## Shared app mobile frame for C–F

390×844, warm canvas, header 64 with compact brand and labeled teal Jaga Diri.
20px gutters; content scrolls. Bottom navigation minimum 72 + safe-area inset,
five labeled intents in order TODAY / ESSENTIAL / ASK DUTA / CONNECT / ME.
Each has at least 44×44 target. ASK uses an outlined 24px microphone/message
symbol and understated raised emphasis, not a large floating orb. Active label
and underline provide non-color cue. Bottom content padding uses measured nav
height + inset +16. Auth can use a full page with the same safety access.

## C — DUTA TODAY, mobile, anonymous/minimal context

At y96: small “Selamat datang” then H1 30 “Ada yang bisa DUTA bantu?”
At 24 gap: single white interaction surface, 20 padding, 16 radius, fine border.
Label “Tanya atau cakap ke DUTA”; text field with visible label, 52px voice
control and “Ketik pertanyaan” alternative. Two low-emphasis text suggestions:
“Cari layanan RI” and “Temukan komunitas”. No fabricated location or name.
Next section at 32 gap: H2 24 “Kebutuhan hari ini”; divided 64px rows for
“Layanan resmi” and “Informasi kerja”, with 20px icons and destination arrows.
No sourced important item exists in this specimen, so Penting Hari Ini is absent.
Nearby uses a plain “Pilih area secara manual” link; no fake distance. For You
and Continue are absent for this anonymous state. Offline variant shows a 14px
inline status above rows; available navigation stays usable. Returning-user
variant may add one genuine continuation row only after persistence exists.

## D — ASK / CAKAP KE DUTA, mobile

H1 30 “Apa yang ingin Anda cari?” and 16px explanation. White multiline input,
visible label “Pertanyaan Anda”, minimum 112 high, 16px text. Send action 48 high;
voice control 52 diameter, paired label “Cakap ke DUTA”. No automatic recording.
Below, one state rail with icon and plain-language status; space reserved to
avoid jumping. In listening variant it reads “Mendengar…” with Stop and Cancel.
In no-source specimen: H3 20 “Sumber tepercaya belum ditemukan”, 16px explanation,
outlined “Jelajahi layanan resmi”, quiet “Perjelas pertanyaan”. No fake citation.
Successful design variant replaces that region with concise answer, 14px source/
checked-date footer, “Panduan DUTA AI” and one named destination. Actual source
content must come from governed records. Permission denied retains input and
focuses typing. Slow/degraded status preserves the same geometry and cancel.

## E — JAGA DIRI, mobile, no location

H1 30 “Butuh bantuan?”; brief explanation that DUTA helps find official channels.
Warning region pale amber, 16 padding, caution icon, H3 “Dalam bahaya langsung?”
and readable guidance to seek local emergency help without waiting for chat.
No claimed dispatch service or invented telephone number. Next: teal 48px action
“Cari kontak resmi”, then labeled manual area selector 48 high. Secondary location
action states purpose and has “Tidak sekarang”; no permission prompt on entry.
Two plain situation rows: “Dokumen hilang” and “Masalah pekerjaan”. Contact-detail
variant uses institution heading, actual checked-date/source, jurisdiction caveat
and telephone/external actions only where supported. Offline displays fallback
age clearly. Safety disclaimer 14px stays adjacent to contact actions.

## F — Auth entry, mobile

Visible Back plus global Jaga Diri. At y112 H1 “Simpan untuk nanti”; body explains
the chosen task will resume after sign-in. White form section, 20 padding,
Google action 48 high first, email outlined action 48 high second, gap 12.
The Google action uses text until an approved logo asset is supplied. New-account
boundary variant shows an unchecked 18+ self-attestation with 44px target and
14px readable label. No name, city, DOB or password in primary entry.
Quiet “Lanjut tanpa menyimpan” returns to public result; compatible existing-account
password entry is separated below. Email variant reveals one labeled field;
waiting variant reads “Periksa email Anda” with generic explanatory copy,
resend cooldown, change email and cancel. Expired-link variant preserves intended
task and offers a new link. All states retain the same typography and spacing.
No mock control initiates provider authentication or collects real credentials.

## Review boundary

These six specimens specify hierarchy, typography, dimensions, color, surface,
navigation, human art direction, state language and actions. Founder review is
of the integrated proposed direction. Pixel rendering, photo approval and actual
five-second/accessibility tests are not claimed complete. No live route was changed.
