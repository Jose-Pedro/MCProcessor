# build-automation-plan-doc.content.ps1 - dot-sourced by
# build-automation-plan-doc.ps1. Exposes Write-AutomationPlanDoc.
function Write-AutomationPlanDoc {
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

        $s.Style = "Title";    $s.TypeText("Automation Plan");           $s.TypeParagraph()
        $s.Style = "Subtitle"; $s.TypeText("How Not so fast AI is implemented end-to-end in this workspace"); $s.TypeParagraph()
        P ("Companion to MCounterPart-Architecture-v4.docx - {0}" -f (Get-Date -Format yyyy-MM-dd))
        P "Goal of this document: capture every piece of automation that runs in this workspace (scheduled tasks, file-based queues, delegation loops) so that a new architect, the laptop agent, or MimicClaude can rebuild the orchestration from this single page. No automation lives only in someone's head."
        $s.InsertNewPage()

        H1 "1. Architecture diagram"
        $s.InlineShapes.AddPicture($DiagramPng) | Out-Null
        $s.TypeParagraph()
        P "Read the diagram top-to-bottom. The human asks Claude. Claude asks MimicClaude (R11). MimicClaude or Claude write into the file-based queues (inbox, clone-agent, memory/raw). The scheduled fleet, owned by LocalContextAgent on the Desktop, drains those queues off-hours and emits durable outputs (distilled memory, SESSION_LOG, airouter budget log). In-session token cost of anything in the bottom half of the diagram is zero."

        H1 "2. Mission and target metric"
        P "Mission. Make Claude's per-week token spend trend downward, not upward, even as the project grows. Every new piece of automation we add either (a) absorbs work that used to hit Claude or (b) lets MimicClaude / LocalContextAgent absorb more of it."
        P "Target metric. Weekly Claude-tier tokens, tracked via the airouter budget log (.augment/.airouter-budget.jsonl) and the MimicClaude tag share. The mimic-claude tag should grow as a fraction of total spend over time; the unspecified / coding tags should shrink."

        H1 "3. Routing ladder (R3 - cheapest tier first)"
        Tbl @(
            @("Tier","Tool / channel","Cost shape","Use when"),
            @("0. Human ask Claude directly","VS Code Augment Agent","Most expensive, in-session","Human types 'you do it', or R11 case 1 trigger"),
            @("1. MimicClaude","mimic-claude-ask.ps1","Free of Claude's budget, ~3 K system + ~1-5 s wall-clock","DEFAULT for every non-trivial request (R11)"),
            @("2. LocalContextAgent + LocalContextModel","airouter NOT used; Ollama on Desktop","Free, slow (10-15 s reload)","Classify / summarize / extract / embed / draft, where the answer can wait"),
            @("3. Scheduled task","AugmentColdPathDistill / AugmentCloneAgentWorker / etc","Free, off-hours","ANY work that recurs on a known cadence (must NOT be inline)"),
            @("4. Clone-agent queue","clone-agent-enqueue.ps1 -> AugmentCloneAgentWorker every 10 min","Real airouter quota, deferred","Scriptable airouter work that can wait minutes"),
            @("5. Inline remote-master-call","remote-master-call.ps1","Real airouter quota, in-turn","Reasoning above MimicClaude ceiling that Claude needs in-turn")
        )
        P "Rule: never reach for tier N+1 until tier N has been ruled out with a concrete reason. R11 (Not so fast AI) covers tier 0 vs 1. R3 covers the rest."

        H1 "4. Scheduled task fleet (already running on Desktop)"
        Tbl @(
            @("Task name","Cadence","Script","Purpose","Output"),
            @("AugmentColdPathDistill","Daily 02:00","cold-path-distill.ps1","Load CModel-writer (Qwen), distill the day's raw memory entries into structured facts; unload, load CModel-retriever (nomic), embed; commit + push; mirror to Seagate + Catel OneDrive","memory/distilled/*.jsonl, memory/index/*.vec.jsonl, today.index.json, SESSION_BOOTSTRAP refresh"),
            @("AugmentAutoCheckpoint","Every 30 min","auto-checkpoint.ps1","Sample git log + done.jsonl + inbox + memory/raw for the last window; prepend a synthetic entry to SESSION_LOG.md so a crashed session never loses progress","SESSION_LOG.md auto entry"),
            @("AugmentInboxNotifier","Every 5 min","inbox-notifier.ps1","Diff inbox-<self>.jsonl against last-seen state; pop a Windows toast for any new pending task assigned to this host","Action Center toast"),
            @("AugmentCloneAgentWorker","Every 10 min","clone-agent-worker.ps1","Drain .augment/clone-agent/queue.jsonl; each entry becomes one airouter call tagged 'clone-agent:<purpose>'; writes result back into the queue state","clone-agent state.json + airouter budget entries"),
            @("AugmentRemoteMasterReview","Sunday 04:00","remote-master-review.ps1","Fetch live airouter catalog; smoke-test only models not previously seen; append one JSON line per new model; update weeklyReview.lastRun. NEVER auto-switches the current model","airouter.config.json .weeklyReview.lastRun, .remote-master-reviews.jsonl")
        )
        P "All five tasks are registered via register-*-task.ps1 sibling scripts. They run under the logged-in user, wake-the-computer enabled where relevant (cold-path)."

        H1 "5. Hot path vs cold path"
        Tbl @(
            @("Path","When","Who","Cost"),
            @("Hot path","During live conversation","Claude or MimicClaude appends to memory/raw/<date>.<architect>.jsonl directly (no model load)","Tokens-of-the-tier that wrote the entry; ~0 disk"),
            @("Cold path","02:00 daily, off-hours","AugmentColdPathDistill loads LocalContextModel, distills + embeds yesterday's raw entries","Zero in-session tokens; ~5 min wall-clock CPU on Desktop")
        )
        P "Crash safety: a session that dies mid-day loses no memory because hot-path writes are already on disk. The next nightly cold-path run picks them up."

        H1 "6. Delegation automation"
        H2 "6.1 Counterpart-first (R2) - cross-machine"
        P "When Claude or MimicClaude detect that work belongs on the OTHER architect's host (multi-file edits where the files live, judgment calls easier there), they call agent-task-assign.ps1 -To <other>. The task lands in inbox-<other>.jsonl. AugmentInboxNotifier on the receiving host pops a toast; the receiving architect nudges their Augment session to read the task via agent-task-list.ps1 -Mine. Completion is recorded in done.jsonl (append-only, OneDrive-synced, never committed to git)."
        H2 "6.2 Not so fast AI (R11) - same host"
        P "Claude's first move for every non-trivial request is mimic-claude-ask.ps1 -Prompt '<verbatim user request>'. The wrapper injects the operating rules (and optionally AGENTS.md) into MimicClaude's system prompt so MimicClaude behaves the way Claude would. Claude reviews the output; if executable, propagates and runs any shell commands; if wrong, asks MimicClaude for stated understanding (R2-style) and only then takes over."
        H2 "6.3 Latency visibility"
        P "mimic-claude-ask.ps1 spawns a background Start-Job that fires a Windows toast if MimicClaude is still thinking after -ToastAfterSec (default 30 s). The job is killed cleanly when the foreground call returns. Pass -NoToast to suppress (e.g. in scripted batch use)."

        H1 "7. What is still manual"
        Tbl @(
            @("Pain point","Why still manual","Smallest next automation"),
            @("Laptop-side smoke tests","No SSH tunnel back to Desktop terminal; requires laptop architect","Tunnel cmd outputs to a shared verify-*.txt that Desktop polls"),
            @("Model swap decisions","Weekly review file is informational; humans must edit .current","Auto-PR opener that proposes the swap with the review snippet"),
            @("MimicClaude rule-set drift","Charter is concatenated at call time; no version pinning","Hash + log the system-prompt size per call in the budget tag"),
            @("Cross-architect lesson promotion","'If repeated 3+ times, promote to AGENTS.md' is honor-system","Count lesson reapplication in the cold path; flag candidates")
        )

        H1 "8. Operational playbook (failure modes)"
        Tbl @(
            @("Symptom","Most likely cause","Fix"),
            @("airouter 400 'Invalid model name passed in model=None'","PS 5.1 mangling UTF-8 in Invoke-RestMethod body","Use airouter-call.ps1 (already patched); for new wrappers, send body as UTF-8 bytes - see LESSONS.md"),
            @("Bootstrap shows STALE > 48 h","AugmentColdPathDistill did not run (Desktop off, Ollama down, or task disabled)","Manually run .\.augment\scripts\cold-path-distill.ps1, then check Get-ScheduledTask AugmentColdPathDistill"),
            @("Inbox task never picked up","AugmentInboxNotifier disabled OR receiving architect never opened their VS Code","Verify task in Task Scheduler; ping the architect; agent-task-list.ps1 -Mine"),
            @("Budget log shows mimic-claude spend dropping over time","Claude is bypassing R11 too often","Audit recent session-briefing outputs; tighten R11 case 4 (trivially short threshold)"),
            @("Toast never fires","Notification policy off OR background job blocked","Test inbox-notifier.ps1 -Force; check Windows Focus Assist; verify Start-Job permissions")
        )

        $d.SaveAs([ref]$OutPath, [ref]16)
        $d.Close()
    } finally {
        $w.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($w) | Out-Null
    }
}
