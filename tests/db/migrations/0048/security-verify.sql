-- 0048 is structural only. This verification records the non-regression boundary:
-- no function, trigger, policy, RLS, grant, role, or ACL statements are present.
SELECT '0048_SECURITY_NON_REGRESSION_SCOPE_PASS' AS marker;
