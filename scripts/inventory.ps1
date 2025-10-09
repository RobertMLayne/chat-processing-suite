#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Root = ".",
    [string]$OutDir = "docs/ledger",
    [switch]$Execute,
    [switch]$DryRun
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

$rootPath = Resolve-Path -LiteralPath $Root
$out = Join-Path $rootPath $OutDir
New-Item -ItemType Directory -Force -Path $out | Out-Null

$fileIndex = Join-Path $out "file-index.csv"
$hashFile = Join-Path $out "inventory.sha256"

$files = Get-ChildItem -LiteralPath $rootPath -Recurse -File -Force |
Where-Object { $_.FullName -notmatch '\\.git(\\|$)' }

# Build CSV
$rows = foreach ($f in $files) {
    $rel = $f.FullName.Substring($rootPath.Path.Length + 1).Replace('\', '/')
    $lfsOut = git lfs ls-files --name-only -- $rel 2>$null
    $isLfs = -not [string]::IsNullOrEmpty($lfsOut)
    [pscustomobject]@{
        path     = $rel
        size     = $f.Length
        type     = $f.Extension
        modified = $f.LastWriteTimeUtc.ToString("o")
        lfs      = $isLfs
    }
}

if ($null -eq $DryRun) { $DryRun = $true }

if ($DryRun -and -not $Execute) {
    $rows | Select-Object -First 5 | Format-Table -AutoSize | Out-String | Write-Host
    Write-Host "DryRun: would write $fileIndex and $hashFile"
    return
}

$rows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $fileIndex

# Hashes
Remove-Item -ErrorAction Ignore $hashFile
foreach ($f in $files) {
    $rel = $f.FullName.Substring($rootPath.Path.Length + 1).Replace('\', '/')
    $h = (Get-FileHash -Algorithm SHA256 -LiteralPath $f.FullName).Hash.ToLower()
    "$h  $rel" | Add-Content -Encoding UTF8 -LiteralPath $hashFile
}
Write-Host "Inventory complete: $fileIndex, $hashFile"
