[CmdletBinding()]
param(
    [string]$ContainerName = 'duta-local-test-db-0043',
    [int]$LoopbackPort = 55434
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$docker = 'C:\Users\User\AppData\Local\Programs\DockerDesktop\resources\bin\docker.exe'
$psql = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'
$database = 'duta_local_test_0043'
$repository = Split-Path -Parent $PSScriptRoot
$adminPassword = (([guid]::NewGuid().ToString('N')) + ([guid]::NewGuid().ToString('N'))).Substring(0, 48)
$appPassword = (([guid]::NewGuid().ToString('N')) + ([guid]::NewGuid().ToString('N'))).Substring(0, 48)
$created = $false

function Invoke-Database {
    param([string]$Role, [string]$Password, [string]$Sql, [string]$File, [switch]$ExpectAuthSchemaFailure)
    $env:PGPASSWORD = $Password
    $previousErrorAction = $ErrorActionPreference
    try {
        # Windows PowerShell promotes native stderr (including PostgreSQL
        # NOTICE messages) to ErrorRecord objects. Judge psql by its exit code.
        $ErrorActionPreference = 'Continue'
        $arguments = @('-X', '-q', '-v', 'ON_ERROR_STOP=1', '-h', '127.0.0.1', '-p', $LoopbackPort, '-U', $Role, '-d', $database)
        if ($File) { $output = & $psql @arguments -f $File 2>&1 }
        else { $output = $Sql | & $psql @arguments 2>&1 }
        $exitCode = $LASTEXITCODE
        if ($ExpectAuthSchemaFailure) {
            if ($exitCode -eq 0 -or ($output -join "`n") -notmatch 'permission denied for schema auth') {
                throw 'The staging auth-schema failure was not reproduced.'
            }
            return
        }
        if ($exitCode -ne 0) { throw ($output -join "`n") }
        return $output
    } finally {
        $ErrorActionPreference = $previousErrorAction
        Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path $docker) -or -not (Test-Path $psql)) { throw 'Required local Docker or psql executable is unavailable.' }
if (@(& $docker ps -a --filter "name=^/$ContainerName$" --format '{{.Names}}') -contains $ContainerName) {
    throw 'Disposable validation container already exists.'
}

try {
    & $docker run -d --rm --name $ContainerName `
        --tmpfs '/var/lib/postgresql/data:rw,noexec,nosuid,size=1024m' `
        -p "127.0.0.1:${LoopbackPort}:5432" `
        -e "POSTGRES_DB=$database" -e 'POSTGRES_USER=postgres' -e "POSTGRES_PASSWORD=$adminPassword" `
        postgres:16-alpine | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Disposable PostgreSQL start failed.' }
    $created = $true

    $ready = $false
    foreach ($attempt in 1..30) {
        $previousErrorAction = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $docker exec $ContainerName psql -U postgres -d $database -c 'select 1' 1>$null 2>$null
        $ErrorActionPreference = $previousErrorAction
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) { throw 'Disposable PostgreSQL did not become ready.' }

    $topology = @'
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN BYPASSRLS;
CREATE ROLE duta_system NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE SCHEMA auth AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA auth FROM PUBLIC;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role, postgres;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT coalesce(nullif(current_setting('request.jwt.claim.sub',true),''),(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub'))::uuid
$$;
CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$
  SELECT coalesce(nullif(current_setting('request.jwt.claim',true),''),nullif(current_setting('request.jwt.claims',true),''))::jsonb
$$;
CREATE FUNCTION auth.role() RETURNS text LANGUAGE sql STABLE AS $$
  SELECT coalesce(nullif(current_setting('request.jwt.claim.role',true),''),(nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'role'))::text
$$;
GRANT EXECUTE ON FUNCTION auth.uid(), auth.jwt(), auth.role() TO PUBLIC;
'@
    Invoke-Database postgres $adminPassword $topology '' | Out-Null

    $files = @()
    $files += Get-ChildItem "$repository\db\migrations" -File | Where-Object Name -Match '^000[0-3]_.*\.sql$' | Sort-Object Name
    $files += Get-ChildItem "$repository\db\migrations" -File | Where-Object Name -Match '^001[0-2]_.*\.sql$' | Sort-Object Name
    $files += Get-Item "$repository\db\migrations\0037_runtime_identity_helpers.sql"
    $files += Get-ChildItem "$repository\db\migrations" -File | Where-Object {
        $_.Name -match '^\d{4}_.*\.sql$' -and [int]$_.Name.Substring(0, 4) -ge 8 -and
        $_.Name -notmatch '^001[0-2]_' -and $_.Name -notmatch '^0037_' -and
        [int]$_.Name.Substring(0, 4) -le 42
    } | Sort-Object Name
    foreach ($file in $files) {
        Write-Output ("APPLY=" + $file.Name)
        Invoke-Database postgres $adminPassword '' $file.FullName | Out-Null
    }

    Invoke-Database postgres $adminPassword @"
ALTER ROLE duta_app PASSWORD '$appPassword';
INSERT INTO public.users(id,email,name,role) VALUES ('11111111-1111-4111-8111-111111111111','owner@test','Owner','USER');
INSERT INTO public.entities(id,entity_type,display_name,slug,owner_user_id,record_status,legal_status)
VALUES ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','organisation','Owner Org','owner-org','11111111-1111-4111-8111-111111111111','PENDING','unknown');
INSERT INTO public.organizations(id,entity_id,name,type,description,verification,status)
VALUES ('50000000-0000-4000-8000-000000000001','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Owner Org','association','Org description','USER_GENERATED','PENDING');
"@ '' | Out-Null

    $ownerInsert = @'
BEGIN;
SELECT set_config('app.user_id','11111111-1111-4111-8111-111111111111',true);
INSERT INTO public.organization_members(organization_id,user_id,role)
VALUES ('50000000-0000-4000-8000-000000000001','11111111-1111-4111-8111-111111111111','OWNER');
COMMIT;
'@
    Invoke-Database duta_app $appPassword $ownerInsert '' -ExpectAuthSchemaFailure
    Write-Output 'LOCAL_BEFORE_0043_REPRODUCTION=PASS'

    Invoke-Database postgres $adminPassword '' "$repository\db\migrations\0043_runtime_auth_dependency_remediation.sql" | Out-Null
    Invoke-Database duta_app $appPassword $ownerInsert '' | Out-Null
    $inserted = Invoke-Database postgres $adminPassword @'
SELECT count(*) FROM public.organization_members
WHERE organization_id='50000000-0000-4000-8000-000000000001'
  AND user_id='11111111-1111-4111-8111-111111111111'
  AND role='OWNER';
'@ ''
    if (($inserted -join "`n") -notmatch '(?m)^\s*1\s*$') { throw 'Organization owner insert did not pass after 0043.' }
    Invoke-Database postgres $adminPassword '' "$repository\tests\db\migrations\0043\verify.sql" | Out-Null

    Write-Output 'LOCAL_AFTER_0043=PASS'
    Write-Output ("MIGRATION_REPLAY_THROUGH_0043=PASS files=" + ($files.Count + 1))

    # Reset the one-row reproduction fixture, then run the complete 0042
    # behavioral contract through the actual duta_app login topology.
    Invoke-Database postgres $adminPassword @'
DELETE FROM public.organization_members WHERE organization_id='50000000-0000-4000-8000-000000000001';
DELETE FROM public.organizations WHERE id='50000000-0000-4000-8000-000000000001';
DELETE FROM public.entities WHERE id='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
DELETE FROM public.users WHERE id='11111111-1111-4111-8111-111111111111';
'@ '' | Out-Null

    $behaviorLines = Get-Content "$repository\tests\db\migrations\0042\behavior.sql"
    $roleStart = [Array]::IndexOf($behaviorLines, 'SET ROLE duta_app;')
    $roleEnd = [Array]::IndexOf($behaviorLines, 'RESET ROLE;')
    if ($roleStart -lt 0 -or $roleEnd -le $roleStart) { throw '0042 behavioral harness markers are missing.' }
    $setup = ($behaviorLines[1..($roleStart - 1)] -join "`n")
    $runtimeBehavior = ($behaviorLines[($roleStart + 1)..($roleEnd - 1)] -join "`n")
    $ownerVerification = ($behaviorLines[($roleEnd + 1)..($behaviorLines.Count - 1)] -join "`n")

    try {
        Invoke-Database postgres $adminPassword $setup '' | Out-Null
        Invoke-Database duta_app $appPassword $runtimeBehavior '' | Out-Null
        Invoke-Database postgres $adminPassword $ownerVerification '' | Out-Null

        Invoke-Database postgres $adminPassword @'
INSERT INTO public.entities(id,entity_type,display_name,slug,owner_user_id,record_status,legal_status)
VALUES ('cccccccc-cccc-4ccc-8ccc-cccccccccccc','organisation','Other Org','other-org','22222222-2222-4222-8222-222222222222','PENDING','unknown');
INSERT INTO public.organizations(id,entity_id,name,type,description,verification,status)
VALUES ('51000000-0000-4000-8000-000000000001','cccccccc-cccc-4ccc-8ccc-cccccccccccc','Other Org','association','Other description','USER_GENERATED','PENDING');
INSERT INTO public.organization_members(organization_id,user_id,role)
VALUES ('51000000-0000-4000-8000-000000000001','22222222-2222-4222-8222-222222222222','OWNER');
'@ '' | Out-Null
        Invoke-Database duta_app $appPassword '' "$repository\tests\db\migrations\0043\security-semantics.sql" | Out-Null

        $semanticCheck = Invoke-Database postgres $adminPassword @'
SELECT
  (SELECT role='OWNER' FROM public.organization_members WHERE organization_id='50000000-0000-4000-8000-000000000001' AND user_id='11111111-1111-4111-8111-111111111111')
  AND
  (SELECT verification='USER_GENERATED' FROM public.organizations WHERE id='50000000-0000-4000-8000-000000000001');
'@ ''
        if (($semanticCheck -join "`n") -notmatch '(?m)^\s*t\s*$') { throw 'Organization role or verification protection changed.' }
        Write-Output 'LOCAL_SECURITY_SEMANTICS=PASS'
        Write-Output 'LOCAL_BEHAVIORAL_RLS=PASS'
    } finally {
        Invoke-Database postgres $adminPassword @'
BEGIN;
DELETE FROM public.audit_logs WHERE actor_id IN ('11111111-1111-4111-8111-111111111111','22222222-2222-4222-8222-222222222222','33333333-3333-4333-8333-333333333333','44444444-4444-4444-8444-444444444444','55555555-5555-4555-8555-555555555555');
DELETE FROM public.notifications WHERE id='60000000-0000-4000-8000-000000000001';
DELETE FROM public.community_members WHERE community_id='40000000-0000-4000-8000-000000000001';
DELETE FROM public.organization_members WHERE organization_id='50000000-0000-4000-8000-000000000001';
DELETE FROM public.organization_members WHERE organization_id='51000000-0000-4000-8000-000000000001';
DELETE FROM public.entity_responsible_persons WHERE entity_id='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
DELETE FROM public.jobs WHERE id='10000000-0000-4000-8000-000000000001';
DELETE FROM public.products WHERE id='30000000-0000-4000-8000-000000000001';
DELETE FROM public.sellers WHERE id='20000000-0000-4000-8000-000000000001';
DELETE FROM public.organizations WHERE id='50000000-0000-4000-8000-000000000001';
DELETE FROM public.organizations WHERE id='51000000-0000-4000-8000-000000000001';
DELETE FROM public.entity_eligibilities WHERE id IN ('aaaaaaaa-0000-4000-8000-000000000001','aaaaaaaa-0000-4000-8000-000000000002');
DELETE FROM public.communities WHERE id='40000000-0000-4000-8000-000000000001';
DELETE FROM public.entities WHERE id IN ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
DELETE FROM public.entities WHERE id='cccccccc-cccc-4ccc-8ccc-cccccccccccc';
DELETE FROM public.users WHERE id IN ('11111111-1111-4111-8111-111111111111','22222222-2222-4222-8222-222222222222','33333333-3333-4333-8333-333333333333','44444444-4444-4444-8444-444444444444','55555555-5555-4555-8555-555555555555');
COMMIT;
'@ '' | Out-Null
    }
} catch {
    if ($created) {
        $previousErrorAction = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $docker logs $ContainerName 2>&1
        $ErrorActionPreference = $previousErrorAction
    }
    throw
} finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
    if ($created) { & $docker rm -f $ContainerName 1>$null 2>$null }
}
