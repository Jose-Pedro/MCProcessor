# build-mcounterpart-doc-v4.content.ps1 - dot-sourced by build-mcounterpart-doc-v4.ps1.
# Exposes Write-MCounterPartDocV4 (Word COM rendering of the v4 spec).
function Write-MCounterPartDocV4 {
    param([Parameter(Mandatory)][string]$OutPath, [Parameter(Mandatory)][string]$DiagramPng)
    $w = New-Object -ComObject Word.Application
    $w.Visible = $false
    try {
        $d = $w.Documents.Add()
        $s = $w.Selection
        function H1 { param($t) $s.Style = "Heading 1"; $s.TypeText($t); $s.TypeParagraph() }
        function H2 { param($t) $s.Style = "Heading 2"; $s.TypeText($t); $s.TypeParagraph() }
        function P  { param($t) $s.Style = "Normal";    $s.TypeText($t); $s.TypeParagraph() }
        function Tbl {
            param([object[][]]$Rows)
            $rc = $Rows.Count; $cc = $Rows[0].Count
            $t = $d.Tables.Add($s.Range, $rc, $cc)
            $t.Borders.Enable = $true
            for ($r=0; $r -lt $rc; $r++) { for ($c=0; $c -lt $cc; $c++) { $t.Cell($r+1,$c+1).Range.Text = [string]$Rows[$r][$c] } }
            $s.EndKey(6) | Out-Null
            $s.TypeParagraph()
        }

        $s.Style = "Title"; $s.TypeText("MCounterPart"); $s.TypeParagraph()
        $s.Style = "Subtitle"; $s.TypeText("Not so fast AI - reduce Claude's tokens by inserting cheaper agents in front of him"); $s.TypeParagraph()
        P ("Architecture v4 - {0}" -f (Get-Date -Format yyyy-MM-dd))
        P "v4 changes vs v3: (a) rename ContextLocalAgent -> LocalContextAgent and CModel -> LocalContextModel (the model that the LocalContextAgent uses); (b) rename CloudServerAgents -> CloudAgents and introduce CloudModels as a distinct concept (CloudAgents are AGENT IDENTITIES instantiated from CloudModels); (c) introduce MimicClaude - a specific CloudAgent that mimics Claude and that Claude ASKS FIRST for everything; (d) formalize the principle Not so fast AI: Claude is the most expensive tier and acts directly only when the human asks directly, otherwise delegates."
        $s.InsertNewPage()

        H1 "1. Mission and principle"
        P "Mission. Build Claude's counterpart and any other agent needed to run our work, so that Claude (the expensive top-tier Augment Agent) spends progressively fewer tokens over time. Trainings, learnings, history, and the shared rule set live in the workspace and are owned by LocalContextAgent on the Desktop."
        P "Principle - Not so fast AI. Slow Claude down on purpose. Insert cheaper agents (LocalContextAgent, MimicClaude, scheduled tasks, clone-queue, other CloudAgents) between the human and Claude so that Claude only runs when the human asks him directly or when MimicClaude reports a real ceiling. The cost curve trends downward as the lower tiers absorb more of the work."

        H1 "2. Glossary - naming conventions"
        P "Two layers exist on purpose. User-facing names (Claude, MimicClaude, LocalContextAgent, LocalContextModel, CloudAgents, CloudModels) are stable concepts used in docs and conversation. Internal short IDs (chost, laptop, K1, K2) are stable filesystem / env-var identifiers and never change - renaming them would break scripts, scheduled tasks, queue files, and done.jsonl history."
        Tbl @(
            @("Term","Meaning"),
            @("Claude","The Augment Agent - the top-tier model the humans talk to in VS Code. The most expensive tier. Acts directly ONLY when the human asks directly; otherwise asks MimicClaude first."),
            @("MimicClaude","A specific CloudAgent (today: airouter Qwen3.6) that mimics Claude and follows the SAME rule set. Claude asks MimicClaude first for any non-trivial work. MimicClaude can in turn delegate to LocalContextAgent or spawn subagents."),
            @("LocalContextModel","The local model fleet kept loaded in the Desktop's memory by Ollama: qwen2.5-coder:7b-instruct-q4_K_M (writer) + nomic-embed-text (retriever). Free, slow, always-ready."),
            @("LocalContextAgent","The agent IDENTITY that uses LocalContextModel. Owns the workspace memory tree, runs scheduled tasks (cold-path, clone-worker, bake-off, notifier, auto-checkpoint), and saves trainings/learnings/history. Internal id: 'chost'. A second LocalContextAgent lives on the Laptop (internal id: 'laptop') and reaches the Desktop's LocalContextModel over Tailscale."),
            @("CloudModels","The actual models hosted by airouter (today: Qwen3.6 plus whatever the weekly bake-off identifies for fastCheap / longContext / multimodal). New CloudModels can be added at any time."),
            @("CloudAgents","Agent IDENTITIES instantiated from CloudModels via airouter. Each slot (concurrent request capacity) on an API key is one CloudAgent. Today: 2 keys x 3 slots = 6 CloudAgents. MimicClaude occupies slot 1."),
            @("Pair","1 human architect + 1 dedicated communication endpoint (a VS Code session). Today: Jose has 2 endpoints (Desktop + his laptop), Juan has 1 (his laptop). All endpoints talk to the same Claude."),
            @("Subagent","Short-lived single-purpose worker spawned by a CloudAgent (typically via the clone-agent queue) to fan out a unit of work. Reports back through the inbox / done.jsonl."),
            @("Routing ladder R3 (v4)","1. Claude (only when asked directly). 2. MimicClaude (first delegation). 3. LocalContextAgent (free local). 4. Scheduled task / clone-queue (zero in-session cost). 5. Other CloudAgents (above MimicClaude's ceiling)."),
            @("Not so fast AI","The architectural principle: insert cheaper agents in front of Claude so Claude's token use trends downward over time."),
            @("Bake-off","Scheduled weekly multi-model smoke test on slot 5, off-hours. Zero in-session token cost."),
            @("Hot path","Live conversation. Writes raw memory entries to disk. No model load."),
            @("Cold path","Nightly distill + embed pipeline (02:00 daily). Uses LocalContextModel via LocalContextAgent."),
            @("Internal IDs","Short lowercase identifiers used in env vars, file paths, queue names, scheduled-task names: 'chost' (Desktop LocalContextAgent), 'laptop' (Laptop LocalContextAgent), 'K1' / 'K2' (airouter API keys). Stable - never renamed.")
        )

        H1 "3. Architecture diagram"
        $s.InlineShapes.AddPicture($DiagramPng) | Out-Null
        $s.TypeParagraph()
        P "Notation: green outlined block = Claude (top tier); tan blocks = humans; light blue = VS Code endpoints and LocalContextAgent; rose = LocalContextModel; sand = CloudModels; purple = CloudAgents (MimicClaude darker); cream = subagents / scheduled tasks; cylinders = shared persistent state. Bold double-line arrow = mandatory ask. Dashed arrows = optional / on-demand."

        H1 "4. Communication topology"
        P "Humans never talk to MimicClaude, LocalContextAgent, or any CloudAgent directly. They talk to Claude through a VS Code session on one of three endpoints: Desktop, Jose laptop, or Juan laptop. All three endpoints route into the same Claude. Claude is then responsible for delegating downward."
        P "Pair model. Jose has two endpoints (Desktop + his laptop) but one pair contract; Juan has one endpoint (his laptop). Adding more humans or endpoints does not multiply Claude - it multiplies the inbox queue and the demand for delegation."

        H1 "5. Shared brain"
        P "Memory: .augment/memory/{raw,distilled,index}/YYYY-MM-DD.<architect>.jsonl. Append-only daily files per architect. Owned and maintained by LocalContextAgent on the Desktop."
        P "Inbox queues: .augment/agent-tasks/inbox-{chost,laptop}.jsonl plus done.jsonl. Read by agent-task-list.ps1; mutated by agent-task-assign.ps1 / agent-task-complete.ps1. Used for cross-endpoint and cross-agent coordination."
        P "Rules + LESSONS: AGENTS.md, .augment/rules/agent-operating-rules.md, .augment/agent-tasks/LESSONS.md. Loaded at every Claude session start. The same rule set governs MimicClaude (he is told to follow it explicitly in his system prompt)."
        P "Sync: git is the source of truth (Tier 2); OneDrive / SharePoint mirrors the whole tree continuously (Tier 3) so the Laptop LocalContextAgent sees Desktop-written state without a git pull on every change."

        H1 "6. LocalContextModel and LocalContextAgent (Desktop)"
        P "Definition. LocalContextModel is the local model fleet kept loaded in Desktop memory by Ollama and always ready. Composition: writer = qwen2.5-coder:7b-instruct-q4_K_M; retriever = nomic-embed-text. Served at 127.0.0.1:11434 on the Desktop; the Laptop reaches the same endpoint via Tailscale at 100.83.6.49:11434."
        P "LocalContextAgent is the AGENT IDENTITY that uses LocalContextModel. It owns the memory tree, runs every scheduled task (cold-path distill at 02:00, clone-agent worker every 10 min, weekly bake-off Sundays 04:00, inbox-notifier every 2 min, auto-checkpoint every 30 min), and is the keeper of trainings, learnings, and history for the whole mission. Internal id: chost. A second LocalContextAgent lives on the Laptop (internal id: laptop) for parity and reaches the Desktop's LocalContextModel over Tailscale."
        P "Operating discipline. OLLAMA_MAX_LOADED_MODELS=2, OLLAMA_NUM_PARALLEL=1, keep_alive=24h. Batching is mandatory: all writer calls together, then all retriever calls together, to avoid the ~10-15s evict-reload cost when switching members."
        P "Role in the ladder. LocalContextAgent is tier 3. MimicClaude and Claude both DELEGATE TO it whenever the work is summary / extract / classify / embed / draft / small refactor / lesson digestion."

        H1 "7. CloudModels and CloudAgents (airouter)"
        P "CloudModels are the actual model checkpoints hosted by airouter (today: Qwen3.6 plus whatever the weekly bake-off promotes for fastCheap / longContext / multimodal). New CloudModels can be added at any time by adding API keys or by swapping the byPurpose entries in airouter.config.json."
        P "CloudAgents are the AGENT IDENTITIES instantiated from those CloudModels. Each concurrent slot on an API key is one CloudAgent. Today: 2 keys x 3 slots = 6 CloudAgents. Each CloudAgent has a stable purpose and is invoked from a stable caller."
        Tbl @(
            @("Slot","Key","CloudAgent","Caller","Backing CloudModel"),
            @("1","K1","MimicClaude (master)","Claude in-session - asked FIRST","Qwen3.6"),
            @("2","K1","Coding CloudAgent","Claude / MimicClaude in-session","Qwen3.6"),
            @("3","K1","Clone-agent drain (subagent host)","Desktop background queue, every 10 min","Qwen3.6"),
            @("4","K2","Cold-path assist CloudAgent","Scheduled, 02:00 nightly","TBD fast/cheap"),
            @("5","K2","Bake-off CloudAgent","Scheduled, Sun 04:00","rotates per category"),
            @("6","K2","On-demand CloudAgent","Either architect ad-hoc","whatever fits")
        )

        H1 "8. MimicClaude - Claude's main counterpart"
        P "MimicClaude is the single CloudAgent that Claude asks BEFORE doing any non-trivial work himself. He runs on slot 1 (K1, Qwen3.6 today). He is given the SAME rule set as Claude (AGENTS.md + agent-operating-rules.md) in his system prompt so his behavior matches: counterpart-first delegation, token discipline, no unsolicited file creation, etc."
        P "How Claude uses him. For every non-trivial human request: (1) Claude forwards the request verbatim to MimicClaude with the question stated understanding; (2) Claude reviews MimicClaude's plan; (3) if the plan is right -> Claude lets MimicClaude execute (typically via the clone-agent queue or via inline remote-master-call.ps1); (4) if the plan is wrong -> Claude asks for stated understanding; (5) only if understanding is still wrong does Claude take over himself, do the work, and append a LESSONS.md entry so MimicClaude does not repeat the mistake."
        P "Subagents. MimicClaude can spawn subagents (short-lived workers drained from the clone-agent queue) to parallelize work. Subagents do not share context across runs - by design, to bound cost and contain failure."

        H1 "9. Token discipline and telemetry"
        P "Routing ladder R3 (v4 ordering, cheapest tier first for Claude's POV): (1) Claude only when the human asks directly. (2) MimicClaude first. (3) LocalContextAgent for trivia, summarize, classify, embed, draft. (4) Scheduled task / clone-queue for recurring or batchable work (zero in-session cost). (5) Other CloudAgents above MimicClaude's ceiling."
        P "Telemetry: .airouter-budget.jsonl (per remote-master-call cost log), .remote-master-reviews.jsonl (weekly bake-off), agent-spend-digest.ps1 planned (weekly per-agent per-tier summary). Commander-in-chief rule: Claude measures his own in-session token cost on non-trivial responses and reports it inline so the human sees the spend in real time."

        H1 "10. Implementation status and roadmap"
        P "Done: counterpart-first review-loop, JSONL inboxes, toast notifier, LocalContextModel fleet on the Desktop, scheduled cold-path / clone-worker / auto-checkpoint, OneDrive + git two-tier persistence, session-briefing single-read, architecture docs v1 / v2 / v3."
        P "Pending (gated on user confirmation): wire MimicClaude as the explicit slot-1 CloudAgent with Claude's rule set in its system prompt; add a Claude-only rule 'act directly only when the human asks directly' to agent-operating-rules.md (R8 amendment); AIROUTER_API_KEY_2; byPurpose block in airouter.config.json; airouter-pick.ps1 helper; multi-purpose bake-off extension; agent-spend-digest.ps1; MCP-Worker daemon (Desktop-local executor of file-dropped jobs); rename existing R2 Counterpart references to align with the v4 naming."

        $d.SaveAs2($OutPath, 16)
        $d.Close()
    } finally {
        $w.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($w) | Out-Null
    }
}
