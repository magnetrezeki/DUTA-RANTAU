# DUTA 2.5 target architecture — design only

Preserve the existing application and Supabase data. AI is an optional layer over existing services, not a replacement application.

```text
USER -> TEXT or optional VOICE
     -> DUTA INPUT GATEWAY (validation, identity, quotas, request ID)
     -> ASR if voice -> editable transcript
     -> INTENT ROUTER
     -> DUTA AI ORCHESTRATOR
     -> SOURCE POLICY
     -> RAG / AUTHORIZED DUTA TOOLS / GENERAL AI
     -> RESPONSE VALIDATION
     -> TEXT RESPONSE + PROVENANCE
     -> optional TTS -> VOICE RESPONSE

General AI -> PROVIDER INTERFACE -> NVIDIA hosted NIM
                               -> optional fallback adapter
```

## Responsibilities and boundaries

Gateway keeps transport concerns out of domain services, supports AbortSignal and quotas, and binds verified app identity. Public questions stay public; private organization requests require active membership and entitlement. ASR produces untrusted user text, not privileged instructions.

Router retains deterministic safety/official precedence and can later add evaluated intent classification. Orchestrator chooses an allowed path under source policy. Policy determines acceptable trust/jurisdiction/freshness, authorized data and provider destinations. Official facts require evidence, not model confidence alone. Untrusted retrieved text never changes system policy or authorizes a tool.

RAG retrieves verified, accessible source revisions. Tools are allowlisted typed service calls over existing database boundaries. General AI operates only where permitted and discloses uncited general knowledge. Provider adapters only translate model requests; they cannot access database credentials or grant permissions to tools.

Validator checks output schema, citations, unsupported sensitive claims, required disclaimers and source freshness. Return normalized answer, intent, evidence IDs/URLs, verified dates, confidence basis, limitations, request ID and failure state. TTS uses validated answer text and never removes the visible source record.

## Failure isolation

AI off: existing navigation, account, jobs/community/marketplace/organization and official directory stay usable. ASR off/fails: typing and transcript editing remain. TTS off/fails: full text remains. Provider timeout: deterministic response/source links. Source unavailable: state that limitation rather than return invented official instructions. No AI outage should throw from AppShell or gate non-AI routes.

Use independent flags for inference, retrieval, read tools, voice input/output and realtime. Flags default off until validated; server enforces capabilities, browser receives a nonsecret capability snapshot. Provider fallback respects original data and trust policy, has bounded retries and never duplicates a mutation. Circuit breakers and budgets must work across instances.

## Auditability and privacy

Correlate gateway/router/retrieval/tool/provider/validation events using request IDs. Store minimal intent, model/provider, timings, source revision IDs, tool name, authorization decision and usage. Do not log tokens, cookies, raw audio or unrestricted personal conversations. Define opt-in conversation persistence, user/tenant RLS, retention/deletion propagation and redaction before activating ai_conversations writes.

Keep admin/service credentials server-only; preserve verified-user transaction bridge and reconcile older paths first. Read tools must be safe under both direct HTTP calls and model orchestration. Private data must never enter public PWA caches or shared response caches.

## Mobile and future realtime

Retain current responsive shell and progressive text experience. Add explicit recording/transcript/playback states, cancellation and accessible controls. A future service worker should cache only appropriate static/public assets and must not replay non-idempotent or sensitive requests blindly. Realtime transport is replaceable: prove current Vercel beta fit or use an external gateway with short-lived authorization and shared durable state. See voice report for current platform references and limits.

## Acceptance criteria

Non-AI regression suite passes with every AI/voice provider disabled. No secrets are browser accessible. Official answers cite approved source revisions or abstain. Unauthorized/cross-tenant tool requests fail before data access. Provider failure and disconnected audio recover to text. No mutation is executed solely from retrieved/model instructions. Each stage can be disabled independently without schema rollback or data loss.
