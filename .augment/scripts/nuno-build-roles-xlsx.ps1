# nuno-build-roles-xlsx.ps1
# Reads the latest clone-agent result tagged 'nuno-employer-intel',
# parses the JSON inside its .response, and emits a multi-sheet .xlsx
# at Nuno-Job\03_deliverables\nuno-roles.xlsx via Excel COM.

[CmdletBinding()]
param(
    [string]$ResultId,
    [string]$SeedJson,
    [string]$OutFile
)
$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

if ($SeedJson) {
    if (-not (Test-Path -LiteralPath $SeedJson)) { throw "seed json not found: $SeedJson" }
    Write-Host "seed: $SeedJson"
    $data = Get-Content -LiteralPath $SeedJson -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    $resultsDir = Join-Path $scriptDir '..\clone-agent\results'
    if (-not (Test-Path $resultsDir)) { throw "results dir missing: $resultsDir" }
    if ($ResultId) {
        $resultPath = Join-Path $resultsDir "$ResultId.json"
    } else {
        $cand = Get-ChildItem $resultsDir -Filter *.json |
            ForEach-Object {
                try {
                    $o = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($o.tag -match 'nuno-employer-intel' -and $o.status -eq 'ok' -and $o.response) {
                        [PSCustomObject]@{ path=$_.FullName; ts=$_.LastWriteTime }
                    }
                } catch {}
            } | Sort-Object ts -Descending | Select-Object -First 1
        if (-not $cand) { throw "no ok result with tag 'nuno-employer-intel' yet - try -SeedJson" }
        $resultPath = $cand.path
    }
    Write-Host "result: $resultPath"
    $raw = Get-Content $resultPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $text = $raw.response
    $text = $text -replace '^```(?:json)?\s*\r?\n','' -replace '\r?\n```\s*$',''
    $first = $text.IndexOf('{'); $last = $text.LastIndexOf('}')
    if ($first -lt 0 -or $last -le $first) { throw "no JSON object in response" }
    $json = $text.Substring($first, $last-$first+1)
    try { $data = $json | ConvertFrom-Json } catch { throw "JSON parse failed: $($_.Exception.Message)" }
}

$employers = @($data.employers)
$boards    = @($data.job_board_searches)
Write-Host "parsed: employers=$($employers.Count)  job_boards=$($boards.Count)"

if (-not $OutFile) {
    $repoRoot = Split-Path (Split-Path $scriptDir -Parent) -Parent
    $godmode  = Split-Path $repoRoot -Parent
    $nuno     = Join-Path $godmode 'Nuno-Job'
    if (-not (Test-Path -LiteralPath $nuno)) { throw "Nuno-Job not found at $nuno" }
    $OutFile = Join-Path $nuno '03_deliverables\nuno-roles.xlsx'
}
$null = New-Item -ItemType Directory -Force -Path (Split-Path $OutFile -Parent)
if (Test-Path $OutFile) { Remove-Item $OutFile -Force }

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Add()
while ($wb.Sheets.Count -gt 1) { $wb.Sheets.Item($wb.Sheets.Count).Delete() }

function Add-Sheet($wb, $name) {
    if ($wb.Sheets.Count -eq 1 -and $wb.Sheets.Item(1).Name -like 'Sheet*') {
        $s = $wb.Sheets.Item(1); $s.Name = $name; return $s
    }
    $s = $wb.Sheets.Add([Type]::Missing, $wb.Sheets.Item($wb.Sheets.Count))
    $s.Name = $name; return $s
}

function Write-Header($sheet, $row, $cols) {
    for ($i=0; $i -lt $cols.Count; $i++) {
        $c = $sheet.Cells.Item($row, $i+1); $c.Value2 = $cols[$i]
        $c.Font.Bold = $true; $c.Interior.Color = 4886754
        $c.Font.Color = 16777215
    }
}

# Sheet 1: Employers
$s1 = Add-Sheet $wb 'Employers'
$hdr = @('Name','Profile','Sector','City','District','Careers URL','Fit (1-5)','Why fit (PT)','Status','Date added','Date applied','Notes')
Write-Header $s1 1 $hdr
$today = (Get-Date).ToString('yyyy-MM-dd')
$row = 2
foreach ($e in $employers) {
    $s1.Cells.Item($row,1).Value2  = [string]$e.name
    $s1.Cells.Item($row,2).Value2  = [string]$e.profile
    $s1.Cells.Item($row,3).Value2  = [string]$e.sector
    $s1.Cells.Item($row,4).Value2  = [string]$e.city
    $s1.Cells.Item($row,5).Value2  = [string]$e.district
    $s1.Cells.Item($row,6).Value2  = [string]$e.careers_url
    $s1.Cells.Item($row,7).Value2  = [int]($e.fit_score)
    $s1.Cells.Item($row,8).Value2  = [string]$e.why_fit_pt
    $s1.Cells.Item($row,9).Value2  = 'Pending'
    $s1.Cells.Item($row,10).Value2 = $today
    $row++
}
$last = $row - 1
$rng = $s1.Range("A1").Resize($last,$hdr.Count)
$null = $rng.Worksheet.ListObjects.Add(1, $rng, $null, 1)
$s1.Columns.AutoFit() | Out-Null
$s1.Columns.Item(6).ColumnWidth = 40; $s1.Columns.Item(8).ColumnWidth = 55; $s1.Columns.Item(12).ColumnWidth = 30
$s1.Application.ActiveWindow.SplitRow = 1; $s1.Application.ActiveWindow.FreezePanes = $true

