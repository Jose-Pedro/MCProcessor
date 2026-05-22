# memory-append.ps1 - hot-path appender for .augment/memory/raw/.
#
# Writes one JSON line per call. No model load, no embedding, no
# distillation - the nightly cold-path job consumes these raws.
#
# Usage:
#   .\memory-append.ps1 -Kind decision -Text "Adopt write-now/index-later"
#   .\memory-append.ps1 -Kind fact -Text "..." -Refs @{ file='AGENTS.md'; lines='120-214' }
#   .\memory-append.ps1 -Architect juan -Kind question -Text "..."
#
[CmdletBinding()]
param(
    [string]$Architect = $(if ($env:AUGMENT_ARCHITECT) { $env:AUGMENT_ARCHITECT } else { 'zepedro' }),
    [Parameter(Mandatory=$true)][string]$Kind,
    [Parameter(Mandatory=$true)][string]$Text,
    [object]$Refs = $null
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$rawDir = Resolve-Path (Join-Path $scriptDir '..\memory\raw')
$date = (Get-Date).ToString('yyyy-MM-dd')
$file = Join-Path $rawDir "$date.$Architect.jsonl"

$entry = [ordered]@{
    ts        = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    architect = $Architect
    kind      = $Kind
    text      = $Text
}
if ($null -ne $Refs) { $entry.refs = $Refs }

$line = ($entry | ConvertTo-Json -Depth 6 -Compress)
Add-Content -Path $file -Value $line -Encoding UTF8
Write-Host "appended -> $file" -ForegroundColor Green
