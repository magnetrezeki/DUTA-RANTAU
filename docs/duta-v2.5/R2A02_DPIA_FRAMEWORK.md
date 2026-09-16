# R2A-02A DPIA Framework

## Document governance

- **DOCUMENT OWNER / ACCOUNTABLE OWNER:** Founder / Managing Director — Interim.
- **SOURCE OF TRUTH:** Reusable DPIA methodology, template, workflow, and queue.
- **REVIEW CADENCE:** Before each queued activation and after material changes.
- **LAST REVIEW STATUS:** Framework only; no DPIA is completed by this document.
- **UPDATE TRIGGERS:** Feature design, data-flow change, processor change, incident, legal advice, or residual-risk change.
- **DEPENDENCIES:** Processing inventory, vendor/cross-border registers, DPO assessment, legal review.
- **NO_SECRET_CONTENT:** Required.
- **UNKNOWN / TO_VERIFY HANDLING:** Unknown design facts block approval rather than being assumed safe.

## Methodology and risk classification

The owner documents purpose, necessity, proportionality, data flow, people affected, vendors, threats, controls, impact, likelihood, residual risk, consultation, legal review, and approval. Impact and likelihood are assessed as `LOW`, `MEDIUM`, `HIGH`, or `TO_VERIFY`; high or unknown residual risk requires documented escalation before activation. Human review cannot be assumed where it is not designed.

## DPIA template

**DPIA_ID; FEATURE; OWNER; STATUS; PURPOSE; NECESSITY; PROPORTIONALITY; DATA_SUBJECTS; DATA_CATEGORIES; SENSITIVE_DATA; DATA_FLOW; VENDORS; CROSS_BORDER; AUTOMATED_DECISION; HUMAN_REVIEW; THREAT_SCENARIOS; PRIVACY_RISKS; IMPACT; LIKELIHOOD; EXISTING_CONTROLS; REQUIRED_CONTROLS; RESIDUAL_RISK; CONSULTATION_REQUIRED; LEGAL_REVIEW_STATUS; APPROVAL; REVIEW_DATE.**

## Approval workflow and reassessment

1. Feature owner creates a `DRAFT` assessment before activation.
2. Accountable owner checks factual completeness and required controls.
3. Legal review occurs where the template states `LEGAL_REVIEW_REQUIRED`.
4. Approval is recorded only after unresolved required controls are addressed.
5. Reassess on a trigger listed in document governance.

## DPIA queue

| Feature | Required point |
| --- | --- |
| AI | Before public launch |
| Voice | Before activation/public launch |
| Verification | Before activation |
| Citizen Report / moderation evidence | Before activation/public exposure |
| Precise location | Before build/activation |
| Career Passport | Before build/activation |
| Job matching | Before build/activation |
| Health | Before build/activation |
| CCTV | Before build/activation |
| MyDigital ID | Legal review and DPIA before integration |
| Cross-border processing | Before public launch where applicable |
