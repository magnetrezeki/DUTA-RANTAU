# Day 2 — NVIDIA Text Inference and Bahasa Benchmark

For general text questions, the DUTA AI router calls the server-only provider abstraction. When `NVIDIA_API_KEY` is present, it sends an OpenAI-compatible `chat/completions` request to `NVIDIA_BASE_URL` (default: NVIDIA Integrate) with `NVIDIA_MODEL` (default: `meta/llama-3.1-8b-instruct`). Official-service and safety routing remain deterministic and source-aware.

The provider never exposes keys, headers, upstream bodies, stack traces, or internal errors. Missing configuration, HTTP errors, timeouts, malformed results, and empty output return a safe fallback. Automated tests use mocked requests and never require a live key.

`scripts/benchmark-nvidia-text.ts --live` is an explicit manual benchmark. It records only category, language, success, latency, provider/model, fallback state, and reviewer-set language/hallucination flags. Its eight categories cover Indonesian, Malay, Malaysia diaspora, KBRI/KJRI, employment, uncertainty, prompt injection, and provider fallback. No live language-quality claim is made until a human reviews benchmark output.

Voice, ASR, TTS, microphone, and realtime features remain out of scope.
