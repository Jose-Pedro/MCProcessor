[CmdletBinding()]
param(
    [switch]$PdfOnly,
    [switch]$DocxOnly,
    [string[]]$Only  # optional filter: substrings to match against source filenames
)
$ErrorActionPreference = 'Stop'

$repo    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Codebase'
$nuno    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Nuno-Job'
$drafts  = Join-Path $nuno '02_drafts'
$reclet  = Join-Path $nuno '04_recommendation'
$out     = Join-Path $nuno '03_deliverables'
$pdfScript  = Join-Path $repo '.augment\scripts\md-to-pdf.ps1'
$docxScript = Join-Path $repo '.augment\scripts\md-to-docx.ps1'
$null = New-Item -ItemType Directory -Force -Path $out
$null = New-Item -ItemType Directory -Force -Path (Join-Path $out 'pt')
$null = New-Item -ItemType Directory -Force -Path (Join-Path $out 'en')

$items = @(
    @{ src=(Join-Path $drafts  'cv-pt.md');             lang='pt'; name='cv-pt' }
    @{ src=(Join-Path $drafts  'cv-en.md');             lang='en'; name='cv-en' }
    @{ src=(Join-Path $reclet  'reclet-pt.md');         lang='pt'; name='reclet-pt' }
    @{ src=(Join-Path $reclet  'reclet-en.md');         lang='en'; name='reclet-en' }
    @{ src=(Join-Path $drafts  'cover-hotel-pt.md');    lang='pt'; name='cover-hotel-pt' }
    @{ src=(Join-Path $drafts  'cover-hotel-en.md');    lang='en'; name='cover-hotel-en' }
    @{ src=(Join-Path $drafts  'cover-qc-pt.md');       lang='pt'; name='cover-qc-pt' }
    @{ src=(Join-Path $drafts  'cover-qc-en.md');       lang='en'; name='cover-qc-en' }
    @{ src=(Join-Path $drafts  'cover-sales-pt.md');    lang='pt'; name='cover-sales-pt' }
    @{ src=(Join-Path $drafts  'cover-sales-en.md');    lang='en'; name='cover-sales-en' }
    @{ src=(Join-Path $drafts  'linkedin-about-pt.md'); lang='pt'; name='linkedin-about-pt' }
    @{ src=(Join-Path $drafts  'linkedin-about-en.md'); lang='en'; name='linkedin-about-en' }
    @{ src=(Join-Path $drafts  'linkedin-roles-pt.md'); lang='pt'; name='linkedin-roles-pt' }
    @{ src=(Join-Path $drafts  'linkedin-roles-en.md'); lang='en'; name='linkedin-roles-en' }
)

if ($Only) {
    $items = $items | Where-Object { $n = $_.name; ($Only | Where-Object { $n -match $_ }).Count -gt 0 }
}

$results = New-Object System.Collections.Generic.List[object]
foreach ($it in $items) {
    if (-not (Test-Path -LiteralPath $it.src)) {
        Write-Warning "missing source: $($it.src)"; continue
    }
    $destDir = Join-Path $out $it.lang
    $pdfOut  = Join-Path $destDir ($it.name + '.pdf')
    $docxOut = Join-Path $destDir ($it.name + '.docx')

    $pdfOk  = $false
    $docxOk = $false

    if (-not $DocxOnly) {
        try {
            & $pdfScript -Source $it.src -OutFile $pdfOut | Out-Null
            $pdfOk = Test-Path -LiteralPath $pdfOut
        } catch { Write-Warning "PDF failed for $($it.name): $($_.Exception.Message)" }
    }
    if (-not $PdfOnly) {
        try {
            & $docxScript -Source $it.src -OutFile $docxOut | Out-Null
            $docxOk = Test-Path -LiteralPath $docxOut
        } catch { Write-Warning "DOCX failed for $($it.name): $($_.Exception.Message)" }
    }

    $results.Add([pscustomobject]@{
        name = $it.name
        lang = $it.lang
        pdf  = if ($pdfOk)  { '{0:N0}' -f (Get-Item $pdfOut).Length  } else { '-' }
        docx = if ($docxOk) { '{0:N0}' -f (Get-Item $docxOut).Length } else { '-' }
    })
}

# Also stage the LinkedIn headline plain-text files (no conversion needed)
foreach ($f in 'linkedin-headline-pt.txt','linkedin-headline-en.txt') {
    $s = Join-Path $drafts $f
    if (Test-Path -LiteralPath $s) {
        $lang = if ($f -match '-pt\.') { 'pt' } else { 'en' }
        Copy-Item -LiteralPath $s -Destination (Join-Path $out $lang) -Force
    }
}

Write-Host ""
Write-Host "=== export summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize
Write-Host "output root: $out" -ForegroundColor Green
