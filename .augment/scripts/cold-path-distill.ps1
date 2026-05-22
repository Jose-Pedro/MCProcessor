# cold-path-distill.ps1 - nightly batch: raw -> distilled -> embedded -> git.
#
# Runs at 02:00 local (registered via register-nightly-task.ps1). Never
# called from the live conversation path - it owns the model toggling.
#
# Batching law: ALL writer calls first (Qwen hot), then ALL embed calls
# (nomic hot). One reload per model per run, never per chunk.
#
# Usage:
#   .\cold-path-distill.ps1                 # default: process yesterday + today
#   .\cold-path-distill.ps1 -Date 2026-05-22
#   .\cold-path-distill.ps1 -DryRun
#   .\cold-path-distill.ps1 -SkipGit        # don't commit/push
#   .\cold-path-distill.ps1 -SkipBackup     # don't mirror to Seagate
#   .\cold-path-distill.ps1 -SkipCatel      # don't mirror to Catel OneDrive
#
[CmdletBinding()]
param(
    [string]$Date = '',
    [string[]]$Architects = @('zepedro','juan'),
    [switch]$DryRun,
    [switch]$SkipGit,
    [switch]$SkipBackup,
    [switch]$SkipCatel,
    [string]$OllamaBase = 'http://127.0.0.1:11434',
    [string]$WriterModel = 'qwen2.5-coder:7b-instruct-q4_K_M',
    [string]$EmbedModel = 'nomic-embed-text:latest',
    [string]$BackupRoot = 'D:\Backups\MCProcessor',
    [string]$CatelMirrorRoot = '',
    [string]$CatelTenantId = '0cca651b-b45a-4199-b7b2-bd44f771253f',
    [string]$CatelMirrorSubdir = 'MCProcessor'
)

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$memRoot = Resolve-Path (Join-Path $scriptDir '..\memory')
$rawDir = Join-Path $memRoot 'raw'
$distDir = Join-Path $memRoot 'distilled'
$idxDir = Join-Path $memRoot 'index'
$stateFile = Join-Path $memRoot '.state\distilled.json'
$logFile = Join-Path $memRoot '.cold-path.log'
foreach ($d in @($distDir,$idxDir,(Split-Path $stateFile))) { $null = New-Item -ItemType Directory -Force -Path $d }

function Log([string]$msg) {
    $line = "$((Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')) $msg"
    Write-Host $line
    if (-not $DryRun) { Add-Content -Path $logFile -Value $line -Encoding UTF8 }
}

# Resolve which date(s) to process
if ($Date) { $dates = @($Date) }
else { $dates = @((Get-Date).AddDays(-1).ToString('yyyy-MM-dd'), (Get-Date).ToString('yyyy-MM-dd')) | Select-Object -Unique }

# Load state (last-processed line count per source file)
$state = @{}
if (Test-Path $stateFile) {
    $raw = Get-Content $stateFile -Raw | ConvertFrom-Json
    $raw.PSObject.Properties | ForEach-Object { $state[$_.Name] = [int]$_.Value }
}

Log "=== cold-path run start (dryRun=$DryRun) ==="

# Collect work units: { srcPath, architect, date, newLines[] }
$work = @()
foreach ($d in $dates) {
    foreach ($a in $Architects) {
        $src = Join-Path $rawDir "$d.$a.jsonl"
        if (-not (Test-Path $src)) { continue }
        $lines = Get-Content $src -Encoding UTF8
        $already = if ($state.ContainsKey($src)) { $state[$src] } else { 0 }
        if ($lines.Count -le $already) { continue }
        $work += [pscustomobject]@{
            src = $src; architect = $a; date = $d; offset = $already; newLines = $lines[$already..($lines.Count-1)]
        }
    }
}

$skipDistill = -not $work
if ($skipDistill) { Log "no new raw entries; skipping phases 1+2, still running mirror/git" }
else {
    $totalNew = ($work | ForEach-Object { $_.newLines.Count } | Measure-Object -Sum).Sum
    Log "work units: $($work.Count), total new lines: $totalNew"
}

if ($DryRun) { $work | ForEach-Object { Log "  would process: $($_.src) (+$($_.newLines.Count))" }; exit 0 }

