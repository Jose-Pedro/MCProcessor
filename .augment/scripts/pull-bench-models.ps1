# Sequential pull of the bench-model set.
# Run as background; tail $LogFile to monitor.

$ErrorActionPreference = 'Continue'
$Ollama  = "$env:LocalAppData\Programs\Ollama\ollama.exe"
$LogDir  = "$env:TEMP\ollama-logs"
$LogFile = "$LogDir\pulls.log"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$models = @(
  'acidtib/qwen2.5-coder-cline:7b',
  'qwen2.5-coder:7b-instruct-q4_K_M',
  'deepseek-coder:6.7b',
  'nemotron-3-nano:4b',
  'nomic-embed-text'
)

"=== bench pull started $(Get-Date -Format o) ===" | Out-File $LogFile -Append -Encoding UTF8

foreach ($m in $models) {
  $started = Get-Date
  "[$($started.ToString('HH:mm:ss'))] PULL START  $m" | Out-File $LogFile -Append -Encoding UTF8
  & $Ollama pull $m 2>&1 | Out-File $LogFile -Append -Encoding UTF8
  $ended = Get-Date
  $dur = [int]($ended - $started).TotalSeconds
  "[$($ended.ToString('HH:mm:ss'))] PULL END    $m  (exit=$LASTEXITCODE, ${dur}s)" | Out-File $LogFile -Append -Encoding UTF8
}

"=== final ollama list ===" | Out-File $LogFile -Append -Encoding UTF8
& $Ollama list 2>&1 | Out-File $LogFile -Append -Encoding UTF8
"=== bench pull finished $(Get-Date -Format o) ===" | Out-File $LogFile -Append -Encoding UTF8
