# mimic-claude-ask.ps1 - Claude's first-ask channel to MimicClaude.
#
# Per R11 (Not so fast AI) in .augment/rules/agent-operating-rules.md,
# Claude delegates non-trivial work to MimicClaude BEFORE attempting
# it himself. MimicClaude is the CloudAgent on airouter slot 1
# (today: model from .augment/config/airouter.config.json .current)
# carrying the same operating rules as Claude in his system prompt.
#
# This wrapper:
#   1. Loads .augment/rules/agent-operating-rules.md verbatim.
#   2. Wraps it in a charter telling MimicClaude who he is.
#   3. Calls airouter-call.ps1 with that text as -System.
#   4. Tags the spend as 'mimic-claude' so the budget log separates
#      MimicClaude spend from coding / probe / remote-master spend.
#
# Usage:
#   .\mimic-claude-ask.ps1 -Prompt "<verbatim user request>"
#   .\mimic-claude-ask.ps1 -Prompt "..." -MaxTokens 4096
#   .\mimic-claude-ask.ps1 -Prompt "..." -OutputFile result.json
#   .\mimic-claude-ask.ps1 -Prompt "..." -IncludeAgents     # also send AGENTS.md
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Prompt,

    [int]$MaxTokens = 2048,
    [double]$Temperature = 0.2,
    [string]$OutputFile = '',
    [string]$Model = '',
    [string]$Tag = 'mimic-claude',

    [switch]$IncludeAgents,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$callee    = Join-Path $scriptDir 'airouter-call.ps1'
$rulesPath = Join-Path $scriptDir '..\rules\agent-operating-rules.md'
$agentsPath = Join-Path $scriptDir '..\..\AGENTS.md'

if (-not (Test-Path $rulesPath)) { throw "rules file missing: $rulesPath" }
$rulesText = Get-Content $rulesPath -Raw

$agentsText = ''
if ($IncludeAgents) {
    if (Test-Path $agentsPath) {
        $agentsText = Get-Content $agentsPath -Raw
    } else {
        Write-Host "WARN: -IncludeAgents set but AGENTS.md missing at $agentsPath" -ForegroundColor DarkYellow
    }
}

$charter = @"
You are MimicClaude, a CloudAgent in the MCounterPart architecture.
You are NOT Claude. Claude is the Augment Agent currently running in
VS Code talking to a human architect (today: Jose or Juan). Claude
asked YOU first per the "Not so fast AI" principle (R11), so that the
human spends as few of his expensive Claude-tier tokens as possible.

Your job: produce the answer Claude would have produced, following
the SAME operating rules below. Be concise, structured, and direct
(R9: no flattery, no restating, tables over prose, lead with the
answer). If the request is above your ceiling, say so explicitly with
the reason - do not guess.

You cannot execute commands, edit files, call other airouter slots,
or schedule tasks directly. When the request requires those, describe
the EXACT PowerShell commands or file edits Claude should run, in the
format a human can copy-paste. Stay in the workspace conventions:
PowerShell on Windows, paths relative to the repo root, never echo
secrets, prefer existing scripts under .augment/scripts/ over new
ones.

Respect token discipline (R4): narrow reads, filter terminal output,
prefer codebase-retrieval over file scans, no proactive file creation
(R6). Match the commenting density of surrounding code.

If the request involves cross-machine work (touches files easier to
edit on the other architect's host, or coordinates with the laptop
agent / CHost agent), recommend that Claude use R2
(agent-task-assign.ps1) instead of acting on your output.

=== OPERATING RULES (verbatim from .augment/rules/agent-operating-rules.md) ===
$rulesText
=== END OPERATING RULES ===
"@

if ($agentsText) {
    $charter += @"


=== AGENTS.md (verbatim) ===
$agentsText
=== END AGENTS.md ===
"@
}

$charter += @"


Now answer the human's request below. Output only the answer Claude
should pass back to the user (and any commands Claude should run).
"@

if ($DryRun) {
    Write-Host "--- system prompt (DryRun) ---" -ForegroundColor Cyan
    Write-Host ("system  : {0} chars / ~{1} tokens" -f $charter.Length, [int]($charter.Length/4))
    Write-Host ("prompt  : {0} chars / ~{1} tokens" -f $Prompt.Length,  [int]($Prompt.Length/4))
    Write-Host ("tag     : {0}" -f $Tag)
    Write-Host ("model   : {0}" -f ($(if($Model){$Model}else{'(from config .current)'})))
    Write-Host "(no API call made)"
    exit 0
}

$splat = @{
    Prompt      = $Prompt
    System      = $charter
    MaxTokens   = $MaxTokens
    Temperature = $Temperature
    Tag         = $Tag
}
if ($OutputFile) { $splat['OutputFile'] = $OutputFile }
if ($Model)      { $splat['Model']      = $Model }

& $callee @splat
