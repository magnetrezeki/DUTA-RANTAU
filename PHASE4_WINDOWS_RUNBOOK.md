# Phase 4 Windows LOCAL_STAGING Runbook

Arena cannot access the Windows filesystem or Docker Desktop. Run these commands from the Windows machine only.

## 1. Apply source patch

Download these archives and extract them in order into `D:\DUTA-RANTAU\phase3-package`:

1. `DUTA-RANTAU-MEMBERSHIP-ORG-REDESIGN-PATCH.zip`
2. `DUTA-RANTAU-PHASE4-REAL-DATA-PATCH.zip`

Use an elevated PowerShell only if the directory requires it:

```powershell
Set-Location D:\DUTA-RANTAU\phase3-package
Expand-Archive .\DUTA-RANTAU-MEMBERSHIP-ORG-REDESIGN-PATCH.zip -DestinationPath . -Force
Expand-Archive .\DUTA-RANTAU-PHASE4-REAL-DATA-PATCH.zip -DestinationPath . -Force
Remove-Item -Recurse -Force .\_phase3_zip_inspect -ErrorAction SilentlyContinue
Remove-Item .\lib\demo-data.ts -Force -ErrorAction SilentlyContinue
Remove-Item .\components\secretary-workspace.tsx -Force -ErrorAction SilentlyContinue
```

Do not extract `.env.local`, credentials, or service-role keys from any archive.

## 2. Static gates

```powershell
npm ci
npm run test
npm run typecheck
npm run lint
npm run build
```

Stop if any command fails. Do not modify tests to make them pass.

## 3. Local database only

Confirm Docker container and target before applying anything:

```powershell
docker inspect -f '{{.State.Running}}' duta-rantau-phase1a-postgres
docker exec duta-rantau-phase1a-postgres psql -U duta_rantau -d duta_rantau_staging -Atc "select current_database()||'|'||current_user"
```

The expected output is:

```text
duta_rantau_staging|duta_rantau
```

Then run the guarded local script:

```powershell
.\phase3_apply_local.ps1
```

The script applies migrations 0004 through 0009 and verifies the expected local RLS state, including archival-only organization mutations. It must print:

```text
PHASE3_LOCAL_APPLY_PASS
PHASE3_LOCAL_VERIFICATION_PASS
```

## 4. Local security tests

Set only local connection variables in the current PowerShell process. Do not use a production or unknown Supabase URL.

```powershell
$env:PHASE3_ADMIN_DATABASE_URL = '<local-only-admin-url>'
$env:APP_DATABASE_URL = '<local-only-duta-app-url>'
$env:SYSTEM_DATABASE_URL = '<local-only-duta-system-url>'
$env:ALLOW_RLS_SECURITY_TESTS = 'true'

npm run phase3:seed
npm run test:rls
npm run phase3:pool-test
```

Required markers:

```text
PHASE3_TEST_FIXTURES_READY
PHASE3_ATTACK_MATRIX_SQL_PASS
PHASE3_POOL_IDENTITY_TEST_PASS
```

## 5. Provider configuration blockers

The actual user flows remain blocked until approved providers are configured:

- `SMS_PROVIDER_ENDPOINT` and `SMS_PROVIDER_TOKEN`
- `LOCATION_GEOCODER_ENDPOINT`
- `FACE_VERIFICATION_ENDPOINT` and `FACE_VERIFICATION_TOKEN`
- `OTP_HASH_SECRET`
- `EMAIL_PROVIDER_ENDPOINT` and `EMAIL_PROVIDER_TOKEN`
- payment provider for post-promotion checkout

The application intentionally returns configuration errors instead of fake success when these values are absent.

## 6. Production deployment

Arena did not push GitHub or deploy Vercel. Only after local gates and security markers pass should the Windows operator run the existing repository push/deployment workflow. Verify the actual command output before reporting success.
