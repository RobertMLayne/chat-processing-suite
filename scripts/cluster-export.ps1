#requires -Version 7.0
[CmdletBinding(DefaultParameterSetName = 'DryRun', SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false, ParameterSetName = 'Run')]
    [switch]$Execute,

    [Parameter(Mandatory = $false, ParameterSetName = 'DryRun')]
    [switch]$DryRun
)
Set-StrictMode -Version Latest; $ErrorActionPreference = 'Stop'

$conv = Get-ChildItem -LiteralPath $ExportDir -Recurse -File -Filter "conversations.json" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $conv) { throw "conversations.json not found under $ExportDir" }

$clusterMap = Join-Path $OutDir "cluster-map.md"
$taskIndex = Join-Path $OutDir "task-index.csv"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# naive label rules
$rules = @{
    '^bug'     = 'Bug'
    '^feature' = 'Feature'
    '.*'       = 'Other'
}

function Get-LabelForName {
    param([string]$Name)
    foreach ($pattern in $rules.Keys) {
        if ($Name -match $pattern) { return $rules[$pattern] }
    }
    return $null
}

# Example: write cluster map using $rules
# assumes $clusters is an array of objects with Name and Items properties
$sb = [System.Text.StringBuilder]::new()
foreach ($cluster in $clusters) {
    $label = Get-LabelForName $cluster.Name
    $sb.AppendLine("## $($cluster.Name) - $label") | Out-Null
    foreach ($item in $cluster.Items) { $sb.AppendLine("- $item") | Out-Null }
    $sb.AppendLine() | Out-Null
}
$sb.ToString() | Out-File -FilePath $clusterMap -Encoding utf8

# determine effective mode from parameter set (clear and testable)
$IsDryRun = $PSCmdlet.ParameterSetName -eq 'DryRun'

# Example usage: only write files when not a dry run
if ($IsDryRun) {
    Write-Verbose "Dry run: would write cluster map to $clusterMap"
}
else {
    # perform the actual write
    $sb.ToString() | Out-File -FilePath $clusterMap -Encoding utf8
}

# Example usage: run commands only when not a dry run
if (-not $IsDryRun) {
    kubectl apply -f $someManifest
}
else {
    Write-Verbose "Dry run: would run 'kubectl apply -f $someManifest'"
}

# Minimal outputs (placeholders) — real labeling logic can be extended
@("# Cluster Map", "", "_Generated from conversations.json_") | Set-Content -Encoding UTF8 $clusterMap
"id,cluster,goal,inputs,outputs,status,notes" | Set-Content -Encoding UTF8 $taskIndex
Write-Host "Cluster docs written."
