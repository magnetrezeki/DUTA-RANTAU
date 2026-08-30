#requires -Version 5.1

$ErrorActionPreference = "Continue"

$Root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = (Get-Location).Path
}

$BaseUrl = if ($env:DUTA_BASE_URL) {
    $env:DUTA_BASE_URL.TrimEnd("/")
} else {
    "http://127.0.0.1:3000"
}

$CookieFile = Join-Path $Root "cookies.txt"
$LoginFile  = Join-Path $Root "login-test.json"
$LogDir     = Join-Path $Root "test-results"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile   = Join-Path $LogDir "autotest-full-$Timestamp.log"
$CsvFile   = Join-Path $LogDir "autotest-full-$Timestamp.csv"

$Results = [System.Collections.Generic.List[object]]::new()

function Write-Log {
    param(
        [AllowEmptyString()]
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )

    Write-Host $Message -ForegroundColor $Color

    if ($LogFile) {
        Add-Content -LiteralPath $LogFile -Value $Message
    }
}

function Add-Result {
    param(
        [string]$Name,
        [bool]$Pass,
        [string]$Expected,
        [string]$Actual,
        [string]$Details = ""
    )

    $Status = if ($Pass) { "PASS" } else { "FAIL" }

    $Results.Add([PSCustomObject]@{
        Status   = $Status
        Name     = $Name
        Expected = $Expected
        Actual   = "$Actual"
        Details  = $Details
    })

    if ($Pass) {
        Write-Log "[PASS] $Name" Green
    }
    else {
        Write-Log "[FAIL] $Name" Red

        if ($Details) {
            Write-Log "       $Details" Yellow
        }
    }
}

