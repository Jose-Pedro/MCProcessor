# Smoke test: load each chat model, send one identical prompt via Ollama HTTP API,
# capture cold-load time, first-token latency proxy, sustained tok/s, output sanity,
# and VRAM/RAM footprint from `ollama ps`. ~1 min per model.

$ErrorActionPreference = 'Stop'
$ollama = "$env:LocalAppData\Programs\Ollama\ollama.exe"
$api = "http://127.0.0.1:11434/api/generate"

$models = @(
    'acidtib/qwen2.5-coder-cline:7b',
    'qwen2.5-coder:7b-instruct-q4_K_M',
    'deepseek-coder:6.7b',
    'nemotron-3-nano:4b'
)

$prompt = "Write a JavaScript function called sumArray that takes an array of numbers and returns their sum. Output ONLY the function, no explanation, no markdown fences."

$results = @()

foreach ($m in $models) {
    Write-Host ""
    Write-Host "=== $m ===" -ForegroundColor Cyan

    # Force unload anything currently resident (cold load measurement)
    try { & $ollama stop $m 2>$null | Out-Null } catch {}
    Start-Sleep -Milliseconds 500

    $body = @{
        model  = $m
        prompt = $prompt
        stream = $false
        options = @{ num_predict = 120; temperature = 0.2 }
    } | ConvertTo-Json -Compress

    $wall = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $resp = Invoke-RestMethod -Uri $api -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 180
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Model = $m; Status = "FAIL"; Error = $_.Exception.Message
        }
        continue
    }
    $wall.Stop()

    # ollama returns durations in nanoseconds
    $loadMs    = [math]::Round($resp.load_duration       / 1e6, 0)
    $promptMs  = [math]::Round($resp.prompt_eval_duration / 1e6, 0)
    $genMs     = [math]::Round($resp.eval_duration       / 1e6, 0)
    $totalMs   = [math]::Round($resp.total_duration      / 1e6, 0)
    $tokGen    = $resp.eval_count
    $tokPrompt = $resp.prompt_eval_count
    $tokPerSec = if ($resp.eval_duration -gt 0) {
        [math]::Round($tokGen / ($resp.eval_duration / 1e9), 1)
    } else { 0 }

    # Capture VRAM/RAM while still hot
    $psRaw = & $ollama ps 2>$null
    $psLine = $psRaw | Select-String -Pattern ([regex]::Escape($m.Split(':')[0])) | Select-Object -First 1
    $footprint = if ($psLine) { ($psLine.Line -split '\s{2,}')[-2..-1] -join ' / ' } else { 'n/a' }

    # First 200 chars of output for sanity
    $out = ($resp.response -replace '\s+',' ').Trim()
    if ($out.Length -gt 200) { $out = $out.Substring(0,200) + '...' }

    $results += [PSCustomObject]@{
        Model        = $m
        LoadMs       = $loadMs
        PromptTok    = $tokPrompt
        PromptMs     = $promptMs
        GenTok       = $tokGen
        GenMs        = $genMs
        TokPerSec    = $tokPerSec
        TotalMs      = $totalMs
        WallMs       = $wall.ElapsedMilliseconds
        Footprint    = $footprint
        Output       = $out
    }

    Write-Host ("  load={0}ms  prompt={1}tok/{2}ms  gen={3}tok/{4}ms  -> {5} tok/s" -f `
        $loadMs,$tokPrompt,$promptMs,$tokGen,$genMs,$tokPerSec)
    Write-Host ("  resident: $footprint")
    Write-Host ("  output: $out")
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Yellow
$results | Format-Table Model,LoadMs,GenTok,TokPerSec,Footprint -AutoSize | Out-String -Width 200 | Write-Host
$results | ConvertTo-Json -Depth 5 | Set-Content -Path ".augment\scripts\smoke-bench-results.json" -Encoding UTF8
Write-Host "Full results -> .augment\scripts\smoke-bench-results.json"
