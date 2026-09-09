# Authenticated API authorization matrix

| Test | Actor | Operation and target | Expected business result | Expected authorization layer |
| --- | --- | --- | --- | --- |
| T01 | A | SELECT own profile | allow | ALLOW |
| T02 | A | SELECT B profile | deny | RLS_DENY |
| T03 | A | UPDATE own private_note | allow, then restore | ALLOW |
| T04 | A | SELECT Organization A | allow | ALLOW |
| T05 | A | SELECT Organization B | deny | RLS_DENY |
| T06 | A | SELECT B membership in Organization B | deny | RLS_DENY |
| T07 | A | SELECT Job A | allow | ALLOW |
| T08 | A | UPDATE B private_note | deny | RLS_DENY |
| T09_ADMIN | B | UPDATE own Organization A membership to ADMIN | deny | GRANT_DENY |
| T09_OWNER | B | UPDATE own Organization A membership to OWNER | deny | GRANT_DENY |
| T10_PEER | B | UPDATE A membership | deny | GRANT_DENY |
| T10_ORG | B | UPDATE Organization A name | deny | RLS_DENY |
| T11 | A | UPDATE Job B title | deny | RLS_DENY |
| T12_ALLOWED | A | INSERT own Job A audit event | allow; manual readonly verification follows | ALLOW |
| T12_SPOOF | A | INSERT audit event with B actor | deny | RLS_DENY |
| T12_CROSS_ORG | A | INSERT own-actor audit event for Job B | deny | RLS_DENY |
| T12_DELETE_JOB | A | DELETE Job B | deny | GRANT_DENY |

Membership UPDATE and job DELETE have no authenticated base privilege in the
reviewed policy script. Their GRANT_DENY results are successful boundary tests,
while a GRANT_DENY in an RLS_DENY row remains BLOCKED. Audit INSERT has the
minimal named-column grant; audit SELECT, UPDATE, and DELETE remain absent.
