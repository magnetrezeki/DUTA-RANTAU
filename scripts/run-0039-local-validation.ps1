[CmdletBinding()]
param(
    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$container = 'duta-local-test-db-clean'
$database = 'duta_local_test'
$hostAddress = '127.0.0.1'
$port = 55434
$image = 'postgres:16-alpine'
$expected = @{
    Prestate = '467027a30647438637335c1a406e4cf4d89c7bb991c8632215aa1bebb8f0dff2'
    Migration = '5d7d68730f12dce3a2c8d87ff589cfa1e3bd90d9fe6df28932703ccf82da0a30'
    Verify = 'a93e06c32585e13def8b3e97381566af2abc3e711032a464bcefed988d072698'
    SecurityVerify = 'f42252761080f429bd7b0a187a2bc63190da975e116e3276511e71082bab9341'
}
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$artifacts = [ordered]@{
    Prestate = Join-Path $repositoryRoot 'tests\db\migrations\0039\prestate.sql'
    Migration = Join-Path $repositoryRoot 'db\migrations\0039_source_registry_governance_foundation.sql'
    Verify = Join-Path $repositoryRoot 'tests\db\migrations\0039\verify.sql'
    SecurityVerify = Join-Path $repositoryRoot 'tests\db\migrations\0039\security-verify.sql'
}
$phases = [ordered]@{ ENVIRONMENT_GUARD = 'NOT_RUN'; BOOTSTRAP = 'NOT_RUN'; PRESTATE = 'NOT_RUN'; MIGRATION_0039 = 'NOT_RUN'; VERIFY = 'NOT_RUN'; SECURITY_VERIFY = 'NOT_RUN'; FINAL_EVIDENCE = 'NOT_RUN' }

function Fail([string]$Classification, [string]$Message) {
    throw "$Classification`: $Message"
}

function Require-ExitCode([string]$Operation) {
    if ($LASTEXITCODE -ne 0) { Fail 'STATE_UNCERTAIN' "$Operation failed with exit code $LASTEXITCODE" }
}

function Get-Hash([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Fail 'ENVIRONMENT_BLOCKED' "Required artifact is missing: $Path" }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Assert-Artifacts {
    foreach ($name in $artifacts.Keys) {
        $actual = Get-Hash $artifacts[$name]
        if ($actual -ne $expected[$name]) { Fail 'ENVIRONMENT_BLOCKED' "Artifact hash mismatch: $name" }
    }
}

function New-LocalPassword {
    (([guid]::NewGuid().ToString('N')) + ([guid]::NewGuid().ToString('N'))).Substring(0, 48)
}

function Invoke-Psql([string[]]$Arguments, [string]$Phase) {
    & $script:psql @Arguments
    Require-ExitCode $Phase
}

function Assert-ContainerIdentity {
    $names = @(& $script:docker ps -a --filter "name=^/$container$" --format '{{.Names}}')
    Require-ExitCode 'Docker container lookup'
    if ($names -notcontains $container) { Fail 'TARGET_IDENTITY_FAILED' 'Expected disposable container is absent.' }
    $running = (& $script:docker inspect --format '{{.State.Running}}' $container).Trim()
    Require-ExitCode 'Docker running-state check'
    if ($running -ne 'true') { Fail 'TARGET_IDENTITY_FAILED' 'Expected disposable container is not running.' }
    $configuredImage = (& $script:docker inspect --format '{{.Config.Image}}' $container).Trim()
    Require-ExitCode 'Docker image check'
    if ($configuredImage -notmatch '^postgres:16(?:[.-]|$)') { Fail 'TARGET_IDENTITY_FAILED' 'Container image is not PostgreSQL major version 16.' }
    $binding = (& $script:docker port $container '5432/tcp').Trim()
    Require-ExitCode 'Docker port-binding check'
    if ($binding -ne "$hostAddress`:$port") { Fail 'TARGET_IDENTITY_FAILED' 'Container does not have the required loopback-only port binding.' }
}

function Get-SafeServerIdentity {
    $identity = (& $script:psql -X -At -v ON_ERROR_STOP=1 -c "select current_database(), current_user, coalesce(inet_server_addr()::text, 'local'), inet_server_port(), current_setting('server_version_num');").Trim()
    Require-ExitCode 'PostgreSQL server identity check'
    if ($identity -notmatch "^$database\|postgres\|") { Fail 'TARGET_IDENTITY_FAILED' 'PostgreSQL database or bootstrap user identity mismatch.' }
    return $identity
}

function Write-Evidence([string]$Result, [string]$Classification, [string]$ServerIdentity) {
    $evidence = [ordered]@{
        timestamp = (Get-Date).ToUniversalTime().ToString('o')
        branch = (& git -C $repositoryRoot branch --show-current).Trim()
        head = (& git -C $repositoryRoot rev-parse HEAD).Trim()
        tree = (& git -C $repositoryRoot show -s --format='%T' HEAD).Trim()
        worktreeClean = [string]::IsNullOrWhiteSpace((& git -C $repositoryRoot status --porcelain))
        migrationSha256 = $expected.Migration
        prestateSha256 = $expected.Prestate
        verifySha256 = $expected.Verify
        securityVerifySha256 = $expected.SecurityVerify
        container = $container
        postgresqlMajor = 16
        externalHost = $hostAddress
        externalPort = $port
        database = $database
        serverIdentity = $ServerIdentity
        phases = $phases
        result = $Result
        classification = $Classification
    }
    $evidence | ConvertTo-Json -Depth 4 -Compress | Write-Host
}

$docker = Get-Command docker -ErrorAction SilentlyContinue
$psql = Get-Command psql -ErrorAction SilentlyContinue
if ($null -eq $docker) { Fail 'ENVIRONMENT_BLOCKED' 'Docker CLI is required.' }
if ($null -eq $psql) { Fail 'ENVIRONMENT_BLOCKED' 'Host psql is required; container-internal execution is not substituted.' }
if ($container -ne 'duta-local-test-db-clean' -or $database -ne 'duta_local_test' -or $hostAddress -ne '127.0.0.1' -or $port -ne 55434) { Fail 'ENVIRONMENT_BLOCKED' 'Locked local target invariant failed.' }

Assert-Artifacts
if (-not $Execute) {
    Write-Host 'DRY_RUN_ONLY: artifacts and fixed local target prepared; pass -Execute only in the separately authorized execution gate.'
    exit 0
}

$phases.ENVIRONMENT_GUARD = 'FAIL'
$phases.BOOTSTRAP = 'FAIL'
$serverIdentity = 'NOT_RUN'
$originalPassword = $env:PGPASSWORD
try {
    & $docker version --format '{{.Server.Version}}' | Out-Null
    Require-ExitCode 'Docker daemon check'
    & $docker image inspect $image | Out-Null
    Require-ExitCode 'Local PostgreSQL image check'
    $existing = @(& $docker ps -a --filter "name=^/$container$" --format '{{.Names}}')
    Require-ExitCode 'Existing-container check'
    if ($existing -contains $container) { Fail 'ENVIRONMENT_BLOCKED' 'Disposable container already exists; refusing to reuse or reset it.' }
    if (@(Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).Count -ne 0) { Fail 'ENVIRONMENT_BLOCKED' 'Required loopback port is already in use.' }
    $adminPassword = New-LocalPassword
    & $docker run -d --rm --pull never --name $container --tmpfs '/var/lib/postgresql/data:rw,noexec,nosuid,size=256m' -p "$hostAddress`:$port`:5432" -e "POSTGRES_DB=$database" -e 'POSTGRES_USER=postgres' -e "POSTGRES_PASSWORD=$adminPassword" $image | Out-Null
    Require-ExitCode 'Disposable PostgreSQL container creation'
    foreach ($attempt in 1..30) {
        & $docker exec $container pg_isready -U postgres -d $database 1>$null 2>$null
        if ($LASTEXITCODE -eq 0) { break }
        if ($attempt -eq 30) { Fail 'ENVIRONMENT_BLOCKED' 'Disposable PostgreSQL container did not become ready.' }
        Start-Sleep -Seconds 1
    }
    Assert-ContainerIdentity
    $env:PGPASSWORD = $adminPassword
    $env:PGHOST = $hostAddress
    $env:PGPORT = [string]$port
    $env:PGUSER = 'postgres'
    $env:PGDATABASE = $database
    $phases.ENVIRONMENT_GUARD = 'PASS'
    $phases.BOOTSTRAP = 'PASS'

    $phases.PRESTATE = 'FAIL'; Invoke-Psql -Arguments @('-X','-v','ON_ERROR_STOP=1','-f',$artifacts.Prestate) -Phase 'PRESTATE'; $phases.PRESTATE = 'PASS'
    $serverIdentity = Get-SafeServerIdentity
    $phases.MIGRATION_0039 = 'FAIL'; Invoke-Psql -Arguments @('-X','-v','ON_ERROR_STOP=1','-f',$artifacts.Migration) -Phase 'MIGRATION_0039'; $phases.MIGRATION_0039 = 'PASS'
    $phases.VERIFY = 'FAIL'; Invoke-Psql -Arguments @('-X','-v','ON_ERROR_STOP=1','-f',$artifacts.Verify) -Phase 'VERIFY'; $phases.VERIFY = 'PASS'
    $phases.SECURITY_VERIFY = 'FAIL'; Invoke-Psql -Arguments @('-X','-v','ON_ERROR_STOP=1','-f',$artifacts.SecurityVerify) -Phase 'SECURITY_VERIFY'; $phases.SECURITY_VERIFY = 'PASS'
    $phases.FINAL_EVIDENCE = 'PASS'
    Write-Evidence 'LOCAL_VALIDATION_PASS' 'LOCAL_VALIDATION_PASS' $serverIdentity
} catch {
    Write-Evidence 'FAIL' (($_.Exception.Message -split ':')[0]) $serverIdentity
    throw
} finally {
    if ($null -eq $originalPassword) { Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue } else { $env:PGPASSWORD = $originalPassword }
    Remove-Item Env:PGHOST,Env:PGPORT,Env:PGUSER,Env:PGDATABASE -ErrorAction SilentlyContinue
}
