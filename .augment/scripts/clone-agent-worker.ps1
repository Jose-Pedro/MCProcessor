# clone-agent-worker.ps1 - drain the clone-agent queue.
#
# Reads .augment/clone-agent/queue.jsonl, processes each not-yet-done task
# serially through airouter (slot 1 = "clone-agent"), writes:
#   - per-task result file: .augment/clone-agent/results/<id>.json
#   - raw memory entry via memory-append.ps1 (kind=clone-agent-result)
#   - state cursor:        .augment/clone-agent/.state.json (gitignored)
# A simple lock file prevents concurrent runs (every-10-min scheduled task
# overlapping with an on-demand invocation).
#
# Usage:
#   .\clone-agent-worker.ps1                    # drain whatever is pending
#   .\clone-agent-worker.ps1 -MaxTasks 1        # only one task this cycle
#   .\clone-agent-worker.ps1 -DryRun            # show pending, no calls
#
[CmdletBinding()]
param(
    [int]$MaxTasks = 10,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$caDir = Join-Path $scriptDir '..\clone-agent'
$null = New-Item -ItemType Directory -Force -Path $caDir
$null = New-Item -ItemType Directory -Force -Path (Join-Path $caDir 'results')
$queuePath  = Join-Path $caDir 'queue.jsonl'
$statePath  = Join-Path $caDir '.state.json'
$lockPath   = Join-Path $caDir '.worker.lock'
$logPath    = Join-Path $caDir 'worker.log'
$airouter   = Join-Path $scriptDir 'airouter-call.ps1'
$memAppend  = Join-Path $scriptDir 'memory-append.ps1'

function Log([string]$msg) {
    $line = "{0}  {1}" -f (Get-Date).ToString('s'), $msg
    Write-Host $line
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

if (-not (Test-Path $queuePath)) {
    Log "queue empty (no $queuePath yet) - exit"
    exit 0
}

# Lock
if (Test-Path $lockPath) {
    $age = (Get-Date) - (Get-Item $lockPath).LastWriteTime
    if ($age.TotalMinutes -lt 30) {
        Log "another worker holds lock (age=$([int]$age.TotalSeconds)s) - exit"
        exit 0
    }
    Log "stale lock (age=$([int]$age.TotalMinutes)m) - reclaiming"
    Remove-Item $lockPath -Force
}
Set-Content -Path $lockPath -Value $PID -Encoding UTF8

try {
    # Load state
    $done = @{}
    if (Test-Path $statePath) {
        $s = Get-Content $statePath -Raw | ConvertFrom-Json
        foreach ($id in $s.done_ids) { $done[$id] = $true }
    }

    # Load queue
    $tasks = @(Get-Content $queuePath -Encoding UTF8 | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ })

    $pending = @($tasks | Where-Object { -not $done.ContainsKey($_.id) })
    Log "queue=$($tasks.Count) done=$($done.Count) pending=$($pending.Count) maxThisRun=$MaxTasks"

    if ($DryRun) {
        $pending | Select-Object -First $MaxTasks id, kind, tag, max_tokens, enqueued_by | Format-Table -AutoSize | Out-String | Write-Host
        exit 0
    }

    $processed = 0
    foreach ($t in $pending) {
        if ($processed -ge $MaxTasks) { break }
        Log "task id=$($t.id) kind=$($t.kind) tag=$($t.tag) by=$($t.enqueued_by) -> calling airouter"
        $resultFile = Join-Path $caDir "results\$($t.id).json"
        $airArgs = @{
            Prompt     = [string]$t.prompt
            MaxTokens  = [int]$t.max_tokens
            Tag        = "clone-agent:$($t.tag)"
            OutputFile = $resultFile
        }
        if ($t.system) { $airArgs.System = [string]$t.system }

        $ok = $true
        try {
            & $airouter @airArgs | Out-Null
        } catch {
            $ok = $false
            Log "task id=$($t.id) FAILED: $($_.Exception.Message)"
        }

        if ($ok -and (Test-Path $resultFile)) {
            $res = Get-Content $resultFile -Raw | ConvertFrom-Json
            $snippet = if ($res.response) { $res.response } else { '(empty)' }
            if ($snippet.Length -gt 400) { $snippet = $snippet.Substring(0,400) + '...' }
            $refs = @{
                clone_agent_id = $t.id
                result_file    = ".augment/clone-agent/results/$($t.id).json"
                tag            = $t.tag
                status         = $res.status
                latency_ms     = $res.latency_ms
                total_tokens   = if ($res.usage) { [int]$res.usage.total_tokens } else { 0 }
            }
            & $memAppend -Architect 'clone-agent' -Kind 'clone-agent-result' -Text $snippet -Refs $refs | Out-Null
            Log "task id=$($t.id) ok status=$($res.status) tokens=$($refs.total_tokens)"
        }

        $done[$t.id] = $true
        $processed++
    }

    # Persist state
    $newState = [ordered]@{
        updated  = (Get-Date).ToString('s')
        done_ids = @($done.Keys)
    }
    $newState | ConvertTo-Json -Depth 4 | Set-Content -Path $statePath -Encoding UTF8
    Log "cycle done processed=$processed total_done=$($done.Count)"
}
finally {
    if (Test-Path $lockPath) { Remove-Item $lockPath -Force }
}
