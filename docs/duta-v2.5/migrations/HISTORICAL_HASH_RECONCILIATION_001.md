# Historical Hash Reconciliation 001

| Field | Value |
| --- | --- |
| Scope | `db/migrations/forward-manifest.json` → `historicalIntegrity.files[]` |
| Defect | `HISTORICAL_HASH_MISMATCH: 0008_phase4_real_content_rls.sql` |
| Root cause class | A — stale artifact (pins), not a modified historical migration |
| Entries corrected | 20 of 35 |
| Historical SQL modified | No |
| Git history rewritten | No |
| Migrations applied to any shared environment | No |

## Summary

`npm run migration:check` failed closed on every run. Twenty of the thirty-five
pinned historical digests did not match the files in the repository. The
migration SQL itself was never at fault: the pins were.

Every meaningful piece of authority inside the repository already treats the
**committed bytes** as authoritative and the pins as a *detector*:

- `scripts/check-migration-authority.mjs` compares each pin to
  `hashFile(file)` — the raw bytes on disk — and reports `HISTORICAL_HASH_MISMATCH`.
- `tests/migration-manifest.test.ts` asserts
  `entry.sha256 === sha256(actual file)` for every historical entry, and
  `entry.checksum === 'sha256:' + sha256(file)` for governed entries.
- `historicalIntegrity.purpose` is `MUTATION_DETECTION_ONLY`; the block is not
  an authority source for the historical set.
- The forward entries `0039` and `0040` carry checksums that match their files
  as committed with LF endings.

The pinned set did not satisfy that contract, so the detector fired on every
run and eleven enforcement tests short-circuited.

## Evidence

### 1. Nineteen of the twenty mismatches are line-ending artifacts

Rendering each mismatching file's committed bytes from LF to CRLF reproduces the
pinned digest for nineteen of the twenty. The remaining file is treated
separately below.

Those nineteen files each have exactly **one** byte-variant across all 110
reachable commits. No commit in the repository has ever contained content that
hashes to the pinned value. The pin cannot therefore be a digest of any
committed artifact — it was taken from a working copy, not from Git.

### 2. The authoring checkout was a CRLF environment

- `.gitattributes` is absent, so no repository-level line-ending normalisation exists.
- `core.autocrlf` is unset.
- The fifteen pins that matched as-is are the LF-authored set; the twenty that
  mismatched correspond to files introduced on a Windows checkout
  (`cccb6a95…`, "docs: prepare staging release readiness gate"), where 0008
  first appears.
- The manifest's own forward entries use LF digests, so the pinned set was
  internally inconsistent with the repository's own convention.

### 3. `0033` is a separate, narrower loss

`0033_moderation_trust_foundation.sql` matches its pinned digest under no
transformation — not as committed, not as CRLF, not with a BOM — at any of the
110 reachable commits. `git log --follow` shows a single creating commit
(`7f6a7c9`) and no later modification. This is per-entry provenance loss for one
pin: the declared value corresponds to no reachable state of the file. It is
corrected here on the same basis as the other nineteen, and recorded as
unexplained rather than as a line-ending artifact.

### 4. A pre-existing governance observation, not remediated here

Five historical files were deliberately modified by later commits while already
committed: `0023` and `0027` by `2d83b43` ("security: enforce core-runtime RLS
on fresh bootstrap") and `0034`, `0035`, `0036` by `427cfa3` ("Harden AI quota
and telemetry migration gate", wrapping bodies in `BEGIN;`/`COMMIT;` and adding
`DROP POLICY IF EXISTS`).

The mutation detector therefore cannot have been a complete immutability record
even with correct digests. Reclassifying those five files is a governance
decision about historical immutability and is **out of scope** for this
reconciliation. It is recorded here as an open item for the Founder, and no
remediation was attempted.

## What was changed, and what was not

Changed:

- The twenty stale digests in `historicalIntegrity.files[]` were corrected to
  the SHA-256 of each file as committed.
- A `historicalIntegrity.reconciliation` block was added pointing at this record,
  so the correction is explicit in the artifact rather than silent.

Not changed:

- No historical migration SQL file was edited. `git status` shows only
  `forward-manifest.json` modified and `0041_audit_runtime_write_grant.sql` added.
- No commit was rewritten, reverted, or re-derived.
- No migration was applied to any shared, staging, or Production database.
- The checker was not disabled, bypassed, or weakened; no test was skipped.

## Why the correction runs in this direction

The alternative — forcing the check to pass by restoring CRLF content to the
working tree — would require rewriting committed historical migrations so that
working copies match a Windows checkout. That is precisely the "illegitimate
historical rewrite" the migration authority forbids, and it would break the
`HISTORICAL_FILESET`/hash contract that the checker and the manifest test both
enforce against the committed bytes.

Correcting the detector to describe the frozen historical bytes preserves the
immutability model. Rewriting the bytes to satisfy the detector destroys it.
