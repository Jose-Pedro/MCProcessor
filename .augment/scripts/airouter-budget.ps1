# airouter-budget.ps1 - summarise per-call records written by airouter-call.ps1.
#
# Source of truth: .augment/.airouter-budget.jsonl (one JSON object per line).
# Use this BEFORE adopting any "use airouter more aggressively" policy so
# spend is observable, not assumed.
#
# Usage:
#   .\airouter-budget.ps1                # human-readable summary, today + 7d + 30d
#   .\airouter-budget.ps1 -Compact       # one-line summary suitable for bootstrap brief
#   .\airouter-budget.ps1 -ByTag         # break down today's totals by -Tag value
#
[CmdletBinding()]
param(
    [switch]$Compact,
    [switch]$ByTag,
    [string]$BudgetPath = ''
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if ([string]::IsNullOrEmpty($BudgetPath)) {
    $BudgetPath = Join-Path $scriptDir '..\.airouter-budget.jsonl'
}

if (-not (Test-Path $BudgetPath)) {
    if ($Compact) { "airouter: no calls recorded yet" } else { Write-Host "No budget file at $BudgetPath (no calls recorded yet)." }
    exit 0
}

$now = Get-Date
$cutToday = $now.Date
$cut7d    = $now.AddDays(-7)
$cut30d   = $now.AddDays(-30)

$records = Get-Content $BudgetPath -Encoding UTF8 | Where-Object { $_ -and $_.Trim() } | ForEach-Object {
    try { $_ | ConvertFrom-Json } catch { $null }
} | Where-Object { $_ }

function Sum-Window {
    param($recs, [datetime]$since)
    $w = @($recs | Where-Object { [datetime]$_.ts -ge $since })
    [pscustomobject]@{
        calls    = $w.Count
        prompt   = ($w | Measure-Object -Property prompt_tokens -Sum).Sum
        compl    = ($w | Measure-Object -Property completion_tokens -Sum).Sum
        reason   = ($w | Measure-Object -Property reasoning_tokens -Sum).Sum
        total    = ($w | Measure-Object -Property total_tokens -Sum).Sum
        errors   = @($w | Where-Object { $_.status -eq 'error' }).Count
        empties  = @($w | Where-Object { $_.status -eq 'empty' }).Count
    }
}

$today = Sum-Window $records $cutToday
$wk    = Sum-Window $records $cut7d
$mo    = Sum-Window $records $cut30d

if ($Compact) {
    $todayN = if ($null -eq $today.total) { 0 } else { $today.total }
    $wkN    = if ($null -eq $wk.total)    { 0 } else { $wk.total }
    $moN    = if ($null -eq $mo.total)    { 0 } else { $mo.total }
    "airouter: today={0} calls / {1} tok  |  7d={2} / {3} tok  |  30d={4} / {5} tok" -f `
        $today.calls, $todayN, $wk.calls, $wkN, $mo.calls, $moN
    exit 0
}

function Show-Window {
    param([string]$label, $w)
    $totalN  = if ($null -eq $w.total)  { 0 } else { $w.total }
    $promptN = if ($null -eq $w.prompt) { 0 } else { $w.prompt }
    $complN  = if ($null -eq $w.compl)  { 0 } else { $w.compl }
    $reasonN = if ($null -eq $w.reason) { 0 } else { $w.reason }
    "{0,-8} calls={1,-4} prompt={2,-7} completion={3,-7} (reasoning={4,-7}) total={5,-7} errors={6} empties={7}" -f `
        $label, $w.calls, $promptN, $complN, $reasonN, $totalN, $w.errors, $w.empties
}

Write-Host "airouter budget - source: $BudgetPath" -ForegroundColor Cyan
Show-Window 'today'  $today
Show-Window '7d'     $wk
Show-Window '30d'    $mo

if ($ByTag) {
    Write-Host ''
    Write-Host "today by -Tag:" -ForegroundColor Cyan
    $records | Where-Object { [datetime]$_.ts -ge $cutToday } | Group-Object tag | ForEach-Object {
        $g = $_.Group
        $tot = ($g | Measure-Object -Property total_tokens -Sum).Sum
        $cal = $g.Count
        "  {0,-20} calls={1,-4} total_tokens={2}" -f $_.Name, $cal, ($(if ($null -eq $tot) { 0 } else { $tot }))
    }
}
