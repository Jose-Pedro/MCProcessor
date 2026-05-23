# session-briefing.ps1 - single command, single output, agent's only
# session-start read.
#
# Replaces the previous 4-file session-start ritual (bootstrap + inbox
# + lessons + task-list). This is text concatenation with NO LLM call,
# so token cost to the agent = the size of this one output, nothing more.
#
# Heavy summarization (the "Where we are" synthesis) is still produced
# nightly by cold-path-distill.ps1 using local CModel; this script just
# tops it with live same-day data the bootstrap can't see.
#
# Usage:
#   .\session-briefing.ps1               # print to terminal
#   .\session-briefing.ps1 -WriteFile    # also write .augment/SESSION_BRIEFING.md
#
[CmdletBinding()]
param(
    [int]$InboxDays  = 14,
    [int]$LessonsTop = 5,
    [switch]$WriteFile
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..')
$bootPath  = Join-Path $root 'SESSION_BOOTSTRAP.md'
$inboxPath = Join-Path $root 'AGENT_INBOX.md'
$lessPath  = Join-Path $root 'agent-tasks\LESSONS.md'

$self = if ($env:AUGMENT_AGENT_HOST) { $env:AUGMENT_AGENT_HOST }
        elseif ($env:COMPUTERNAME -match 'CHOST|WORK') { 'chost' }
        else { 'laptop' }

$out = New-Object System.Text.StringBuilder
[void]$out.AppendLine("# SESSION BRIEFING ($self, $(Get-Date -Format 's'))")
[void]$out.AppendLine("# Single source for session-start context. Read this and only this.")
[void]$out.AppendLine("")

# 1. Bootstrap freshness + content (nightly heavy distillation)
[void]$out.AppendLine("## 1. Nightly bootstrap")
if (Test-Path $bootPath) {
    $bAge = (Get-Date) - (Get-Item $bootPath).LastWriteTime
    $bAgeStr = "{0:N1} h old" -f $bAge.TotalHours
    if ($bAge.TotalHours -gt 48) { $bAgeStr += "  STALE - flag to user" }
    [void]$out.AppendLine("_(bootstrap $bAgeStr)_")
    [void]$out.AppendLine("")
    # Take everything except trailing scaffolding lines (cap at first 80 lines)
    Get-Content $bootPath -TotalCount 80 | ForEach-Object { [void]$out.AppendLine($_) }
} else {
    [void]$out.AppendLine("_(bootstrap missing - run cold-path-distill.ps1)_")
}
[void]$out.AppendLine("")

# 2. Same-day inbox entries the nightly bootstrap can't have seen
[void]$out.AppendLine("## 2. AGENT_INBOX (last $InboxDays days)")
if (Test-Path $inboxPath) {
    $cutoff = (Get-Date).AddDays(-$InboxDays).ToString('yyyy-MM-dd')
    $lines = Get-Content $inboxPath
    # Extract entries newer than cutoff. Entry headers look like: ## YYYY-MM-DD HH:MM
    $emit = $false; $kept = @()
    foreach ($l in $lines) {
        if ($l -match '^##\s+(\d{4}-\d{2}-\d{2})') {
            $emit = ($matches[1] -ge $cutoff)
        }
        if ($emit) { $kept += $l }
    }
    if ($kept.Count -eq 0) { [void]$out.AppendLine("_(no inbox entries in window)_") }
    else { $kept | ForEach-Object { [void]$out.AppendLine($_) } }
} else {
    [void]$out.AppendLine("_(AGENT_INBOX.md missing)_")
}
[void]$out.AppendLine("")

# 3. Top-N lessons
[void]$out.AppendLine("## 3. Active LESSONS (top $LessonsTop)")
if (Test-Path $lessPath) {
    $lines = Get-Content $lessPath
    $count = 0; $emit = $false; $kept = @()
    foreach ($l in $lines) {
        if ($l -match '^##\s+\d{4}-\d{2}-\d{2}') {
            $count++
            if ($count -gt $LessonsTop) { break }
            $emit = $true
        }
        if ($emit) { $kept += $l }
    }
    if ($kept.Count -eq 0) { [void]$out.AppendLine("_(no lessons yet)_") }
    else { $kept | ForEach-Object { [void]$out.AppendLine($_) } }
} else {
    [void]$out.AppendLine("_(LESSONS.md missing)_")
}
[void]$out.AppendLine("")

# 4. My pending tasks (live) - inlined; do not call agent-task-list.ps1
# because it uses Write-Host which is not captured by stdout redirection.
[void]$out.AppendLine("## 4. My pending tasks (this host = $self)")
$tasksDir = Join-Path $root 'agent-tasks'
$inboxFile = Join-Path $tasksDir "inbox-$self.jsonl"
$donePath  = Join-Path $tasksDir 'done.jsonl'
$doneIds = @{}
if (Test-Path $donePath) {
    Get-Content $donePath -Encoding UTF8 | ForEach-Object {
        try { $d = $_ | ConvertFrom-Json; if ($d) { $doneIds[$d.id] = $d.status } } catch {}
    }
}
if (Test-Path $inboxFile) {
    $pending = @()
    Get-Content $inboxFile -Encoding UTF8 | ForEach-Object {
        try { $j = $_ | ConvertFrom-Json } catch { $j = $null }
        if ($j -and -not $doneIds.ContainsKey($j.id)) { $pending += $j }
    }
    if ($pending.Count -eq 0) {
        [void]$out.AppendLine("_(no pending tasks)_")
    } else {
        [void]$out.AppendLine('```')
        foreach ($p in $pending) {
            [void]$out.AppendLine(("{0}  [{1}]  from={2}  {3}" -f $p.id, $p.priority, $p.from, $p.title))
        }
        [void]$out.AppendLine('```')
    }
} else {
    [void]$out.AppendLine("_(no inbox file: $inboxFile)_")
}

# 5. Hint footer
[void]$out.AppendLine("")
[void]$out.AppendLine("---")
[void]$out.AppendLine("Routing reminder: prefer local CModel (slow but free) over airouter for")
[void]$out.AppendLine("summarize/classify/extract/embed. Airouter only when local can't do it.")

$text = $out.ToString()
Write-Output $text
if ($WriteFile) {
    $outPath = Join-Path $root 'SESSION_BRIEFING.md'
    Set-Content -Path $outPath -Value $text -Encoding UTF8
}
