# AI fair-use quota policy

The authoritative production policy is **30 weighted AI units per authenticated user per UTC calendar day**.

`public.consume_ai_usage` is the authoritative persistent enforcement boundary. Model weights and the user identity are derived by the server; the browser cannot choose either. `lib/services/duta-ai-fair-use.ts` is a deprecated compatibility meter used only by legacy unit tests and is not a production enforcement path.
