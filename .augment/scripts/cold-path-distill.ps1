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
                @{ Src = (Join-Path $repoRoot '.augment\SESSION_LOG.md'); Dst = (Join-Path $dotAug 'SESSION_LOG.md') },
                @{ Src = (Join-Path $repoRoot 'AGENTS.md');               Dst = (Join-Path $CatelMirrorRoot 'AGENTS.md') }
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
        & git add .augment/memory .augment/SESSION_LOG.md *>$null
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
