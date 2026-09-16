# R2A-02A Data Processing Inventory

## Document governance

- **DOCUMENT OWNER / ACCOUNTABLE OWNER:** Founder / Managing Director — Interim.
- **SOURCE OF TRUTH:** Proposed processing inventory.
- **REVIEW CADENCE:** Before public launch and on a processing change.
- **LAST REVIEW STATUS:** Initial inventory; `LEGAL_REVIEW_REQUIRED`.
- **UPDATE TRIGGERS:** New feature, vendor, data category, storage path, or activation decision.
- **DEPENDENCIES:** Privacy framework, vendor register, cross-border register, DPIA framework.
- **NO_SECRET_CONTENT:** Required.
- **UNKNOWN / TO_VERIFY HANDLING:** Unknown fields use `TO_VERIFY`; legal conclusions use `LEGAL_REVIEW_REQUIRED`.

Each entry has the required fields: **PROCESSING_ID, FEATURE, STATUS, DATA_SUBJECT, DATA_CATEGORY, SPECIFIC_DATA, PURPOSE, COLLECTION_SOURCE, PROCESSING_ACTION, STORAGE_SYSTEM, ACCESS_ROLE, EXTERNAL_RECIPIENT, PROCESSOR_VENDOR, HOSTING_REGION, RETENTION_STATUS, DELETION_METHOD, LEGAL_BASIS_STATUS, SENSITIVE_DATA_STATUS, CROSS_BORDER_STATUS, DPIA_STATUS, OWNER, EVIDENCE, NOTES**.

| PROCESSING_ID | FEATURE / STATUS | DATA SUBJECT / CATEGORY / SPECIFIC DATA | PURPOSE / ACTION / SOURCE | Storage, access, recipients | Governance status |
| --- | --- | --- | --- | --- | --- |
| PROC-001 | Authentication and account lifecycle / `PARTIAL` | Account holders; identity/contact/authentication data | Register, login, recovery, deletion; user and auth context | Supabase/auth and public users; owner/admin scopes; vendor facts `TO_VERIFY` | Retention, legal basis, region, transfer and DPIA `TO_VERIFY` |
| PROC-002 | Profile / `PARTIAL` | Users; profile and presence-related data | Profile operation; user entry and auth context | `users`, presence records; self/admin access | Sensitive status, retention and legal basis `TO_VERIFY` |
| PROC-003 | Organizations / `PARTIAL` | Entity owners and representatives; organization/legal-status claims | Organization workspace and governance; user/admin entry | Entity/organization records; scoped roles | Verification, retention, region and legal basis `TO_VERIFY` |
| PROC-004 | Organization membership / `PARTIAL` | Members/applicants; membership answers and access geography | Membership administration; user submission/review | Membership/application tables; entity-scoped access | Application-answer sensitivity and deletion `TO_VERIFY` |
| PROC-005 | Community membership / `PARTIAL` | Community members; membership/role data | Community participation | Community/member records; scoped roles | Retention and legal basis `TO_VERIFY` |
| PROC-006 | Verification / `PARTIAL` | Users/entities; verification metadata and evidence metadata | Trust/eligibility review | Verification/evidence records; authorized reviewers | `DPIA_REQUIRED_BEFORE_ACTIVATION`; sensitive scope `TO_VERIFY` |
| PROC-007 | Citizen Report / `DEFERRED` | Reporters and reported persons; report/evidence data | Safety and moderation | Repository structures; moderator-first policy | `DPIA_REQUIRED_BEFORE_ACTIVATION`; retention/legal basis `TO_VERIFY` |
| PROC-008 | Moderation evidence / `DEFERRED` | Reporters, subjects, moderators; evidence/review data | Moderation and safety | Restricted moderation records | `DPIA_REQUIRED_BEFORE_ACTIVATION`; sensitive data `TO_VERIFY` |
| PROC-009 | DUTA AI / `PARTIAL` | Authenticated users; message-derived operational metadata | Answer generation and safety routing | AI services/telemetry; provider activation `TO_VERIFY` | Provider, region, retention and cross-border `TO_VERIFY` |
| PROC-010 | Voice/transcription / `PARTIAL` | Meeting participants; audio/transcript/summary | Optional transcription and summaries | Meeting transcript records; audio handling is limited by repository behavior | `DPIA_REQUIRED_BEFORE_ACTIVATION`; consent and retention review required |
| PROC-011 | Official-source retrieval / `ACTIVE` | Public-source publishers; source metadata | Trusted-information retrieval | `official_sources`, evidence and bundled directory | Public data; freshness, retention and region `TO_VERIFY` |
| PROC-012 | Jobs / `PARTIAL` | Public/job source data; employer fields in legacy structures | Public discovery only | Job and external-job records | Employer submission/application/placement disabled; legal basis `LEGAL_REVIEW_REQUIRED` |
| PROC-013 | Marketplace / `DISABLED` | Seller/product fields in legacy structures | No active public discovery or seller creation | Products/sellers legacy structures | Seller onboarding, checkout and payments disabled |
| PROC-014 | Jaga Diri/location-adjacent / `PARTIAL` | Users; browser-selected place and optional browser coordinates | Nearest-office display and safety information | Browser-local behavior and official directory | Precise location private/default off; no stored precise coordinates evidenced |
| PROC-015 | Notifications and telemetry / `PARTIAL` | Users; notification, audit and AI operational metadata | Product notices, security audit, reliability/cost metadata | Notifications/audit/telemetry tables | General analytics vendor and retention `TO_VERIFY` |
| PROC-016 | Files, uploads and admin / `PARTIAL` | Organization users/admins; document metadata/content | Organization administration | Document fields and admin paths; operational upload flow `TO_VERIFY` | Storage processor, deletion and retention `TO_VERIFY` |
| PROC-017 | Legacy membership/payment structures / `LEGACY_PRESERVED` | Members/organization subscribers; billing fields | Historical schema support only | Membership/payment/subscription tables | Consumer subscription absent; payment execution disabled; vendor/legal status `TO_VERIFY` |

All rows have **OWNER:** Founder / Managing Director — Interim; **EXTERNAL_RECIPIENT / PROCESSOR_VENDOR / HOSTING_REGION / CROSS_BORDER_STATUS:** `TO_VERIFY` unless separately evidenced in the vendor and transfer registers.
