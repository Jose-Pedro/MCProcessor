$env:Path = "$env:ProgramFiles\Docker\Docker\resources\bin;" + $env:Path
$ErrorActionPreference = 'Continue'

$pviewsDir = "Prv\prv-intprojects-app\hana\pviews"
$missing = @(
  'BLOCKS_RESPONSIBLES','BLOCK_SUPPORT_DOCUMENTS','CHECKLIST_BLOCK_PHASE_REQUEST',
  'CUSTOMERS','FIRST_INPROGRESS_PHASE','LANDLORD_BY_SITE','LAST_ACTIVE_PHASES',
  'REQUEST_ALL_TASKS_DOCUMENTS','REQUEST_CUSTOMERS','SINGLE_REQUEST_PROCESS',
  'SITES_BY_AOTYPE','WORKS_BLOCK_PHASE_REQUEST',
  'project_Customers','project_firstInprogressPhase','project_lastActivePhases','project_singleRequestProcess'
)

$tmpOut = [System.IO.Path]::GetTempFileName()
$tmpErr = [System.IO.Path]::GetTempFileName()
$ok = 0; $fail = 0; $dup = 0
$results = @()

foreach ($name in $missing) {
  $src = Join-Path $pviewsDir "$name.sql"
  if (-not (Test-Path $src)) { $results += "MISS $name (file not found)"; continue }
  # Wrap with SET SCHEMA + DROP IF EXISTS-style guard. CDS pviews already end with ;
  $body = Get-Content $src -Raw
  $wrapped = "SET SCHEMA INTPROJ;`r`n" + $body
  $local = Join-Path $env:TEMP "_pview_run.sql"
  Set-Content -Path $local -Value $wrapped -Encoding ASCII
  docker cp $local "prv-intprojects-hana:/tmp/_pview_run.sql" 2>&1 | Out-Null
  # Convert CRLF to LF for hdbsql -I
  docker exec prv-intprojects-hana sh -c "sed -i 's/\r$//' /tmp/_pview_run.sql" 2>&1 | Out-Null
  $proc = Start-Process -FilePath "docker" `
    -ArgumentList @("exec","prv-intprojects-hana","/usr/sap/HXE/HDB90/exe/hdbsql","-n","localhost:39041","-u","INTPROJ","-p","IntprojPwd2026","-d","HXE","-a","-I","/tmp/_pview_run.sql") `
    -RedirectStandardOutput $tmpOut -RedirectStandardError $tmpErr -NoNewWindow -PassThru -Wait
  $stdout = Get-Content $tmpOut -Raw
  $stderr = Get-Content $tmpErr -Raw
  $combined = "$stdout`n$stderr"
  $errLine = (($combined -split "`n") | Where-Object { $_ -match '\* \d+:' } | Select-Object -First 1)
  if ($errLine) {
    if ($errLine -match 'duplicate view name') {
      $results += "DUP  $name"
      $dup++
    } else {
      $results += "FAIL $name => $($errLine.Trim())"
      $fail++
    }
  } else {
    $results += "OK   $name"
    $ok++
  }
}
Remove-Item $tmpOut, $tmpErr -ErrorAction SilentlyContinue

$results | ForEach-Object { $_ }
""
"=== summary: ok=$ok dup=$dup fail=$fail ==="
""

# Final check
"--- final view count ---"
docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a -x "SELECT COUNT(*) FROM VIEWS WHERE SCHEMA_NAME='INTPROJ'" 2>&1
"--- parameterized view count ---"
docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a -x "SELECT COUNT(DISTINCT VIEW_NAME) FROM VIEW_PARAMETERS WHERE SCHEMA_NAME='INTPROJ'" 2>&1
"--- IS_VALID stats ---"
docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a -x "SELECT IS_VALID, COUNT(*) FROM VIEWS WHERE SCHEMA_NAME='INTPROJ' GROUP BY IS_VALID" 2>&1
