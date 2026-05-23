# build-mcounterpart-doc-v3.content.ps1 - dot-sourced by build-mcounterpart-doc-v3.ps1.
# Exposes Write-MCounterPartDocV3 which uses Word COM to render the v3 spec.
function Write-MCounterPartDocV3 {
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

        # Title page
        $s.Style = "Title"; $s.TypeText("MCounterPart"); $s.TypeParagraph()
        $s.Style = "Subtitle"; $s.TypeText("Paired human-agent collaboration with shared persistent brain, local-first inference, and pooled cloud-host escalation"); $s.TypeParagraph()
        P ("Architecture v3 - {0}" -f (Get-Date -Format yyyy-MM-dd))
        P "v3 changes vs v2: rename CHost (concept) -> ContextLocalAgent and CHosts/CloudModels -> CloudServerAgents. ContextLocalAgent is treated as a ROLE (any local agent that holds context); the Desktop is the PRIMARY ContextLocalAgent today because it also hosts CModel and all scheduled tasks; the Laptop is a second ContextLocalAgent that reaches CModel over Tailscale. Internal short IDs (env var AUGMENT_AGENT_HOST, queue file names, scheduled task names) stay 'chost' / 'laptop' - they are stable filesystem identifiers, not user-facing terms."
        $s.InsertNewPage()

        H1 "1. Executive summary"
        P "MCounterPart bonds each human architect to one dedicated Augment Agent. Pairs share one workspace, one memory, one rule set; coordination is through file-based inboxes and scheduled background work. The product scales by adding pairs, not by scaling a single agent. Cost is minimized via a 5-tier routing ladder: CModel (local) -> counterpart agent -> scheduled task -> clone-queue -> inline CloudServerAgent slot. The standing rule is: always pick the cheapest-token path, and continuously train local helpers on the Primary ContextLocalAgent (CModel, scheduled scripts, future MCP-Worker daemon) so they handle more work over time with less agent involvement."

        H1 "2. Glossary - naming conventions"
        P "Several short names are reused in the codebase and in chat. Two layers exist on purpose: user-facing names (ContextLocalAgent, CloudServerAgents, CModel) are stable concepts used in docs and conversation; internal short IDs (chost, laptop, K1, K2) are stable filesystem / env-var identifiers and never change. ContextLocalAgent is a ROLE not a machine: any local agent that holds context for its architect is one. The Desktop is the PRIMARY ContextLocalAgent today because it also hosts CModel and all scheduled tasks; the Laptop is a second ContextLocalAgent that reaches CModel over Tailscale."
        Tbl @(
            @("Term","Meaning"),
            @("MCounterPart","The product / architecture. 1 human + 1 dedicated agent = 1 pair; N pairs share one workspace, one memory, one rule set."),
            @("Pair","1 human architect + 1 dedicated Augment Agent on 1 host. Today: Jose + Primary ContextLocalAgent (Desktop) and Juan + ContextLocalAgent (Laptop)."),
            @("Architect","A human user of the workspace (Jose, Juan)."),
            @("ContextLocalAgent","A local-on-host Augment Agent that holds context for its architect and reads/writes the shared workspace. A ROLE, not a machine. Multiple ContextLocalAgents can exist (today: 2 - Desktop and Laptop)."),
            @("Primary ContextLocalAgent","The single ContextLocalAgent (today: Desktop) that also hosts CModel + all scheduled tasks. Other ContextLocalAgents reach CModel over Tailscale."),
            @("Counterpart agent","The OTHER pair's agent. Symmetric: for the Desktop ContextLocalAgent the counterpart is the Laptop ContextLocalAgent, and vice versa."),
            @("CModel","Context Model. The local model pair (writer + retriever) kept loaded in the Primary ContextLocalAgent's memory by Ollama. Config, prompts, and state synced via git + OneDrive (SharePoint). Free, slow, the first tier of the routing ladder."),
            @("CloudServerAgents","Cloud-hosted server-side model agents (airouter today). Multiple API keys, multiple slots per key; can be incremented at will by adding keys or swapping models per purpose. Acts as the agent's heavy-lift counterpart for work above the local ceiling. Replaces the older names CHosts / CloudModels."),
            @("Slot","One concurrent request capacity on a CloudServerAgents API key. Airouter today: 3 slots per key."),
            @("K1 / K2","The two airouter API keys (today). K1 = 3 slots, K2 = 3 slots. Total = 6 concurrent slots."),
            @("Subagent","A worker spawned BY a CloudServerAgent slot (typically via the clone-agent queue) to parallelize work for the main agent. Subagents are short-lived, single-purpose, and report results back through the inbox or queue files."),
            @("Bake-off","Scheduled weekly multi-model smoke test on slot 5, off-hours. Zero in-session token cost."),
            @("Hot path","Live conversation. Writes raw memory entries directly to disk. No model load."),
            @("Cold path","Nightly distill + embed pipeline (02:00). Uses CModel; never blocks the hot path."),
            @("Routing ladder R3","The 5-tier escalation rule in agent-operating-rules.md: 1.CModel -> 2.counterpart agent -> 3.scheduled task -> 4.clone-queue -> 5.inline CloudServerAgent slot."),
            @("Inbox notifier","Per-host scheduled task; pops a 15-sec Windows toast within 2 min of a new pending inbox item. Alert-only; never auto-executes."),
            @("Internal IDs","Short lowercase identifiers used in env vars, file paths, queue names, scheduled-task names: 'chost' (Primary ContextLocalAgent host), 'laptop' (Laptop ContextLocalAgent host), 'K1' / 'K2' (CloudServerAgents API keys). These never change.")
        )

        H1 "3. Architecture diagram"
        $s.InlineShapes.AddPicture($DiagramPng) | Out-Null
        $s.TypeParagraph()
        P "Notation: rounded blocks = ContextLocalAgents; oval-tagged tall blocks = humans (architects); cylinders = shared persistent state; rose blocks = CModel (local on the Primary ContextLocalAgent); purple blocks = CloudServerAgents slots (remote pool); sand blocks = subagents spawned by a CloudServerAgent slot; tan blocks = scheduled tasks; dashed arrows = optional / on-demand; solid arrows = always-on dependencies."

        H1 "4. The pair contract"
        P "A pair = 1 human + 1 dedicated agent on 1 host. Each pair owns one Augment subscription. Both pairs read the same AGENTS.md, agent-operating-rules.md, LESSONS.md, and SESSION_LOG.md. Counterpart-first delegation (R2) is symmetric: either agent forwards the user's request to the other before acting, and only takes over if the counterpart's stated understanding is wrong (training-by-correction)."

        H1 "5. Shared brain"
        P "Memory: .augment/memory/{raw,distilled,index}/YYYY-MM-DD.<architect>.jsonl. Append-only daily files per architect. The cold-path job (02:00 daily, CHost) summarizes raw to distilled and embeds for retrieval."
        P "Inbox queues: .augment/agent-tasks/inbox-{chost,laptop}.jsonl plus done.jsonl. Read by agent-task-list.ps1; mutated by agent-task-assign.ps1 and agent-task-complete.ps1."
        P "Awareness: inbox-notifier scheduled task pops a Windows toast within 2 minutes of any new pending inbox entry. Alert-only; never auto-executes."
        P "Sync: git is the source of truth (Tier 2); OneDrive / SharePoint mirrors the whole memory tree continuously (Tier 3) and is the channel by which the laptop reads CHost-written state without git-pulling on every change."

        H1 "6. CModel - Context Model (local on the Primary ContextLocalAgent)"
        P "Definition. CModel is the 'Context Model' - a local model pair kept loaded in the Primary ContextLocalAgent's memory by Ollama so it is always ready, with no cold-start cost. Its full configuration, prompt templates, and operational state live in the workspace and are synced through git and OneDrive/SharePoint, so any ContextLocalAgent reading the workspace can reproduce and call it identically."
        P "Composition. CModel-writer = qwen2.5-coder:7b-instruct-q4_K_M (generation). CModel-retriever = nomic-embed-text (embeddings). Served by Ollama at 127.0.0.1:11434 on the Primary ContextLocalAgent host; the Laptop ContextLocalAgent reaches the same endpoint via Tailscale at 100.83.6.49:11434."
        P "Operating discipline. OLLAMA_MAX_LOADED_MODELS=2, OLLAMA_NUM_PARALLEL=1, keep_alive=24h on every call. Batching is mandatory: run all writer calls together, then all retriever calls together, to avoid the ~10-15s evict-reload cost when switching members."
        P "Role in the ladder. CModel is tier 1. Anything the agent can plausibly delegate here goes here, even when it is slower than a CloudServerAgent slot. The fleet improves over time (better prompts, sharper decomposition, eventual fine-tunes) so the remote-call rate trends downward, not up."

        H1 "7. CloudServerAgents - cloud-hosted remote scalable pool"
        P "Definition. CloudServerAgents are the remote scalable model-backed agents the ContextLocalAgent escalates to. Today this is the airouter pool: 2 API keys, 3 concurrent slots per key, 6 slots total. The pool can be incremented at any time by adding keys, opening more slots, or swapping in new models per purpose. CloudServerAgents act as the heavy-lift counterpart - the place real reasoning, large refactors, and multi-file judgment calls go when CModel cannot do them."
        P "Subagent capability. A CloudServerAgent slot can act as an orchestrator that spawns subagents - short-lived single-purpose workers (today drained from the clone-agent queue) that fan out a unit of work in parallel and report results back through the shared workspace. Subagents are owned by the slot that spawned them and never persist context across runs."
        Tbl @(
            @("Slot","Key","Purpose","Caller","Today's model"),
            @("1","K1","Master reasoning (remote-master-call)","Either pair, in-session","Qwen3.6"),
            @("2","K1","Coding (refactors, multi-file edits)","Either pair, in-session","Qwen3.6"),
            @("3","K1","Clone-agent worker drain (subagent host)","Primary ContextLocalAgent background queue, every 10 min","Qwen3.6"),
            @("4","K2","Cold-path distill assist","Scheduled, 02:00 nightly","TBD (fast / cheap)"),
            @("5","K2","Weekly model bake-off","Scheduled, Sun 04:00","rotates per category"),
            @("6","K2","User on-demand","Either architect ad-hoc","whatever fits")
        )
        P "Per-purpose routing in airouter.config.json byPurpose block: reasoning, coding, fastCheap, longContext, multimodal. airouter-pick.ps1 -Purpose <name> resolves at call time. .current is the fallback."

        H1 "8. Subagents"
        P "A subagent is a worker spawned by a CloudServerAgent slot (or by a scheduled task draining the clone-queue into a slot) to parallelize a single unit of work for the main ContextLocalAgent. Subagents are short-lived, single-purpose, and report results back through the inbox queues or done.jsonl. They do not share context with the spawning agent across runs, which is by design - it keeps their cost bounded and their failure modes contained."
        P "Today's subagent host is slot 3 (clone-agent worker drain). The roadmap MCP-Worker daemon will expand the subagent pattern to Primary-ContextLocalAgent-local Python / PowerShell workers that pick up file-dropped jobs from a watched folder, costing zero agent tokens on re-runs."

        H1 "9. Weekly bake-off (zero in-session token cost)"
        P "Runs every Sunday 04:00 via the existing AugmentRemoteMasterReview scheduled task. Steps: (1) GET /models (free metadata). (2) For every model live on airouter, run one prompt per purpose category: reasoning (3-step logic), coding (small function with test), fastCheap (1-sentence classify), longContext (needle-in-haystack at 100k tokens, only if ctx >= 200k), multimodal (small image describe, only if image-input). (3) Score: ok, latency_ms, tokens, correctness_heuristic. (4) Append one JSON line per (model, purpose) to .remote-master-reviews.jsonl. (5) Print top-3 per category. (6) Never auto-switch byPurpose - the agent or human decides and records in SESSION_LOG.md."
        P "Runner = slot 5 on K2, off-hours. Per-week worst case ~25 calls at smokeMaxTokens=1024 = ~25 K output tokens / week on K2. Zero tokens on either agent's in-session budget."

        H1 "10. Token discipline and telemetry"
        P "Routing ladder R3 cheapest tier first: (1) CModel local, (2) Counterpart ContextLocalAgent, (3) Scheduled task, (4) Clone-queue, (5) Inline CloudServerAgent slot. Skip a tier only with a stated reason."
        P "Telemetry: .airouter-budget.jsonl (per remote-master-call cost log), .remote-master-reviews.jsonl (weekly bake-off), agent-spend-digest.ps1 planned (weekly per-pair per-tier summary)."
        P "Commander-in-chief rule: the agent measures its own in-session token cost on non-trivial responses and reports it inline so the human can see the spend in real time."

        H1 "11. Implementation status and roadmap"
        P "Done: counterpart-first review-loop, JSONL inboxes, toast notifier, CModel fleet on the Primary ContextLocalAgent, scheduled cold-path / clone-worker / auto-checkpoint, OneDrive + git two-tier persistence, session-briefing single-read, v1 + v2 architecture docs."
        P "Pending (gated on user confirmation): AIROUTER_API_KEY_2 env var; byPurpose block in airouter.config.json; airouter-pick.ps1 helper; multi-purpose bake-off extension of remote-master-review.ps1; agent-spend-digest.ps1 weekly digest; MCP-Worker daemon (Primary-ContextLocalAgent-local executor of file-dropped jobs - zero agent tokens on re-runs); rename Counterpart architecture section in AGENTS.md to MCounterPart architecture and align prose to ContextLocalAgent / CloudServerAgents terms."

        # 16 = wdFormatDocumentDefault (.docx)
        $d.SaveAs2($OutPath, 16)
        $d.Close()
    } finally {
        $w.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($w) | Out-Null
    }
}
