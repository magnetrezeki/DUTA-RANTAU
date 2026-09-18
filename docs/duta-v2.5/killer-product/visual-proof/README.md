# KPP-03A.1 — Founder visual proof

Status: READY_FOR_FOUNDER_VISUAL_REVIEW. Not founder approved.

Open index.html for the overview and six local HTML prototypes. The renders
folder contains six viewport PNGs, full-page PNGs for scrolling content, a
contact sheet and three supplemental ASK state images. Desktop: 1440×900;
all mobile viewports: 390×844. Full-page images are supplementary.

## Direction and rationale

Teman di Rantau uses warm paper, deep ink, disciplined red actions and calm teal
safety. Human life in Kuala Lumpur anchors the landing. Text-first mobile
composition keeps audience, benefit, action and independent status above the
photo. The same typography, source region and labeled five-intent navigation
continue into the app specimens. Auth uses Google first, email second and a
lightweight attestation. It does not perform sign-in.

## Asset register

TEMPORARY_VISUAL: 1 — hero.png. AI-generated, edited through the built-in
image-generation tool using two owner-provided face references. Woman wears
hijab, faces are intended as friendly young adults. This is an illustrative
scene, not a real testimonial or factual photograph. Source reference portraits
are not copied into this repository. Original generated variants are not used.

PRODUCTION_ASSET_REQUIRED: 1 — final approved hero photograph/illustration with
owner consent, usage rights, likeness approval and mobile/desktop crop approval.
The generated result still requires founder judgment of likeness and apparent age.
Existing lucide-react supplies icons; no external fonts or images are fetched.
The prototype text lockup is a review treatment, not replacement logo authority.

Final image prompt: edit the Kuala Lumpur hero using the woman's and man's supplied
portrait references; depict both as young adults in their mid-20s with friendly,
warm, natural smiles. Woman wears a blush/cream hijab covering hair/neck with
modest long-sleeved clothing; man retains reference hair/glasses with an olive
casual shirt. Preserve the walkway, Petronas context, afternoon light and phone
held naturally. No text, logos, flags or UI. Built-in imagegen mode was used.

## Review and limits

All six screens were visually inspected individually and together. The landing
shows audience, value and first action within the viewport; this is a designer
self-check, not a timed participant test. Cross-screen coherence passes self-review.
Renderer checks show no horizontal overflow at the recorded viewports and all
images loaded. No real Auth, microphone, geolocation, AI, API or provider request
is made. Some links are visual placeholders or navigate among review specimens.

ACCESSIBILITY_VISUAL_CHECK: ISSUES. Readable text and labeled states were reviewed,
but full keyboard/screen-reader/zoom/contrast testing is not complete; the
18+ checkbox itself is 20px inside a larger label region, and some illustrative
field-like regions are static divs rather than accessible functional inputs.
These are explicit prototype limitations, not production-ready components.
Contact-sheet thumbnails are for comparison; use original PNGs for text review.

Today deliberately uses empty/non-personalized examples. Lower sections are in
the full-page render. Durable continuation remains unimplemented. ASK source/date
region is explicitly placeholder metadata, not invented official proof. Supplemental
state images show MENDENGAR, MEMAHAMI and MENCARI SUMBER; base screen shows SIAP.
No fake performance, usability or production certification is claimed.

## Reproduce

Run node build.cjs from a repository with its existing React/lucide dependencies.
Set DUTA_RUNTIME_MODULES to the bundled node_modules directory containing
playwright and sharp; run node render.cjs. The script uses installed Microsoft
Edge headlessly, local file URLs and blocks HTTP requests. No server/deployment
is required. Original KPP-02/KPP-03A documentation and live application remain unchanged.