$distilledItems = @()
$synthesisText = ''
if (-not $skipDistill) {
# ============ PHASE 1: WRITER (Qwen hot, nomic absent) ============
Log "--- phase 1: load $WriterModel ---"
$null = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 180 -Body (@{
    model=$WriterModel; prompt='ready'; stream=$false; keep_alive='24h'; options=@{ num_predict=2; temperature=0 }
} | ConvertTo-Json -Compress)

$distillSys = 'You compress chat memory entries into ONE compact JSON object per input. Schema: {"summary":"<one sentence>","topics":["..."],"entities":["..."]}. Output ONLY the JSON object, no prose, no markdown.'
foreach ($u in $work) {
    foreach ($line in $u.newLines) {
        $obj = $line | ConvertFrom-Json
        $prompt = "Input entry:`n$line`n`nOutput JSON now:"
        $body = @{ model=$WriterModel; prompt=$prompt; system=$distillSys; stream=$false; keep_alive='24h'; format='json'; options=@{ num_predict=256; temperature=0 } } | ConvertTo-Json -Compress
        try {
            $r = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 180 -Body $body
            $j = $r.response | ConvertFrom-Json
            $out = [ordered]@{ ts=$obj.ts; architect=$u.architect; src_kind=$obj.kind; summary=$j.summary; topics=$j.topics; entities=$j.entities }
            $outPath = Join-Path $distDir "$($u.date).$($u.architect).jsonl"
            Add-Content -Path $outPath -Value (($out | ConvertTo-Json -Depth 6 -Compress)) -Encoding UTF8
            $distilledItems += [pscustomobject]@{ path=$outPath; obj=$out }
        } catch { Log "  WRITER FAIL on entry ts=$($obj.ts): $($_.Exception.Message)" }
    }
    $state[$u.src] = $u.offset + $u.newLines.Count
}
Log "phase 1 done: $($distilledItems.Count) distilled entries"

# ============ PHASE 1b: BRIEF SYNTHESIS (Qwen still hot, before nomic evicts) ============
# Generates a 2-3 sentence "you are here" used by the bootstrap brief below.
# Captured here so we don't pay a Qwen reload after Phase 2.
$synthesisText = ''
try {
    $logPath = Join-Path (Split-Path $memRoot) 'SESSION_LOG.md'
    if (Test-Path $logPath) {
        $logLines = Get-Content $logPath -Encoding UTF8
        $hdrIdx = @()
        for ($i = 0; $i -lt $logLines.Count; $i++) {
            if ($logLines[$i] -match '^### \d{4}-\d{2}-\d{2}') { $hdrIdx += $i }
        }
        if ($hdrIdx.Count -ge 1) {
            $sStart = $hdrIdx[0]
            $sEnd = if ($hdrIdx.Count -ge 2) { $hdrIdx[1] - 1 } else { $logLines.Count - 1 }
            $latestEntry = ($logLines[$sStart..$sEnd] -join "`n")
            $sysB = 'You produce a tight 2-3 sentence "you are here, do this next" briefing for the next AI agent session. Output pure text only - no markdown, no bullets, no headers, no rationale.'
            $usrB = "Latest session log entry:`n$latestEntry`n`nWrite the 2-3 sentence briefing now:"
            $bodyB = @{ model=$WriterModel; prompt=$usrB; system=$sysB; stream=$false; keep_alive='24h'; options=@{ num_predict=200; temperature=0.2 } } | ConvertTo-Json -Compress
            $rsB = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 180 -Body $bodyB
            $synthesisText = ($rsB.response).Trim()
            Log "phase 1b: brief synthesis $($synthesisText.Length) chars"
        }
    }
} catch { Log "  BRIEF SYNTHESIS FAIL: $($_.Exception.Message)" }

# ============ PHASE 2: EMBED (nomic hot, Qwen evicted) ============
Log "--- phase 2: load $EmbedModel ---"
$null = Invoke-RestMethod -Uri "$OllamaBase/api/embeddings" -Method Post -ContentType 'application/json' -TimeoutSec 60 -Body (@{
    model=$EmbedModel; prompt='ready'; keep_alive='24h'
} | ConvertTo-Json -Compress)

foreach ($it in $distilledItems) {
    $textToEmbed = "$($it.obj.summary) || topics: $($it.obj.topics -join ', ') || entities: $($it.obj.entities -join ', ')"
    $body = @{ model=$EmbedModel; prompt=$textToEmbed; keep_alive='24h' } | ConvertTo-Json -Compress
    try {
        $r = Invoke-RestMethod -Uri "$OllamaBase/api/embeddings" -Method Post -ContentType 'application/json' -TimeoutSec 60 -Body $body
        $vec = [ordered]@{ ts=$it.obj.ts; architect=$it.obj.architect; summary=$it.obj.summary; vec=$r.embedding }
        $vecPath = $it.path -replace '\\distilled\\','\index\' -replace '\.jsonl$','.vec.jsonl'
        $null = New-Item -ItemType Directory -Force -Path (Split-Path $vecPath)
        Add-Content -Path $vecPath -Value (($vec | ConvertTo-Json -Depth 6 -Compress)) -Encoding UTF8
    } catch { Log "  EMBED FAIL on ts=$($it.obj.ts): $($_.Exception.Message)" }
}
Log "phase 2 done"

# Persist state
$stateObj = New-Object PSObject
$state.GetEnumerator() | ForEach-Object { Add-Member -InputObject $stateObj -NotePropertyName $_.Key -NotePropertyValue $_.Value }
$stateObj | ConvertTo-Json -Depth 4 | Set-Content -Path $stateFile -Encoding UTF8

# Pointer file for fast retrieval
$pointer = [ordered]@{ updated=(Get-Date).ToString('s'); files=@(Get-ChildItem $idxDir -Filter '*.vec.jsonl' | ForEach-Object { $_.Name }) }
$pointer | ConvertTo-Json | Set-Content -Path (Join-Path $memRoot 'today.index.json') -Encoding UTF8
} # end if (-not $skipDistill)

