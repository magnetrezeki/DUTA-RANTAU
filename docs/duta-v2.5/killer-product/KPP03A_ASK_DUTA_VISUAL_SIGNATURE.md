# KPP-03A ASK DUTA Visual Signature
A useful conversation embedded in the warm DUTA shell. No separate neon,
robot-avatar or full-screen dark AI identity.

| State | Visual + copy | Next action |
| --- | --- | --- |
| Idle | H1 “Apa yang ingin Anda cari?”; labeled field and two example prompts | Type, tap example or voice |
| Text entry | Expanding white field, visible send label | Send/cancel |
| Voice ready | 52px microphone, “Cakap ke DUTA” | Explicit start |
| MENDENGAR | Teal recording indicator + “Mendengar…” + stop | Stop or cancel |
| MEMAHAMI | Static transcript region, “Memahami pertanyaan…” | Review/cancel |
| MENCARI SUMBER | Quiet activity mark + actual state text | Cancel; no fake percentage |
| SIAP | Plain answer + provenance + one next action | Official/action handoff |
| Provider degraded | Amber inline status, retained input | Direct source or retry |
| No trusted source | “Sumber tepercaya belum ditemukan” | Official discovery, clarify |
| Permission denied | Inline explanation, no blocking modal | Type instead |

Status uses aria-live polite; error announcement is appropriate and bounded.
Do not render pretend live evidence. Prototype D uses an illustrative no-source
state and never suggests a provider is operational.
