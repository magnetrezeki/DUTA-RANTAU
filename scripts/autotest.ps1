$ErrorActionPreference = "Stop"

$BASE = "http://127.0.0.1:3000"
$ORIGIN = "$BASE"
$COOKIE = ".\autotest-cookies.txt"

function Invoke-CurlChecked {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & curl.exe @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "curl.exe failed with exit code $exitCode : $($output -join "`n")"
    }

    if ($output) {
        $output -join "`n"
    }
}

function Test-Step {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "[$Name]" -ForegroundColor Cyan

    try {
        $result = & $Action
        Write-Host "PASS" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

Write-Host "============================================" -ForegroundColor Green
Write-Host " DUTA-RANTAU AUTOTEST" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "BASE: $BASE" -ForegroundColor DarkGray

Remove-Item $COOKIE -Force -ErrorAction SilentlyContinue

# 1. Health
Test-Step "ADMIN HEALTH" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "$BASE/api/admin/health"
    )
}

# 2. Sources
Test-Step "OFFICIAL SOURCES" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "$BASE/api/sources"
    )
}

# 3. Jobs
Test-Step "JOBS API" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "$BASE/api/jobs"
    )
}

# 4. Organizations
Test-Step "ORGANIZATIONS API" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "$BASE/api/organizations"
    )
}

# 5. Login
Test-Step "LOGIN" {
    if (!(Test-Path ".\login-test.json")) {
        throw "login-test.json tidak ditemukan."
    }

    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "-c", $COOKIE,
        "-X", "POST",
        "-H", "Origin: $ORIGIN",
        "-H", "Content-Type: application/json",
        "--data-binary", "@login-test.json",
        "$BASE/api/auth/login"
    )
}

# 6. Authenticated profile
Test-Step "PROFILE GET AUTHENTICATED" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "-b", $COOKIE,
        "-H", "Origin: $ORIGIN",
        "$BASE/api/users/me"
    )
}

# 7. Profile PATCH
$profileBody = @{
    name = "Seraiwangi Emas"
    city = "Johor Bahru"
    state = "Johor"
    hometown = "Indonesia"
    profession = "Pengusaha"
    interests = @("bisnis", "komunitas", "perantauan")
    profileVisibility = "COMMUNITY_ONLY"
    locationVisibility = "CITY"
} | ConvertTo-Json -Compress

$profileBody | Set-Content ".\autotest-profile.json" -Encoding utf8

Test-Step "PROFILE PATCH" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "-X", "PATCH",
        "-b", $COOKIE,
        "-H", "Origin: $ORIGIN",
        "-H", "Content-Type: application/json",
        "--data-binary", "@autotest-profile.json",
        "$BASE/api/users/me"
    )
}

# 8. Profile read-back
Test-Step "PROFILE DATABASE READ-BACK" {
    $r = Invoke-CurlChecked @(
        "-sS",
        "-f",
        "-b", $COOKIE,
        "-H", "Origin: $ORIGIN",
        "$BASE/api/users/me"
    )

    $obj = $r | ConvertFrom-Json

    if ($obj.user.name -ne "Seraiwangi Emas") {
        throw "Nama profile tidak tersimpan."
    }

    if ($obj.user.city -ne "Johor Bahru") {
        throw "City profile tidak tersimpan."
    }

    if ($obj.user.state -ne "Johor") {
        throw "State profile tidak tersimpan."
    }

    if ($obj.user.profileVisibility -ne "COMMUNITY_ONLY") {
        throw "Profile visibility tidak tersimpan."
    }

    $r
}

# 9. Logout
Test-Step "LOGOUT" {
    Invoke-CurlChecked @(
        "-sS",
        "-f",
        "-X", "POST",
        "-b", $COOKIE,
        "-H", "Origin: $ORIGIN",
        "$BASE/api/auth/logout"
    )
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " DUTA-RANTAU AUTOTEST: PASS" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
