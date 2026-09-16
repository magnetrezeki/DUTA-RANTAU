# R2A-02A Cross-Border Processing Register

## Document governance

- **DOCUMENT OWNER / ACCOUNTABLE OWNER:** Founder / Managing Director — Interim.
- **SOURCE OF TRUTH:** Cross-border processing and transfer fact register.
- **REVIEW CADENCE:** Before public launch and before a processor or region change.
- **LAST REVIEW STATUS:** Initial register; `LEGAL_REVIEW_REQUIRED`.
- **UPDATE TRIGGERS:** Vendor activation, region confirmation, subprocessor change, contract update, or feature activation.
- **DEPENDENCIES:** Processing inventory, vendor register, DPO assessment, DPIA framework, authoritative Malaysian legal review.
- **NO_SECRET_CONTENT:** Required.
- **UNKNOWN / TO_VERIFY HANDLING:** Do not infer geography from vendor headquarters.

## Current verified position

**CURRENT VERIFIED TRANSFERS: NONE CONCLUSIVELY ESTABLISHED from repository evidence.** This is not a conclusion that no cross-border transfers occur. Applicable external processors have **TRANSFER STATUS: TO_VERIFY**.

| TRANSFER_ID | PROCESSING_ACTIVITY | VENDOR | DATA_CATEGORY | ORIGIN / DESTINATION_REGION | PURPOSE / MECHANISM / CONTRACT | Security, retention, subprocessors | Legal review, owner, evidence, last verified |
| --- | --- | --- | --- | --- | --- | --- |
| XBR-001 | Authentication and application database | Supabase | Account and application data | Origin `TO_VERIFY`; destination `TO_VERIFY` | Service operation; mechanism and contract `TO_VERIFY` | Security, retention, deletion and subprocessors `TO_VERIFY` | `LEGAL_REVIEW_REQUIRED`; Founder / Managing Director; repository runtime integration; `TO_VERIFY` |
| XBR-002 | Optional AI/ASR processing | NVIDIA | Input/audio/operational metadata if activated | Origin and destination `TO_VERIFY` | Optional provider; activation, mechanism and contract `TO_VERIFY` | Security, retention, deletion and subprocessors `TO_VERIFY` | `LEGAL_REVIEW_REQUIRED`; Founder / Managing Director; code reference only; `TO_VERIFY` |
| XBR-003 | Hosting configuration | Vercel | Data categories `TO_VERIFY` | Origin and destination `TO_VERIFY` | Deployment status, mechanism and contract `TO_VERIFY` | Security, retention, deletion and subprocessors `TO_VERIFY` | `LEGAL_REVIEW_REQUIRED`; Founder / Managing Director; configuration evidence only; `TO_VERIFY` |

Every future entry must retain the fields **TRANSFER_ID, PROCESSING_ACTIVITY, VENDOR, DATA_CATEGORY, ORIGIN, DESTINATION_REGION, TRANSFER_PURPOSE, TRANSFER_MECHANISM_STATUS, CONTRACT_STATUS, SECURITY_STATUS, RETENTION_STATUS, SUBPROCESSOR_STATUS, LEGAL_REVIEW_STATUS, OWNER, EVIDENCE, LAST_VERIFIED**.
