# remote-master-review.ps1 - weekly airouter model review.
#
# Goals (in order):
#   1. Discover models that appeared on airouter since last review.
#   2. Run ONE small smoke prompt against each *new* candidate
#      (no re-smoking known-good models — token discipline).
#   3. Append a structured result record to the review log.
#   4. Print a recommendation: "current is fine" or "candidate <id>
#      passed smoke; consider A/B test against <current>".
#   5. NEVER auto-switch the current model. The agent (or a human)
#      reads the log, decides, edits airouter.config.json .current,
#      and records the decision in SESSION_LOG.md.
#
# Cost shape: 1 smoke call per *new* model per week. Steady state
# is 0 token-cost (one free GET /models) once the catalog stabilizes.
#
# Usage:
#   .\remote-master-review.ps1                # respect cadence; skip if too recent
#   .\remote-master-review.ps1 -Force         # ignore cadence; re-run now
#   .\remote-master-review.ps1 -ReSmokeAll    # smoke even known models (expensive)
#
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$ReSmokeAll
)

$ErrorActionPreference = 'Stop'
$scriptDir  = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$cfgPath    = Join-Path $scriptDir '..\config\airouter.config.json'
$callee     = Join-Path $scriptDir 'airouter-call.ps1'

if (-not (Test-Path $cfgPath)) { throw "airouter config not found: $cfgPath" }
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
$review = $cfg.weeklyReview
if (-not $review) { throw "weeklyReview block missing in $cfgPath" }

$logPath = Join-Path $scriptDir ('..\' + ($review.logPath -replace '^\.augment[\\/]+',''))

# Cadence check
$now = Get-Date
if (-not $Force -and $review.lastRun) {
    try {
        $last = [datetime]::Parse($review.lastRun)
        $days = ($now - $last).TotalDays
        if ($days -lt [double]$review.cadenceDays) {
            Write-Host ("Last review {0:N1}d ago (cadence={1}d). Skipping. -Force to override." -f $days, $review.cadenceDays) -ForegroundColor DarkGray
            exit 0
        }
    } catch { }
}

# Fetch live model list (metadata only - no token cost)
Write-Host "Fetching airouter model catalog..." -ForegroundColor Cyan
$keyVar = $cfg.apiKeyEnvVar
$apiKey = [Environment]::GetEnvironmentVariable($keyVar, 'Process')
if (-not $apiKey) { $apiKey = [Environment]::GetEnvironmentVariable($keyVar, 'User') }
if (-not $apiKey) { throw "env var $keyVar not set" }
$headers = @{ 'Authorization' = "Bearer $apiKey"; 'Content-Type' = 'application/json' }
$base = $cfg.baseUrl.TrimEnd('/')
$resp = Invoke-RestMethod -Uri "$base/models" -Headers $headers -Method Get -TimeoutSec 30
$live = @($resp.data | Select-Object -ExpandProperty id)
Write-Host ("Found {0} model(s) live on airouter: {1}" -f $live.Count, ($live -join ', '))

$known = @{}
foreach ($m in $cfg.models) { $known[$m.id] = $m }

$newOnes = @($live | Where-Object { -not $known.ContainsKey($_) })
$toSmoke = if ($ReSmokeAll) { $live } else { $newOnes }

Write-Host ("Known: {0}. New: {1}. Will smoke: {2}." -f $known.Count, $newOnes.Count, $toSmoke.Count) -ForegroundColor Cyan

$results = @()
foreach ($id in $toSmoke) {
    Write-Host "`n  smoking $id ..." -ForegroundColor Yellow
    $tmp = Join-Path $env:TEMP ("airouter-smoke-{0}-{1}.json" -f ($id -replace '[^a-zA-Z0-9]','_'), [Guid]::NewGuid().ToString('N').Substring(0,6))
    try {
        & $callee -Prompt $review.smokePrompt -Model $id -MaxTokens ([int]$review.smokeMaxTokens) -Tag 'remote-master-review' -OutputFile $tmp 2>&1 | Out-Host
        if (Test-Path $tmp) {
            $out = Get-Content $tmp -Raw | ConvertFrom-Json
            $status = if ([string]::IsNullOrWhiteSpace($out.response)) { 'empty' } else { 'ok' }
            $results += [pscustomobject]@{
                id = $id; status = $status; latency_ms = $out.latency_ms
                total_tokens = $out.usage.total_tokens; response = $out.response
            }
            Remove-Item $tmp -EA 0
        } else {
            $results += [pscustomobject]@{ id = $id; status = 'no-output'; latency_ms = 0; total_tokens = 0; response = '' }
        }
    } catch {
        $results += [pscustomobject]@{ id = $id; status = 'error'; latency_ms = 0; total_tokens = 0; response = $_.Exception.Message }
    }
}

# Append review record to log (one JSON line per review run)
$record = [ordered]@{
    ts            = $now.ToString('s')
    current       = $cfg.current
    live_models   = $live
    new_models    = $newOnes
    smoke_results = $results
    note          = if ($newOnes.Count -gt 0) { 'NEW MODELS DETECTED - review smoke_results and decide whether to A/B against current' } else { 'no new candidates - current model retained' }
}
Add-Content -Path $logPath -Value ($record | ConvertTo-Json -Depth 6 -Compress) -Encoding UTF8

# Update lastRun in config (only field touched - preserves manual edits)
$cfg.weeklyReview.lastRun = $now.ToString('s')
($cfg | ConvertTo-Json -Depth 10) | Set-Content -Path $cfgPath -Encoding UTF8

Write-Host "`n--- review complete ---" -ForegroundColor Green
Write-Host "Current model : $($cfg.current)"
Write-Host "Log appended  : $logPath"
if ($newOnes.Count -gt 0) {
    Write-Host "ACTION: $($newOnes.Count) new candidate(s). Review log and decide." -ForegroundColor Yellow
    $results | Format-Table id, status, latency_ms, total_tokens -AutoSize
} else {
    Write-Host "No new candidates. Next review in $($review.cadenceDays) day(s)." -ForegroundColor DarkGray
}
