$env:Path = "$env:ProgramFiles\Docker\Docker\resources\bin;" + $env:Path
$missing = @(
  'BLOCKS_RESPONSIBLES','BLOCK_SUPPORT_DOCUMENTS','CHECKLIST_BLOCK_PHASE_REQUEST',
  'CUSTOMERS','FIRST_INPROGRESS_PHASE','LANDLORD_BY_SITE','LAST_ACTIVE_PHASES',
  'REQUEST_ALL_TASKS_DOCUMENTS','REQUEST_CUSTOMERS','SINGLE_REQUEST_PROCESS',
  'SITES_BY_AOTYPE','WORKS_BLOCK_PHASE_REQUEST',
  'project_Customers','project_firstInprogressPhase','project_lastActivePhases','project_singleRequestProcess'
)
$ok = 0; $fail = 0
foreach ($name in $missing) {
  $sql = (Get-Content "Prv\prv-intprojects-app\hana\pviews\$name.sql" -Raw) -replace "`r?`n", ' ' -replace ';\s*$',''
  $out = docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a $sql 2>&1
  $errLine = ($out | Where-Object { $_ -match '\* \d+:' } | Select-Object -First 1)
  if ($errLine) { "FAIL $name => $errLine"; $fail++ } else { "OK   $name"; $ok++ }
}
"summary: ok=$ok fail=$fail"
"--- view count ---"
docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a -x "SELECT COUNT(*) FROM VIEWS WHERE SCHEMA_NAME='INTPROJ'" 2>&1
"--- IS_VALID stats ---"
docker exec prv-intprojects-hana /usr/sap/HXE/HDB90/exe/hdbsql -n localhost:39041 -u INTPROJ -p IntprojPwd2026 -d HXE -a -x "SELECT IS_VALID, COUNT(*) FROM VIEWS WHERE SCHEMA_NAME='INTPROJ' GROUP BY IS_VALID" 2>&1
