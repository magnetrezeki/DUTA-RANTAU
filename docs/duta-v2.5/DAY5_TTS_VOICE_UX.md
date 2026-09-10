# Day 5 — TTS and Turn-Based Voice UX

Voice input reaches ASR, the existing DUTA AI and trusted-tool path, and the full on-screen answer. A speakable-response policy removes URLs, limits length, and retains uncertainty wording before optional playback. Users explicitly select Dengarkan jawaban or Berhenti; no microphone restart, background listening, realtime voice, or barge-in is implemented.

The server-only TTS abstraction and /api/ai/speak validate text and language and fail safely. NVIDIA TTS is DEFERRED_PROVIDER_VALIDATION because this repository has no established compatible NVIDIA TTS model or endpoint. Browser speech playback is the user-triggered, non-persistent fallback, so a TTS server failure never removes the text answer.

Raw input audio and generated speech audio are not persisted. Indonesian and Malay are supported by the speakable-text path, without quality claims. The benchmark script lists eight manual categories; future live provider tests must use temporary, untracked audio artifacts only.