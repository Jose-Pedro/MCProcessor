# build-mcounterpart-doc.ps1 - regenerate MCounterPart-Architecture.docx
# at workspace root. Reusable: no agent tokens after the first build; a
# scheduled task can fire this on demand or on relevant rule/architecture
# changes. Renders the architecture diagram via npx mermaid-cli (falls
# back to Kroki public API if npx fails). Builds the .docx via Word COM.
[CmdletBinding()]
param(
    [string]$OutPath = ''
)
$ErrorActionPreference = 'Stop'
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$root      = Resolve-Path (Join-Path $scriptDir '..\..')
if (-not $OutPath) { $OutPath = Join-Path $root 'MCounterPart-Architecture.docx' }
$tmp       = $env:TEMP
$mmd       = Join-Path $tmp 'mcounterpart-diag.mmd'
$png       = Join-Path $tmp 'mcounterpart-diag.png'

# 1. Mermaid source
Set-Content -Path $mmd -Encoding UTF8 -Value @'
flowchart TB
    classDef human fill:#e8e3d3,stroke:#6b6048,stroke-width:2px,color:#000
    classDef agent fill:#cfd8e8,stroke:#3a5478,stroke-width:2px,color:#000
    classDef shared fill:#d9e4d0,stroke:#4a6b3e,stroke-width:1.5px,color:#000
    classDef local fill:#e8d3d3,stroke:#7a4848,stroke-width:1.5px,color:#000
    classDef remote fill:#e0d3e8,stroke:#5a3e7a,stroke-width:1.5px,color:#000
    classDef sched fill:#f0e1c4,stroke:#7a5e2a,stroke-width:1.5px,color:#000
    subgraph P1 [Pair 1]
      H1[Jose<br/>architect]:::human
      A1[CHost Agent]:::agent
      H1 <--> A1
    end
    subgraph P2 [Pair 2]
      H2[Juan<br/>architect]:::human
      A2[Laptop Agent]:::agent
      H2 <--> A2
    end
    subgraph WS [Shared Workspace - OneDrive + git]
      MEM[(Memory raw / distilled / index)]:::shared
      INB[(Inbox queues JSONL)]:::shared
      RUL[Rules + LESSONS]:::shared
      LOG[SESSION_LOG + BOOTSTRAP]:::shared
    end
    A1 <--> MEM
    A2 <--> MEM
    A1 <--> INB
    A2 <--> INB
    A1 -.session start.-> RUL
    A2 -.session start.-> RUL
    subgraph CH [CHost always-on host]
      CW[CModel-writer Qwen2.5-coder]:::local
      CR[CModel-retriever nomic-embed]:::local
      ST[Scheduled tasks]:::sched
    end
    A1 --> CW
    A2 -.Tailscale.-> CW
    A1 --> CR
    A2 -.Tailscale.-> CR
    subgraph AR [Airouter pool - 2 keys x 3 slots = 6]
      subgraph K1 [Key 1]
        S1[Slot 1 Master reasoning]:::remote
        S2[Slot 2 Coding]:::remote
        S3[Slot 3 Clone worker]:::remote
      end
      subgraph K2 [Key 2]
        S4[Slot 4 Cold-path assist]:::remote
        S5[Slot 5 Weekly bake-off]:::remote
        S6[Slot 6 User on-demand]:::remote
      end
    end
    A1 -.above ceiling.-> S1
    A2 -.above ceiling.-> S1
    A1 --> S2
    A2 --> S2
    ST --> S3
    ST --> S4
    ST --> S5
    H1 --> S6
    H2 --> S6
    subgraph RT [Routing ladder R3]
      R1[1 Local CModel] --> R2[2 Counterpart] --> R3[3 Scheduled] --> R4[4 Clone-queue] --> R5[5 Inline airouter]
    end
'@

# 2. Render PNG. Kroki first (fast HTTP POST, no local deps); npx mmdc
# fallback only if Kroki unreachable (offline, etc). npx-first was tried
# but the first-run download of @mermaid-js/mermaid-cli takes minutes
# and stalls non-interactive callers.
Write-Host "Rendering diagram via Kroki..." -ForegroundColor Cyan
Remove-Item $png -EA 0
$src = Get-Content $mmd -Raw
try {
    Invoke-WebRequest -Uri 'https://kroki.io/mermaid/png' -Method Post -Body $src -ContentType 'text/plain' -OutFile $png -TimeoutSec 45 -UseBasicParsing | Out-Null
} catch {
    Write-Host "  Kroki failed ($($_.Exception.Message)); trying npx mmdc..." -ForegroundColor Yellow
    try {
        & npx -y "@mermaid-js/mermaid-cli@latest" -i $mmd -o $png -b white -w 1800 2>&1 | Out-Null
    } catch { throw "Both renderers failed: $($_.Exception.Message)" }
}
if (-not (Test-Path $png) -or (Get-Item $png).Length -lt 1000) { throw "Diagram PNG was not produced." }
Write-Host ("  PNG: {0} ({1} KB)" -f $png, [int]((Get-Item $png).Length/1024))

# 3. Build .docx via Word COM. Content is in a sibling helper to keep
# this orchestrator short; helper writes title, sections, tables, image.
$helper = Join-Path $scriptDir 'build-mcounterpart-doc.content.ps1'
if (-not (Test-Path $helper)) { throw "content helper missing: $helper" }
. $helper
Write-MCounterPartDoc -OutPath $OutPath -DiagramPng $png

Write-Host "`nDone: $OutPath" -ForegroundColor Green
Get-Item $OutPath | Format-List Name, Length, LastWriteTime
