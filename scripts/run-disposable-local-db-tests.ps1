[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$docker = 'C:\Users\User\AppData\Local\Programs\DockerDesktop\resources\bin\docker.exe'
$container = 'duta-local-test-db'
$database = 'duta_local_test'
$port = 55433
$image = 'postgres:16-alpine'
$repo = Split-Path -Parent $PSScriptRoot

function New-LocalPassword {
    (([guid]::NewGuid().ToString('N')) + ([guid]::NewGuid().ToString('N'))).Substring(0, 48)
}

function Assert-DisposableTarget {
    if ($container -ne 'duta-local-test-db' -or $database -ne 'duta_local_test') { throw 'Unexpected disposable target.' }
    if (-not (Test-Path -LiteralPath $docker -PathType Leaf)) { throw 'Docker executable not found.' }
    & $docker version --format '{{.Server.Version}}' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Docker daemon is not reachable.' }
    $existing = @(& $docker ps -a --filter "name=^/$container$" --format '{{.Names}}')
    if ($existing -contains $container) { throw 'Disposable container already exists; refusing to alter it.' }
    if (@(Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).Count -ne 0) { throw "Loopback port $port is already in use." }
}

Assert-DisposableTarget
$adminPassword = New-LocalPassword
$appPassword = New-LocalPassword
$bootstrapUrl = "postgresql://postgres:$adminPassword@127.0.0.1:$port/$database"
$runtimeUrl = "postgresql://duta_app:$appPassword@127.0.0.1:$port/$database"
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ("duta-local-psql-$PID")
$shim = Join-Path $tempDir 'psql.cmd'
$originalPath = $env:PATH
$created = $false

try {
    New-Item -ItemType Directory -Path $tempDir -ErrorAction Stop | Out-Null
    $env:DUTA_LOCAL_DOCKER = $docker
    $env:DUTA_LOCAL_CONTAINER = $container
    $env:DUTA_LOCAL_DATABASE = $database
    $env:DUTA_LOCAL_APP_PASSWORD = $appPassword
    @'
@echo off
setlocal EnableExtensions
set "FILE="
:args
if "%~1"=="" goto run
if /I "%~1"=="--file" set "FILE=%~2"& shift& shift& goto args
shift
goto args
:run
if "%FILE%"=="" exit /b 2
type "%FILE%" | "%DUTA_LOCAL_DOCKER%" exec -i --user postgres "%DUTA_LOCAL_CONTAINER%" psql --set ON_ERROR_STOP=1 --dbname "%DUTA_LOCAL_DATABASE%"
if errorlevel 1 exit /b %errorlevel%
echo %FILE% | findstr /I /C:"bootstrap-local-test.sql" >nul
if not errorlevel 1 "%DUTA_LOCAL_DOCKER%" exec --user postgres "%DUTA_LOCAL_CONTAINER%" psql --set ON_ERROR_STOP=1 --dbname "%DUTA_LOCAL_DATABASE%" --command "ALTER ROLE duta_app PASSWORD '%DUTA_LOCAL_APP_PASSWORD%';"
exit /b %errorlevel%
'@ | Set-Content -LiteralPath $shim -Encoding ascii -NoNewline

    & $docker run -d --rm --name $container --tmpfs '/var/lib/postgresql/data:rw,noexec,nosuid,size=256m' -p "127.0.0.1:${port}:5432" -e "POSTGRES_DB=$database" -e 'POSTGRES_USER=postgres' -e "POSTGRES_PASSWORD=$adminPassword" $image | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Disposable PostgreSQL container creation failed.' }
    $created = $true
    $ready = $false
    foreach ($attempt in 1..30) {
        & $docker exec $container pg_isready -U postgres -d $database 1>$null 2>$null
        if ($LASTEXITCODE -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 1
    }
    if (-not $ready) { throw 'Disposable PostgreSQL container did not become ready.' }

    $env:PATH = "$tempDir;C:\Program Files\nodejs;$env:PATH"
    & (Join-Path $repo 'scripts\run-local-db-tests.ps1') -LocalDatabaseUrl $runtimeUrl -BootstrapDatabaseUrl $bootstrapUrl -Execute -RunFullSuite
    if ($LASTEXITCODE -ne 0) { throw 'Isolated local database tests failed.' }
    Write-Host 'Disposable local database test suite completed.'
} finally {
    $env:PATH = $originalPath
    Remove-Item Env:DUTA_LOCAL_DOCKER,Env:DUTA_LOCAL_CONTAINER,Env:DUTA_LOCAL_DATABASE,Env:DUTA_LOCAL_APP_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    if ($created) { & $docker rm -f $container 1>$null 2>$null }
}
