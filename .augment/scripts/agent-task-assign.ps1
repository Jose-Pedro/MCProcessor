# agent-task-assign.ps1 - assign a task to the counterpart Augment agent.
#
# Writes one JSON line to .augment/agent-tasks/inbox-<to>.jsonl. The
# target agent picks it up at session start (see AGENTS.md "Agent task
# inbox" section) or whenever its user pings it to check.
#
# This is for tasks that need an Augment agent's *judgment* (code
# changes, design decisions, multi-file edits). For scriptable airouter
# work, use clone-agent-enqueue.ps1 instead. For embeddings / local
# memory work, that's CModel only - never assign as an agent task.
#
# Usage:
#   .\agent-task-assign.ps1 -To laptop -Title "Wire up X" -Prompt "Edit foo.ts to ..."
#   .\agent-task-assign.ps1 -To chost  -Title "Tune cold-path" -Prompt "..." -Priority high
#   .\agent-task-assign.ps1 -To laptop -Title "..." -Prompt "..." -DependsOn 7c3e1a
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('laptop','chost')][string]$To,
    [Parameter(Mandatory=$true)][string]$Title,
    [Parameter(Mandatory=$true)][string]$Prompt,
    [ValidateSet('low','normal','high')][string]$Priority = 'normal',
    [string]$DependsOn = '',
    [string[]]$Refs = @(),
    [string]$From = $(if ($env:AUGMENT_AGENT_HOST) { $env:AUGMENT_AGENT_HOST } elseif ($env:COMPUTERNAME -match 'CHOST|WORK') { 'chost' } else { 'laptop' }),
    [string]$Architect = $(if ($env:AUGMENT_ARCHITECT) { $env:AUGMENT_ARCHITECT } else { 'zepedro' })
)

$ErrorActionPreference = 'Stop'
if ($From -eq $To) { throw "Cannot assign to self (-From and -To both '$From'). Just do it yourself." }

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$tasksDir = Join-Path $scriptDir '..\agent-tasks'
$null = New-Item -ItemType Directory -Force -Path $tasksDir
$inbox = Join-Path $tasksDir "inbox-$To.jsonl"

$id = [guid]::NewGuid().ToString('N').Substring(0,8)
$entry = [ordered]@{
    id           = $id
    ts           = (Get-Date).ToString('s')
    from         = $From
    to           = $To
    architect    = $Architect
    priority     = $Priority
    status       = 'pending'
    title        = $Title
    prompt       = $Prompt
    depends_on   = $DependsOn
    refs         = $Refs
}
Add-Content -Path $inbox -Value ($entry | ConvertTo-Json -Depth 4 -Compress) -Encoding UTF8
Write-Host "assigned id=$id  $From -> $To  [$Priority]  $Title" -ForegroundColor Green
Write-Host "inbox: $inbox"
Write-Host ""
Write-Host "Tell the $To architect to open their Augment session and have it check:" -ForegroundColor Yellow
Write-Host "  .\.augment\scripts\agent-task-list.ps1 -Mine" -ForegroundColor Yellow
