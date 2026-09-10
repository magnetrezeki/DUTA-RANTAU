# Day 7 Preview Acceptance — Phase A

Preview isolation was verified for commit 820c3a6 on the supplied Preview deployment: branch duta-v2.5 uses staging ref bftdfvihtewjwotrzwwe, not production; NVIDIA is not configured and no public NVIDIA key is present.

Observed defects: database-backed navigation pages failed when staging lacked an application database connection; the chat route mislabeled downstream source failures as validation 400s; MediaRecorder WebM codec parameters caused an incorrect 415; mic denial left a recovery concern. Community lookup was correctly SAFE_UNAVAILABLE. Security disclosure and write-action prompts remained blocked. Mobile layout passed, but navigation failures affected acceptance.

Phase A fixes make those pages render empty staging-safe states, keep KBRI source unavailability safe, normalize explicitly allowed audio MIME parameters, and add regressions. No data was seeded or fabricated. Browser microphone retest remains required.

Answer-first refinement: trusted consulate facts now appear directly in the response with source evidence retained. Info Rantau has no visible href-based category actions; the observed 404 therefore was not caused by its current category controls. Main navigation, 400/415 repairs, and mic text fallback passed the browser repair retest. ASR remains expected 503 while NVIDIA is unconfigured.
