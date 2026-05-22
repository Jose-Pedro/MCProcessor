# remote-master-call.ps1 - call the currently-blessed airouter model.
#
# This is the agent's "master tool": the highest-capability remote
# brain available. The specific model id is read from
# .augment/config/airouter.config.json -> .current and is refreshed
# weekly by remote-master-review.ps1 (Sunday 04:00 task).
#
# Use ONLY when the local CModel ensemble cannot do the job (per
# AGENTS.md > Token discipline > rule 7). Every call here costs real
# tokens; the wrapper just enforces the canonical tag so the budget
# log can attribute remote-master spend separately from coding /
# clone-agent / probe spend.
#
# Usage:
#   .\remote-master-call.ps1 -Prompt "..."                # uses cfg.current
#   .\remote-master-call.ps1 -Prompt "..." -MaxTokens 4096
#   .\remote-master-call.ps1 -Prompt "..." -Model "Qwen3.6"  # override
#
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Prompt,

    [string]$System = $null,
    [int]$MaxTokens = 2048,
    [double]$Temperature = 0.2,
    [string]$Tag = 'remote-master',
    [string]$OutputFile = '',
    [string]$Model = ''
)

$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$callee = Join-Path $scriptDir 'airouter-call.ps1'

$splat = @{
    Prompt      = $Prompt
    MaxTokens   = $MaxTokens
    Temperature = $Temperature
    Tag         = $Tag
}
if ($System)     { $splat['System']     = $System }
if ($OutputFile) { $splat['OutputFile'] = $OutputFile }
if ($Model)      { $splat['Model']      = $Model }

& $callee @splat
