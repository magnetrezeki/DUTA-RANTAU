# Voice readiness

Static application inspection on 2026-09-08; no microphone access or voice implementation performed.

| Capability | Current evidence |
|---|---|
| Microphone permission handling | NOT FOUND |
| MediaRecorder / getUserMedia | NOT FOUND |
| Web Audio / AudioContext | NOT FOUND |
| Audio selection | PARTIAL: secretary UI stores selected filename only; process button has no handler |
| Audio upload endpoint | PARTIAL: authenticated organization transcription multipart handler, consent, MIME allowlist and 25 MB check; not connected to UI |
| ASR/transcription | NOT FOUND operationally: interface exists, factory returns null |
| TTS/playback | NOT FOUND |
| WebSocket | NOT FOUND in application |
| SSE / streaming response | NOT FOUND; chat uses JSON |
| PWA | PARTIAL: linked standalone manifest and logo; no service worker/registration or offline strategy |
| Mobile UI | Responsive CSS, bottom navigation, safe-area padding, Indonesian document language and viewport |
| Chat voice suitability | Text, loading, error/retry and source cards are reusable; only one answer, no audio state/transcript editing/cancel control |
| Browser compatibility | Geolocation capability/error handling exists in emergency contacts; no microphone MIME/device compatibility handling |

## Hosting constraints

Existing vercel.json declares Next.js only. No inspected deployed plan, duration override, region, persistent session store, queue or realtime service. The current multipart route allows 25 MB, exceeding the documented 4.5 MB Function request/response payload limit; it cannot be assumed deployable unchanged. Use short bounded recordings or a separately authorized ephemeral upload path with retention controls. [Vercel Function limits](https://vercel.com/docs/functions/limitations).

Current Vercel documentation describes WebSocket support in beta. Connections end at Function maximum duration and reconnects may reach a different instance; persistent coordination must be external. Therefore a blanket claim that Vercel cannot host WebSockets would be outdated. This repository has no WebSocket implementation and its framework/deployment capability still needs a Preview proof. Keep external realtime infrastructure as an architectural option. [Vercel WebSockets](https://vercel.com/docs/functions/websockets).

## Optional voice design

Begin with push-to-talk: explicit permission -> supported recording format -> bounded recording -> cancellable upload -> ASR -> editable transcript -> existing text submission. Denied permission, unsupported browser, interruption or ASR error must leave typing available. Stop media tracks on completion/unmount; handle mobile backgrounding and network loss. Do not promise reliable continuous background recording from a PWA.

Add optional TTS only after validated text. User chooses playback; handle autoplay restrictions, stop/replay and text alternatives. Do not speak unvalidated partial official claims. Test actual Android Chrome and iOS Safari, supported recorder MIME types, low bandwidth, screen readers and Bluetooth device changes. Current compatibility is unverified, not presumed broken.

Voice state model: idle, requesting-permission, recording, uploading, transcribing, transcript-review, thinking, ready, speaking, error/cancelled. Preserve source links and visible text throughout. Raw audio retention defaults to none; disclose third-party processing and define separate consent for storing transcripts. Zeroing a Uint8Array does not guarantee provider-side deletion.

For later realtime: transport abstraction, short-lived session authorization, per-message quotas, cancellation/barge-in, reconnect sequence numbers, durable minimal state outside function memory, and tenant-scoped tool authorization. Select Vercel beta or an external realtime gateway only after latency/reliability and security tests. Non-AI modules must have no dependency on that choice.

Voice readiness result: PARTIAL UI foundation; NOT READY for production voice. Audit PASS means these gaps were documented.
