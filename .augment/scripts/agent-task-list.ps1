# agent-task-list.ps1 - inspect the agent-to-agent task queues.
[CmdletBinding()]
param(
    [switch]$Mine,
    [switch]$Other,
    [switch]$All,
    [switch]$IncludeDone,
    [string]$Self = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($Self)) {
    if ($env:AUGMENT_AGENT_HOST) { $Self = $env:AUGMENT_AGENT_HOST }
    elseif ($env:COMPUTERNAME -match 'CHOST|WORK') { $Self = 'chost' }
    else { $Self = 'laptop' }
}
if (-not $Mine -and -not $Other -and -not $All) { $Mine = $true }

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$tasksDir = Join-Path $scriptDir '..\agent-tasks'
$donePath = Join-Path $tasksDir 'done.jsonl'

function Read-InboxLines {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    @(Get-Content $Path -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ })
}

$doneIds = @{}
if (Test-Path $donePath) {
    foreach ($d in (Read-InboxLines -Path $donePath)) { $doneIds[$d.id] = $d.status }
}

if ($Self -eq 'chost') { $otherSide = 'laptop' } else { $otherSide = 'chost' }

$boxes = @()
if ($All -or $Mine) { $boxes += [pscustomobject]@{ label = "INBOX (assigned to $Self)"; path = (Join-Path $tasksDir "inbox-$Self.jsonl") } }
if ($All -or $Other) { $boxes += [pscustomobject]@{ label = "OUTBOX (this host -> $otherSide)"; path = (Join-Path $tasksDir "inbox-$otherSide.jsonl") } }

foreach ($b in $boxes) {
    Write-Host ""
    Write-Host "=== $($b.label) ===" -ForegroundColor Cyan
    $items = Read-InboxLines -Path $b.path
    if (-not $items) { Write-Host "  (empty)" -ForegroundColor DarkGray; continue }
    $shown = $items | ForEach-Object {
        $closed = ''
        if ($doneIds.ContainsKey($_.id)) { $closed = $doneIds[$_.id] }
        if (-not $IncludeDone -and $closed) { return }
        $st = if ($closed) { $closed } else { $_.status }
        [pscustomobject]@{
            id = $_.id; ts = $_.ts; from = $_.from; to = $_.to
            pri = $_.priority; status = $st; title = $_.title
        }
    } | Where-Object { $_ }
    if (-not $shown) { Write-Host "  (no pending; -IncludeDone to see closed)" -ForegroundColor DarkGray; continue }
    $shown | Format-Table id, ts, from, to, pri, status, title -AutoSize | Out-String | Write-Host
}