# Sheet 2: Job Boards
$s2 = Add-Sheet $wb 'Job Boards'
$hdr2 = @('Board','Profile','Region','Search URL','Last checked','Notes')
Write-Header $s2 1 $hdr2
$row = 2
foreach ($b in $boards) {
    $s2.Cells.Item($row,1).Value2 = [string]$b.board
    $s2.Cells.Item($row,2).Value2 = [string]$b.profile
    $s2.Cells.Item($row,3).Value2 = [string]$b.region
    $s2.Cells.Item($row,4).Value2 = [string]$b.url
    $row++
}
$last2 = $row - 1
if ($last2 -ge 2) {
    $rng2 = $s2.Range("A1").Resize($last2,$hdr2.Count)
    $null = $rng2.Worksheet.ListObjects.Add(1, $rng2, $null, 1)
}
$s2.Columns.AutoFit() | Out-Null
$s2.Columns.Item(4).ColumnWidth = 80

# Sheet 3: Dashboard
$s3 = Add-Sheet $wb 'Dashboard'
$s3.Cells.Item(1,1).Value2 = 'Nuno — Role Search Tracker'
$s3.Cells.Item(1,1).Font.Size = 16; $s3.Cells.Item(1,1).Font.Bold = $true
$s3.Cells.Item(3,1).Value2 = "Generated"; $s3.Cells.Item(3,2).Value2 = $today
$s3.Cells.Item(4,1).Value2 = "Total employers"; $s3.Cells.Item(4,2).Formula = "=COUNTA(Employers!A:A)-1"

$profileLabels = [ordered]@{
    'hotel'         = 'Hotel / Hostel GM'
    'hotel-fb'      = 'F&B / Restaurant'
    'hotel-fo'      = 'Front Office / Reservas'
    'tourism'       = 'Turismo / Agencias / DMC'
    'qc'            = 'Quality Control (industria)'
    'qc-supplier'   = 'Supplier Quality / Procurement'
    'sales'         = 'B2B Sales / Export'
    'sales-account' = 'Key Account / CS B2B'
    'training'      = 'Training / Formacao'
    'ops'           = 'Operations Manager'
}
$rowD = 5
foreach ($k in $profileLabels.Keys) {
    if ($employers | Where-Object { $_.profile -eq $k }) {
        $s3.Cells.Item($rowD,1).Value2 = $profileLabels[$k]
        $s3.Cells.Item($rowD,2).Formula = "=COUNTIF(Employers!B:B,""$k"")"
        $rowD++
    }
}
$other = $employers | Where-Object { -not $profileLabels.Contains([string]$_.profile) } | Select-Object -ExpandProperty profile -Unique
foreach ($k in $other) {
    $s3.Cells.Item($rowD,1).Value2 = "[$k]"
    $s3.Cells.Item($rowD,2).Formula = "=COUNTIF(Employers!B:B,""$k"")"
    $rowD++
}
$rowD++
$s3.Cells.Item($rowD,1).Value2  = "Applied";   $s3.Cells.Item($rowD,2).Formula  = "=COUNTIF(Employers!I:I,""Applied"")"; $rowD++
$s3.Cells.Item($rowD,1).Value2 = "Interview"; $s3.Cells.Item($rowD,2).Formula = "=COUNTIF(Employers!I:I,""Interview"")"; $rowD++
$s3.Cells.Item($rowD,1).Value2 = "Rejected";  $s3.Cells.Item($rowD,2).Formula = "=COUNTIF(Employers!I:I,""Rejected"")"; $rowD++
$s3.Cells.Item($rowD,1).Value2 = "Pending";   $s3.Cells.Item($rowD,2).Formula = "=COUNTIF(Employers!I:I,""Pending"")"; $rowD += 2
$s3.Cells.Item($rowD,1).Value2 = "Status values"; $s3.Cells.Item($rowD,1).Font.Bold = $true; $rowD++
$s3.Cells.Item($rowD,1).Value2 = "Pending / Researching / Applied / Interview / Offer / Rejected / Withdrawn"
$s3.Columns.AutoFit() | Out-Null

$wb.Sheets.Item('Dashboard').Move($wb.Sheets.Item(1)) | Out-Null

$wb.SaveAs($OutFile, 51) # xlOpenXMLWorkbook
$wb.Close($false)
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb)    | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
[GC]::Collect(); [GC]::WaitForPendingFinalizers()

$sz = (Get-Item $OutFile).Length
Write-Host "done: $OutFile ($sz bytes)" -ForegroundColor Green
