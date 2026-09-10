# Day 1 — AI Provider Foundation

User input flows through the DUTA AI route and existing intent/safety layer to a server-only provider abstraction. NVIDIA is selected only when `NVIDIA_API_KEY` exists on the server; otherwise a deterministic safe fallback preserves core DUTA behavior.

`NVIDIA_API_KEY` is never public or required for tests. Provider results expose safe provider/model/error metadata only. Text remains supported. `voice` is a future input contract and does not implement ASR, TTS, microphone, or realtime processing.

Day 2 will evaluate actual NVIDIA text integration and benchmarking. Provider outages must never break non-AI DUTA functionality.
