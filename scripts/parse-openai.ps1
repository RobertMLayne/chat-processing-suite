#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ExportDir = "examples/openai-export",
    [string]$OutDir = "docs/ledger/out",
    [switch]$Execute,
    [switch]$DryRun = $false
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

$conversations = Join-Path $ExportDir "conversations.json"
if (!(Test-Path -LiteralPath $conversations)) { throw "conversations.json not found under $ExportDir" }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if ($DryRun -and -not $Execute) {
    Write-Host "DryRun: would parse $conversations and emit normalized CSV/JSON into $OutDir"
    return
}

# Placeholder: implement parsing as needed; keep outputs out of repo by default.
Write-Host "Parsing complete (placeholder)."
