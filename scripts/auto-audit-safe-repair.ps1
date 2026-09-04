$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Backup = Join-Path $Root "_auto_audit_backup_$Stamp"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " DUTA-RANTAU PHASE 4 - AUTO AUDIT / SAFE REPAIR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "ROOT   : $Root"
Write-Host "BACKUP : $Backup"
Write-Host ""

New-Item -ItemType Directory -Force -Path $Backup | Out-Null

function Backup-File([string]$Path) {
    if (Test-Path $Path) {
        $dest = Join-Path $Backup $Path
        $dir = Split-Path $dest -Parent
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Copy-Item $Path $dest -Force
        Write-Host "BACKUP $Path" -ForegroundColor DarkGray
    }
}

function Read-Text([string]$Path) {
    if (!(Test-Path $Path)) { return "" }
    return Get-Content $Path -Raw
}

function Fail-Safe([string]$Message) {
    Write-Host ""
    Write-Host "!!! SAFE STOP !!!" -ForegroundColor Red
    Write-Host $Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Tidak ada migration database yang dijalankan." -ForegroundColor Yellow
    Write-Host "Tidak ada CREATE ROLE yang dijalankan." -ForegroundColor Yellow
    Write-Host "Backup: $Backup" -ForegroundColor Green
    exit 2
}

# ============================================================
# 1. REQUIRED FILES
# ============================================================

Write-Host "[1] REQUIRED FILES" -ForegroundColor Yellow

$required = @(
    "db\client.ts",
    "db\schema.ts",
    "lib\db\identity-bridge.ts",
    "lib\auth\verified-user.ts",
    "vitest.config.ts",
    "package.json"
)

foreach ($f in $required) {
    if (Test-Path $f) {
        Write-Host "PASS $f" -ForegroundColor Green
    } else {
        Fail-Safe "Missing required file: $f"
    }
}

# ============================================================
# 2. ENVIRONMENT
# ============================================================

Write-Host ""
Write-Host "[2] ENVIRONMENT AUDIT" -ForegroundColor Yellow

if (!(Test-Path ".env.local")) {
    Fail-Safe ".env.local tidak ditemukan."
}

$envText = Get-Content ".env.local" -Raw

foreach ($name in @(
    "DATABASE_URL",
    "DIRECT_URL",
    "APP_DATABASE_URL",
    "SYSTEM_DATABASE_URL"
)) {
    if ($envText -match "(?m)^\s*$name\s*=\s*\S+") {
        Write-Host "PRESENT $name" -ForegroundColor Green
    } else {
        Write-Host "ABSENT  $name" -ForegroundColor Yellow
    }
}

$hasAppUrl = $envText -match "(?m)^\s*APP_DATABASE_URL\s*=\s*\S+"
$hasSystemUrl = $envText -match "(?m)^\s*SYSTEM_DATABASE_URL\s*=\s*\S+"

if (!$hasAppUrl -or !$hasSystemUrl) {
    Write-Host ""
    Write-Host "SAFE STOP: APP_DATABASE_URL / SYSTEM_DATABASE_URL belum tersedia." -ForegroundColor Yellow
    Write-Host "Belum membuat role dan belum mengubah DB runtime." -ForegroundColor Yellow
}

# ============================================================
# 3. DATABASE CLIENT AUDIT
# ============================================================

Write-Host ""
Write-Host "[3] DATABASE CLIENT" -ForegroundColor Yellow

$dbClient = Read-Text "db\client.ts"

if ($dbClient -match "export const appDb = db" -and
    $dbClient -match "export const systemDb = db") {

    Write-Host "FOUND shared appDb/systemDb" -ForegroundColor Red
    Write-Host "Runtime masih memakai satu DATABASE_URL." -ForegroundColor Yellow
    $sharedClient = $true
} else {
    Write-Host "Shared client pattern tidak ditemukan." -ForegroundColor Green
    $sharedClient = $false
}

if (Test-Path "lib\db\client.ts") {

    $libClientRefs = Get-ChildItem app,lib,components -Recurse -File `
        -Include *.ts,*.tsx `
        -ErrorAction SilentlyContinue |
        Select-String "@/lib/db/client" -ErrorAction SilentlyContinue

    if (!$libClientRefs) {
        Write-Host "DEAD CLIENT: lib\db\client.ts" -ForegroundColor Yellow
    } else {
        Write-Host "lib\db\client.ts masih direferensikan." -ForegroundColor Green
    }
}

# ============================================================
# 4. IDENTITY FUNCTIONS
# ============================================================

Write-Host ""
Write-Host "[4] IDENTITY FUNCTION AUDIT" -ForegroundColor Yellow

$sqlFiles = Get-ChildItem db -Recurse -File -Filter *.sql

$identityRefs = $sqlFiles |
    Select-String -Pattern `
    "current_app_user_id|current_app_has_role|current_app_has_org_role" `
    -AllMatches `
    -ErrorAction SilentlyContinue

if ($identityRefs) {
    Write-Host "Identity function references ditemukan:" -ForegroundColor Yellow

    $identityRefs | ForEach-Object {
        Write-Host "$($_.Path):$($_.LineNumber)" -ForegroundColor DarkGray
    }
}

$functionDefinitions = $sqlFiles |
    Select-String -Pattern `
    "CREATE\s+(OR\s+REPLACE\s+)?FUNCTION\s+public\.(current_app_user_id|current_app_has_role|current_app_has_org_role)" `
    -AllMatches `
    -ErrorAction SilentlyContinue

if (!$functionDefinitions) {
    Write-Host "MISSING: current_app_* function definitions" -ForegroundColor Red
    $missingIdentityFunctions = $true
} else {
    Write-Host "PASS identity function definitions found" -ForegroundColor Green
    $missingIdentityFunctions = $false
}

