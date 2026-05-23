# build-mcounterpart-doc-v4.ps1 - regenerate MCounterPart-Architecture-v4.docx
# v4 differences vs v3:
#   - Rename ContextLocalAgent  -> LocalContextAgent
#   - Rename CModel/Context Model -> LocalContextModel (the model itself)
#   - LocalContextAgent is the agent identity that USES the LocalContextModel
#   - Rename CloudServerAgents  -> CloudAgents
#   - Introduce CloudModels (the actual models on airouter)
#   - Introduce MimicClaude (specific CloudAgent = Claude's main counterpart)
#   - Introduce the "Not so fast AI" principle: insert cheap intermediaries
#     in front of Claude so Claude spends fewer tokens over time
#   - Claude (the Augment Agent) acts directly only when the human asks
#     directly; otherwise asks MimicClaude first
#   - Internal short IDs (env vars, queue file names) stay 'chost' / 'laptop'
# Diagram rendered via Kroki (POST mermaid -> SVG + PNG). Doc via Word COM.
[CmdletBinding()]
param([string]$OutPath = '')
$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
if (-not $OutPath) { $OutPath = Join-Path $root 'MCounterPart-Architecture-v4.docx' }
$tmp       = $env:TEMP
$mmd       = Join-Path $tmp 'mcounterpart-diag-v4.mmd'
$png       = Join-Path $tmp 'mcounterpart-diag-v4.png'
$svgOut    = Join-Path $root 'MCounterPart-Architecture-Diagram-v4.svg'

Set-Content -Path $mmd -Encoding UTF8 -Value @'
flowchart TB
    classDef claude fill:#b8e0d2,stroke:#1a4a3a,stroke-width:3px,color:#000
    classDef human  fill:#e8e3d3,stroke:#6b6048,stroke-width:2px,color:#000
    classDef ep     fill:#cfd8e8,stroke:#3a5478,stroke-width:1.5px,color:#000
    classDef lca    fill:#cfd8e8,stroke:#3a5478,stroke-width:2px,color:#000
    classDef lcm    fill:#e8d3d3,stroke:#7a4848,stroke-width:1.5px,color:#000
    classDef shared fill:#d9e4d0,stroke:#4a6b3e,stroke-width:1.5px,color:#000
    classDef cmod   fill:#e8d8c4,stroke:#7a5e2a,stroke-width:1.5px,color:#000
    classDef mimic  fill:#d8c8e8,stroke:#3a2a78,stroke-width:3px,color:#000
    classDef cagent fill:#e0d3e8,stroke:#5a3e7a,stroke-width:1.5px,color:#000
    classDef sub    fill:#f4e6c4,stroke:#7a5e2a,stroke-width:1px,color:#000
    classDef sched  fill:#f0e1c4,stroke:#7a5e2a,stroke-width:1.5px,color:#000

    subgraph HUM [Humans]
      H1[Jose<br/>architect]:::human
      H2[Juan<br/>architect]:::human
    end
    subgraph EP [Communication endpoints - VS Code sessions]
      E1[Desktop<br/>VS Code]:::ep
      E2[Jose laptop<br/>VS Code]:::ep
      E3[Juan laptop<br/>VS Code]:::ep
    end
    H1 --> E1
    H1 --> E2
    H2 --> E3

    CLAUDE[Claude - Augment Agent<br/>top tier, expensive<br/>acts directly ONLY when human asks directly<br/>otherwise asks MimicClaude first]:::claude
    E1 --> CLAUDE
    E2 --> CLAUDE
    E3 --> CLAUDE

    subgraph DESK [Desktop - always-on host]
      LCM[LocalContextModel<br/>qwen2.5-coder 7b + nomic-embed<br/>kept loaded by Ollama, free]:::lcm
      LCA[LocalContextAgent<br/>saves trainings / learnings / history<br/>scheduled tasks + future MCP-Worker<br/>internal id: chost]:::lca
      LCA --> LCM
      ST[Scheduled tasks<br/>cold-path / clone-worker<br/>notifier / bake-off / auto-checkpoint]:::sched
      LCA -.owns.-> ST
    end

    subgraph WS [Shared workspace - git + OneDrive/SharePoint]
      MEM[(Memory<br/>raw / distilled / index)]:::shared
      INB[(Inbox queues + done.jsonl)]:::shared
      RUL[Rules + LESSONS + SESSION_LOG]:::shared
    end
    LCA <--> MEM
    LCA <--> INB
    LCA -.reads.-> RUL
    CLAUDE -.session start.-> RUL

    subgraph AIR [Cloud - airouter API]
      subgraph CMOD [CloudModels - the models]
        CM1[Qwen3.6]:::cmod
        CM2[other models<br/>weekly bake-off picks]:::cmod
      end
      subgraph CAG [CloudAgents - created from CloudModels]
        MC[MimicClaude<br/>main counterpart<br/>Claude asks him FIRST<br/>follows same rules as Claude]:::mimic
        CA2[Coding CloudAgent]:::cagent
        CA3[Cold-path CloudAgent]:::cagent
        CA4[Bake-off CloudAgent]:::cagent
        CA5[On-demand CloudAgent]:::cagent
      end
      CM1 --> MC
      CM1 --> CA2
      CM1 --> CA3
      CM2 --> CA4
    end

    CLAUDE ==>|always ask first| MC
    MC -.delegates trivia.-> LCA
    MC -.spawns workers.-> SUBAG
    CLAUDE -.above MimicClaude ceiling.-> CA2

    subgraph SUBAG [Subagents - short-lived workers spawned by a CloudAgent]
      SA1[clone-agent<br/>worker 1]:::sub
      SA2[clone-agent<br/>worker N]:::sub
    end
    ST --> SA1
    ST --> SA2

    subgraph PRIN [Not so fast AI - the principle]
      direction LR
      P1[1. Claude only when asked directly] --> P2[2. MimicClaude first]
      P2 --> P3[3. LocalContextAgent for trivia]
      P3 --> P4[4. Scheduled tasks / clone-queue for recurrence]
      P4 --> P5[5. Other CloudAgents above MimicClaude ceiling]
    end
'@

Write-Host "Rendering diagram via Kroki (SVG + PNG)..." -ForegroundColor Cyan
$src = Get-Content $mmd -Raw
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/svg' -Method Post -Body $src -ContentType 'text/plain' -OutFile $svgOut -TimeoutSec 60 | Out-Null
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/png' -Method Post -Body $src -ContentType 'text/plain' -OutFile $png    -TimeoutSec 60 | Out-Null
if (-not (Test-Path $png) -or (Get-Item $png).Length -lt 1000) { throw "PNG render failed." }
Write-Host ("  SVG: {0} ({1} KB)" -f $svgOut, [int]((Get-Item $svgOut).Length/1024))
Write-Host ("  PNG: {0} ({1} KB)" -f $png,    [int]((Get-Item $png).Length/1024))

$helper = Join-Path $scriptDir 'build-mcounterpart-doc-v4.content.ps1'
if (-not (Test-Path $helper)) { throw "content helper missing: $helper" }
. $helper
Write-MCounterPartDocV4 -OutPath $OutPath -DiagramPng $png

Write-Host "`nDone:" -ForegroundColor Green
Get-Item $OutPath, $svgOut | Format-List Name, Length, LastWriteTime