# Fallback synthesis: when Phase 1b didn't run (skipDistill=true), pay one
# Qwen load now so the bootstrap brief always has fresh "where we are" prose.
if (-not $synthesisText) {
    try {
        $logPath2 = Join-Path (Split-Path $memRoot) 'SESSION_LOG.md'
        if (Test-Path $logPath2) {
            $logLines2 = Get-Content $logPath2 -Encoding UTF8
            $hdrIdx2 = @()
            for ($i = 0; $i -lt $logLines2.Count; $i++) {
                if ($logLines2[$i] -match '^### \d{4}-\d{2}-\d{2}') { $hdrIdx2 += $i }
            }
            if ($hdrIdx2.Count -ge 1) {
                $s3 = $hdrIdx2[0]
                $e3 = if ($hdrIdx2.Count -ge 2) { $hdrIdx2[1] - 1 } else { $logLines2.Count - 1 }
                $latestEntry2 = ($logLines2[$s3..$e3] -join "`n")
                Log "fallback synthesis: loading $WriterModel"
                $null = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 180 -Body (@{
                    model=$WriterModel; prompt='ready'; stream=$false; keep_alive='24h'; options=@{ num_predict=2; temperature=0 }
                } | ConvertTo-Json -Compress)
                $sysF = 'You produce a tight 2-3 sentence "you are here, do this next" briefing for the next AI agent session. Output pure text only - no markdown, no bullets, no headers, no rationale.'
                $usrF = "Latest session log entry:`n$latestEntry2`n`nWrite the 2-3 sentence briefing now:"
                $bodyF = @{ model=$WriterModel; prompt=$usrF; system=$sysF; stream=$false; keep_alive='24h'; options=@{ num_predict=200; temperature=0.2 } } | ConvertTo-Json -Compress
                $rsF = Invoke-RestMethod -Uri "$OllamaBase/api/generate" -Method Post -ContentType 'application/json' -TimeoutSec 180 -Body $bodyF
                $synthesisText = ($rsF.response).Trim()
                Log "fallback synthesis: $($synthesisText.Length) chars"
            }
        }
    } catch { Log "  FALLBACK SYNTHESIS FAIL: $($_.Exception.Message)" }
}

