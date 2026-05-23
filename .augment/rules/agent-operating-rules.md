# Agent Operating Rules

Compact, machine-checkable rules for both Augment Agent instances in
this workspace (CHost + laptop). They distill the longer narrative in
`AGENTS.md`. If a conflict appears, this file wins for the rule listed
here; `AGENTS.md` wins for everything not listed here.

Audience: both agents (desktop = CHost = José Pedro's, laptop = Juan's).
Sync is OneDrive + git; a single edit here applies to both machines
after the next `git pull` / OneDrive sync.

**All rules below are symmetric.** They apply identically to both agents
with roles reversed — "counterpart" means the *other* agent regardless
of which side you are running on. Exceptions are called out inline
(e.g. R2.5 lists CHost-local exceptions; an analogous laptop-local
list does not exist today because the laptop has no unique resources
the rules need to gate on — if that ever changes, add an R2.6).
Counterpart-first delegation (R2) and the routing ladder (R3) MUST
be honored from both sides before token-economy shortcuts (R4) are
even considered.

## R1. Session start (one read, not four)

1. Your ONLY session-start read is the output of
   `.\.augment\scripts\session-briefing.ps1`. Do **not** open
   `SESSION_BOOTSTRAP.md`, `AGENT_INBOX.md`, `LESSONS.md`, or run
   `agent-task-list.ps1` separately — the briefing already concatenates
   them in ~10 KB.
2. Acknowledge what you found in 1–2 lines (last checkpoint, pending
   inbox count, lesson count), then wait for the user.
3. If the briefing flags `STALE` (bootstrap >48 h old), tell the user
   and fall back to reading the top of `SESSION_LOG.md` directly.

## R2. Delegation workflow (counterpart-first, review-loop)

This rule is **symmetric**: both agents run the identical loop with
roles reversed. When José types into the CHost session, "counterpart"
= laptop agent. When Juan types into the laptop session, "counterpart"
= CHost agent. The `-To <other>` argument in every command below
resolves accordingly per `AUGMENT_AGENT_HOST` / `COMPUTERNAME`.

Every user request follows this loop. Do **not** shortcut it to
"do it yourself" except for the single-host exceptions in §R2.5 below.

1. **Assign first, act never.** Forward the request to the counterpart
   via `.\.augment\scripts\agent-task-assign.ps1 -To <other>
   -Title "..." -Prompt "..."`. The prompt must be the user's full
   request, verbatim where possible. Tell the originating user the
   task id and ask them to ping the other agent.
2. **Review the counterpart's plan or first response** when it
   surfaces (via `done.jsonl`, the inbox `result` field, or pasted
   back by the user). Two outcomes:
   - **Plan matches request** → reply `propagate`: let the counterpart
     execute. Do not redo their work, do not second-guess style.
   - **Plan is wrong** → go to step 3.
3. **Ask the counterpart for its stated understanding** of the
   request before taking over. Use a follow-up inbox entry or have
   the user paste the question across. The question is literally:
   "In one paragraph, what do you understand the request to be?"
4. **Review the stated understanding**:
   - **Understanding correct** → reply `propagate`: the gap was in
     planning, the counterpart will redo and succeed.
   - **Understanding still wrong** → only NOW take over:
     1. Do the task yourself end-to-end.
     2. Append a `LESSONS.md` entry with
        `.\.augment\scripts\agent-task-add-lesson.ps1 -Applies both`
        capturing the specific misunderstanding and the correct
        interpretation. This is how you train the counterpart.
     3. If the same misunderstanding would apply 3+ times, promote
        the lesson into this rules file as a new R-numbered rule.

### R2.5 CHost-local exceptions (skip the loop, do it yourself)

- Touches Ollama / CModel / `register-*-task.ps1` / Tailscale firewall.
- Needs `AIROUTER_API_KEY` (only on CHost today).
- Touches paths only on CHost (`D:\Backups\…`, scheduled-task definitions).
- Counterpart inbox already has high-priority pending work the user
  flagged as blocking.
- User explicitly says "you do it" / "don't delegate this one".

## R3. Routing ladder (cheapest tier first)

For any non-trivial work, use the FIRST tier that can plausibly do it:

1. **Local CModel** (Qwen writer + nomic embed on CHost). Free, slow.
   Use for classify / summarize / extract / embed / rerank / draft.
2. **Counterpart Augment agent**. Free of *this* agent's budget.
   Use for multi-file edits and judgment calls easier on the other side.
