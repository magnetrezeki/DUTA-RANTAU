#requires -Version 5.1

$ErrorActionPreference = "Continue"

$Root = (Get-Location).Path
$BaseUrl = if ($env:DUTA_BASE_URL) {
    $env:DUTA_BASE_URL.TrimEnd("/")
} else {
    "http://localhost:3000"
}

$Time = Get-Date -Format "yyyyMMdd-HHmmss"
$OutDir = Join-Path $Root "test-results"
$Report = Join-Path $OutDir "server-diagnosis-$Time.txt"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Section {
    param([string]$Title)

    $line = ""
    $line += "`r`n"
    $line += "============================================================`r`n"
    $line += " $Title`r`n"
    $line += "============================================================"

    Write-Host $line -ForegroundColor Cyan
    Add-Content -LiteralPath $Report -Value $line
}

function Run-Command {
    param(
        [scriptblock]$Command
    )

    try {
        $result = & $Command 2>&1

        if ($null -eq $result) {
            Write-Host "(no output)" -ForegroundColor DarkGray
            Add-Content -LiteralPath $Report -Value "(no output)"
        }
        else {
            $text = $result | Out-String
            Write-Host $text
            Add-Content -LiteralPath $Report -Value $text
        }
    }
    catch {
        $text = $_ | Out-String
        Write-Host $text -ForegroundColor Yellow
        Add-Content -LiteralPath $Report -Value $text
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " DUTA-RANTAU SERVER DIAGNOSTIC" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Root    : $Root"
Write-Host "Base URL: $BaseUrl"
Write-Host "Report  : $Report"
Write-Host ""

Add-Content -LiteralPath $Report -Value "DUTA-RANTAU SERVER DIAGNOSTIC"
Add-Content -LiteralPath $Report -Value "Time    : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Add-Content -LiteralPath $Report -Value "Root    : $Root"
Add-Content -LiteralPath $Report -Value "BaseURL : $BaseUrl"

# ============================================================
# 1. CURRENT DIRECTORY
# ============================================================

Section "1. CURRENT DIRECTORY"

Run-Command {
    Get-Location
}

# ============================================================
# 2. NODE / NPM / CURL
# ============================================================

Section "2. TOOL VERSIONS"

Run-Command {
    node --version
}

Run-Command {
    npm --version
}

Run-Command {
    curl.exe --version | Select-Object -First 3
}

# ============================================================
# 3. PORT 3000
# ============================================================

Section "3. PORT 3000 CONNECTION"

Run-Command {
    Test-NetConnection localhost -Port 3000
}

# ============================================================
# 4. PROCESS USING PORT 3000
# ============================================================

Section "4. PROCESS USING PORT 3000"

$Connections = Get-NetTCPConnection `
    -LocalPort 3000 `
    -ErrorAction SilentlyContinue

if ($Connections) {
    $Connections |
        Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess |
        Format-Table -AutoSize |
        Out-String |
        ForEach-Object {
            Write-Host $_
            Add-Content -LiteralPath $Report -Value $_
        }

    $Pids = $Connections |
        Select-Object -ExpandProperty OwningProcess -Unique

    foreach ($Pid in $Pids) {
        Write-Host ""
        Write-Host "PID: $Pid" -ForegroundColor Yellow

        try {
            Get-Process -Id $Pid |
                Select-Object Id,ProcessName,Path,StartTime |
                Format-List |
                Out-String |
                ForEach-Object {
                    Write-Host $_
                    Add-Content -LiteralPath $Report -Value $_
                }
        }
        catch {
            Write-Host $_ -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "COMMAND LINE:" -ForegroundColor Yellow

        try {
            Get-CimInstance Win32_Process -Filter "ProcessId=$Pid" |
                Select-Object ProcessId,Name,CommandLine |
                Format-List |
                Out-String |
                ForEach-Object {
                    Write-Host $_
                    Add-Content -LiteralPath $Report -Value $_
                }
        }
        catch {
            Write-Host $_ -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "NO PROCESS LISTENING ON PORT 3000" -ForegroundColor Red
    Add-Content -LiteralPath $Report -Value "NO PROCESS LISTENING ON PORT 3000"
}

# ============================================================
# 5. HTTP ROOT
# ============================================================

Section "5. HTTP ROOT - curl -v"

Run-Command {
    curl.exe -v --max-time 10 "$BaseUrl/"
}

# ============================================================
# 6. HEALTH ENDPOINT
# ============================================================

Section "6. API HEALTH - curl -v"

Run-Command {
    curl.exe -v --max-time 10 "$BaseUrl/api/admin/health"
}

# ============================================================
# 7. SOURCES ENDPOINT
# ============================================================

Section "7. API SOURCES - curl -v"

Run-Command {
    curl.exe -v --max-time 10 "$BaseUrl/api/sources"
}

# ============================================================
# 8. AUTH ME WITHOUT COOKIE
# ============================================================

Section "8. AUTH ME WITHOUT COOKIE"

Run-Command {
    curl.exe -v --max-time 10 "$BaseUrl/api/auth/me"
}

# ============================================================
# 9. AUTH ME WITH COOKIE
# ============================================================

Section "9. AUTH ME WITH COOKIE"

$CookieFile = Join-Path $Root "cookies.txt"

if (Test-Path -LiteralPath $CookieFile) {
    Run-Command {
        curl.exe -v --max-time 10 `
            --cookie "$CookieFile" `
            "$BaseUrl/api/auth/me"
    }
}
else {
    Write-Host "cookies.txt NOT FOUND" -ForegroundColor Yellow
    Add-Content -LiteralPath $Report -Value "cookies.txt NOT FOUND"
}

# ============================================================
# 10. LISTENING PORTS / NODE PROCESSES
# ============================================================

Section "10. NODE PROCESSES"

Run-Command {
    Get-Process node,npm `
        -ErrorAction SilentlyContinue |
        Select-Object Id,ProcessName,CPU,StartTime,Path |
        Format-Table -AutoSize
}

# ============================================================
# 11. NEXT.JS / PACKAGE INFORMATION
# ============================================================

Section "11. PACKAGE INFORMATION"

$PackageJson = Join-Path $Root "package.json"

if (Test-Path -LiteralPath $PackageJson) {
    try {
        $Package = Get-Content -LiteralPath $PackageJson -Raw |
            ConvertFrom-Json

        Write-Host "name    : $($Package.name)"
        Write-Host "version : $($Package.version)"

        Add-Content -LiteralPath $Report -Value "name    : $($Package.name)"
        Add-Content -LiteralPath $Report -Value "version : $($Package.version)"

        if ($Package.scripts) {
            Write-Host ""
            Write-Host "SCRIPTS:" -ForegroundColor Yellow

            $Package.scripts |
                Format-List |
                Out-String |
                ForEach-Object {
                    Write-Host $_
                    Add-Content -LiteralPath $Report -Value $_
                }
        }
    }
    catch {
        Write-Host $_ -ForegroundColor Yellow
    }
}
else {
    Write-Host "package.json NOT FOUND" -ForegroundColor Red
}

# ============================================================
# 12. RECENT TEST RESULTS
# ============================================================

Section "12. RECENT TEST RESULTS"

if (Test-Path -LiteralPath $OutDir) {
    Get-ChildItem -LiteralPath $OutDir -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10 Name,Length,LastWriteTime |
        Format-Table -AutoSize |
        Out-String |
        ForEach-Object {
            Write-Host $_
            Add-Content -LiteralPath $Report -Value $_
        }
}

# ============================================================
# 13. ENVIRONMENT VARIABLES - SAFE NAMES ONLY
# ============================================================

Section "13. RELEVANT ENVIRONMENT VARIABLE NAMES"

# Only show variable NAMES, never values.
Get-ChildItem Env: |
    Where-Object {
        $_.Name -match '^(NODE_ENV|PORT|HOST|DUTA_BASE_URL|NEXT_PUBLIC_)'
    } |
    Select-Object Name |
    Sort-Object Name |
    Format-Table -AutoSize |
    Out-String |
    ForEach-Object {
        Write-Host $_
        Add-Content -LiteralPath $Report -Value $_
    }

# ============================================================
# 14. NEXT / DEV SERVER FILES
# ============================================================

Section "14. SERVER FILES"

$ImportantPaths = @(
    ".next",
    "next.config.js",
    "next.config.mjs",
    "next.config.ts",
    "package.json"
)

foreach ($Relative in $ImportantPaths) {
    $Full = Join-Path $Root $Relative

    if (Test-Path -LiteralPath $Full) {
        $Item = Get-Item -LiteralPath $Full

        Write-Host "[FOUND] $Relative" -ForegroundColor Green
        Add-Content -LiteralPath $Report -Value "[FOUND] $Relative"

        if ($Item.PSIsContainer) {
            Write-Host "        Directory"
        }
        else {
            Write-Host "        $($Item.Length) bytes"
        }
    }
    else {
        Write-Host "[MISS]  $Relative" -ForegroundColor DarkGray
        Add-Content -LiteralPath $Report -Value "[MISS] $Relative"
    }
}

# ============================================================
# FINAL
# ============================================================

Section "DIAGNOSTIC COMPLETE"

Write-Host ""
Write-Host "Report tersimpan di:" -ForegroundColor Green
Write-Host $Report -ForegroundColor Green
Write-Host ""
Write-Host "PENTING: script ini READ-ONLY." -ForegroundColor Yellow
Write-Host "Tidak restart server, tidak kill process, dan tidak mengubah source code." -ForegroundColor Yellow
Write-Host ""

