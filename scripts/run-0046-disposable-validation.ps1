[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$RepositoryRoot=Split-Path -Parent $PSScriptRoot
Push-Location $RepositoryRoot
try {
  & node (Join-Path $RepositoryRoot 'scripts/validate-0046.mjs')
  if($LASTEXITCODE -ne 0){throw '0046_DISPOSABLE_VALIDATION_FAILED'}
} finally { Pop-Location }
