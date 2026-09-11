# Day 8I-A admin and RBAC matrix

Platform and entity authority are separate. A platform assignment never supplies entity membership, and an entity role never supplies a platform capability. Eligibility, verification, legal status, and plans are evaluated separately from either role model.

| Capability | super_admin | compliance_admin | verification_reviewer | moderation_admin | entity roles |
| --- | --- | --- | --- | --- | --- |
| Platform configuration and role assignment | yes | no | no | no | no |
| Eligibility review | no | yes | no | no | no |
| Verification review and evidence access | no | no | yes | no | no |
| Platform moderation | no | no | no | yes | no |
| Entity settings and membership administration | no | no | no | no | owner/admin in the same entity |
| Entity content work | no | no | no | no | owner/admin/secretary/staff in the same entity |
| Entity finance records | no | no | no | no | owner/treasurer in the same entity |

`OWNER`, `ADMIN`, `SECRETARY`, `TREASURER`, `STAFF`, and `MEMBER` are the existing persisted organisation roles. They map to owner, admin, editor, finance, manager, and viewer concepts respectively. No global platform role is inferred from them. Community moderation and multi-role platform assignment require the additive `user_platform_roles` model and a dedicated server-authorized workflow; no self-service assignment endpoint exists.

High-risk activity remains separately gated: marketplace requires `commercial`, paid events require `paid_event`, jobs require `employer`, and payment connection requires `payment_connect`. Plans only confer software entitlements.
