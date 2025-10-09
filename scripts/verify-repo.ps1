#requires -Version 7.0
[CmdletBinding()]
param([string]$RepoRoot = ".")
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $RepoRoot

Write-Host "== Git status =="; git status --porcelain=v1
Write-Host "== LFS tracked patterns =="; git lfs track
Write-Host "== LFS files =="; git lfs ls-files
Write-Host "== Large file check =="; .\scripts\detect-large.ps1
Write-Host "== Done =="; exit 0
