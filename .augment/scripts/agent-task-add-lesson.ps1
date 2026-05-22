# agent-task-add-lesson.ps1 - prepend a corrective lesson to LESSONS.md.
#
# Use when you intervened to fix something the counterpart agent (or a
# prior session of yourself) did wrong, so the same mistake doesn't
# recur. Both Augment instances read LESSONS.md at session start.
#
# Usage:
#   .\agent-task-add-lesson.ps1 -Title "Don't splat hashtable as array" `
#       -Context "clone-agent-worker calling airouter-call.ps1" `
#       -Wrong  "Used @arrayName which passed everything positionally" `
#       -Right  "Use @hashtableName so PowerShell binds by name" `
#       -Applies both
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Title,
    [Parameter(Mandatory=$true)][string]$Context,
    [Parameter(Mandatory=$true)][string]$Wrong,
    [Parameter(Mandatory=$true)][string]$Right,
    [ValidateSet('chost','laptop','both')][string]$Applies = 'both'
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$lessonsPath = Join-Path $scriptDir '..\agent-tasks\LESSONS.md'
if (-not (Test-Path $lessonsPath)) { throw "LESSONS.md not found at $lessonsPath" }

$ts = (Get-Date).ToString('yyyy-MM-dd HH:mm')
$block = @"
## $ts - $Title
- **Context:** $Context
- **What went wrong:** $Wrong
- **Correct approach:** $Right
- **Applies to:** $Applies

"@

# Read existing, find "## Entries" marker, insert new block right after it
$content = Get-Content $lessonsPath -Raw
$marker = "## Entries`r`n"
if ($content -notmatch [regex]::Escape($marker)) { $marker = "## Entries`n" }
$idx = $content.IndexOf($marker)
if ($idx -lt 0) { throw "Cannot find '## Entries' header in $lessonsPath" }
$insertAt = $idx + $marker.Length
$new = $content.Substring(0, $insertAt) + "`r`n" + $block + $content.Substring($insertAt)
Set-Content -Path $lessonsPath -Value $new -Encoding UTF8 -NoNewline
Write-Host "lesson prepended -> $lessonsPath" -ForegroundColor Green
Write-Host "title: $Title  applies: $Applies"
