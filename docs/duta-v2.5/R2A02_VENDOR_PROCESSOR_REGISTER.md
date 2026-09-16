# R2A-02A Vendor / Processor Register

## Document governance

- **DOCUMENT OWNER / ACCOUNTABLE OWNER:** Founder / Managing Director — Interim.
- **SOURCE OF TRUTH:** Vendor and processor evidence register.
- **REVIEW CADENCE:** Before public launch and before vendor activation/change.
- **LAST REVIEW STATUS:** Initial evidence register; `LEGAL_REVIEW_REQUIRED`.
- **UPDATE TRIGGERS:** Contract, processor, region, subprocessor, feature activation, or incident change.
- **DEPENDENCIES:** Processing inventory, cross-border register, DPO assessment, DPIA framework.
- **NO_SECRET_CONTENT:** Required.
- **UNKNOWN / TO_VERIFY HANDLING:** Do not infer processor status from a package or company name.

| VENDOR_ID | VENDOR | EVIDENCE_CLASS / ACTIVATION_STATUS | SERVICE / DATA CATEGORIES / PURPOSE | Region, contract, security and retention | OWNER / EVIDENCE / LAST_VERIFIED |
| --- | --- | --- | --- | --- | --- |
| VND-001 | Supabase | `CONFIGURED_RUNTIME_INTEGRATION` | Auth and database client integration; account/session and application data according to activation | Hosting region, subprocessors, controller/processor role, DPA, retention, deletion, transfer and security review `TO_VERIFY` | Founder / Managing Director; Supabase client/server/admin modules; `TO_VERIFY` |
| VND-002 | NVIDIA | `CODE_REFERENCED / OPTIONAL`; activation `TO_VERIFY` | Optional AI/ASR server configuration | No production personal-data processing is established; region, contracts, subprocessors, retention and transfer `TO_VERIFY` | Founder / Managing Director; `ai-provider.ts` and `asr-provider.ts`; `TO_VERIFY` |
| VND-003 | Vercel | `REPOSITORY_CONFIGURATION_EVIDENCE`; deployment status `TO_VERIFY` | Next.js hosting configuration evidence | Deployment, data categories, region, contracts, subprocessors, retention and transfer `TO_VERIFY` | Founder / Managing Director; `vercel.json`; `TO_VERIFY` |

## Future or unverified providers

Gemini, Groq, OpenAI, email, analytics, storage, maps, and payment providers are not recorded as active processors by this register. If repository or operational evidence emerges, classify each precisely as `CODE_REFERENCED`, `CONFIGURED`, `DISABLED`, `PLANNED`, or `TO_VERIFY` before recording processing facts.

Required register fields for any future row are: **VENDOR_ID, VENDOR, EVIDENCE_CLASS, SERVICE, ACTIVATION_STATUS, DATA_CATEGORIES, PROCESSING_PURPOSE, CONTROLLER_PROCESSOR_ROLE_STATUS, HOSTING_PROCESSING_REGION, SUBPROCESSOR_STATUS, CROSS_BORDER_STATUS, CONTRACT_DPA_STATUS, SECURITY_REVIEW_STATUS, RETENTION_STATUS, DELETION_STATUS, OWNER, LEGAL_REVIEW_STATUS, EVIDENCE, LAST_VERIFIED**.
