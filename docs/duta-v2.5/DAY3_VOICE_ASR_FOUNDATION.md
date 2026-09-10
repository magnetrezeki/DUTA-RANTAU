# Day 3 — Voice Input and ASR Foundation

Tap-to-talk is explicit: browser recording starts only after the microphone button is pressed, then submits an in-memory audio blob to `/api/ai/transcribe`. The server validates five audio types, rejects empty files and files above 10 MB, and passes valid audio to a server-only ASR abstraction. The returned transcript then enters the existing read-only DUTA AI chat path.

Raw audio is never written to Supabase, the database, filesystem, analytics, or application logs. It is discarded after the request; transcripts are treated as untrusted user input and cannot trigger privileged actions.

NVIDIA ASR is configured only with `NVIDIA_API_KEY`, `NVIDIA_ASR_MODEL`, and optional `NVIDIA_ASR_BASE_URL`. Missing configuration, timeout, malformed output, and provider failures give a safe message while text entry remains available. Indonesian is the default request language; Malay is supported through request metadata, and mixed-language quality is not claimed.

Run `tsx scripts/benchmark-nvidia-asr.ts <category> <audio-file> --live` only for manual testing. It reports safe metrics for Indonesian, Malay, mixed speech, Malaysian place names, KBRI/KJRI terms, migrant-worker vocabulary, noise, and short questions. It does not retain audio or print transcripts. Realtime voice and TTS remain deferred.
