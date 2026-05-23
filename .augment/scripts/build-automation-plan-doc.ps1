# build-automation-plan-doc.ps1 - regenerate Automation-Plan.docx.
# Sibling of build-mcounterpart-doc-v4.ps1; captures the automation
# strategy (scheduled fleet, hot/cold paths, R2 + R11 delegation
# automation, what is still manual). Diagram rendered via Kroki.
[CmdletBinding()]
param([string]$OutPath = '')
$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
if (-not $OutPath) { $OutPath = Join-Path $root 'Automation-Plan.docx' }
$tmp       = $env:TEMP
$mmd       = Join-Path $tmp 'automation-plan-diag.mmd'
$png       = Join-Path $tmp 'automation-plan-diag.png'
$svgOut    = Join-Path $root 'Automation-Plan-Diagram.svg'

Set-Content -Path $mmd -Encoding UTF8 -Value @'
flowchart TB
    classDef human  fill:#e8e3d3,stroke:#6b6048,stroke-width:2px,color:#000
    classDef claude fill:#b8e0d2,stroke:#1a4a3a,stroke-width:3px,color:#000
    classDef mimic  fill:#d8c8e8,stroke:#3a2a78,stroke-width:3px,color:#000
    classDef lca    fill:#cfd8e8,stroke:#3a5478,stroke-width:2px,color:#000
    classDef sched  fill:#f0e1c4,stroke:#7a5e2a,stroke-width:1.5px,color:#000
    classDef queue  fill:#d9e4d0,stroke:#4a6b3e,stroke-width:1.5px,color:#000
    classDef out    fill:#e8d3d3,stroke:#7a4848,stroke-width:1.5px,color:#000

    H[Human architect]:::human --> C[Claude<br/>Augment Agent]:::claude
    C ==>|R11 always ask first| MC[MimicClaude<br/>airouter slot 1]:::mimic
    MC -.delegates trivia.-> LCA[LocalContextAgent<br/>chost / laptop]:::lca

    subgraph SCH [Scheduled fleet - zero in-session tokens]
      direction TB
      T1[AugmentColdPathDistill<br/>daily 02:00]:::sched
      T2[AugmentAutoCheckpoint<br/>every 30 min]:::sched
      T3[AugmentInboxNotifier<br/>every 5 min]:::sched
      T4[AugmentCloneAgentWorker<br/>every 10 min]:::sched
      T5[AugmentRemoteMasterReview<br/>Sun 04:00]:::sched
    end
    LCA -.owns + runs.-> SCH

    subgraph Q [Workspace queues - file-based]
      direction TB
      QI[(inbox-*.jsonl<br/>R2 cross-agent tasks)]:::queue
      QC[(clone-agent queue<br/>R3 tier-4 work)]:::queue
      QR[(memory/raw/*.jsonl<br/>hot-path entries)]:::queue
    end
    C -.write.-> QI
    LCA -.write.-> QR
    C -.write.-> QC
    T4 -.drain.-> QC
    T1 -.read raw write distilled.-> QR
    T3 -.poll.-> QI

    subgraph O [Persistent outputs]
      direction TB
      O1[(memory/distilled + index)]:::out
      O2[SESSION_LOG.md + bootstrap]:::out
      O3[airouter budget + reviews jsonl]:::out
    end
    T1 --> O1
    T2 --> O2
    T5 --> O3
'@

Write-Host "Rendering diagram via Kroki (SVG + PNG)..." -ForegroundColor Cyan
$src = Get-Content $mmd -Raw
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/svg' -Method Post -Body $src -ContentType 'text/plain' -OutFile $svgOut -TimeoutSec 60 | Out-Null
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/png' -Method Post -Body $src -ContentType 'text/plain' -OutFile $png    -TimeoutSec 60 | Out-Null
if (-not (Test-Path $png) -or (Get-Item $png).Length -lt 1000) { throw "PNG render failed." }
Write-Host ("  SVG: {0} ({1} KB)" -f $svgOut, [int]((Get-Item $svgOut).Length/1024))
Write-Host ("  PNG: {0} ({1} KB)" -f $png,    [int]((Get-Item $png).Length/1024))

$helper = Join-Path $scriptDir 'build-automation-plan-doc.content.ps1'
if (-not (Test-Path $helper)) { throw "content helper missing: $helper" }
. $helper
Write-AutomationPlanDoc -OutPath $OutPath -DiagramPng $png

Write-Host "`nDone:" -ForegroundColor Green
Get-Item $OutPath, $svgOut | Format-List Name, Length, LastWriteTime
