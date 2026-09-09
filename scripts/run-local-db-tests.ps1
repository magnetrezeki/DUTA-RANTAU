[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$LocalDatabaseUrl,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BootstrapDatabaseUrl,

    [switch]$Execute,
    [switch]$RunFullSuite
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SafeLocalDatabaseTarget {
    param([Parameter(Mandatory = $true)][string]$ConnectionUrl)

    try {
        $uri = [System.Uri]$ConnectionUrl
    } catch {
        throw 'The database URL is malformed.'
    }

    if ($uri.Scheme -notin @('postgres', 'postgresql') -or [string]::IsNullOrWhiteSpace($uri.Host)) {
        throw 'The database URL must use postgres or postgresql and include a host.'
    }

    $hostName = $uri.Host.Trim('[', ']').ToLowerInvariant()
    if ($hostName -match 'supabase\.co|supabase|production|prod') {
        throw 'Hosted Supabase and production-style hosts are prohibited.'
    }
    if ($hostName -notin @('localhost', '127.0.0.1', '::1')) {
        throw 'Only localhost, 127.0.0.1, or ::1 may be used.'
    }

    $databaseName = $uri.AbsolutePath.Trim('/')
    if ([string]::IsNullOrWhiteSpace($databaseName)) {
        throw 'The database URL must name a database.'
    }
    if ($databaseName -notmatch '^duta_local_test(?:_[a-z0-9_]+)?$') {
        throw 'The database name must be duta_local_test or a duta_local_test_* variant.'
    }

    [pscustomobject]@{
        Uri = $uri
        Host = $hostName
        Database = $databaseName
    }
}

function Get-MaskedDatabaseTarget {
    param([Parameter(Mandatory = $true)]$Target)

    $portSuffix = if ($Target.Uri.IsDefaultPort) { '' } else { ':' + $Target.Uri.Port }
    return '{0}://<redacted>@{1}{2}/{3}' -f $Target.Uri.Scheme, $Target.Host, $portSuffix, $Target.Database
}

if ($MyInvocation.InvocationName -eq '.') {
    throw 'Run this script normally, not by dot-sourcing it; APP_DATABASE_URL must remain process-scoped.'
}

$testTarget = Get-SafeLocalDatabaseTarget -ConnectionUrl $LocalDatabaseUrl
$bootstrapTarget = Get-SafeLocalDatabaseTarget -ConnectionUrl $BootstrapDatabaseUrl
if ($testTarget.Database -ne $bootstrapTarget.Database) {
    throw 'The application and bootstrap URLs must target the same isolated local-test database.'
}

Write-Host ('Validated isolated target: ' + (Get-MaskedDatabaseTarget -Target $testTarget))
if (-not $Execute) {
    Write-Host 'Dry run only. Re-run with -Execute after deliberately preparing the disposable local database.'
    exit 0
}

$psql = Get-Command psql -ErrorAction SilentlyContinue
if ($null -eq $psql) {
    throw 'psql is required for future local bootstrap execution but was not found.'
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$bootstrapSql = Join-Path $repositoryRoot 'tests\db\bootstrap-local-test.sql'
$seedSql = Join-Path $repositoryRoot 'tests\db\seed-local-test.sql'
$verifySql = Join-Path $repositoryRoot 'tests\db\verify-local-test.sql'
foreach ($path in @($bootstrapSql, $seedSql, $verifySql)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required local-test file is missing: $path"
    }
}

$originalAppDatabaseUrl = $env:APP_DATABASE_URL
try {
    & $psql.Source --set ON_ERROR_STOP=1 --dbname $BootstrapDatabaseUrl --file $bootstrapSql
    & $psql.Source --set ON_ERROR_STOP=1 --dbname $BootstrapDatabaseUrl --file $seedSql
    & $psql.Source --set ON_ERROR_STOP=1 --dbname $BootstrapDatabaseUrl --file $verifySql

    # This assignment is scoped to this script process and restored in finally.
    $env:APP_DATABASE_URL = $LocalDatabaseUrl
    Push-Location $repositoryRoot
    try {
        & npm test -- tests/source-integrity.test.ts tests/ai-router.test.ts
        if ($LASTEXITCODE -ne 0) { throw 'The six APP_DATABASE_URL-blocked tests failed.' }

        if ($RunFullSuite) {
            & npm test
            if ($LASTEXITCODE -ne 0) { throw 'The full test suite failed.' }
        }
    } finally {
        Pop-Location
    }
} finally {
    if ($null -eq $originalAppDatabaseUrl) {
        Remove-Item Env:APP_DATABASE_URL -ErrorAction SilentlyContinue
    } else {
        $env:APP_DATABASE_URL = $originalAppDatabaseUrl
    }
}
