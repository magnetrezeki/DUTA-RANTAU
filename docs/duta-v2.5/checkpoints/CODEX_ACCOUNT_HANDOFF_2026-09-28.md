# Codex account handoff — 2026-09-28

## Repository identity

- Repository: `D:\DUTA-RANTAU`
- Branch: `duta-v2.5`
- HEAD before Founder acceptance: `0913f1b81a8c52301f44528a2afbaa902989fe89`
- Canonical 0046 introduction commit: `9119a7196a2ed254385d3d75be73cacb67709420`
- The authority-and-handoff acceptance commit is created immediately after this checkpoint is staged. Read `git rev-parse HEAD` after it completes for the final local HEAD; the checkpoint intentionally does not self-reference its own commit hash.
- Existing unrelated worktree changes are preserved. Acceptance work is limited to the files named by the acceptance commit.

## Migration model

Numbers `0000`–`0038` are frozen historical evidence and are not a fresh replay path. `DUTA_V2_5_BASELINE_V1` is the schema-only pre-0039 baseline, with SHA-256 `94107afd6ea93c71f308ef51a45153ae908ae43139c8cb69dd53d9288ee36b8e`.

Forward authority is `db/migrations/forward-manifest.json`, enforced by `scripts/check-migration-authority.mjs`. The accepted forward chain is `0039` through `0046`. Canonical 0046 is `db/migrations/0046_official_news_public_publishing_contract.sql` with SHA-256 `fe6f75a5393ad376968d9c8bfd416c5d3edeb5394cd00b8251154e605a550a65` and status `AUTHORITY_ACCEPTED`.

## 0046 identity and Founder acceptance

The following identities are **SUPERSEDED — NEVER USE FOR FOUNDER ACCEPTANCE**:

- `99ac4729880c81a8454f97888f39b0ad33aaeff78579a7fed47fbfea76b3dd28`
- `675da837e51947de21eec12b39fa79b2f52317fec3cb021994acefae049063a1`

Founder explicitly accepted only SHA-256 `fe6f75a5393ad376968d9c8bfd416c5d3edeb5394cd00b8251154e605a550a65` as `AUTHORITY_ACCEPTED`. Any future byte change to canonical 0046 invalidates that exact-SHA acceptance and requires new governance handling.

## ASTRA verification

ASTRA Gate 1 found five blockers. Gate 1B found ASTRA-1B-01: preexisting reviewed/moderated stories with NULL public slugs could not enter publication without administrative repair. Remediation-02 added governed first-slug assignment. Final independent evidence was:

```text
ASTRA_GATE_1C=PASS
ASTRA_1B_01_ROOT_CAUSE_REMOVED=PASS
NEW_BLOCKERS=0
REMAINING_BLOCKERS=0
FOUNDER_ACCEPTANCE_BLOCKER=NONE
```

## Locked architecture

`PUBLIC_READER_AUTHORITY_DECISION=PRESERVE_DUTA_APP_0045_AUTHORITY_USE_0046_NARROW_APPLICATION_PATH`

Accepted 0045 remains unchanged. `official_sources` remains the sole source-authority registry. The application reads the narrow 0046 public projection. First-slug assignment is governed and audited; high-risk moderation and explicit human publication remain mandatory; published slugs remain immutable. One canonical story may retain multiple ordered official source references.

AI does not verify, approve, publish, withdraw, merge, or supersede stories.

## Validation state

Before canonical acceptance, ASTRA Gate 1C independently applied the canonical baseline and accepted 0039–0045 to a fresh disposable PostgreSQL 17 target, applied exact 0046 bytes, and passed public projection, provenance/cardinality, authority abuse, audit, in-flight slug workflow, accepted 0045 compatibility, Drizzle parity, and cleanup. It also recorded typecheck, lint, build, migration authority, migration enforcement, and focused News regression as passing. The acceptance commit reruns the repository authority, enforcement, focused News, canonical 0046 disposable, typecheck, lint, and build checks.

## Database and environment boundaries

Persistent normal-local is `duta-rantau-dev-postgres` on `127.0.0.1:5434`, database `duta_rantau_dev`, role `duta_rantau`. It was not mutated by this acceptance task.

Staging Supabase ref is `bftdfvihtewjwotrzwwe`; production Supabase ref is `uokljxqqvpujwmubildy`. They are distinct. This task did not apply 0046 to staging or production.

Known staging boundary: legacy schema was reconciled/adopted for 0039–0044 and accepted 0045 was applied. News RLS smoke is paused because direct `duta_app` execution evidence remains required. A temporary direct credential, if used, must be generated in memory, never persisted or pasted, and invalidated afterward. Do not resume staging work in this acceptance task.

Vercel staging identity: project `duta-rantau`, account `amar99`, deployment `dpl_8YnjWpKUZatRetGr8teSF76NzJSV`, preview alias `duta-rantau-git-duta-v25-amar99.vercel.app`. `STAGING_APP_NOT_PRODUCTION=PASS`. No deployment occurred here.

## Product-track boundary

The repository contains uncommitted SEO-related work, but public `/info/[slug]` is not established as a completed, validated track. SEO-R1 remains paused until the staging sequence below reaches its database gate.

Do not reopen the frozen historical replay, baseline architecture, accepted 0039–0046 authority, the 0045 `duta_app` authority decision, manual social editorial MVP, no-X-spend/no-scraping constraint, `official_sources` authority, 5W→H editorial contract, or human publication authority without concrete contrary repository or runtime evidence.

## Next execution sequence

1. Verify this checkpoint against repository identity.
2. Prepare the accepted 0046 staging migration gate.
3. Apply accepted 0046 to staging only through the established staging identity.
4. Complete staging News RLS smoke with direct `duta_app` evidence and safe temporary credentials if required.
5. Validate staging public projection, slug workflow, and publication boundaries.
6. After the staging database gate, execute SEO-R1 and `/info/[slug]`.
7. Deploy Vercel Preview and validate SEO and public Info Rantau behavior.
8. Perform production-readiness gate.
9. Perform production work only after explicit authorization.

`NEXT_STEP=STAGING_0046_MIGRATION_AND_NEWS_RLS_GATE`
