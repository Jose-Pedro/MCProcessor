# nuno-roles-merge-expand.ps1
# Merges the salvaged employers from clone-agent result 83386af88212 with
# the original seed board searches plus new 30-day-filtered searches for
# the new profile buckets. Writes nuno-roles-seed-expanded.json.

[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$scriptDir = $PSScriptRoot

$rawPath = Join-Path $scriptDir '_nuno-roles-expand-raw.txt'
if (-not (Test-Path -LiteralPath $rawPath)) { throw "raw not found: $rawPath" }
$text = Get-Content -LiteralPath $rawPath -Raw -Encoding UTF8

# salvage employers array (truncated mid-entry)
$emStart = $text.IndexOf('[', $text.IndexOf('"employers"'))
$body = $text.Substring($emStart+1)
$lastClose = $body.LastIndexOf('},')
if ($lastClose -lt 0) { $lastClose = $body.LastIndexOf('}') }
$employersText = $body.Substring(0, $lastClose+1)
$obj = ('{ "employers": [' + $employersText + '] }') | ConvertFrom-Json
$employers = @($obj.employers)
Write-Host "salvaged employers: $($employers.Count)"

# original seed for board searches
$originalSeedPath = Join-Path $scriptDir 'nuno-roles-seed.json'
$orig = Get-Content -LiteralPath $originalSeedPath -Raw -Encoding UTF8 | ConvertFrom-Json
$boards = @($orig.job_board_searches)
Write-Host "original boards: $($boards.Count)"

# new board searches for new profile buckets, with 30-day freshness where supported
$newBoards = @(
    # hotel-fb (F&B / Restaurant)
    [PSCustomObject]@{ board='indeed.pt';     profile='hotel-fb'; region='both';    url='https://pt.indeed.com/jobs?q=f%26b+manager+restaurante&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='hotel-fb'; region='both';    url='https://www.linkedin.com/jobs/search/?keywords=f%26b%20manager&location=Coimbra%2C%20Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='hosco.com';     profile='hotel-fb'; region='both';    url='https://www.hosco.com/en/jobs?countries=portugal&jobCategory=food-and-beverage' },
    # hotel-fo (Front Office / Reservations / Revenue)
    [PSCustomObject]@{ board='indeed.pt';     profile='hotel-fo'; region='both';    url='https://pt.indeed.com/jobs?q=front+office+manager+reservas&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='hotel-fo'; region='both';    url='https://www.linkedin.com/jobs/search/?keywords=front%20office%20manager&location=Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='hosco.com';     profile='hotel-fo'; region='both';    url='https://www.hosco.com/en/jobs?countries=portugal&jobCategory=front-office' },
    # tourism (Travel agencies / DMC / Tour operators)
    [PSCustomObject]@{ board='net-empregos.com'; profile='tourism'; region='both'; url='https://www.net-empregos.com/pesquisa-empregos.asp?chaves=agencia+viagens&zona=Aveiro' },
    [PSCustomObject]@{ board='indeed.pt';        profile='tourism'; region='both'; url='https://pt.indeed.com/jobs?q=tour+operator+turismo&l=Coimbra&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs';    profile='tourism'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=tour%20operator&location=Portugal&f_TPR=r2592000' },
    # qc-supplier (Supplier quality / Procurement)
    [PSCustomObject]@{ board='indeed.pt';     profile='qc-supplier'; region='both'; url='https://pt.indeed.com/jobs?q=supplier+quality+procurement&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='qc-supplier'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=supplier%20quality&location=Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='hays.pt';       profile='qc-supplier'; region='both'; url='https://www.hays.pt/job-search/procurement-jobs-in-portugal' },
    # sales-account (Key Account / CS B2B)
    [PSCustomObject]@{ board='indeed.pt';     profile='sales-account'; region='both'; url='https://pt.indeed.com/jobs?q=key+account+customer+success&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='sales-account'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=key%20account%20manager&location=Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='michael page';  profile='sales-account'; region='both'; url='https://www.michaelpage.pt/job-search?keywords=key+account' },
    # training (Hospitality / Quality trainer)
    [PSCustomObject]@{ board='indeed.pt';     profile='training'; region='both'; url='https://pt.indeed.com/jobs?q=formador+hotelaria+qualidade&l=Portugal&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='training'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=training%20manager&location=Portugal&f_TPR=r2592000' },
    # ops (Operations Manager cross-sector)
    [PSCustomObject]@{ board='indeed.pt';     profile='ops'; region='both'; url='https://pt.indeed.com/jobs?q=operations+manager&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='ops'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=operations%20manager&location=Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='michael page';  profile='ops'; region='both'; url='https://www.michaelpage.pt/job-search?keywords=operations+manager' },
    # extra 30-day-filtered variants of existing buckets
    [PSCustomObject]@{ board='indeed.pt';     profile='hotel'; region='both'; url='https://pt.indeed.com/jobs?q=gestor+hotel&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='indeed.pt';     profile='qc';    region='both'; url='https://pt.indeed.com/jobs?q=controlo+qualidade&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='indeed.pt';     profile='sales'; region='both'; url='https://pt.indeed.com/jobs?q=export+sales+b2b&l=Aveiro&fromage=30' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='hotel'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=hotel%20general%20manager&location=Portugal&f_TPR=r2592000' },
    [PSCustomObject]@{ board='linkedin jobs'; profile='sales'; region='both'; url='https://www.linkedin.com/jobs/search/?keywords=export%20sales%20manager&location=Portugal&f_TPR=r2592000' }
)
$allBoards = @($boards) + @($newBoards)
Write-Host "total boards: $($allBoards.Count)"

# breakdown by profile
$byProfile = $employers | Group-Object profile | Sort-Object Count -Descending
Write-Host ""
Write-Host "=== employers by profile ==="
$byProfile | ForEach-Object { Write-Host ("  {0,-15} {1,3}" -f $_.Name, $_.Count) }
Write-Host ""

$out = [PSCustomObject]@{ employers = $employers; job_board_searches = $allBoards }
$outPath = Join-Path $scriptDir 'nuno-roles-seed-expanded.json'
$out | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $outPath -Encoding UTF8
$sz = (Get-Item -LiteralPath $outPath).Length
Write-Host "wrote: $outPath ($sz bytes)"
