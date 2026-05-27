[CmdletBinding()]
param(
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

$repo    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Codebase'
$nuno    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Nuno-Job'
$drafts  = Join-Path $nuno '02_drafts'
$reclet  = Join-Path $nuno '04_recommendation'
$results = Join-Path $repo '.augment\clone-agent\results'

$jobs = @(
    @{ id='9d1ef83a690b'; tag='cv-en';       files=@(Join-Path $drafts 'cv-en.md') }
    @{ id='11772fc5f681'; tag='reclet-en';   files=@(Join-Path $reclet 'reclet-en.md') }
    @{ id='d89b89d7e5d5'; tag='linkedin-en'; files=@(
        (Join-Path $drafts 'linkedin-headline-en.txt'),
        (Join-Path $drafts 'linkedin-about-en.md'),
        (Join-Path $drafts 'linkedin-roles-en.md')) }
    @{ id='8c9100b904a2'; tag='cover-en';    files=@(
        (Join-Path $drafts 'cover-hotel-en.md'),
        (Join-Path $drafts 'cover-qc-en.md'),
        (Join-Path $drafts 'cover-sales-en.md')) }
)

function Extract-Block {
    param([string]$Text, [string]$Label)
    # Match: ```<Label>\n<content>\n```  (allow optional whitespace after backticks)
    $pattern = '(?ms)```\s*' + [regex]::Escape($Label) + '\s*\r?\n(.*?)\r?\n```'
    $m = [regex]::Match($Text, $pattern)
    if ($m.Success) { return $m.Groups[1].Value }
    # Fallback: corrected may be unlabeled second block
    return $null
}

function Extract-AllBlocks {
    param([string]$Text)
    $pattern = '(?ms)```\s*([A-Za-z]*)\s*\r?\n(.*?)\r?\n```'
    [regex]::Matches($Text, $pattern) | ForEach-Object {
        [pscustomobject]@{ label = $_.Groups[1].Value; content = $_.Groups[2].Value }
    }
}

$utf8 = New-Object System.Text.UTF8Encoding($false)

foreach ($j in $jobs) {
    $rp = Join-Path $results ($j.id + '.json')
    if (-not (Test-Path -LiteralPath $rp)) { Write-Warning "missing result: $rp"; continue }
    $r = Get-Content -LiteralPath $rp -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($r.status -ne 'ok') { Write-Warning "$($j.tag): status=$($r.status)"; continue }

    $corrected = Extract-Block -Text $r.response -Label 'corrected'
    if (-not $corrected) {
        $blocks = @(Extract-AllBlocks -Text $r.response)
        if ($blocks.Count -ge 2) { $corrected = $blocks[1].content }
    }
    if (-not $corrected) { Write-Warning "$($j.tag): no corrected block extractable"; continue }

    Write-Host ""
    Write-Host "[$($j.tag)] corrected block: $($corrected.Length) chars" -ForegroundColor Cyan

    if ($j.files.Count -eq 1) {
        $f = $j.files[0]
        if ($DryRun) {
            Write-Host "  DRY: would write $f ($($corrected.Length) chars)"
        } else {
            Copy-Item -LiteralPath $f -Destination ($f + '.bak') -Force
            [System.IO.File]::WriteAllText($f, $corrected, $utf8)
            Write-Host "  wrote: $f (.bak created)" -ForegroundColor Green
        }
    } else {
        # Split on ===== markers
        $parts = @{}
        $currentName = $null
        $currentLines = New-Object System.Collections.Generic.List[string]
        foreach ($ln in ($corrected -split "\r?\n")) {
            if ($ln -match '^=====\s*([^=\s].*?)\s*=====\s*$') {
                if ($currentName) { $parts[$currentName] = ($currentLines -join "`n").TrimEnd() }
                $currentName  = $matches[1].Trim()
                $currentLines = New-Object System.Collections.Generic.List[string]
            } else {
                $currentLines.Add($ln)
            }
        }
        if ($currentName) { $parts[$currentName] = ($currentLines -join "`n").TrimEnd() }

        Write-Host "  found $($parts.Count) parts: $(($parts.Keys -join ', '))"
        foreach ($f in $j.files) {
            $name = Split-Path -Leaf $f
            $content = $parts[$name]
            if (-not $content) {
                # try basename without extension match
                $altKey = $parts.Keys | Where-Object { $_ -eq $name -or (Split-Path -Leaf $_) -eq $name } | Select-Object -First 1
                if ($altKey) { $content = $parts[$altKey] }
            }
            if (-not $content) { Write-Warning "  no content for $name"; continue }
            if ($DryRun) {
                Write-Host "  DRY: would write $f ($($content.Length) chars)"
            } else {
                Copy-Item -LiteralPath $f -Destination ($f + '.bak') -Force
                [System.IO.File]::WriteAllText($f, $content, $utf8)
                Write-Host "  wrote: $f (.bak created)" -ForegroundColor Green
            }
        }
    }
}
