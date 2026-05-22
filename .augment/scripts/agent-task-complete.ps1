# agent-task-complete.ps1 - close an inbox task.
#
# Appends a record to .augment/agent-tasks/done.jsonl. The original
# inbox line is left intact (append-only); agent-task-list.ps1 hides
# closed tasks unless -IncludeDone is passed.
#
# Usage:
#   .\agent-task-complete.ps1 -Id 7c3e1a -Summary "Refactored bar.ts; tests green"
#   .\agent-task-complete.ps1 -Id 7c3e1a -Status failed -Summary "Hit X, deferred to CHost"
#   .\agent-task-complete.ps1 -Id 7c3e1a -Status deferred -Summary "Needs ollama, can't do from laptop"
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Id,
    [ValidateSet('complete','failed','deferred')][string]$Status = 'complete',
    [Parameter(Mandatory=$true)][string]$Summary,
    [string[]]$Artifacts = @(),
    [string]$By = $(if ($env:AUGMENT_AGENT_HOST) { $env:AUGMENT_AGENT_HOST } elseif ($env:COMPUTERNAME -match 'CHOST|WORK') { 'chost' } else { 'laptop' })
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$tasksDir = Join-Path $scriptDir '..\agent-tasks'
$donePath = Join-Path $tasksDir 'done.jsonl'
$null = New-Item -ItemType Directory -Force -Path $tasksDir

# Sanity check: id must exist in one of the inboxes
$found = $false
foreach ($inbox in @('inbox-chost.jsonl','inbox-laptop.jsonl')) {
    $p = Join-Path $tasksDir $inbox
    if (Test-Path $p) {
        if (Select-String -Path $p -Pattern "`"id`":`"$Id`"" -SimpleMatch -Quiet) { $found = $true; break }
    }
}
if (-not $found) { Write-Host "WARN: id '$Id' not found in any inbox - logging anyway" -ForegroundColor Yellow }

$entry = [ordered]@{
    id        = $Id
    ts        = (Get-Date).ToString('s')
    by        = $By
    status    = $Status
    summary   = $Summary
    artifacts = $Artifacts
}
Add-Content -Path $donePath -Value ($entry | ConvertTo-Json -Depth 4 -Compress) -Encoding UTF8
Write-Host "closed id=$Id status=$Status by=$By" -ForegroundColor Green
