param(
    [string[]]$Only = @('cv','reclet','linkedin','cover')
)
$ErrorActionPreference = 'Stop'
$repo    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Codebase'
$nuno    = 'C:\Users\zeped\OneDrive - Pal' + [char]0xE1 + 'cio dos Afetos lda\GODMODE\Nuno-Job'
$enqueue = Join-Path $repo '.augment\scripts\clone-agent-enqueue.ps1'
$drafts  = Join-Path $nuno '02_drafts'
$rec     = Join-Path $nuno '04_recommendation'

function Read-Utf8([string]$p) {
    [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($p)).TrimStart([char]0xFEFF)
}

$sys = @"
You are a senior international-English proofreader for professional job-application documents (CV, recommendation letter, LinkedIn, cover letters). Your job is to detect and correct deviations from polished business English aimed at recruiters in Portugal and across the EU. Flag and fix:

- spelling and typos (keep UK spelling: organise, centralise, specialise, optimise; keep proper nouns intact)
- grammar (tense consistency, subject-verb agreement, article use, prepositions)
- person/number consistency (1st-person singular throughout each bullet list)
- non-idiomatic constructions or Portuguese calques (e.g. "realise" used for "perform", literal translations)
- inconsistent numeric and currency formatting: choose ONE pattern and apply it everywhere. Prefer "EUR 50,000" or "EUR 50k" (do not mix). Comma as thousands separator, period as decimal ("2.2x", "8.9 rating", "1,000 attendees", "4.5 years")
- punctuation (Oxford comma optional but applied consistently; em-dash usage; straight vs curly quotes)
- redundancy, ambiguity, padding
- mojibake or mis-encoded characters (broken accents, curly-quote artefacts)
- register too formal or too casual for the document type
- preserve all numbers, dates, {{...}} markers, and [...] placeholders exactly

OUTPUT RULES:
- Do not invent new facts. Correct form only, not content.
- The output MUST contain EXACTLY two fenced blocks in sequence, with no prose before/between/after:
  1) ``````issues : numbered list (max 20) in the format "N. <type> | <original> -> <corrected> | <short reason>"
  2) ``````corrected : the full revised text, ready to replace the original file
- If there are no issues, return an issues block with the single line "0. no changes" and a corrected block identical to the original.
"@

$jobs = @()
if ($Only -contains 'cv') {
    $jobs += [pscustomobject]@{ tag = 'nuno-review-cv-en'; src = (Join-Path $drafts 'cv-en.md'); label = 'CV (English)' }
}
if ($Only -contains 'reclet') {
    $jobs += [pscustomobject]@{ tag = 'nuno-review-reclet-en'; src = (Join-Path $rec 'reclet-en.md'); label = 'Recommendation letter (English)' }
}
if ($Only -contains 'linkedin') {
    $bundle = @()
    foreach ($f in 'linkedin-headline-en.txt','linkedin-about-en.md','linkedin-roles-en.md') {
        $bundle += "===== $f ====="
        $bundle += (Read-Utf8 (Join-Path $drafts $f))
        $bundle += ""
    }
    $jobs += [pscustomobject]@{ tag = 'nuno-review-linkedin-en'; content = ($bundle -join "`n"); label = 'LinkedIn EN (headline + about + roles)' }
}
if ($Only -contains 'cover') {
    $bundle = @()
    foreach ($f in 'cover-hotel-en.md','cover-qc-en.md','cover-sales-en.md') {
        $bundle += "===== $f ====="
        $bundle += (Read-Utf8 (Join-Path $drafts $f))
        $bundle += ""
    }
    $jobs += [pscustomobject]@{ tag = 'nuno-review-cover-en'; content = ($bundle -join "`n"); label = 'Cover letters EN (hotel + qc + sales)' }
}

Write-Host "enqueuing $($jobs.Count) EN review job(s) (max_tokens=16384 each)..." -ForegroundColor Cyan
foreach ($j in $jobs) {
    $content = if ($j.content) { $j.content } else { Read-Utf8 $j.src }
    $prompt = @"
Review the following text ($($j.label)) according to the OUTPUT RULES in the system prompt.

When the document contains multiple files separated by ===== name.md ===== markers, return ONE SINGLE consolidated issues block (numbered from 1, prefixing each line with the file name) and ONE SINGLE corrected block that reproduces the marker structure with the revised content of each file.

TEXT TO REVIEW:
$content
"@
    & $enqueue -Prompt $prompt -System $sys -Tag $j.tag -MaxTokens 16384 -Kind 'freeform'
}
Write-Host "done." -ForegroundColor Green
