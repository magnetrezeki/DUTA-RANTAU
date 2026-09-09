# AI provider readiness

## Existing DUTA AI

Evidence: lib/services/ai-router.ts, sources.ts, communication-ai.ts, meeting-transcription.ts; app/api/ai/chat/route.ts; components/ai-chat.tsx; tests/ai-router.test.ts and organization-products.test.ts.

| Component | Classification | Current behavior |
|---|---|---|
| Hosted chat provider/model | NOT FOUND | No inference request or active model configuration; env names alone do not establish Gemini/NVIDIA integration |
| Chat provider abstraction/gateway | NOT FOUND | Route calls answerQuestion directly |
| Intent router | REUSABLE WITH REFACTOR | Regex rules, safety first, then official/jobs/community/marketplace/organization/general; no confidence calibration |
| Orchestrator | REUSABLE WITH REFACTOR | answerQuestion combines routing, source lookup and fixed responses; separate policies/execution |
| Official source service | REUSABLE WITH REFACTOR | Institution/P0/active filtering, checked dates; add trust/freshness and bounded DTOs |
| Conservative response templates | REUSABLE | Declines to invent operational official facts; preserve as deterministic fallback |
| LLM system prompts/prompt registry | NOT FOUND | Templates exist, no LLM system message |
| General agent/tools | NOT FOUND | Search responses advertise help but do not query jobs/community/marketplace |
| API validation | REUSABLE | Zod: message 2–1000 trimmed chars, optional location <=100 |
| Chat authorization | REUSABLE WITH REFACTOR | Public endpoint suitable for public info; authenticated tools must receive separately verified identity |
| Safety policy | REUSABLE WITH REFACTOR | Conservative templates and safety precedence; no model response validator |
| Data-safety implementation | REUSABLE WITH REFACTOR | No external chat provider or storage writes today; add data minimization before provider egress |
| Conversation/message persistence | NOT FOUND | ai_conversations schema has JSON messages/source IDs but chat does not read/write it; no separate message table |
| Streaming | NOT FOUND | One JSON response; UI stores only current result |
| Provider fallback | NOT FOUND | Current deterministic chat is not a failure-aware provider chain |
| Rate limiting | REPLACE | In-memory Map unsuitable for distributed spend/abuse protection |
| Chat logs/audit | NOT FOUND | No correlated chat/tool/provider audit flow |
| Security audit infrastructure | REUSABLE WITH REFACTOR | Existing helper/DB table; strengthen redaction and coverage |
| Communication provider interface | REUSABLE WITH REFACTOR | Interface exists but factory returns null; safe review-only template fallback |
| Meeting transcription interface | REUSABLE WITH REFACTOR | Factory returns null; clears input buffer in finally; not a complete ASR service |
| Current AI tests | REUSABLE WITH REFACTOR | Intent and conservative behavior useful; official-source assertions depend on DB and fixed date; no provider contract/stream/tool tests |

Official-service database errors currently become API 400 'invalid question'; preserve honest safe fallback but distinguish invalid input from temporary dependency failure. Chat fixes location to Kuala Lumpur and has no multi-turn context, cancellation or retry identity. Preserve existing text UX and source cards while improving those contracts.

## NVIDIA adapter design — proposal only

DUTA AI -> AI provider interface -> NVIDIA adapter -> NVIDIA hosted NIM. Optional fallback is another adapter behind the same interface. No model is permanently selected.

Suggested future boundaries: lib/ai/providers/types.ts, registry.ts, nvidia.ts, fallback.ts; lib/ai/orchestrator.ts and lib/ai/policy/. These files do not exist and were not created. Keep app/api/ai/chat/route.ts as transport, validation/auth/limit entrypoint; move provider selection below orchestration. Do not replicate NVIDIA calls in organization or other routes.

Interface should accept normalized messages, model capability requirements, generation limits, AbortSignal and request ID; return normalized text/tool proposals, finish reason, token usage, selected provider/model and structured error. Optional streaming yields typed delta/usage/end/error events. Separate chat, embeddings, ASR and TTS capabilities; one NVIDIA model must not be assumed to support all of them.

NVIDIA documents hosted LLM endpoints and chat completion APIs. The adapter can translate the internal contract to the documented hosted API, keeping credentials on the server and model/base URL in validated configuration. Verify each chosen model's tool, streaming, language and context capabilities with contract fixtures; compatibility is not uniform across models. [NVIDIA LLM APIs](https://docs.api.nvidia.com/nim/reference/llm-apis), [NVIDIA chat completion reference](https://docs.api.nvidia.com/nim/reference/qwen-qwen3-5-122b-a10b-infer).

Use bounded timeouts, request cancellation, output/token budgets and a circuit breaker. Retry only transient failure within the deadline. Fallback may receive only data authorized for that destination; do not silently send private organization content to a second provider. Never bypass source policy on fallback. If both providers fail, return existing deterministic guidance and usable source/module links. Do not repeat a write tool on retry. Retain provenance and provider identifiers, not raw secrets or audio, in metrics.

NVIDIA readiness: architectural integration point is clear; implementation and operational readiness are NOT READY. No key validation, model benchmark, provider request, SDK installation or deployment was performed. Audit/design PASS does not mean hosted inference works.
