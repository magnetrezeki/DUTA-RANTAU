#requires -Version 5.1

$ErrorActionPreference = "Continue"

$Root = (Get-Location).Path
$Time = Get-Date -Format "yyyyMMdd-HHmmss"
$OutDir = Join-Path $Root "test-results"
$Report = Join-Path $OutDir "server-diagnosis-deep-$Time.txt"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Section {
    param([string]$Title)

    $Text = @"

============================================================
 $Title
============================================================
"@

    Write-Host $Text -ForegroundColor Cyan
    Add-Content -LiteralPath $Report -Value $Text
}

function Show {
    param($Value)

    if ($null -eq $Value) {
        Write-Host "(no output)"
        Add-Content -LiteralPath $Report -Value "(no output)"
        return
    }

    $Text = $Value | Out-String
    Write-Host $Text
    Add-Content -LiteralPath $Report -Value $Text
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " DUTA-RANTAU DEEP SERVER DIAGNOSTIC" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Report: $Report"
Write-Host ""

# ============================================================
# 1. PORT 3000 CURRENT STATE
# ============================================================

Section "1. CURRENT PORT 3000"

$Connections = Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue

Show (
    $Connections |
    Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess
)

# ============================================================
# 2. INSPECT EVERY PID ON PORT 3000
# ============================================================

Section "2. PROCESS DETAILS FOR PORT 3000"

$PortPids = @(
    $Connections |
    Select-Object -ExpandProperty OwningProcess -Unique
)

if ($PortPids.Count -eq 0) {
    Write-Host "NO PID IS CURRENTLY LISTENING ON PORT 3000" -ForegroundColor Red
}
else {
    foreach ($ProcessIdValue in $PortPids) {

        Write-Host ""
        Write-Host "PID = $ProcessIdValue" -ForegroundColor Yellow
        Add-Content -LiteralPath $Report -Value ""
        Add-Content -LiteralPath $Report -Value "PID = $ProcessIdValue"

        $Proc = Get-Process `
            -Id $ProcessIdValue `
            -ErrorAction SilentlyContinue

        if ($Proc) {
            Show (
                $Proc |
                Select-Object Id,ProcessName,Path,StartTime,CPU,Responding
            )
        }
        else {
            Write-Host "PROCESS NO LONGER EXISTS" -ForegroundColor Red
            Add-Content -LiteralPath $Report -Value "PROCESS NO LONGER EXISTS"
        }

        Write-Host "COMMAND LINE:" -ForegroundColor Yellow
        Add-Content -LiteralPath $Report -Value "COMMAND LINE:"

        try {
            $CimProc = Get-CimInstance Win32_Process `
                -Filter "ProcessId=$ProcessIdValue" `
                -ErrorAction SilentlyContinue

            Show (
                $CimProc |
                Select-Object ProcessId,Name,ParentProcessId,CommandLine
            )
        }
        catch {
            Show $_
        }
    }
}

# ============================================================
# 3. ALL NODE PROCESSES
# ============================================================

Section "3. ALL NODE PROCESSES"

$Nodes = Get-CimInstance Win32_Process `
    -Filter "Name='node.exe'" `
    -ErrorAction SilentlyContinue

Show (
    $Nodes |
    Select-Object ProcessId,ParentProcessId,Name,CommandLine
)

# ============================================================
# 4. PARENT PROCESS TREE
# ============================================================

Section "4. NODE PARENT PROCESS TREE"

foreach ($Node in $Nodes) {

    Write-Host ""
    Write-Host "NODE PID $($Node.ProcessId)" -ForegroundColor Yellow

    $ParentId = $Node.ParentProcessId

    if ($ParentId) {
        Show (
            Get-CimInstance Win32_Process `
                -Filter "ProcessId=$ParentId" `
                -ErrorAction SilentlyContinue |
            Select-Object ProcessId,ParentProcessId,Name,CommandLine
        )
    }
}

# ============================================================
# 5. LOCALHOST VS 127.0.0.1
# ============================================================

Section "5. HTTP TEST USING 127.0.0.1"

Write-Host "--- ROOT ---" -ForegroundColor Yellow

try {
    & curl.exe -v --max-time 10 `
        "http://127.0.0.1:3000/" 2>&1 |
        Tee-Object -Variable RootCurl

    Add-Content -LiteralPath $Report -Value (
        $RootCurl | Out-String
    )
}
catch {
    Show $_
}

Write-Host ""
Write-Host "--- HEALTH ---" -ForegroundColor Yellow

try {
    & curl.exe -v --max-time 10 `
        "http://127.0.0.1:3000/api/admin/health" 2>&1 |
        Tee-Object -Variable HealthCurl

    Add-Content -LiteralPath $Report -Value (
        $HealthCurl | Out-String
    )
}
catch {
    Show $_
}

# ============================================================
# 6. HTTP HEAD
# ============================================================

Section "6. HTTP HEAD TEST"

try {
    & curl.exe -I -v --max-time 10 `
        "http://127.0.0.1:3000/" 2>&1 |
        Tee-Object -Variable HeadCurl

    Add-Content -LiteralPath $Report -Value (
        $HeadCurl | Out-String
    )
}
catch {
    Show $_
}

# ============================================================
# 7. POWERSHELL HTTP CLIENT
# ============================================================

Section "7. POWERSHELL HTTP CLIENT"

try {
    $Response = Invoke-WebRequest `
        -Uri "http://127.0.0.1:3000/api/admin/health" `
        -Method GET `
        -TimeoutSec 10 `
        -UseBasicParsing `
        -ErrorAction Stop

    Write-Host "STATUS : $($Response.StatusCode)" -ForegroundColor Green
    Write-Host "BODY   : $($Response.Content)"

    Add-Content -LiteralPath $Report -Value "STATUS : $($Response.StatusCode)"
    Add-Content -LiteralPath $Report -Value "BODY   : $($Response.Content)"
}
catch {
    Write-Host "REQUEST ERROR:" -ForegroundColor Red
    Show $_
}

# ============================================================
# 8. NEXT BUILD / SERVER METADATA
# ============================================================

Section "8. NEXT BUILD INFORMATION"

$NextDir = Join-Path $Root ".next"

if (Test-Path $NextDir) {

    Show (
        Get-ChildItem $NextDir -Force |
        Select-Object Name,Length,LastWriteTime,PSIsContainer
    )

    $BuildIdFile = Join-Path $NextDir "BUILD_ID"

    if (Test-Path $BuildIdFile) {
        Write-Host "BUILD_ID:"
        Show (Get-Content $BuildIdFile)
    }
}
else {
    Write-Host ".next DOES NOT EXIST" -ForegroundColor Red
}

# ============================================================
# 9. NEXT CONFIG
# ============================================================

Section "9. NEXT CONFIG"

$ConfigFiles = @(
    "next.config.ts",
    "next.config.js",
    "next.config.mjs"
)

foreach ($Config in $ConfigFiles) {

    $FullPath = Join-Path $Root $Config

    if (Test-Path $FullPath) {
        Write-Host ""
        Write-Host "FOUND: $Config" -ForegroundColor Green

        Show (
            Get-Content $FullPath -Raw
        )
    }
}

# ============================================================
# 10. DEV COMMAND
# ============================================================

Section "10. PACKAGE DEV COMMAND"

$PackageFile = Join-Path $Root "package.json"

if (Test-Path $PackageFile) {

    try {
        $Pkg = Get-Content $PackageFile -Raw |
            ConvertFrom-Json

        Write-Host "dev   : $($Pkg.scripts.dev)"
        Write-Host "build : $($Pkg.scripts.build)"
        Write-Host "start : $($Pkg.scripts.start)"

        Add-Content -LiteralPath $Report -Value "dev   : $($Pkg.scripts.dev)"
        Add-Content -LiteralPath $Report -Value "build : $($Pkg.scripts.build)"
        Add-Content -LiteralPath $Report -Value "start : $($Pkg.scripts.start)"
    }
    catch {
        Show $_
    }
}

# ============================================================
# 11. ENVIRONMENT - NAMES ONLY
# ============================================================

Section "11. ENVIRONMENT VARIABLE NAMES ONLY"

Show (
    Get-ChildItem Env: |
    Where-Object {
        $_.Name -match 'NODE|NEXT|PORT|HOST|DUTA'
    } |
    Select-Object Name |
    Sort-Object Name
)

# ============================================================
# 12. FINAL
# ============================================================

Section "DIAGNOSTIC COMPLETE"

Write-Host ""
Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report -ForegroundColor Green
Write-Host ""