# ============ PHASE 2b: WRITE SESSION_BOOTSTRAP.md ============
# Always regenerated (even if skipDistill) so date/budget/fleet status are fresh.
# Mirrored via tier-3c and committed via 3b below so laptop + git both see it.
try {
    $repoRootBrf = Split-Path (Split-Path $memRoot)
    $brfPath = Join-Path $repoRootBrf '.augment\SESSION_BOOTSTRAP.md'
    $logPath = Join-Path (Split-Path $memRoot) 'SESSION_LOG.md'
    $latestEntry = '(SESSION_LOG.md missing)'
    if (Test-Path $logPath) {
        $logLines = Get-Content $logPath -Encoding UTF8
        $hdrIdx = @()
        for ($i = 0; $i -lt $logLines.Count; $i++) {
            if ($logLines[$i] -match '^### \d{4}-\d{2}-\d{2}') { $hdrIdx += $i }
        }
        if ($hdrIdx.Count -ge 1) {
            $s2 = $hdrIdx[0]
            $e2 = if ($hdrIdx.Count -ge 2) { $hdrIdx[1] - 1 } else { $logLines.Count - 1 }
            $latestEntry = ($logLines[$s2..$e2] -join "`n")
        }
    }
    $distRecent = @()
    foreach ($a in $Architects) {
        foreach ($d in ($dates | Sort-Object -Descending)) {
            $dp = Join-Path $distDir "$d.$a.jsonl"
            if (Test-Path $dp) {
                $ll = Get-Content $dp -Encoding UTF8 | Select-Object -Last 5
                foreach ($l in $ll) {
                    try { $o = $l | ConvertFrom-Json; $distRecent += "- [$($o.ts)] [$($o.architect)] $($o.summary)" } catch {}
                }
            }
        }
    }
    $distRecent = $distRecent | Select-Object -Last 5
    if (-not $distRecent) { $distRecent = @('- (no distilled entries yet for the current/previous day)') }
    $budgetScript = Join-Path $scriptDir 'airouter-budget.ps1'
    $budgetLine = if (Test-Path $budgetScript) {
        try { (& $budgetScript -Compact 2>&1 | Out-String).Trim() } catch { "airouter: budget reader error: $($_.Exception.Message)" }
    } else { 'airouter: budget reader not installed' }
    if (-not $synthesisText) { $synthesisText = '(no synthesis available - cold-path skipped distill or Qwen unreachable last run)' }
    $now = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
    $brf = @"
# Session Bootstrap (auto-generated $now)

> Generated by ``.augment/scripts/cold-path-distill.ps1`` (nightly 02:00).
> Read this FIRST on every new session to warm yourself with current state.
> Do **not** edit by hand - changes are overwritten on next cold-path run.

## Where we are (synthesis)

$synthesisText

## Last SESSION_LOG entry (verbatim, newest)

$latestEntry

## Recent distilled facts (top 5)

$($distRecent -join "`n")

## Airouter spend

$budgetLine

## CModel local fleet

- writer:    ``qwen2.5-coder:7b-instruct-q4_K_M`` (extract / summarize / rerank)
- retriever: ``nomic-embed-text:latest`` (embeddings, dim=768)
- endpoint (CHost):   ``http://127.0.0.1:11434``
- endpoint (tailnet): ``http://100.83.6.49:11434`` (firewall rule ``Augment-Ollama-Tailscale`` scoped to 100.64.0.0/10)
- batching law:       all writer calls first, then all retriever calls; never interleave.
"@
    Set-Content -Path $brfPath -Value $brf -Encoding UTF8
    Log "phase 2b: bootstrap brief -> $brfPath"
} catch { Log "  BOOTSTRAP BRIEF FAIL: $($_.Exception.Message)" }

# ============ PHASE 3a: TIER 3a BACKUP (Seagate, sometimes-plugged) ============
if (-not $SkipBackup) {
    $backupDriveRoot = (Split-Path $BackupRoot -Qualifier) + '\'
    if (Test-Path $backupDriveRoot) {
        try {
            $backupTarget = Join-Path $BackupRoot '.augment\memory'
            $null = New-Item -ItemType Directory -Force -Path $backupTarget
            $rc = & robocopy $memRoot $backupTarget /MIR /R:1 /W:1 /MT:4 /NFL /NDL /NP /NJH /NJS 2>&1
            if ($LASTEXITCODE -lt 8) {
                Log "tier-3a backup: OK -> $backupTarget (robocopy exit=$LASTEXITCODE)"
            } else {
                Log "tier-3a backup: FAILED (robocopy exit=$LASTEXITCODE) :: $($rc -join ' ')"
            }
        } catch { Log "tier-3a backup: ERROR $($_.Exception.Message)" }
    } else {
        Log "tier-3a backup: drive $backupDriveRoot not mounted, skipping (sometimes-plugged)"
    }
}

