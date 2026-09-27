# 0046 validation

Status: AUTHORITY_ACCEPTED. Founder accepted exactly the canonical SQL SHA-256
`fe6f75a5393ad376968d9c8bfd416c5d3edeb5394cd00b8251154e605a550a65`.

Superseded identities, never valid for Founder acceptance:

- `99ac4729880c81a8454f97888f39b0ad33aaeff78579a7fed47fbfea76b3dd28`
- `675da837e51947de21eec12b39fa79b2f52317fec3cb021994acefae049063a1`

## Reader contract

Accepted 0045 `duta_app` grants and policies remain intact. The public application
module `lib/services/public-news.ts` executes explicit list/detail projections via
`withPublicTransaction`. The view uses SECURITY INVOKER and explicitly grants
SELECT to duta_app, not PUBLIC/anon/authenticated. Database table access is not
revoked: this is the Founder-approved application boundary, not a new DB identity.

One view row represents one story. Canonical attribution uses the existing
canonical_official_source_id and a reference matching canonical_url. Earliest
created_at then UUID deterministically selects between matching references.
All eligible references are retained in an ordered public array. Missing canonical
reference, inactive/wrong-purpose canonical source, or unapproved publication
state fails closed by excluding the story. Registry authority is never mutated.

## Slug and migration prestate

Migration is transactional. Existing published, withdrawn, superseded, or otherwise
previously published stories receive `news-` plus their UUID without hyphens.
These slugs are unique, stable, and never derived from titles. Other stories keep
NULL until the governed workflow assigns the first slug through
assign_official_news_public_slug. An owning Editor may work on its eligible
routine or submitted high-risk story; a Moderator may assign a missing slug only
after high-risk approval. Assignment is audited, uses a row lock, and cannot
approve or publish. Draft corrections are permitted. First publication
permanently freezes the slug, including after withdrawal/supersession.

No production slug auto-generation trigger exists. Before a real application,
operators must verify the prestate, recovery position, and canonical provenance;
this document grants no remote execution authority. Transaction failure rolls
back the entire migration. Post-publication rollback requires preserving issued
URLs and a separately reviewed recovery procedure, not blind DROP statements.

## Executable evidence and marker audit

`scripts/run-0046-disposable-validation.ps1` delegates to `validate-0046.mjs`.
The runner validates accepted checksums, provisions a uniquely named isolated
PostgreSQL 17 container, tests real pre-0046 data, and cleans up in finally.
Every behavioral marker follows a SQL assertion (NULL is failure), an exact
expected SQLSTATE, or an explicit comparison. The old bulk PASS output is removed.
Real exported Drizzle column metadata and generated public application queries
are tested in `tests/official-news-public.test.ts`; comments cannot satisfy parity.

Accepted 0045 fixtures run in a separate disposable database. Only missing
required user/source fields are adapted in memory. Inactive and service sources
are retained and verified. A fixture-ID-scoped legacy slug trigger bridges old
publication fixtures; production assignment is tested first without that trigger.
Triggers/functions are explicitly dropped and checked in catalogs. No temporary
adapted SQL files exist. Accepted fixture files and migration 0045 stay unchanged.

Remediation audit: removed duplicate role setup from the new runner because the
canonical baseline already creates those roles; retained baseline bytes.
Imported the Node timer explicitly after ESLint flagged the readiness delay.
Expanded negative fixtures to include real high-risk moderation, rejected and
draft rows with slugs; added inconsistent-review and missing-canonical-reference
exclusion tests. No accepted migration or accepted fixture was edited.
