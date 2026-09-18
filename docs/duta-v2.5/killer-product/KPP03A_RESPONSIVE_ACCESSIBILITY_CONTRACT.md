# KPP-03A Responsive and Accessibility Contract
Mobile reference 390×844; stress widths 320 and 360. Tablet 768×1024; desktop
1440×900. Mobile is a single reading/action column. Tablet uses two columns only
when reading order remains clear; desktop constrains line length and whitespace.
No fixed-height text containers; Indonesian/Malay labels wrap.

Five labeled bottom intents retain KPP-02 order: TODAY, ESSENTIAL, ASK DUTA,
CONNECT, ME. ASK central emphasis does not shrink adjacent targets. Global Jaga
Diri remains reachable without overflow. Desktop retains the same model.
Keyboard opening must leave input and submit visible; use dynamic viewport and
safe-area insets in later implementation, with scrollable content.

Acceptance targets: body contrast ≥4.5:1, large text ≥3:1, meaningful controls/
focus ≥3:1; touch targets ≥44×44, primary/safety 48 high; 3px visible focus;
200% text scaling and 320px reflow without content loss. These are project
acceptance requirements, not a claim of a completed accessibility certification.
No color-only error/trust/safety meaning. Visible labels, logical headings,
screen-reader names and understandable error association are required.
Reduced motion has no pulsing/scroll animation. Slow network preserves text,
navigation and media space; no skeleton blocks safety access.

Validation pending KPP-03B: actual browser contrast across all states, keyboard,
screen reader, zoom, long text, viewport and performance measurements.
