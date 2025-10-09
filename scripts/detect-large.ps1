#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$Path = ".",
    [long]$WarnBytes = 50MB,
    [long]$BlockBytes = 100MB
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
$root = Resolve-Path -LiteralPath $Path
$files = Get-ChildItem -LiteralPath $root -Recurse -File -Force |
Where-Object { $_.FullName -notmatch '\.git(\\|$)' }

$violations = @()
foreach ($f in $files) {
    if ($f.Length -ge $WarnBytes) {
        $rel = $f.FullName.Substring($root.Path.Length + 1).Replace('\', '/')
        $lfsOut = git lfs ls-files --name-only -- $rel 2>$null
        $hasLfs = -not [string]::IsNullOrEmpty($lfsOut)
        if (-not $hasLfs) { $violations += [pscustomobject]@{ Path = $rel; Size = $f.Length; TrackedInLFS = $false } }
    }
}
if ($violations) { Write-Warning "Files ≥$WarnBytes not tracked by LFS:"; $violations | Format-Table -AutoSize }
if ($files | Where-Object { $_.Length -ge $BlockBytes }) { throw "Files ≥$BlockBytes found. Use LFS." } # GitHub blocks ≥100 MiB. :contentReference[oaicite:8]{index=8}
