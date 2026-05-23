# build-mcounterpart-doc.content.ps1 - dot-sourced by build-mcounterpart-doc.ps1.
# Exposes Write-MCounterPartDoc which uses Word COM to render the spec.
function Write-MCounterPartDoc {
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
            $s.EndKey(6) | Out-Null  # 6 = wdStory
            $s.TypeParagraph()
        }

        # Title page
        $s.Style = "Title"; $s.TypeText("MCounterPart"); $s.TypeParagraph()
        $s.Style = "Subtitle"; $s.TypeText("Paired human-agent collaboration with shared persistent brain, local-first inference, and pooled remote escalation"); $s.TypeParagraph()
        P ("Architecture v1 - {0}" -f (Get-Date -Format yyyy-MM-dd))
        $s.InsertNewPage()

        H1 "1. Executive summary"
        P "MCounterPart bonds each human architect to one dedicated Augment Agent. Pairs share one workspace, one memory, one rule set; coordination is through file-based inboxes and scheduled background work. The product scales by adding pairs, not by scaling a single agent. Cost is minimized via a 5-tier routing ladder: local CModel, counterpart agent, scheduled task, clone-queue, inline airouter. The standing rule is: always pick the path with the lowest token cost, and continuously train CHost-local helpers (CModel, scheduled scripts, future MCP-Worker daemon) so they handle more work over time with less agent involvement."

        H1 "2. Architecture diagram"
        $s.InlineShapes.AddPicture($DiagramPng) | Out-Null
        $s.TypeParagraph()

        H1 "3. Entities and layers"
        Tbl @(
            @("Layer","Entity","Location","Cost model"),
            @("Pair","1 human + 1 Augment Agent","Per-architect VS Code + Augment subscription","1 subscription per human"),
            @("Team","N pairs sharing 1 workspace","Repo via git + OneDrive","-"),
            @("Local fleet","CModel-writer + CModel-retriever","CHost (always-on)","Free, slow"),
            @("Remote fleet","Airouter pool (2 keys x 3 slots = 6)","Provider","Per-key quota"),
            @("Memory","raw / distilled / index JSONL","Workspace, git-tracked","-"),
            @("Coordination","inbox-*.jsonl + done.jsonl","Workspace, OneDrive","-"),
            @("Awareness","inbox-notifier toast","Per-host scheduled task","Free")
        )

        H1 "4. The pair contract"
        P "A pair = 1 human + 1 dedicated agent on 1 host. Today: Jose + CHost-agent, Juan + Laptop-agent. Each pair owns one Augment subscription. Both pairs read the same AGENTS.md, agent-operating-rules.md, LESSONS.md, and SESSION_LOG.md. Counterpart-first delegation (R2) is symmetric: either agent forwards the user's request to the other before acting. Important terminology: a CHost agent's counterpart is the laptop agent (different host, different human, different subscription). There is no second Augment Agent running on the same host."

        H1 "5. Shared brain"
        P "Memory: .augment/memory/{raw,distilled,index}/YYYY-MM-DD.<architect>.jsonl. Append-only daily files per architect. The cold-path job (02:00 daily, CHost) summarizes raw to distilled and embeds for retrieval."
        P "Inbox queues: .augment/agent-tasks/inbox-{chost,laptop}.jsonl plus done.jsonl. Read by agent-task-list.ps1; mutated by agent-task-assign.ps1 and agent-task-complete.ps1."
        P "Awareness: inbox-notifier scheduled task pops a 15-second Windows toast within 2 minutes of any new pending inbox entry. Alert-only; never auto-executes."

        H1 "6. Local fleet on CHost"
        P "CModel-writer = qwen2.5-coder:7b-instruct-q4_K_M for generation. CModel-retriever = nomic-embed-text for embeddings. Served by Ollama at 127.0.0.1:11434 on CHost; laptop reaches them via Tailscale at 100.83.6.49:11434. OLLAMA_MAX_LOADED_MODELS=2, OLLAMA_NUM_PARALLEL=1. Batching discipline: all writer calls first, then all retriever calls, to avoid model evict-reload thrash (10 to 15 seconds per swap). keep_alive=24h on every call."

        H1 "7. Remote fleet - airouter slot allocation"
        P "Two keys, 3 concurrent calls per key, 6 total slots."
        Tbl @(
            @("Slot","Key","Purpose","Caller","Today's model"),
            @("1","K1","Master reasoning (remote-master-call)","Either pair, in-session","Qwen3.6"),
            @("2","K1","Coding (refactors, multi-file edits)","Either pair, in-session","Qwen3.6"),
            @("3","K1","Clone-agent worker drain","CHost background queue, every 10 min","Qwen3.6"),
            @("4","K2","Cold-path distill assist","Scheduled, 02:00 nightly","TBD (fast / cheap)"),
            @("5","K2","Weekly model bake-off","Scheduled, Sun 04:00","rotates per category"),
            @("6","K2","User on-demand","Either architect ad-hoc","whatever fits")
        )
        P "Per-purpose routing in airouter.config.json byPurpose block: reasoning, coding, fastCheap, longContext, multimodal. airouter-pick.ps1 -Purpose <name> resolves at call time. .current is the fallback."

        H1 "8. Weekly bake-off (zero in-session token cost)"
        P "Runs every Sunday 04:00 via the existing AugmentRemoteMasterReview scheduled task. Steps: (1) GET /models (free metadata). (2) For every model live on airouter, run one prompt per purpose category: reasoning (3-step logic), coding (small function with test), fastCheap (1-sentence classify), longContext (needle-in-haystack at 100k tokens, only if ctx >= 200k), multimodal (small image describe, only if image-input). (3) Score: ok, latency_ms, tokens, correctness_heuristic. (4) Append one JSON line per (model, purpose) to .remote-master-reviews.jsonl. (5) Print top-3 per category. (6) Never auto-switch byPurpose - the agent or human decides and records in SESSION_LOG.md."
        P "Runner = slot 5 on K2, off-hours. Per-week worst case ~25 calls at smokeMaxTokens=1024 = ~25 K output tokens / week on K2. Zero tokens on either agent's in-session budget."

        H1 "9. Token discipline and telemetry"
        P "Routing ladder R3 cheapest tier first: (1) Local CModel, (2) Counterpart agent, (3) Scheduled task, (4) Clone-queue, (5) Inline airouter. Skip a tier only with a stated reason."
        P "Telemetry: .airouter-budget.jsonl (per remote-master-call cost log), .remote-master-reviews.jsonl (weekly bake-off), agent-spend-digest.ps1 planned (weekly per-pair per-tier summary)."
        P "Commander-in-chief rule: the agent measures its own in-session token cost on non-trivial responses and reports it inline."

        H1 "10. Implementation status and roadmap"
        P "Done: counterpart-first review-loop, JSONL inboxes, toast notifier, local CModel fleet, scheduled cold-path / clone-worker / auto-checkpoint, OneDrive + git two-tier persistence, session-briefing single-read."
        P "Pending (gated on user confirmation): AIROUTER_API_KEY_2 env var; byPurpose block in airouter.config.json; airouter-pick.ps1 helper; multi-purpose bake-off extension of remote-master-review.ps1; agent-spend-digest.ps1 weekly digest; MCP-Worker daemon (CHost-local executor of file-dropped jobs, zero agent tokens on re-runs); rename Counterpart architecture section in AGENTS.md to MCounterPart architecture."

        # 16 = wdFormatDocumentDefault (.docx)
        $d.SaveAs2($OutPath, 16)
        $d.Close()
    } finally {
        $w.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($w) | Out-Null
    }
}