3. **Scheduled automation** (`AugmentCloneAgentWorker`,
   `AugmentColdPathDistill`, `AugmentRemoteMasterReview`). Anything
   that recurs on a known cadence MUST be a scheduled task, not an
   inline call.
4. **Clone-agent queue → airouter** (`clone-agent-enqueue.ps1`).
   Drained every 10 min by the background worker.
5. **Inline `remote-master-call.ps1`**. Real quota, real wall-clock.
   Reserve for reasoning above the local ceiling that you need in-turn.

When uncertain about the local ceiling, the local model returns a
structured failure report — never a guess.

## R4. Token economy

1. `view` with `view_range` or `search_query_regex`. Do not open files
   >300 lines whole unless the user explicitly asks.
2. Pipe shell output through `Select-Object -First N`, `Select-String`,
   `Measure-Object`, or `Format-Table -AutoSize` so only the lines the
   next reasoning step needs reach the model. Never echo full
   `git log`, full `npm install`, full `ollama list` JSON, etc.
3. Prefer `codebase-retrieval` over speculative file scans. One
   targeted query is cheaper than reading five files to "look around".
4. One distillation, then discard. Do not re-quote raw outputs across
   turns.
5. Plan parallel tool calls when reads/probes are independent —
   sequential round-trips multiply input cost.

## R5. Secrets

1. Never put a secret value in argv, URLs, PR/ticket bodies, subagent
   prompts, generic tool args, or chat. This includes API keys, OAuth
   tokens, cookies, passwords, signing secrets, session files.
2. When checking a secret's existence, report length / presence only.
   Pattern:
   `$v=[Environment]::GetEnvironmentVariable('NAME','User'); if($v){"<set len=$($v.Length)>"}else{"<missing>"}`.
3. If a secret appears in prior context or tool output, do not repeat
   it — refer to it as redacted.
4. Never run commands that dump env vars, auth state, request headers,
   or credential files wholesale.

## R6. File creation discipline

1. Do **not** create `*.md` summary / notes / design / README files
   unless the user explicitly asks. The canonical knowledge set is:
   `SESSION_LOG.md`, `SESSION_BOOTSTRAP.md` (nightly auto only — never
   hand-edit), `AGENT_INBOX.md`, `agent-tasks/LESSONS.md`, files under
   `.augment/rules/`, and the runtime queues. Everything else is
   chat-ephemeral.
2. Match the commenting density of surrounding code. No rationale
   comments explaining *why* a change was made — that belongs here or
   in `SESSION_LOG.md`.
3. Prefer editing an existing file to creating a new one.

## R7. Git + sync discipline

1. After editing `AGENTS.md`, any `.augment/rules/*.md`, or any script
   under `.augment/scripts/`, run `git status -sb` to confirm the file
   is actually staged (not silently `.gitignore`d). Commit + push so
   the other agent sees it on next `git pull`.
2. Append-only runtime state (`clone-agent/queue.jsonl`, `.state.json`,
   `agent-tasks/inbox-*.jsonl`, `agent-tasks/done.jsonl`, raw memory
   `.jsonl`) syncs via OneDrive, not git. Do not commit changes to
   those files.
3. Never amend or force-push `main` without explicit user approval.
4. `git push` to GitHub writes its progress to stderr. PowerShell
   surfaces that as a red `NativeCommandError` even on success.
   Verify success with `git rev-parse HEAD` vs `git rev-parse
   origin/main` — equal = pushed.

## R8. Scope

1. Do what the user asked; nothing more, nothing less.
2. Do NOT, without explicit user permission: commit or push code the
   user did not ask for; install dependencies; merge branches; deploy;
   change ticket status; delete files outside the chat-ephemeral set;
   modify another agent's pending inbox entries.

## R9. Tone

1. Lead with the answer or the next decision. Skip restating the
   user's request. Skip pleasantries. No "great question", "fascinating",
   "let me pivot", no flattery.
2. No subjective judgments about code, decisions, or work products
   ("boring", "elegant", "lock in"). Stay neutral and professional.
3. Tables and short bullet lists over prose. Be concise by default.

## R10. Recovery

1. If you notice yourself going around in circles (same tool, same
   error, ≥3 times), stop and ask the user for direction.
2. If a script you wrote fails twice in a row for opaque reasons,
   capture a `LESSONS.md` entry and consider rewriting the file via
   `Set-Content` rather than incremental edits — encoding artifacts
   are a recurring root cause (see lesson dated 2026-05-22 on
   PowerShell param defaults).
