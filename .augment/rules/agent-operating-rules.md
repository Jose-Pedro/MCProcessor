# Agent Operating Rules

Compact, machine-checkable rules for both Augment Agent instances in
this workspace (CHost + laptop). They distill the longer narrative in
`AGENTS.md`. If a conflict appears, this file wins for the rule listed
here; `AGENTS.md` wins for everything not listed here.

Audience: both agents (CHost = José Pedro's, laptop = Juan's). Sync is
OneDrive + git; a single edit here applies to both machines after the
next `git pull` / OneDrive sync.

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

## R2. Delegation (counterpart-first by default)

1. Default response to any user task is to ask: "would the *other*
   agent do this better?" If yes per the routing matrix in `AGENTS.md`
   → `.\.augment\scripts\agent-task-assign.ps1 -To <other>`, then tell
   the user which id to ping on the other side.
2. CHost-local exceptions (do it yourself): touches Ollama / CModel /
   `register-*-task.ps1` / Tailscale / `AIROUTER_API_KEY` / paths only
   on CHost (`D:\Backups\…`), or the user explicitly says "you do it".
3. When you intervene to fix a counterpart's mistake, append a
   `LESSONS.md` entry with
   `.\.augment\scripts\agent-task-add-lesson.ps1 -Applies both`.
   Promote any lesson that would apply 3+ times into this rules file.

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
