# Execute a SQL file against HANA by splitting on ';' and running each
# statement individually via docker exec hdbsql (positional argument).
param(
  [Parameter(Mandatory=$true)] [string]$File,
  [string]$Container = "prv-intprojects-hana",
  [string]$User = "INTPROJ",
  [string]$Pwd = "IntprojPwd2026",
  [string]$Database = "HXE",
  [int]$Port = 39041,
  [switch]$ContinueOnError
)

$env:Path = "$env:ProgramFiles\Docker\Docker\resources\bin;" + $env:Path

$raw = Get-Content $File -Raw
# strip line comments
$raw = ($raw -split "`n" | Where-Object { $_ -notmatch '^\s*--' }) -join "`n"
# split on ';' followed by end of line; collapse newlines within statement
$stmts = $raw -split "(?m);\s*$" | Where-Object { $_.Trim() -ne '' }

$ok = 0; $fail = 0
$errs = @()
$tmpHost = [System.IO.Path]::GetTempFileName()
$tmpOut  = [System.IO.Path]::GetTempFileName()
$tmpErr  = [System.IO.Path]::GetTempFileName()
foreach ($s in $stmts) {
  $body = $s.Trim()
  if ($body -eq '') { continue }
  Set-Content -Path $tmpHost -Value ($body + ';') -Encoding ASCII
  docker cp $tmpHost "${Container}:/tmp/_run.sql" 2>&1 | Out-Null
  $proc = Start-Process -FilePath "docker" `
    -ArgumentList @("exec", $Container, "/usr/sap/HXE/HDB90/exe/hdbsql", "-n", "localhost:$Port", "-u", $User, "-p", $Pwd, "-d", $Database, "-a", "-I", "/tmp/_run.sql") `
    -RedirectStandardOutput $tmpOut -RedirectStandardError $tmpErr -NoNewWindow -PassThru -Wait
  $errOut = (Get-Content $tmpErr -Raw)
  if ($errOut -match '\* \d+:') {
    $head = ($body -replace "`r?`n", ' ').Substring(0,[math]::Min(80,$body.Length))
    $errLine = ($errOut -split "`n" | Where-Object { $_ -match '\* \d+:' } | Select-Object -First 1).Trim()
    $errs += "FAIL: $head ... => $errLine"
    $fail++
    if (-not $ContinueOnError) { break }
  } else {
    $ok++
  }
}
Remove-Item $tmpHost, $tmpOut, $tmpErr -ErrorAction SilentlyContinue
"ok=$ok fail=$fail"
if ($errs.Count -gt 0) {
  "--- errors ---"
  $errs | Select-Object -First 20 | ForEach-Object { $_ }
}
