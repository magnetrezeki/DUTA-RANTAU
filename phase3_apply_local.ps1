$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
$container='duta-rantau-phase1a-postgres';$database='duta_rantau_staging';$admin='duta_rantau';$log=Join-Path $PSScriptRoot 'PHASE3_CHANGELOG_LOCAL.txt'
function Log($m){"$(Get-Date -Format o) $m"|Add-Content $log}
function Plain([Security.SecureString]$s){$p=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($s);try{[Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)}finally{[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($p)}}
if(-not(Get-Command docker -ErrorAction SilentlyContinue)){throw 'Docker required'}
docker info *> $null
$running=(docker inspect -f '{{.State.Running}}' $container 2>$null);if($running -ne 'true'){throw 'LOCAL_STAGING container is not running'}
$target=(docker exec $container psql -U $admin -d $database -Atc "select current_database()||'|'||current_user")
if($target -ne 'duta_rantau_staging|duta_rantau'){throw "Target verification failed: $target"}
$required=@('phase3_preflight.sql','phase3_identity_bridge.sql','phase3_verification.sql','phase3_rollback.sql','db/migrations/0004_phase1a_identity_bridge_rls.sql','db/migrations/0005_membership_organization_registration.sql','db/migrations/0006_membership_organization_registration_rls.sql','db/migrations/0007_member_face_verification.sql','db/migrations/0008_phase4_real_content_rls.sql','db/migrations/0009_organization_archival_workflow.sql');foreach($file in $required){if(-not(Test-Path $file)){throw "Required artifact missing: $file"}}
$migration=(Get-Content 'db/migrations/0004_phase1a_identity_bridge_rls.sql' -Raw)+(Get-Content 'db/migrations/0005_membership_organization_registration.sql' -Raw)+(Get-Content 'db/migrations/0006_membership_organization_registration_rls.sql' -Raw)+(Get-Content 'db/migrations/0007_member_face_verification.sql' -Raw)+(Get-Content 'db/migrations/0008_phase4_real_content_rls.sql' -Raw)+(Get-Content 'db/migrations/0009_organization_archival_workflow.sql' -Raw)
if($migration -match 'auth\.uid\(' -or $migration -match 'https?://' -or $migration -match 'supabase\.co'){throw 'Incompatible or remote reference detected in migration'}
Get-Content 'phase3_preflight.sql' -Raw | docker exec -i $container psql -v ON_ERROR_STOP=1 -U $admin -d $database | Tee-Object -FilePath 'phase3_preflight_output.txt'
if(-not(Select-String -Path 'phase3_preflight_output.txt' -Pattern 'PHASE3_PREFLIGHT_READ_ONLY_PASS' -Quiet)){throw 'Preflight PASS marker missing'}
$baseline=(docker exec $container psql -U $admin -d $database -Atc "select (select count(*) from drizzle.__drizzle_migrations)||(select '|'||count(*) from pg_tables where schemaname='public' and rowsecurity)||(select '|'||count(*) from pg_policies where schemaname='public')")
Write-Host "Verified LOCAL_STAGING: $target; baseline migrations|rls|policies=$baseline"
$confirm=Read-Host 'Type LOCAL_STAGING_APPLY to continue';if($confirm -ne 'LOCAL_STAGING_APPLY'){throw 'Cancelled'}
$appSecure=Read-Host 'New duta_app password' -AsSecureString;$systemSecure=Read-Host 'New duta_system password' -AsSecureString;$adminSecure=Read-Host 'Local duta_rantau password' -AsSecureString
$appPlain=Plain $appSecure;$systemPlain=Plain $systemSecure;$adminPlain=Plain $adminSecure;$migrationAttempted=$false
try{
 Log "PRE baseline=$baseline target=$target"
 Get-Content 'phase3_identity_bridge.sql' -Raw | docker exec -i $container psql -v ON_ERROR_STOP=1 -v "app_password=$appPlain" -v "system_password=$systemPlain" -U $admin -d $database
 $roleCheck=(docker exec $container psql -U $admin -d $database -Atc "select count(*) from pg_roles where rolname in ('duta_app','duta_system') and not rolsuper and not rolbypassrls and not rolcreaterole and not rolcreatedb and not rolreplication")
 if($roleCheck -ne '2'){throw 'Restricted role verification failed'}
 Log 'roles provisioned and verified safe'
 $encoded=[Uri]::EscapeDataString($adminPlain);$env:DATABASE_URL="postgresql://$admin`:$encoded@127.0.0.1:5433/$database";$migrationAttempted=$true
 npm run db:migrate
 Remove-Item Env:DATABASE_URL -ErrorAction SilentlyContinue
 Get-Content 'phase3_verification.sql' -Raw | docker exec -i $container psql -v ON_ERROR_STOP=1 -U $admin -d $database
 Log 'migration and post-verification PASS'
 Write-Host 'PHASE3_LOCAL_APPLY_PASS'
 Write-Host 'Set APP_DATABASE_URL and SYSTEM_DATABASE_URL manually in a LOCAL-ONLY environment before application tests. Secrets were not written by this script.'
}catch{
 Remove-Item Env:DATABASE_URL -ErrorAction SilentlyContinue
 Log "FAIL $($_.Exception.Message)"
 if($migrationAttempted){Write-Warning 'Applying Phase 3 rollback SQL';Get-Content 'phase3_rollback.sql' -Raw | docker exec -i $container psql -v ON_ERROR_STOP=1 -U $admin -d $database;Log 'rollback SQL executed'}
 throw
}finally{$appPlain=$null;$systemPlain=$null;$adminPlain=$null}
