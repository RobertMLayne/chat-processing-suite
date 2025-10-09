#requires -Version 7.0
[CmdletBinding()]
param(
    [string[]]$Patterns = @("*.zip", "*.html", "*.json", "*.csv", "*.pdf", "*.wav", "*.mp3", "*.mp4", "*.mov", "*.png", "*.jpg", "*.jpeg"),
    [string]$RepoRoot = "."
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $RepoRoot
if (!(Test-Path ".gitattributes")) { '' | Out-File ".gitattributes" -Encoding utf8 -NoNewline }
foreach ($p in $Patterns) { git lfs track -- $p | Out-Null }
git add .gitattributes
git lfs track
