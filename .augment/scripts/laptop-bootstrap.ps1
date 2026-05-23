# laptop-bootstrap.ps1 - idempotent one-shot setup for the laptop so it
# operates like CHost. Safe to re-run any time. Run from the repo root.
#
# What it does:
#   1. Sets AUGMENT_AGENT_HOST=laptop (User env var) so host detection is
#      deterministic in every script.
#   2. Confirms git remote and pulls latest main.
#   3. Probes the CHost Ollama endpoint via Tailscale and reports reach.
#   4. Registers the AugmentAutoCheckpoint scheduled task on this host.
#   5. Lists pending inbox tasks for laptop.
#   6. Prints a short summary the operator can paste back to CHost.
#
# It does NOT register cold-path-distill or remote-master-review - those
# are CHost-only (heavy Ollama work and AIROUTER_API_KEY-only).
#
[CmdletBinding()]
param([switch]$SkipPull, [switch]$SkipTaskRegistration)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
Push-Location $root
$report = [ordered]@{}

try {
    Write-Host "=== laptop-bootstrap (repo: $root) ===" -ForegroundColor Cyan

    # 1. Identity
    $current = [Environment]::GetEnvironmentVariable('AUGMENT_AGENT_HOST','User')
    if ($current -ne 'laptop') {
        [Environment]::SetEnvironmentVariable('AUGMENT_AGENT_HOST','laptop','User')
        $env:AUGMENT_AGENT_HOST = 'laptop'
        $report.identity = "set AUGMENT_AGENT_HOST=laptop (was: '$current')"
    } else {
        $report.identity = "AUGMENT_AGENT_HOST=laptop already set"
    }

    # 2. Git remote + pull
    $origEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $remote  = (& git remote get-url origin 2>$null)
    $report.remote = $remote
    if ($remote -notlike '*Jose-Pedro/MCProcessor*') {
        $report.remoteCheck = "WRONG REMOTE - expected https://github.com/Jose-Pedro/MCProcessor.git"
    } else { $report.remoteCheck = "ok" }

    if (-not $SkipPull) {
        & git fetch origin 2>$null | Out-Null
        $headBefore = (& git rev-parse HEAD).Trim()
        $originMain = (& git rev-parse origin/main).Trim()
        if ($headBefore -ne $originMain) {
            $pullOut = & git pull --ff-only 2>&1 | Select-Object -Last 3
            $headAfter = (& git rev-parse HEAD).Trim()
            $report.gitPull = "pulled: $($headBefore.Substring(0,7)) -> $($headAfter.Substring(0,7))"
        } else {
            $report.gitPull = "already up to date at $($headBefore.Substring(0,7))"
        }
    } else { $report.gitPull = "(skipped)" }
    $ErrorActionPreference = $origEAP

    # 3. Ollama reachability via Tailscale (laptop -> CHost)
    $cfgPath = Join-Path $root '.augment\config\ollama.config.json'
    if (Test-Path $cfgPath) {
        $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
        $ollamaUrl = $cfg.host.tailnet
        try {
            $r = Invoke-RestMethod -Uri "$ollamaUrl/api/tags" -TimeoutSec 5 -ErrorAction Stop
            $count = @($r.models).Count
            $report.ollamaReach = "OK at $ollamaUrl ($count models loaded/installed)"
        } catch {
            $report.ollamaReach = "UNREACHABLE at $ollamaUrl - $($_.Exception.Message). Auto-checkpoint will still run, just without LLM narrative line."
        }
    } else { $report.ollamaReach = "config missing: $cfgPath" }

    # 4. Scheduled tasks. AutoCheckpoint uses StartMinuteOffset=16 on
    # laptop so its fires land at HH:16/HH:46 instead of CHost's
    # HH:01/HH:31, avoiding OneDrive conflict copies. InboxNotifier
    # runs every 2 minutes and pops toasts for new inbox tasks.
    if (-not $SkipTaskRegistration) {
        try {
            & (Join-Path $scriptDir 'register-auto-checkpoint-task.ps1') -StartMinuteOffset 16 | Out-Null
            $t = Get-ScheduledTask -TaskName 'AugmentAutoCheckpoint' -EA 0
            if ($t) {
                $nr = (Get-ScheduledTaskInfo $t).NextRunTime
                $report.scheduledTask = "AugmentAutoCheckpoint registered, next run: $nr"
            } else { $report.scheduledTask = "registration claimed success but task not found" }
        } catch {
            $report.scheduledTask = "FAILED: $($_.Exception.Message)"
        }
        try {
            & (Join-Path $scriptDir 'register-inbox-notifier-task.ps1') | Out-Null
            $t2 = Get-ScheduledTask -TaskName 'AugmentInboxNotifier' -EA 0
            if ($t2) {
                $nr2 = (Get-ScheduledTaskInfo $t2).NextRunTime
                $report.inboxNotifier = "AugmentInboxNotifier registered, next run: $nr2"
            } else { $report.inboxNotifier = "registration claimed success but task not found" }
        } catch {
            $report.inboxNotifier = "FAILED: $($_.Exception.Message)"
        }
    } else { $report.scheduledTask = "(skipped)"; $report.inboxNotifier = "(skipped)" }

    # 5. Inbox snapshot
    try {
        $inbox = Get-Content (Join-Path $root '.augment\agent-tasks\inbox-laptop.jsonl') -EA 0
        $done  = Get-Content (Join-Path $root '.augment\agent-tasks\done.jsonl') -EA 0
        $doneIds = @{}
        foreach ($d in $done) { try { $o = $d | ConvertFrom-Json; $doneIds[$o.id] = $o.status } catch {} }
        $pending = @()
        foreach ($l in $inbox) { try { $o = $l | ConvertFrom-Json; if (-not $doneIds.ContainsKey($o.id)) { $pending += $o } } catch {} }
        $report.pendingTasks = "$($pending.Count) pending in inbox-laptop.jsonl"
        if ($pending.Count) {
            $report.pendingList = ($pending | ForEach-Object { "  $($_.id) [$($_.priority)] $($_.title)" }) -join "`n"
        }
    } catch { $report.pendingTasks = "(could not read inbox)" }

    # 6. Summary
    Write-Host ""
    Write-Host "=== summary ===" -ForegroundColor Cyan
    foreach ($k in $report.Keys) {
        Write-Host ("{0,-15}: {1}" -f $k, $report[$k])
    }

    Write-Host ""
    Write-Host "Next: run .\.augment\scripts\session-briefing.ps1 to load context, then .\.augment\scripts\agent-task-list.ps1 -Mine to see what's queued." -ForegroundColor Green

} finally { Pop-Location }
