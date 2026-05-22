# auto-checkpoint.ps1 - automation that snapshots agent activity into
# SESSION_LOG.md every N minutes (default 30). Per R3.3, this is
# scheduled work, NOT inline agent work - it costs zero context tokens
# to the active agent. Uses local CModel (Qwen, already kept hot) for
# the one-paragraph narrative; falls back to facts-only if Ollama is
# down. Skips writing when there is no activity in the window.
#
# Entries are titled with the "[auto]" prefix so they are visually
# distinct from user-driven checkpoints and can be filtered out later
# if SESSION_LOG.md needs trimming.
#
# Idempotent. Safe to run on any cadence.
#
[CmdletBinding()]
param(
    [int]$WindowMinutes = 30,
    [switch]$NoLLM,
    [string]$OllamaBase  = 'http://127.0.0.1:11434',
    [string]$WriterModel = 'qwen2.5-coder:7b-instruct-q4_K_M'
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
$augDir    = Join-Path $root '.augment'
$logFile   = Join-Path $augDir 'SESSION_LOG.md'
$state     = Join-Path $augDir '.auto-checkpoint.state.json'
$worklog   = Join-Path $augDir '.auto-checkpoint.log'

function Log($m) { Add-Content -Path $worklog -Value ("{0}  {1}" -f (Get-Date -Format s), $m) -Encoding UTF8 }

# 1. Resolve window
$now = Get-Date
$since = if (Test-Path $state) {
    try { [datetime](Get-Content $state -Raw | ConvertFrom-Json).last } catch { $now.AddMinutes(-$WindowMinutes) }
} else { $now.AddMinutes(-$WindowMinutes) }
Log "run: window since $($since.ToString('s'))"

# 2. Gather signals.
# git emits CRLF/LF warnings on stderr; with EAP=Stop those become
# terminating errors. Suppress locally.
$sinceArg = $since.ToString('s')
$origEAP  = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
Push-Location $root
try {
    $commits = @(@(& git log "--since=$sinceArg" --pretty=format:'%h %s' 2>$null) | Where-Object { $_ -and ("$_").Trim() })
    $changed = @(@(& git diff --name-only HEAD 2>$null) | Where-Object { $_ -and ("$_").Trim() })
    $changedSinceCommits = @()
    if ($commits.Count -gt 0) {
        $changedSinceCommits = @(@(& git log "--since=$sinceArg" --name-only --pretty=format: 2>$null) |
            Where-Object { $_ -and ("$_").Trim() } | Sort-Object -Unique)
    }
} finally { Pop-Location; $ErrorActionPreference = $origEAP }

# New lines in append-only queues since window start
function NewLines($path) {
    if (-not (Test-Path $path)) { return @() }
    Get-Content $path -EA 0 | ForEach-Object {
        try { $o = $_ | ConvertFrom-Json; if ($o.ts -and ([datetime]$o.ts) -ge $since) { $_ } } catch {}
    }
}
$doneNew    = @(NewLines (Join-Path $augDir 'agent-tasks\done.jsonl'))
$rawDir     = Join-Path $augDir 'memory\raw'
$rawNew     = @()
if (Test-Path $rawDir) {
    Get-ChildItem $rawDir -Filter *.jsonl -EA 0 | ForEach-Object { $rawNew += NewLines $_.FullName }
}
$inboxNew   = @()
Get-ChildItem (Join-Path $augDir 'agent-tasks') -Filter 'inbox-*.jsonl' -EA 0 | ForEach-Object {
    $inboxNew += NewLines $_.FullName
}

$totalSignals = $commits.Count + $changed.Count + $doneNew.Count + $rawNew.Count + $inboxNew.Count
if ($totalSignals -eq 0) {
    Log "skip: no activity"
    @{ last = $now.ToString('s') } | ConvertTo-Json | Set-Content -Path $state -Encoding UTF8
    return
}

# 3. Build facts bundle
$facts = New-Object System.Text.StringBuilder
[void]$facts.AppendLine("window: $($since.ToString('s')) -> $($now.ToString('s'))")
if ($commits.Count) { [void]$facts.AppendLine("commits:"); $commits | ForEach-Object { [void]$facts.AppendLine("  - $_") } }
$allChanged = @(@($changed) + @($changedSinceCommits) | Sort-Object -Unique)
if ($allChanged.Count) { [void]$facts.AppendLine("files-touched:"); $allChanged | Select-Object -First 20 | ForEach-Object { [void]$facts.AppendLine("  - $_") } }
if ($doneNew.Count)  { [void]$facts.AppendLine("agent-tasks-completed: $($doneNew.Count)") }
if ($inboxNew.Count) { [void]$facts.AppendLine("agent-tasks-assigned: $($inboxNew.Count)") }
if ($rawNew.Count)   { [void]$facts.AppendLine("memory-entries: $($rawNew.Count)") }
$factsText = $facts.ToString().Trim()

# 4. Narrative via CModel (optional)
$narrative = ''
if (-not $NoLLM) {
    try {
        $null = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 60 -Body (@{
            model=$WriterModel; prompt='ready'; stream=$false; keep_alive='24h'; options=@{ num_predict=2; temperature=0 }
        } | ConvertTo-Json -Compress)
        $sys = 'You write ONE compact paragraph (max 3 sentences, plain text, no markdown, no bullets) summarising what an AI coding agent did in the last 30 minutes based ONLY on the facts below. Do not invent reasons; stick to what files/commits/tasks the facts list.'
        $body = @{ model=$WriterModel; prompt="Facts:`n$factsText`n`nWrite the paragraph now:"; system=$sys; stream=$false; keep_alive='24h'; options=@{ num_predict=180; temperature=0.2 } } | ConvertTo-Json -Compress
        $r = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 120 -Body $body
        $narrative = ($r.response).Trim()
        Log "llm: $($narrative.Length) chars"
    } catch { Log "llm fail (falling back to facts-only): $($_.Exception.Message)" }
}

# 5. Build entry
$title = "[auto] $($commits.Count) commits, $($allChanged.Count) files touched, $($doneNew.Count) tasks done"
$ts    = $now.ToString('yyyy-MM-dd HH:mm')
$entry = New-Object System.Text.StringBuilder
[void]$entry.AppendLine("### $ts - $title")
[void]$entry.AppendLine("- **Goal:** (auto-checkpoint; window ${WindowMinutes}m)")
[void]$entry.AppendLine("- **Done:**")
if ($narrative) { [void]$entry.AppendLine("  - $narrative") }
if ($commits.Count) { $commits | Select-Object -First 5 | ForEach-Object { [void]$entry.AppendLine("  - commit: $_") } }
if ($doneNew.Count) { $doneNew | Select-Object -First 5 | ForEach-Object { $o=$_|ConvertFrom-Json; [void]$entry.AppendLine("  - task done: $($o.id) ($($o.status))") } }
if ($allChanged.Count) {
    [void]$entry.AppendLine("- **Files touched:** ($($allChanged.Count) total)")
    $top = @($allChanged | Select-Object -First 10)
    foreach ($f in $top) { [void]$entry.AppendLine("  - $f") }
    if ($allChanged.Count -gt $top.Count) {
        [void]$entry.AppendLine("  - ... and $($allChanged.Count - $top.Count) more")
    }
}
[void]$entry.AppendLine("- **State:** in-progress")
[void]$entry.AppendLine("- **Next step:** (continue active session)")
[void]$entry.AppendLine("- **Notes:** generated by ``auto-checkpoint.ps1``; sources = git, done.jsonl, inbox-*.jsonl, memory/raw/*.jsonl")
[void]$entry.AppendLine("")

# 6. Prepend under "## Entries"
$txt = Get-Content $logFile -Raw
$marker = "## Entries`r`n"
if ($txt -notmatch [regex]::Escape($marker)) { $marker = "## Entries`n" }
$idx = $txt.IndexOf($marker)
if ($idx -lt 0) { Log "FATAL: '## Entries' marker not found in $logFile"; return }
$insertAt = $idx + $marker.Length
$new = $txt.Substring(0,$insertAt) + "`r`n" + $entry.ToString() + $txt.Substring($insertAt)
Set-Content -Path $logFile -Value $new -Encoding UTF8 -NoNewline

# 7. Persist state
@{ last = $now.ToString('s') } | ConvertTo-Json | Set-Content -Path $state -Encoding UTF8
Log "wrote checkpoint: $title"
