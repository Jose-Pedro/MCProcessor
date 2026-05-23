# build-mcounterpart-doc-v3.ps1 - regenerate MCounterPart-Architecture-v3.docx
# at workspace root. V3 differences vs v2:
#   - Rename CHost (concept)  -> ContextLocalAgent
#   - Rename CHosts (concept) -> CloudServerAgents
#   - Internal short IDs (env vars, file paths, queue names) stay 'chost' / 'laptop'
#   - Glossary clarifies: ContextLocalAgent is a ROLE (any local agent that
#     holds context); Desktop is today's *primary* one because it also hosts
#     CModel + scheduled tasks; Laptop is a second ContextLocalAgent that
#     reaches CModel over Tailscale.
# Diagram rendered via Kroki (POST mermaid -> SVG and PNG). Doc via Word COM.
[CmdletBinding()]
param(
    [string]$OutPath = ''
)
$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
if (-not $OutPath) { $OutPath = Join-Path $root 'MCounterPart-Architecture-v3.docx' }
$tmp       = $env:TEMP
$mmd       = Join-Path $tmp 'mcounterpart-diag-v3.mmd'
$png       = Join-Path $tmp 'mcounterpart-diag-v3.png'
$svgOut    = Join-Path $root 'MCounterPart-Architecture-Diagram-v3.svg'

# 1. Mermaid source (v2 - explicit naming + subagent fan-out)
Set-Content -Path $mmd -Encoding UTF8 -Value @'
flowchart TB
    classDef human fill:#e8e3d3,stroke:#6b6048,stroke-width:2px,color:#000
    classDef agent fill:#cfd8e8,stroke:#3a5478,stroke-width:2px,color:#000
    classDef shared fill:#d9e4d0,stroke:#4a6b3e,stroke-width:1.5px,color:#000
    classDef local fill:#e8d3d3,stroke:#7a4848,stroke-width:1.5px,color:#000
    classDef cloud fill:#e0d3e8,stroke:#5a3e7a,stroke-width:1.5px,color:#000
    classDef sub   fill:#f4e6c4,stroke:#7a5e2a,stroke-width:1px,color:#000
    classDef sched fill:#f0e1c4,stroke:#7a5e2a,stroke-width:1.5px,color:#000

    subgraph P1 [Pair 1 - Architect + Agent]
      H1[Jose<br/>architect]:::human
      A1[Primary ContextLocalAgent<br/>Desktop / server VS Code<br/>internal id: chost]:::agent
      H1 <--> A1
    end
    subgraph P2 [Pair 2 - Architect + Agent]
      H2[Juan<br/>architect]:::human
      A2[ContextLocalAgent<br/>Laptop VS Code<br/>internal id: laptop]:::agent
      H2 <--> A2
    end

    subgraph WS [Shared Workspace - git + OneDrive / SharePoint]
      MEM[(Memory<br/>raw / distilled / index)]:::shared
      INB[(Inbox queues<br/>JSONL)]:::shared
      RUL[Rules + LESSONS]:::shared
      LOG[SESSION_LOG + BOOTSTRAP]:::shared
    end
    A1 <--> MEM
    A2 <--> MEM
    A1 <--> INB
    A2 <--> INB
    A1 -.session start.-> RUL
    A2 -.session start.-> RUL

    subgraph DESK [Primary ContextLocalAgent host - Desktop / server, always-on]
      direction TB
      subgraph CMG [CModel - Context Model, kept loaded by Ollama]
        CW[Writer<br/>qwen2.5-coder:7b]:::local
        CR[Retriever<br/>nomic-embed]:::local
      end
      ST[Scheduled tasks<br/>cold-path / clone-worker / notifier / bake-off]:::sched
    end
    A1 --> CW
    A1 --> CR
    A2 -.Tailscale.-> CW
    A2 -.Tailscale.-> CR

    subgraph CHOSTS [CloudServerAgents - cloud-hosted remote scalable pool]
      direction LR
      subgraph K1 [Key K1 - 3 slots]
        S1[Slot 1<br/>master reasoning]:::cloud
        S2[Slot 2<br/>coding]:::cloud
        S3[Slot 3<br/>clone-worker drain]:::cloud
      end
      subgraph K2 [Key K2 - 3 slots]
        S4[Slot 4<br/>cold-path assist]:::cloud
        S5[Slot 5<br/>weekly bake-off]:::cloud
        S6[Slot 6<br/>user on-demand]:::cloud
      end
    end
    A1 -.above local ceiling.-> S1
    A2 -.above local ceiling.-> S1
    A1 --> S2
    A2 --> S2
    ST --> S3
    ST --> S4
    ST --> S5
    H1 --> S6
    H2 --> S6

    subgraph SUBAG [Subagents - spawned by a CloudServerAgent slot to parallelize work]
      SA1[clone-agent<br/>worker 1]:::sub
      SA2[clone-agent<br/>worker N]:::sub
    end
    S3 -.spawns.-> SA1
    S3 -.spawns.-> SA2

    subgraph LADDER [Routing ladder R3 - cheapest tier first]
      L1[1. CModel local] --> L2[2. Counterpart agent] --> L3[3. Scheduled task] --> L4[4. Clone-queue] --> L5[5. Inline CloudServerAgent slot]
    end
'@

# 2. Render diagram via Kroki (SVG for standalone viewing + PNG for Word embed)
Write-Host "Rendering diagram via Kroki (SVG + PNG)..." -ForegroundColor Cyan
$src = Get-Content $mmd -Raw
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/svg' -Method Post -Body $src -ContentType 'text/plain' -OutFile $svgOut -TimeoutSec 60 | Out-Null
Invoke-WebRequest -Uri 'https://kroki.io/mermaid/png' -Method Post -Body $src -ContentType 'text/plain' -OutFile $png    -TimeoutSec 60 | Out-Null
if (-not (Test-Path $png) -or (Get-Item $png).Length -lt 1000) { throw "PNG render failed." }
Write-Host ("  SVG: {0} ({1} KB)" -f $svgOut, [int]((Get-Item $svgOut).Length/1024))
Write-Host ("  PNG: {0} ({1} KB)" -f $png,    [int]((Get-Item $png).Length/1024))

# 3. Build .docx via Word COM through the v3 content helper
$helper = Join-Path $scriptDir 'build-mcounterpart-doc-v3.content.ps1'
if (-not (Test-Path $helper)) { throw "content helper missing: $helper" }
. $helper
Write-MCounterPartDocV3 -OutPath $OutPath -DiagramPng $png

Write-Host "`nDone:" -ForegroundColor Green
Get-Item $OutPath, $svgOut | Format-List Name, Length, LastWriteTime
