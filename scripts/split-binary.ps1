#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [long]$ChunkBytes = 1900MB
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'
$full = Resolve-Path -LiteralPath $Path
$dir = Split-Path -LiteralPath $full -Parent
$base = Split-Path -LiteralPath $full -Leaf
$fs = [System.IO.File]::OpenRead($full)
try {
    $part = 0; $buffer = New-Object byte[] (8MB); $bytesInPart = 0L; $out = $null
    while (($read = $fs.Read($buffer, 0, $buffer.Length)) -gt 0) {
        if (-not $out -or $bytesInPart -ge $ChunkBytes) {
            if ($out) { $out.Dispose() }
            $outPath = Join-Path $dir ("{0}.part{1:d3}" -f $base, $part)
            $out = [System.IO.File]::Open($outPath, 'Create', 'Write', 'None')
            $part++; $bytesInPart = 0
            git lfs track -- (Split-Path -Leaf $outPath) | Out-Null
        }
        $out.Write($buffer, 0, $read); $bytesInPart += $read
    }
}
finally { if ($out) { $out.Dispose() }; $fs.Dispose() }
Write-Host "Split complete. Review and commit parts with LFS."