function Invoke-TestRequest {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Method = "GET",

        [Parameter(Mandatory)]
        [string]$Path,

        [int[]]$ExpectedStatus = @(200),

        [AllowEmptyString()]
        [string]$Body,

        [switch]$Authenticated,

        [switch]$NoCookie,

        [hashtable]$ExtraHeaders
    )

    $Url = "$BaseUrl$Path"

    try {
        $CurlArgs = [System.Collections.Generic.List[string]]::new()

        [void]$CurlArgs.Add("-sS")
        [void]$CurlArgs.Add("-i")
        [void]$CurlArgs.Add("-X")
        [void]$CurlArgs.Add($Method)
        [void]$CurlArgs.Add($Url)

        [void]$CurlArgs.Add("-H")
        [void]$CurlArgs.Add("Accept: application/json")

        if ($ExtraHeaders) {
            foreach ($Key in $ExtraHeaders.Keys) {
                [void]$CurlArgs.Add("-H")
                [void]$CurlArgs.Add("$Key`: $($ExtraHeaders[$Key])")
            }
        }

        if (
            $Authenticated -and
            (-not $NoCookie) -and
            (Test-Path -LiteralPath $CookieFile)
        ) {
            [void]$CurlArgs.Add("--cookie")
            [void]$CurlArgs.Add($CookieFile)
        }

        # IMPORTANT:
        # Only POST/PUT/PATCH/etc. requests with an explicitly supplied body
        # receive --data-binary.
        $HasBody = $PSBoundParameters.ContainsKey("Body")

        if ($HasBody) {
            [void]$CurlArgs.Add("-H")
            [void]$CurlArgs.Add("Content-Type: application/json")

            [void]$CurlArgs.Add("--data-raw")
            [void]$CurlArgs.Add([string]$Body)
        }

        $Raw = (& curl.exe @CurlArgs 2>&1 | Out-String).Trim()

        $StatusMatch = [regex]::Match(
            $Raw,
            "HTTP/\S+\s+(\d{3})"
        )

        if (-not $StatusMatch.Success) {
            Add-Result `
                -Name $Name `
                -Pass $false `
                -Expected ($ExpectedStatus -join "/") `
                -Actual "NO_HTTP_STATUS" `
                -Details $Raw

            return
        }

        $Status = [int]$StatusMatch.Groups[1].Value
        $Pass = $ExpectedStatus -contains $Status

        $Preview = $Raw

        if ($Preview.Length -gt 600) {
            $Preview = $Preview.Substring(0, 600) + "..."
        }

        Add-Result `
            -Name $Name `
            -Pass $Pass `
            -Expected ($ExpectedStatus -join "/") `
            -Actual $Status `
            -Details $Preview
    }
    catch {
        Add-Result `
            -Name $Name `
            -Pass $false `
            -Expected ($ExpectedStatus -join "/") `
            -Actual "ERROR" `
            -Details $_.Exception.Message
    }
}

Write-Log ""
Write-Log "============================================" Cyan
Write-Log " DUTA-RANTAU FULL API AUTOTEST" Cyan
Write-Log "============================================" Cyan
Write-Log "Root       : $Root"
Write-Log "Base URL   : $BaseUrl"
Write-Log "Cookie file: $CookieFile"
Write-Log "Login file : $LoginFile"
Write-Log "Log file   : $LogFile"
Write-Log "CSV file   : $CsvFile"
Write-Log ""

# ============================================================
# CORE
# ============================================================

Write-Log "---- CORE API ----" Cyan

Invoke-TestRequest `
    -Name "/api/admin/health" `
    -Path "/api/admin/health" `
    -ExpectedStatus @(200)

Invoke-TestRequest `
    -Name "/api/sources" `
    -Path "/api/sources" `
    -ExpectedStatus @(200)

Invoke-TestRequest `
    -Name "/api/jobs" `
    -Path "/api/jobs" `
    -ExpectedStatus @(200)

Invoke-TestRequest `
    -Name "/api/organizations" `
    -Path "/api/organizations" `
    -ExpectedStatus @(200)

# ============================================================
# AUTHENTICATED
# ============================================================

Write-Log ""
Write-Log "---- AUTHENTICATED ----" Cyan

Invoke-TestRequest `
    -Name "/api/auth/me authenticated" `
    -Path "/api/auth/me" `
    -ExpectedStatus @(200) `
    -Authenticated

Invoke-TestRequest `
    -Name "/api/users/me authenticated" `
    -Path "/api/users/me" `
    -ExpectedStatus @(200) `
    -Authenticated

# ============================================================
# UNAUTHENTICATED
# ============================================================

Write-Log ""
Write-Log "---- UNAUTHENTICATED SECURITY ----" Cyan

Invoke-TestRequest `
    -Name "/api/auth/me without login" `
    -Path "/api/auth/me" `
    -ExpectedStatus @(401) `
    -NoCookie

Invoke-TestRequest `
    -Name "/api/users/me without login" `
    -Path "/api/users/me" `
    -ExpectedStatus @(401) `
    -NoCookie

Invoke-TestRequest `
    -Name "/api/safety/contacts without login" `
    -Path "/api/safety/contacts" `
    -ExpectedStatus @(401) `
    -NoCookie

# ============================================================
# COMMUNITY
# ============================================================

Write-Log ""
Write-Log "---- COMMUNITY ----" Cyan

Invoke-TestRequest `
    -Name "/api/community" `
    -Path "/api/community" `
    -ExpectedStatus @(200) `
    -Authenticated

# ============================================================
# MARKETPLACE
# ============================================================

Write-Log ""
Write-Log "---- MARKETPLACE ----" Cyan

Invoke-TestRequest `
    -Name "/api/marketplace" `
    -Path "/api/marketplace" `
    -ExpectedStatus @(200) `
    -Authenticated

# ============================================================
# SAFETY
# ============================================================

Write-Log ""
Write-Log "---- SAFETY ----" Cyan

Invoke-TestRequest `
    -Name "/api/safety/contacts authenticated" `
    -Path "/api/safety/contacts" `
    -ExpectedStatus @(200,204) `
    -Authenticated

# ============================================================
# REGISTER INVALID INPUT
# ============================================================

Write-Log ""
Write-Log "---- VALIDATION ----" Cyan

$BadRegister = '{"invalid":true}'

Invoke-TestRequest `
    -Name "/api/auth/register invalid body" `
    -Method "POST" `
    -Path "/api/auth/register" `
    -ExpectedStatus @(400,401,422) `
    -Body $BadRegister

# ============================================================
# CHECKOUT INVALID INPUT
# ============================================================

$BadCheckout = '{"plan":"INVALID_TEST_PLAN"}'

Invoke-TestRequest `
    -Name "/api/membership/checkout invalid plan" `
    -Method "POST" `
    -Path "/api/membership/checkout" `
    -ExpectedStatus @(400,401,422) `
    -Body $BadCheckout `
    -Authenticated

# ============================================================
# AI INVALID INPUT
# ============================================================

$BadAI = '{"message":""}'

Invoke-TestRequest `
    -Name "/api/ai/chat empty message" `
    -Method "POST" `
    -Path "/api/ai/chat" `
    -ExpectedStatus @(400,401,422) `
    -Body $BadAI `
    -Authenticated

# ============================================================
# ORGANIZATION ROUTES
# ============================================================

Write-Log ""
Write-Log "---- ORGANIZATION / SECRETARY ----" Cyan

Invoke-TestRequest `
    -Name "/api/organizations authenticated" `
    -Path "/api/organizations" `
    -ExpectedStatus @(200) `
    -Authenticated

Invoke-TestRequest `
    -Name "/api/organizations/me" `
    -Path "/api/organizations/me" `
    -ExpectedStatus @(200,401,403,404) `
    -Authenticated

Invoke-TestRequest `
    -Name "/api/organizations/secretary" `
    -Path "/api/organizations/secretary" `
    -ExpectedStatus @(200,401,403,404) `
    -Authenticated

# ============================================================
# FAKE ORIGIN
# ============================================================

Write-Log ""
Write-Log "---- ORIGIN SECURITY ----" Cyan

Invoke-TestRequest `
    -Name "Fake Origin /api/auth/me" `
    -Path "/api/auth/me" `
    -ExpectedStatus @(403) `
    -Authenticated `
    -ExtraHeaders @{
        "Origin" = "https://evil.example"
    }

# ============================================================
# SUMMARY
# ============================================================

$PassCount = @(
    $Results | Where-Object { $_.Status -eq "PASS" }
).Count

$FailCount = @(
    $Results | Where-Object { $_.Status -eq "FAIL" }
).Count

$Total = $Results.Count

Write-Log ""
Write-Log "============================================" Cyan
Write-Log " AUTOTEST SUMMARY" Cyan
Write-Log "============================================" Cyan
Write-Log ""
Write-Log "TOTAL : $Total"
Write-Log "PASS  : $PassCount" Green

if ($FailCount -gt 0) {
    Write-Log "FAIL  : $FailCount" Red
}
else {
    Write-Log "FAIL  : 0" Green
}

Write-Log ""

if ($FailCount -gt 0) {
    Write-Log "FAILED TESTS:" Red

    $Results |
        Where-Object { $_.Status -eq "FAIL" } |
        ForEach-Object {
            Write-Log (
                " - {0} | expected={1} | actual={2}" -f
                $_.Name,
                $_.Expected,
                $_.Actual
            ) Red
        }
}
else {
    Write-Log "SEMUA TEST YANG DIJALANKAN LULUS." Green
}

$Results |
    Export-Csv `
        -NoTypeInformation `
        -Encoding UTF8 `
        -LiteralPath $CsvFile

Write-Log ""
Write-Log "Log : $LogFile"
Write-Log "CSV : $CsvFile"

if ($FailCount -gt 0) {
    exit 1
}

exit 0