# ============================================================
# 5. INVALID GLOBAL ADMIN
# ============================================================

Write-Host ""
Write-Host "[5] GLOBAL USER ROLE AUDIT" -ForegroundColor Yellow

$archival = "db\supabase-phase4-organization-archival.sql"

if (Test-Path $archival) {

    $archivalText = Read-Text $archival

    if ($archivalText -match `
        "ARRAY\['ADMIN','SUPER_ADMIN'\]::public\.user_role\[\]") {

        Write-Host "FOUND invalid global ADMIN." -ForegroundColor Red

        Backup-File $archival

        $archivalText = $archivalText -replace `
            "ARRAY\['ADMIN','SUPER_ADMIN'\]::public\.user_role\[\]", `
            "ARRAY['EDITOR','SUPER_ADMIN']::public.user_role[]"

        Set-Content `
            -Path $archival `
            -Value $archivalText `
            -Encoding UTF8

        Write-Host "REPAIRED global ADMIN -> EDITOR/SUPER_ADMIN" -ForegroundColor Green

    } else {
        Write-Host "PASS global role reference" -ForegroundColor Green
    }
}

# ============================================================
# 6. 0010 SAFETY AUDIT
# ============================================================

Write-Host ""
Write-Host "[6] 0010 RUNTIME ROLE MIGRATION" -ForegroundColor Yellow

$roleMigration = "db\migrations\0010_runtime_database_roles.sql"

if (Test-Path $roleMigration) {

    $roleSql = Read-Text $roleMigration

    if ($roleSql -match `
        "GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE") {

        Write-Host "DANGEROUS: broad table grants detected." -ForegroundColor Red
        Write-Host "0010 TIDAK AKAN DIJALANKAN." -ForegroundColor Red
    }

    if ($roleSql -match "CREATE ROLE duta_app" -and
        $roleSql -match "CREATE ROLE duta_system") {

        Write-Host "Role provisioning exists in 0010." -ForegroundColor Yellow
    }
}

# ============================================================
# 7. PROTECT AGAINST POSTGRES RUNTIME
# ============================================================

Write-Host ""
Write-Host "[7] POSTGRES RUNTIME SAFETY" -ForegroundColor Yellow

if ($dbClient -match "process\.env\.DATABASE_URL") {
    Write-Host "WARNING: db/client.ts directly consumes DATABASE_URL." -ForegroundColor Red
}

if ($dbClient -match "appDb\s*=\s*db" -and
    $dbClient -match "systemDb\s*=\s*db") {

    Write-Host "CONFIRMED: appDb/systemDb both resolve to DATABASE_URL." -ForegroundColor Red
    Write-Host "This is the root cause of duta_app failure." -ForegroundColor Yellow
}

# ============================================================
# 8. DEMO DATA
# ============================================================

Write-Host ""
Write-Host "[8] DEMO DATA AUDIT" -ForegroundColor Yellow

$demoHits = Get-ChildItem app,lib,components -Recurse -File `
    -Include *.ts,*.tsx `
    -ErrorAction SilentlyContinue |
    Select-String -Pattern `
    "demo-data|mockData|fakeData|dummyData|sampleData|DemoData" `
    -ErrorAction SilentlyContinue

if ($demoHits) {

    Write-Host "WARNING demo references:" -ForegroundColor Yellow

    $demoHits |
        Select-Object -First 40 |
        ForEach-Object {
            Write-Host "$($_.Path):$($_.LineNumber)" -ForegroundColor DarkGray
        }

} else {
    Write-Host "PASS no obvious demo references" -ForegroundColor Green
}

# ============================================================
# 9. GIT STATUS
# ============================================================

Write-Host ""
Write-Host "[9] GIT STATUS" -ForegroundColor Yellow

git status --short

# ============================================================
# 10. SAFE REPAIR: INVALID ADMIN ONLY
# ============================================================

Write-Host ""
Write-Host "[10] SAFE SOURCE REPAIR" -ForegroundColor Yellow

Write-Host "Only deterministic enum repair has been applied." -ForegroundColor Green
Write-Host "No database migration executed." -ForegroundColor Green
Write-Host "No PostgreSQL role created." -ForegroundColor Green

# ============================================================
# 11. TYPESCRIPT
# ============================================================

Write-Host ""
Write-Host "[11] TYPESCRIPT" -ForegroundColor Yellow

npx tsc --noEmit

if ($LASTEXITCODE -ne 0) {
    Write-Host "TypeScript masih FAIL." -ForegroundColor Red
} else {
    Write-Host "PASS TypeScript" -ForegroundColor Green
}

# ============================================================
# 12. VITEST
# ============================================================

Write-Host ""
Write-Host "[12] VITEST" -ForegroundColor Yellow

npx vitest run

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Vitest masih FAIL — kemungkinan besar karena runtime role." -ForegroundColor Red
} else {
    Write-Host "PASS Vitest" -ForegroundColor Green
}

# ============================================================
# FINAL
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " AUDIT / SAFE REPAIR SELESAI" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "BACKUP:" -ForegroundColor Green
Write-Host $Backup

Write-Host ""
Write-Host "STATUS KEAMANAN:" -ForegroundColor Yellow
Write-Host " - postgres runtime: DILARANG"
Write-Host " - 0010 migration: BELUM DIJALANKAN"
Write-Host " - CREATE ROLE: BELUM DIJALANKAN"
Write-Host " - db:migrate: BELUM DIJALANKAN"
Write-Host " - broad grants: TIDAK DITERAPKAN"

Write-Host ""
Write-Host "NEXT STEP: kirim seluruh output script ini." -ForegroundColor Cyan
