$ErrorActionPreference = "Stop"

$Root = "D:\DUTA-RANTAU-STAGING"
Set-Location $Root

$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Backup = Join-Path $Root "_auto_audit_backup\$Stamp"
New-Item -ItemType Directory -Force -Path $Backup | Out-Null

$Fail = 0
$Repair = 0

function PASS($m) {
    Write-Host "[PASS] $m" -ForegroundColor Green
}
function WARN($m) {
    Write-Host "[WARN] $m" -ForegroundColor Yellow
}
function FAIL($m) {
    Write-Host "[FAIL] $m" -ForegroundColor Red
    $script:Fail++
}
function REPAIR($m) {
    Write-Host "[REPAIR] $m" -ForegroundColor Cyan
    $script:Repair++
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " DUTA-RANTAU SAFE AUTO AUDIT + AUTO REPAIR" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "ROOT   : $Root"
Write-Host "BACKUP : $Backup"
Write-Host ""

# ------------------------------------------------------------
# 1. Preconditions
# ------------------------------------------------------------
if (-not (Test-Path ".git")) {
    FAIL "Bukan Git repository"
    exit 1
}

PASS "Git repository"

# ------------------------------------------------------------
# 2. Backup target files before any repair
# ------------------------------------------------------------
$Targets = @(
    "db\migrations\0008_phase4_real_content_rls.sql",
    "db\migrations\0009_organization_archival_workflow.sql",
    "app\api\admin\organizations\route.ts"
)

foreach ($f in $Targets) {
    if (Test-Path $f) {
        $dest = Join-Path $Backup ($f -replace '[\\/]','_')
        Copy-Item $f $dest -Force
    }
}

PASS "Backup target files dibuat"

# ------------------------------------------------------------
# 3. Safe repair: only known AM/regression targets
# ------------------------------------------------------------
foreach ($f in $Targets) {
    if (Test-Path $f) {
        $wt = git diff -- $f
        if ($LASTEXITCODE -ne 0) {
            FAIL "Git diff gagal: $f"
            continue
        }

        if ($wt) {
            Write-Host ""
            WARN "Working-tree divergence terdeteksi: $f"

            # Only repair files that are already staged additions/changes.
            $cached = git diff --cached --name-only -- $f

            if ($cached -contains $f) {
                git restore --worktree -- $f
                if ($LASTEXITCODE -eq 0) {
                    REPAIR "Working tree dipulihkan ke staged version: $f"
                }
                else {
                    FAIL "Gagal restore: $f"
                }
            }
            else {
                WARN "Tidak disentuh karena belum staged: $f"
            }
        }
        else {
            PASS "Working tree clean: $f"
        }
    }
    else {
        WARN "File tidak ditemukan: $f"
    }
}

# ------------------------------------------------------------
# 4. Migration 0008 / 0009 semantic audit
# ------------------------------------------------------------
foreach ($f in @(
    "db\migrations\0008_phase4_real_content_rls.sql",
    "db\migrations\0009_organization_archival_workflow.sql"
)) {
    if (-not (Test-Path $f)) {
        FAIL "Migration missing: $f"
        continue
    }

    $raw = [System.IO.File]::ReadAllText((Resolve-Path $f))

    if ($raw.StartsWith([char]0xFEFF)) {
        FAIL "$f mengandung UTF-8 BOM"
    }
    else {
        PASS "$f tidak mengandung BOM"
    }

    if ($raw -match "(?i)\bEDITOR\b") {
        FAIL "$f masih mengandung role EDITOR"
    }
    else {
        PASS "$f tidak menggunakan role EDITOR"
    }

    if ($raw -match "(?i)status\s*=\s*'PENDING'") {
        PASS "$f menggunakan physical column status dengan benar"
    }

    if ($f -like "*0009*") {
        foreach ($needle in @(
            "ADMIN','SUPER_ADMIN",
            "PENDING_REVIEW",
            "applicant_id",
            "OWNER','ADMIN",
            "BEFORE INSERT OR UPDATE",
            "DUTA_VERIFIED",
            "reviewed_by",
            "ARCHIVED"
        )) {
            if ($raw -match [regex]::Escape($needle)) {
                PASS "0009 contains: $needle"
            }
            else {
                FAIL "0009 missing expected control: $needle"
            }
        }
    }
}

# ------------------------------------------------------------
# 5. Runtime DB client audit
# ------------------------------------------------------------
if (Test-Path "db\client.ts") {
    PASS "Canonical db/client.ts exists"
}
else {
    FAIL "db/client.ts missing"
}

if (Test-Path "lib\db\client.ts") {
    FAIL "Duplicate lib/db/client.ts masih ada"
}
else {
    PASS "Duplicate lib/db/client.ts tidak ada"
}

$imports = Get-ChildItem -Recurse -File -Include *.ts,*.tsx |
    Where-Object {
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\.next\\" -and
        $_.FullName -notmatch "\\_auto_audit_backup\\"
    } |
    Select-String -Pattern "@/lib/db/client"

if ($imports) {
    FAIL "Masih ada import @/lib/db/client"
    $imports | ForEach-Object { Write-Host $_ }
}
else {
    PASS "Tidak ada import @/lib/db/client"
}

$badRuntime = Get-ChildItem -Recurse -File -Include *.ts,*.tsx |
    Where-Object {
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\.next\\" -and
        $_.FullName -notmatch "\\_auto_audit_backup\\" -and
        $_.FullName -notmatch "drizzle.config.ts"
    } |
    Select-String -Pattern "process\.env\.DATABASE_URL"

if ($badRuntime) {
    FAIL "Runtime code masih memakai DATABASE_URL"
    $badRuntime | ForEach-Object { Write-Host $_ }
}
else {
    PASS "DATABASE_URL hanya boleh tersisa di tooling/migration"
}

# ------------------------------------------------------------
# 6. Runtime role hardening audit
# ------------------------------------------------------------
$client = Get-Content ".\db\client.ts" -Raw

foreach ($needle in @(
    "APP_DATABASE_URL",
    "SYSTEM_DATABASE_URL",
    "export const db = appDb",
    "Does NOT fall back"
)) {
    if ($client -match [regex]::Escape($needle)) {
        PASS "db/client.ts control: $needle"
    }
    else {
        WARN "db/client.ts marker tidak ditemukan: $needle"
    }
}

# ------------------------------------------------------------
# 7. Identity bridge audit
# ------------------------------------------------------------
if (Test-Path "lib\db\identity-bridge.ts") {
    PASS "Canonical identity bridge exists"
}
else {
    FAIL "lib/db/identity-bridge.ts missing"
}

if (Test-Path "lib\auth\identity-bridge.ts") {
    FAIL "Legacy lib/auth/identity-bridge.ts masih ada"
}
else {
    PASS "Legacy lib/auth/identity-bridge.ts tidak ada"
}

# ------------------------------------------------------------
# 8. Runtime migrations audit
# ------------------------------------------------------------
foreach ($n in 10..13) {
    $f = "db\migrations\00$n`_runtime"
    $found = Get-ChildItem "db\migrations" -Filter "00$n*.sql" -ErrorAction SilentlyContinue

    if ($found) {
        PASS "Runtime migration 00$n exists"
    }
    else {
        FAIL "Runtime migration 00$n missing"
    }
}

# ------------------------------------------------------------
# 9. Drizzle journal safety
# ------------------------------------------------------------
$journal = "db\migrations\meta\_journal.json"

if (Test-Path $journal) {
    $j = Get-Content $journal -Raw

    foreach ($n in 10..13) {
        if ($j -match """tag""\s*:\s*""00$n") {
            FAIL "001$n masuk Drizzle journal — seharusnya tidak"
        }
    }

    PASS "0010-0013 tidak terdaftar sebagai Drizzle migration"
}
else {
    FAIL "_journal.json missing"
}

# ------------------------------------------------------------
# 10. Secret/untracked file safety
# ------------------------------------------------------------
foreach ($f in @(
    "env.local",
    ".env.local",
    "app\kerja\page.tsx.bak",
    "FINAL_HARDENING.patch"
)) {
    if (Test-Path $f) {
        WARN "Untracked/sensitive candidate exists: $f"
    }
}

$stagedSecrets = git diff --cached --name-only |
    Where-Object {
        $_ -match "(^|/)(\.env|env\.local|.*\.pem|.*\.key)$"
    }

if ($stagedSecrets) {
    FAIL "Potential secret files staged:"
    $stagedSecrets | ForEach-Object { Write-Host $_ }
}
else {
    PASS "Tidak ada secret filename umum yang staged"
}

# ------------------------------------------------------------
# 11. Cached diff integrity
# ------------------------------------------------------------
git diff --cached --check

if ($LASTEXITCODE -eq 0) {
    PASS "git diff --cached --check"
}
else {
    FAIL "git diff --cached --check gagal"
}

# ------------------------------------------------------------
# 12. TypeScript
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== TYPESCRIPT ===" -ForegroundColor Green

npx tsc --noEmit

if ($LASTEXITCODE -eq 0) {
    PASS "TypeScript"
}
else {
    FAIL "TypeScript"
}

# ------------------------------------------------------------
# 13. Tests
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== VITEST ===" -ForegroundColor Green

npx vitest run

if ($LASTEXITCODE -eq 0) {
    PASS "Vitest"
}
else {
    FAIL "Vitest"
}

# ------------------------------------------------------------
# 14. Final git state
# ------------------------------------------------------------
Write-Host ""
Write-Host "=== FINAL GIT STATUS ===" -ForegroundColor Green
git status --short

Write-Host ""
Write-Host "============================================"
Write-Host " AUTO AUDIT SELESAI"
Write-Host " Repairs : $Repair"
Write-Host " Fail    : $Fail"
Write-Host " Backup  : $Backup"
Write-Host "============================================"

if ($Fail -gt 0) {
    exit 2
}

exit 0
