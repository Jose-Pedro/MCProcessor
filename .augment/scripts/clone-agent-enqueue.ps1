# clone-agent-enqueue.ps1 - append a task to the clone-agent queue.
#
# Tasks are processed serially by .\clone-agent-worker.ps1 (scheduled to
# run on CHost every 10 minutes via AugmentCloneAgentWorker, or invokable
# on-demand). Each task is one airouter call charged to slot 1 ("clone
# agent"); results land back in .augment/memory/raw/ (visible to all
# agents on next OneDrive sync / git pull) and in
# .augment/clone-agent/results/<id>.json for direct lookup.
#
# Usage:
#   .\clone-agent-enqueue.ps1 -Prompt "Summarise today's SESSION_LOG entry into 3 bullets"
#   .\clone-agent-enqueue.ps1 -Prompt "..." -Kind summarize -Tag daily-recap -MaxTokens 1024
#   .\clone-agent-enqueue.ps1 -Prompt "..." -System "You are a code reviewer"
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Prompt,
    [string]$System = '',
    [string]$Kind = 'freeform',
    [string]$Tag = 'general',
    [int]$MaxTokens = 2048,
    [string]$EnqueuedBy = $(if ($env:AUGMENT_ARCHITECT) { $env:AUGMENT_ARCHITECT } else { 'zepedro' })
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$caDir = Join-Path $scriptDir '..\clone-agent'
$null = New-Item -ItemType Directory -Force -Path $caDir
$queuePath = Join-Path $caDir 'queue.jsonl'

$id = [guid]::NewGuid().ToString('N').Substring(0,12)
$entry = [ordered]@{
    id           = $id
    ts           = (Get-Date).ToString('s')
    enqueued_by  = $EnqueuedBy
    enqueued_on  = $env:COMPUTERNAME
    kind         = $Kind
    tag          = $Tag
    max_tokens   = $MaxTokens
    system       = $System
    prompt       = $Prompt
}
Add-Content -Path $queuePath -Value ($entry | ConvertTo-Json -Depth 4 -Compress) -Encoding UTF8
Write-Host "enqueued id=$id kind=$Kind tag=$Tag tokens<=$MaxTokens" -ForegroundColor Green
Write-Host "queue: $queuePath"
