param(
  [string]$Schema = "Prv\prv-intprojects-app\schema-hana.sql",
  [string]$OutDir = "Prv\prv-intprojects-app\hana\pviews"
)
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$lines = Get-Content $Schema
$inView = $false
$buf = New-Object System.Collections.Generic.List[string]
$name = $null
$count = 0

for ($i=0; $i -lt $lines.Count; $i++) {
  $ln = $lines[$i]
  if (-not $inView) {
    $m = [regex]::Match($ln, '^CREATE VIEW ([A-Za-z0-9_\.]+)')
    if ($m.Success) {
      $inView = $true
      $name = $m.Groups[1].Value
      $buf.Clear()
      $buf.Add($ln)
    }
  } else {
    $buf.Add($ln)
    if ($ln -match ';\s*$') {
      $sql = ($buf -join "`n")
      if ($sql -match '\(IN p_') {
        $safe = $name -replace '\.','__'
        Set-Content -Path (Join-Path $OutDir "$safe.sql") -Value $sql -Encoding ASCII
        $count++
      }
      $inView = $false
    }
  }
}
"extracted $count parameterized view files into $OutDir"
Get-ChildItem $OutDir -Filter '*.sql' | Select-Object Name | Format-Table -AutoSize