# ============ PHASE 3c: TIER 3c BACKUP (Catel OneDrive, multi-device) ============
# Mirrors agent state to the Catel OneDrive folder so it propagates to the
# laptop (and any other device signed into the same tenant) without git.
if (-not $SkipCatel) {
    if (-not $CatelMirrorRoot) {
        $acct = Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts' -EA 0 |
            Where-Object { (Get-ItemProperty $_.PSPath -EA 0).ConfiguredTenantId -eq $CatelTenantId } |
            Select-Object -First 1
        if ($acct) {
            $userFolder = (Get-ItemProperty $acct.PSPath -EA 0).UserFolder
            if ($userFolder) { $CatelMirrorRoot = Join-Path $userFolder $CatelMirrorSubdir }
        }
    }
    if ($CatelMirrorRoot -and (Test-Path (Split-Path $CatelMirrorRoot))) {
        try {
            $repoRoot = Split-Path (Split-Path $memRoot)
            $dotAug = Join-Path $CatelMirrorRoot '.augment'
            $null = New-Item -ItemType Directory -Force -Path $dotAug
            $pairs = @(
                @{ Src = $memRoot;                            Dst = (Join-Path $dotAug 'memory') },
                @{ Src = (Join-Path $repoRoot '.augment\scripts'); Dst = (Join-Path $dotAug 'scripts') },
                @{ Src = (Join-Path $repoRoot '.augment\config');  Dst = (Join-Path $dotAug 'config') }
            )
            $allOK = $true
            foreach ($p in $pairs) {
                if (-not (Test-Path $p.Src)) { continue }
                $rc = & robocopy $p.Src $p.Dst /MIR /R:1 /W:1 /MT:4 /NFL /NDL /NP /NJH /NJS 2>&1
                if ($LASTEXITCODE -ge 8) { $allOK = $false; Log "tier-3c mirror: $($p.Src) -> $($p.Dst) FAILED (robocopy exit=$LASTEXITCODE)" }
            }
            $singles = @(
                @{ Src = (Join-Path $repoRoot '.augment\SESSION_LOG.md');            Dst = (Join-Path $dotAug 'SESSION_LOG.md') },
                @{ Src = (Join-Path $repoRoot '.augment\SESSION_BOOTSTRAP.md');      Dst = (Join-Path $dotAug 'SESSION_BOOTSTRAP.md') },
                @{ Src = (Join-Path $repoRoot '.augment\LAPTOP_AGENT_BOOTSTRAP.md'); Dst = (Join-Path $dotAug 'LAPTOP_AGENT_BOOTSTRAP.md') },
                @{ Src = (Join-Path $repoRoot 'AGENTS.md');                          Dst = (Join-Path $CatelMirrorRoot 'AGENTS.md') }
            )
            foreach ($s in $singles) {
                if (Test-Path $s.Src) { Copy-Item -Path $s.Src -Destination $s.Dst -Force }
            }
            if ($allOK) { Log "tier-3c mirror: OK -> $CatelMirrorRoot" }
        } catch { Log "tier-3c mirror: ERROR $($_.Exception.Message)" }
    } else {
        Log "tier-3c mirror: Catel OneDrive folder not found (tenant=$CatelTenantId), skipping"
    }
}


# ============ PHASE 3b: GIT ============
# Git writes benign warnings (e.g. CRLF/LF) to stderr; with the script-wide
# ErrorActionPreference=Stop these are otherwise promoted to terminating errors.
if (-not $SkipGit) {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $repoRoot = Split-Path (Split-Path $memRoot)
        Push-Location $repoRoot
        & git add .augment/memory .augment/SESSION_LOG.md .augment/SESSION_BOOTSTRAP.md *>$null
        if ($LASTEXITCODE -ne 0) {
            Log "git add failed (exit=$LASTEXITCODE)"
        } else {
            $changed = (& git diff --cached --name-only) -join "`n"
            if (-not $changed) {
                Log "git: nothing to commit"
            } else {
                & git commit -m "cold-path: distill $((Get-Date).ToString('yyyy-MM-dd'))" *>$null
                if ($LASTEXITCODE -ne 0) {
                    Log "git commit failed (exit=$LASTEXITCODE)"
                } else {
                    $pushOut = (& git push 2>&1) -join ' '
                    if ($LASTEXITCODE -eq 0) { Log "git: committed + pushed" }
                    else { Log "git: commit OK, push FAILED ($pushOut)" }
                }
            }
        }
    } catch { Log "git step failed: $($_.Exception.Message)" }
    finally {
        Pop-Location
        $ErrorActionPreference = $prevEAP
    }
}

Log "=== cold-path run end ==="
