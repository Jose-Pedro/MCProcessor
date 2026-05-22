# airouter-call.ps1 - minimal reusable client for the remote Execution Engine.
#
# The API key is read from the User-scope environment variable named in
# .augment/config/airouter.config.json (default: AIROUTER_API_KEY).
# The key is NEVER passed as a command-line argument and NEVER echoed.
#
# Usage:
#   .\airouter-call.ps1 -Prompt "Hello"
#   .\airouter-call.ps1 -Prompt "Refactor this"  -System "You are concise" -MaxTokens 256
#   .\airouter-call.ps1 -ListModels
#   .\airouter-call.ps1 -Probe                       # cheapest possible auth check
#
[CmdletBinding(DefaultParameterSetName='Chat')]
param(
    [Parameter(ParameterSetName='Chat', Mandatory=$true, Position=0)]
    [string]$Prompt,

    [Parameter(ParameterSetName='Chat')]
    [string]$System = $null,

    [Parameter(ParameterSetName='Chat')]
    [int]$MaxTokens = 1024,

    [Parameter(ParameterSetName='Chat')]
    [double]$Temperature = 0.2,

    [Parameter(ParameterSetName='Models')]
    [switch]$ListModels,

    [Parameter(ParameterSetName='Probe')]
    [switch]$Probe,

    [string]$ConfigPath = ''
)

$ErrorActionPreference = 'Stop'

# Resolve config path lazily (param defaults can't see $PSScriptRoot in all hosts)
if ([string]::IsNullOrEmpty($ConfigPath)) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $ConfigPath = Join-Path $scriptDir '..\config\airouter.config.json'
}

# Load non-secret config
if (-not (Test-Path $ConfigPath)) { throw "Config not found: $ConfigPath" }
$cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$keyVar = $cfg.apiKeyEnvVar

# Resolve key from environment (current session OR User scope)
$apiKey = [Environment]::GetEnvironmentVariable($keyVar, 'Process')
if (-not $apiKey) { $apiKey = [Environment]::GetEnvironmentVariable($keyVar, 'User') }
if (-not $apiKey) {
    Write-Host "ERROR: env var '$keyVar' not set." -ForegroundColor Red
    Write-Host "Set it once with:" -ForegroundColor Yellow
    Write-Host "  [Environment]::SetEnvironmentVariable('$keyVar', '<your-key>', 'User')" -ForegroundColor Yellow
    exit 2
}

# Build headers (key only goes into Authorization header, never into argv/URL/log)
$headers = @{
    'Authorization' = "Bearer $apiKey"
    'Content-Type'  = 'application/json'
}

$base = $cfg.baseUrl.TrimEnd('/')
$model = $cfg.models[0].id

function Mask([string]$s) {
    if ([string]::IsNullOrEmpty($s)) { return '<empty>' }
    if ($s.Length -le 8) { return '<short>' }
    return $s.Substring(0,3) + '...' + $s.Substring($s.Length-2) + " (len=$($s.Length))"
}

if ($Probe) {
    Write-Host "Endpoint : $base"
    Write-Host "Model    : $model"
    Write-Host "Key      : $(Mask $apiKey)"
    Write-Host "Probing  : GET $base/models ..."
    try {
        $r = Invoke-RestMethod -Uri "$base/models" -Headers $headers -Method Get -TimeoutSec 15
        if ($r.data) {
            Write-Host "OK - server returned $($r.data.Count) model(s)." -ForegroundColor Green
            $r.data | Select-Object -First 8 id | ForEach-Object { "  - $($_.id)" }
        } else {
            Write-Host "Response shape unexpected:" -ForegroundColor Yellow
            $r | ConvertTo-Json -Depth 4 -Compress | Select-Object -First 1
        }
    } catch {
        Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            "HTTP $([int]$_.Exception.Response.StatusCode) $($_.Exception.Response.StatusDescription)"
        }
        exit 1
    }
    exit 0
}

if ($ListModels) {
    $r = Invoke-RestMethod -Uri "$base/models" -Headers $headers -Method Get -TimeoutSec 15
    $r.data | Select-Object id, owned_by | Format-Table -AutoSize
    exit 0
}

# Chat completion
$messages = @()
if ($System) { $messages += @{ role = 'system'; content = $System } }
$messages += @{ role = 'user'; content = $Prompt }

$body = @{
    model       = $model
    messages    = $messages
    max_tokens  = $MaxTokens
    temperature = $Temperature
    stream      = $false
} | ConvertTo-Json -Depth 8 -Compress

try {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $r = Invoke-RestMethod -Uri "$base/chat/completions" -Headers $headers -Method Post -Body $body -TimeoutSec 120
    $sw.Stop()
    $msg = $r.choices[0].message
    $text = $msg.content
    $reasoning = $msg.reasoning_content
    $usage = $r.usage
    Write-Host "--- response ($([int]$sw.Elapsed.TotalMilliseconds) ms) ---" -ForegroundColor Cyan
    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host "(empty content - model spent budget on reasoning; raise -MaxTokens)" -ForegroundColor Yellow
    } else {
        Write-Host $text
    }
    if ($reasoning -and $env:AIROUTER_SHOW_REASONING -eq '1') {
        Write-Host "--- reasoning_content ---" -ForegroundColor DarkGray
        Write-Host $reasoning
    }
    if ($usage) {
        Write-Host "--- usage ---" -ForegroundColor Cyan
        $rt = $usage.completion_tokens_details.reasoning_tokens
        $tt = $usage.completion_tokens_details.text_tokens
        if ($null -ne $rt) {
            "prompt={0}  completion={1} (reasoning={2} text={3})  total={4}" -f $usage.prompt_tokens, $usage.completion_tokens, $rt, $tt, $usage.total_tokens
        } else {
            "prompt={0}  completion={1}  total={2}" -f $usage.prompt_tokens, $usage.completion_tokens, $usage.total_tokens
        }
    }
} catch {
    Write-Host "CALL FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) { $_.ErrorDetails.Message }
    exit 1
}
