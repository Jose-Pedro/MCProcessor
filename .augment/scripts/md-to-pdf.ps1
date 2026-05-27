[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)][string]$Source,
    [string]$OutFile,
    [string]$Title
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Source)) { throw "source not found: $Source" }
$src = Resolve-Path -LiteralPath $Source
if (-not $OutFile) { $OutFile = [System.IO.Path]::ChangeExtension($src.Path, '.pdf') }
if (-not $Title)   { $Title   = [System.IO.Path]::GetFileNameWithoutExtension($src.Path) }

$edgePaths = @(
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
)
$browser = $edgePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw "no Edge or Chrome binary found" }

$md = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($src.Path)).TrimStart([char]0xFEFF)
$lines = $md -split "\r?\n"

$sections = @(
    'Profile','Languages','Experience','Education','Achievements',
    'References on request','Skills','Summary','Certifications'
)

$body = New-Object System.Collections.Generic.List[string]
$prev = ''
$isFirstLine = $true
foreach ($ln in $lines) {
    $esc = $ln -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
    if ($ln -eq '') { $body.Add('<div class="gap"></div>'); $prev = ''; continue }
    if ($isFirstLine -and $ln -match '\|') {
        $body.Add("<div class='name'>$esc</div>")
        $isFirstLine = $false; $prev = $ln; continue
    }
    $isFirstLine = $false
    $trim = $ln.Trim()
    if (($prev -eq '') -and ($sections -contains $trim)) {
        $body.Add("<h2>$esc</h2>")
    } elseif ($ln -match '^### ') {
        $body.Add("<h3>$($esc -replace '^### ','')</h3>")
    } elseif ($ln -match '^\d+\.\s') {
        $body.Add("<div class='bullet'>$esc</div>")
    } elseif (($prev -eq '') -and ($ln -match '\|')) {
        $body.Add("<div class='roleline'>$esc</div>")
    } else {
        $body.Add("<div class='line'>$esc</div>")
    }
    $prev = $ln
}

$css = @'
@page { size: A4; margin: 1.4cm 1.6cm; }
body { font-family: 'Calibri','Segoe UI','Helvetica Neue',sans-serif;
       font-size: 10.5pt; line-height: 1.38; color: #1a202c; margin: 0; }
.name { font-size: 14pt; font-weight: 600; margin-bottom: 0.3em; color: #1a202c; }
h2 { font-size: 12pt; margin: 0.9em 0 0.25em 0; color: #2c5282;
     border-bottom: 1px solid #cbd5e0; padding-bottom: 2px; font-weight: 600; }
h3 { font-size: 10.8pt; margin: 0.6em 0 0.15em 0; font-weight: 600; color: #2d3748; }
.roleline { font-weight: 600; margin-top: 0.4em; color: #2d3748; }
.bullet { margin: 0.05em 0 0.05em 1.6em; text-indent: -1.4em; padding-left: 0; }
.line { margin: 0.05em 0; }
.gap { height: 0.35em; }
'@

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$Title</title>
<style>$css</style>
</head>
<body>
$($body -join "`n")
</body>
</html>
"@

$tmpHtml = Join-Path $env:TEMP ("md2pdf_" + [guid]::NewGuid().ToString('N').Substring(0,8) + ".html")
$utf8 = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($tmpHtml, $html, $utf8)

$tmpProfile = Join-Path $env:TEMP ("md2pdf_profile_" + [guid]::NewGuid().ToString('N').Substring(0,8))
$null = New-Item -ItemType Directory -Force -Path $tmpProfile
$fileUrl = 'file:///' + ([uri]::EscapeUriString(($tmpHtml -replace '\\','/')))
$browserArgs = @(
    '--headless',
    '--disable-gpu',
    '--no-pdf-header-footer',
    "--user-data-dir=`"$tmpProfile`"",
    "--print-to-pdf=`"$OutFile`"",
    "`"$fileUrl`""
)
Write-Host "rendering: $($src.Path)" -ForegroundColor Cyan
Write-Host "browser  : $browser" -ForegroundColor DarkGray
Write-Host "output   : $OutFile" -ForegroundColor DarkGray
Write-Host "tmp html : $tmpHtml" -ForegroundColor DarkGray
$p = Start-Process -FilePath $browser -ArgumentList $browserArgs -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { Write-Warning "browser exit code: $($p.ExitCode)" }

if (Test-Path -LiteralPath $OutFile) {
    $sz = (Get-Item -LiteralPath $OutFile).Length
    Write-Host ("done: $OutFile ({0:N0} bytes)" -f $sz) -ForegroundColor Green
    Remove-Item -LiteralPath $tmpHtml -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tmpProfile -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Warning "PDF not produced; tmp html kept for inspection: $tmpHtml"
    throw "PDF was not produced: $OutFile (browser exit=$($p.ExitCode))"
}
