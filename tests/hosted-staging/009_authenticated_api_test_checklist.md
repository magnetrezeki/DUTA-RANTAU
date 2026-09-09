# Authenticated API RLS test checklist

In one PowerShell session, set process-only NEXT_PUBLIC_SUPABASE_URL,
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY, DUTA_TEST_USER_A_EMAIL,
DUTA_TEST_USER_A_PASSWORD, DUTA_TEST_USER_B_EMAIL, and
DUTA_TEST_USER_B_PASSWORD. Do not write values to disk or chat. Run
scripts/run-hosted-auth-rls-tests.ps1 from that session.

The runner signs in through the ordinary Supabase API with separate
non-persistent sessions. Any BLOCKED or FAIL result is incomplete security
sign-off. No service-role key, database connection, passwords, or tokens are
stored by the harness.

After the harness, require Gate A PASS with only the approved immutable audit
residue. Run 010_cleanup_authenticated_test_residue.sql manually in the staging
SQL Editor, then run 011_verify_authenticated_test_cleanup.sql and require Gate
B PASS. Run 004 again if a final fixture confirmation is useful.
