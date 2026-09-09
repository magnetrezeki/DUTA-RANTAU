$ErrorActionPreference = 'Stop'
$required = 'NEXT_PUBLIC_SUPABASE_URL','NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY','DUTA_TEST_USER_A_EMAIL','DUTA_TEST_USER_A_PASSWORD','DUTA_TEST_USER_B_EMAIL','DUTA_TEST_USER_B_PASSWORD'
foreach ($name in $required) { if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) { throw "Missing process-only environment variable: $name" } }
node tests/hosted-staging/run-authenticated-rls-tests.mjs
