# Agent Instructions

These instructions apply to every Augment Agent session opened in this workspace.
Read them in full at the start of every new session **before responding to the user**.

## Session log protocol

Two on-disk artifacts together form the agent's persistent memory:

- `.augment/SESSION_BOOTSTRAP.md` — auto-generated nightly by the cold-path
  pipeline. Pre-distilled, fixed-size "you are here" briefing built from the
  most recent SESSION_LOG entry + latest distilled facts + airouter spend +
  CModel fleet status. Cheap to read, always current as of last 02:00 run.
- `.augment/SESSION_LOG.md` — full append-only narrative checkpoint history,
  newest entry on top. Authoritative but unbounded in size.

1. **At session start: ONE command, ONE read.** Run
   `.\.augment\scripts\session-briefing.ps1`. It concatenates (no LLM
   call, ~10 KB total) the nightly bootstrap, last 14 days of
   `AGENT_INBOX.md`, top 5 `LESSONS.md` entries, and the live output of
   `agent-task-list.ps1 -Mine`. Read its output and only its output. Do
   **not** open the four source files individually — that was the old
   ritual and it spent ~4× the tokens for the same information.
   Then briefly acknowledge what you found (one or two lines, e.g.
   "Last session: built clone-agent v1. Inbox: 2 pending tasks for me.
   Lessons: 1 entry about PowerShell splat.").
   If the briefing reports the bootstrap is `STALE` (>48 h old), fall
   back to reading the top of `SESSION_LOG.md` directly and flag the
   staleness to the user.

2. **During the session:** do **not** update the log automatically. Only update
   it when the user explicitly says one of:
   - `checkpoint`
   - `save progress`
   - `update session log`
   - or any clear synonym (`log this`, `snapshot`, etc.)

3. **When asked to checkpoint:** prepend a new entry at the top of the
   `## Entries` section of `.augment/SESSION_LOG.md` using this exact template:

   ```
   ### YYYY-MM-DD HH:MM — <one-line title>
   - **Goal:** what the user was trying to accomplish
   - **Done:** concrete actions taken this checkpoint (commands run, files
     changed, decisions made)
   - **Files touched:** repo-relative paths, comma-separated
   - **State:** in-progress / blocked / complete
   - **Next step:** the very next action to take when work resumes
   - **Notes:** anything non-obvious a future session must know (gotchas,
     user preferences, things deliberately not done)
   ```

   Use the local date/time at the moment of the checkpoint. Keep each bullet
   to one or two lines. Do not rewrite or delete previous entries.

4. **Never** create additional log, summary, or documentation files
   beyond the canonical set: `SESSION_LOG.md`, `SESSION_BOOTSTRAP.md`
   (auto-generated, never hand-edit), `AGENT_INBOX.md` (cross-machine
   handoff), `agent-tasks/LESSONS.md` (corrective notes), and the
   `agent-tasks/inbox-*.jsonl` + `agent-tasks/done.jsonl` queue files
   (only via the `agent-task-*.ps1` scripts). Anything else is
   chat-ephemeral.

## Workspace conventions

- This repo holds many independent SAP/UI5/Node.js sub-projects grouped by
  three-letter module prefixes (`Acc/`, `Bim/`, `Cmm/`, `Fac/`, `Inv/`,
  `Mto/`, `Per/`, `Prv/`, `Rng/`, `Sit/`). Treat each subfolder as its own
  project.
- Folders suffixed with `-1`, `-2`, … are clone duplicates and should not
  exist; if you find any, surface them to the user before deleting.
- Folders suffixed with `-v2-`, `-v3-` etc. are intentional version
  branches — do **not** treat them as duplicates.

## Token discipline

This is a long-term, multi-session collaboration. Context tokens are the
single most expensive resource — treat them like budget, not like air.
The following rules apply to every Augment Agent session in this workspace.

1. **Narrow reads, never blanket reads.** When inspecting a file, use
   `view_range` or `search_query_regex` on the `view` tool. Do **not** open
   whole files >300 lines unless the user explicitly asks for it.

2. **Filter terminal output at the source.** When running shell commands,
   pipe through `Select-Object -First N`, `Select-String <pattern>`,
   `Measure-Object`, or `Format-Table -AutoSize` so that only the lines
   the next reasoning step actually needs reach the model. Never echo full
   `git log`, full `npm install` logs, full `ollama list` JSON, etc.
   If `rtk` is on PATH, prefer `rtk <command>` for known-noisy tools
   (`git status`, `cargo test`, `npm test`, `dotnet build`, etc.).

3. **Prefer `codebase-retrieval` over speculative file scans.** One
   targeted retrieval query is cheaper than reading five files to "look
   around." Speculative scans are forbidden.

4. **No proactive file creation.** Never create `.md` summaries, READMEs,
   notes files, or "design docs" unless the user explicitly asks. The
   single source of truth for cross-session knowledge is
   `.augment/SESSION_LOG.md` (and, once built, `.augment/memory/`).
   Everything else is chat-ephemeral.

5. **No unsolicited documentation in code.** Match the commenting density
   of the surrounding code. Do not add rationale comments explaining
   *why* a change was made — that belongs in chat or the session log.

6. **Replies stay concise by default.** Lead with the answer or the next
   decision. Use tables and short bullet lists. Skip restating what the
   user just said. Skip pleasantries. No "great question."

7. **Delegate before escalating — local first, correctness over speed.**
   This is a long-term, cost-bounded relationship; the agent budget
   ceiling is fixed and renews slowly. Optimize for being **right while
   spending nothing**, not for being fast. The escalation ladder, in
   strict order:
   1. **Local CModel** (Qwen2.5-coder writer + nomic-embed retriever
      on CHost, free, slow). Use for: classify, summarize, extract,
      embed, rerank, draft, small refactors, file digestion, JSON
      shape-fixing, label tagging, prompt rewriting.
   2. **Counterpart Augment agent** (laptop ↔ CHost via
      `agent-task-assign.ps1`). Free of *this* agent's budget; uses the
      other architect's subscription. Use for: multi-file code edits and
      judgment calls that are easier where the relevant files live.
   3. **Scheduled automation** (`AugmentCloneAgentWorker`,
      `AugmentColdPathDistill`, `AugmentRemoteMasterReview`). Anything
      that recurs on a known cadence must be a scheduled task, not an
      inline call — recurring work costs the agent zero context tokens.
   4. **Clone-agent queue → airouter** (`clone-agent-enqueue.ps1`).
      Drained every 10 min by the background worker. Use when the local
      CModel cannot do it but the answer can wait minutes.
   5. **Inline airouter call** (`remote-master-call.ps1`). The master
      tool. Costs real airouter quota and real wall-clock. Reserve for
      reasoning above the local ceiling that the agent needs in-turn.
   When uncertain about the local ceiling, the local model returns a
   structured failure report — never a guess.

8. **One distillation, then discard.** Long raw outputs (file contents,
   chat history, command transcripts) are summarized into facts the
   moment they enter context, and the raw form is not re-quoted in
   subsequent turns. Re-quoting raw output across turns is forbidden.

9. **Plan tool use in parallel.** When multiple reads/probes are
   independent, issue them in a single tool-use block instead of
   serially. Sequential round-trips multiply input-token cost.


## Counterpart architecture

This workspace is shared between two human architects and (over time) two
Augment Agent instances, one per architect. Treat it as a long-term
collaborative environment, not a single-user IDE session.

### Architects

- **Primary:** José Pedro Medeiros (`Jose-Pedro` on GitHub).
- **Second:** Juan (joining). Skeptical and a strong coder — every claim
  about local-model capability must be reproducible on his machine.

### Two agents, shared brain (Model A)

Each architect runs their own VS Code + own Augment subscription. The
shared persistent state lives in this repo on CHost (the always-on PC).

Physical topology:

- **José Pedro:** works directly on CHost (or tunnels in from elsewhere).
- **Juan:** works from his own Windows machine and tunnels into CHost via
  Microsoft Remote Tunnels (`code tunnel`, tunnel name `chost-juan`). He
  has full filesystem access through the tunnel — drag-and-drop, integrated
  terminal, git — and runs his own Augment session against the same on-disk
  repo. No local clone, no local Ollama, no airouter key on Juan's laptop.

Shared on-disk state in this repo:

- `.augment/SESSION_LOG.md` — narrative work journal (text, git-mergeable).
- `.augment/memory/raw/YYYY-MM-DD.<architect>.jsonl` — append-only raw
  entries written during the live conversation. One file per architect per
  day (e.g. `2026-05-22.zepedro.jsonl`, `2026-05-22.juan.jsonl`). Never
  edit past entries.
- `.augment/memory/distilled/YYYY-MM-DD.<architect>.jsonl` — structured
  facts produced by the nightly cold-path job (see below).
- `.augment/memory/index/YYYY-MM-DD.<architect>.vec.jsonl` — embeddings
  for retrieval, produced by the same nightly job.
- `.augment/config/` — non-secret routing config; secrets live only in
  environment variables (see "Remote execution engine" below).

Never use a shared binary database (SQLite, etc.) — git and OneDrive
cannot merge it cleanly between two machines.

Real-time collaboration: VS Code Live Share when needed. Otherwise sync
through `git pull` / `git push` and OneDrive's background sync.

### Local model fleet (CHost)

The always-on host **CHost** runs Ollama at `http://127.0.0.1:11434`.
CHost has integrated graphics only (Intel Iris Xe, ~1 GB shared VRAM); no
discrete GPU. All inference is CPU + shared memory.

**CModel** is the local model pair used by the agent for memory work:

| Member | Model | Role |
|---|---|---|
| CModel-writer | `qwen2.5-coder:7b-instruct-q4_K_M` | Generation: extraction, summarization, re-ranking |
| CModel-retriever | `nomic-embed-text:latest` | Embeddings for memory retrieval |

Other installed-but-not-pipeline models: `nemotron-3-nano:4b` (faster
alternative writer, A/B candidate), `acidtib/qwen2.5-coder-cline:7b`
(used only by the Cline extension, not by the agent).

Ollama is configured with `OLLAMA_MAX_LOADED_MODELS=2` and
`OLLAMA_NUM_PARALLEL=1` (User-scope env vars). Even so, CHost's memory
budget will not hold both CModel members simultaneously — loading nomic
evicts Qwen and vice-versa, with a ~10–15 s reload cost per switch.

**Batching discipline (mandatory):** never interleave writer and
retriever calls within a single task. Run all writer calls first
(Qwen hot, nomic absent), then all retriever calls (nomic hot, Qwen
absent). Two reloads per pipeline run, not one per chunk.

`keep_alive=24h` is set on every CModel call so the model that just ran
stays hot for the next batched call rather than unloading after the
default 5 minutes.

Token-discipline rule 7 governs routing: anything this fleet can plausibly
do stays local, even when slower. Continuously improve the local pipeline
(better prompts, sharper task decomposition, eventually fine-tuned variants)
so that the remote-call rate trends downward over time, not up.

### Memory write/read cycle (write-now, index-later)

Heavy local-model work happens off-hours; the live conversation never
waits on it.

**Hot path** (during conversation, no model load):
the agent appends raw entries directly to today's
`.augment/memory/raw/<date>.<architect>.jsonl`.

**Cold path** (scheduled, 02:00 local daily, wake-the-computer enabled):
1. Load CModel-writer (Qwen). Summarize / extract structured facts from
   the day's new raw entries → write to `distilled/`.
2. Unload Qwen, load CModel-retriever (nomic). Embed each distilled
   entry → write vectors to `index/`.
3. Refresh `.augment/memory/today.index.json` pointer.
4. `git commit` + `git push` (Tier 2 persistence).
5. Mirror `.augment/memory/**` to Seagate `D:\Backups\MCProcessor\`
   (Tier 3a). Drive is sometimes-plugged: when absent the step logs
   a skip and the next nightly run catches up.
6. Mirror `.augment/memory/**`, `.augment/SESSION_LOG.md`,
   `.augment/scripts/**`, `.augment/config/**`, and `AGENTS.md`
   to the Catel OneDrive folder
   (`%USERPROFILE%\OneDrive - Palácio dos Afetos lda\MCProcessor\`,
   tenant `0cca651b-b45a-4199-b7b2-bd44f771253f`). Tier 3c — primary
   multi-device mirror; reachable from any device signed into the
   Catel tenant (CHost + laptop today). Path auto-resolved from
   `HKCU:\Software\Microsoft\OneDrive\Accounts\Business*` at runtime.
7. Personal OneDrive sync (Tier 3b) runs on its own in the background
   and covers the entire workspace as a coarse fallback.

**Retrieval** (next session start): load nomic once, query vectors,
return top-K, load matching distilled entries, inject as context.

If a session crashes mid-day, raw entries are already on disk and the
next nightly run picks them up. No interactive work is ever blocked on
the cold path.

### Remote execution engine (airouter)

- **Provider:** airouter.ch via OpenAI-compatible `/v1` API.
- **Current model:** read from `.augment/config/airouter.config.json` →
  `.current` (bootstrap: `Qwen3.6`). The model id is **not** hard-coded
  in any script — change the config field and every caller follows.
- **Concurrency:** every airouter model accepts 3 parallel requests per key.
- **Auth:** API key in User-scope env var `AIROUTER_API_KEY`. Never put the
  key on a command line, in a file, in chat, or in a log.
- **Calling conventions:**
  - **Master tool** (preferred): `.\.augment\scripts\remote-master-call.ps1
    -Prompt "..." -MaxTokens 2048`. Always tagged `remote-master` in the
    budget log. Use this when the agent itself needs a remote brain.
  - **Raw / scripted:** `.\.augment\scripts\airouter-call.ps1
    -Prompt "..." -MaxTokens N -Tag "<purpose>"` (or `-Probe` for the
    cheapest auth check, `-ListModels` for the free catalog metadata).
- **Cost shape:** the current model is a heavy reasoning model — a 4-token
  answer typically burns 150–200 internal reasoning tokens and 10+ s
  wall-clock. Never route trivial questions remotely. Use `-MaxTokens` ≥ 1024
  when you do call it, otherwise the budget is spent on reasoning and
  `content` is empty.
- **Weekly model review (automated):** `remote-master-review.ps1` runs every
  Sunday 04:00 (scheduled task `AugmentRemoteMasterReview`). It fetches the
  live airouter catalog (free metadata), smoke-tests **only models not
  previously seen**, appends one JSON line to
  `.augment/.remote-master-reviews.jsonl`, and updates
  `airouter.config.json.weeklyReview.lastRun`. It **never auto-switches**
  the current model — the agent reads the log, decides, edits
  `.current`, and records the decision in `SESSION_LOG.md`.

### Agent task inbox (counterpart-first delegation)

Two Augment Agent instances run against this workspace: one on CHost
(`AUGMENT_AGENT_HOST=chost`), one on the laptop (`...=laptop`). They
collaborate through a file-based inbox under `.augment/agent-tasks/`.

**Default mode is counterpart-first.** Every user request follows the
review-loop in `.augment/rules/agent-operating-rules.md` §R2. The rule
is **symmetric** — when José types into the CHost session, the
counterpart is the laptop agent; when Juan types into the laptop
session, the counterpart is the CHost agent. Summary:

1. **Assign first.** Forward the user's request verbatim to the
   counterpart via `agent-task-assign.ps1 -To <other> -Title "..."
   -Prompt "..."`. Tell the user the task id and ask them to ping
   the other agent.
2. **Review the counterpart's plan or first response.** If it matches
   the request → reply `propagate` (let counterpart execute, do not
   redo their work). If it's wrong → step 3.
3. **Ask the counterpart for its stated understanding** before taking
   over: "In one paragraph, what do you understand the request to be?"
4. **Decide on the stated understanding.** Correct → propagate (gap
   was just in planning, counterpart will redo). Still wrong → only
   NOW take over, do it yourself end-to-end, and append a `LESSONS.md`
   entry with `agent-task-add-lesson.ps1 -Applies both` describing
   the specific misunderstanding and the correct interpretation.

**Skip the loop only for these CHost-local constraints:**

- Touches Ollama / CModel / `register-*-task.ps1` / Tailscale firewall.
- Needs the `AIROUTER_API_KEY` (only on CHost today).
- Needs files only in CHost-local paths (e.g. `D:\Backups\...`).
- Counterpart inbox already has high-priority pending work the user
  flagged as blocking.
- User explicitly says "you do it" / "don't delegate this one".

**When you intervene to fix a counterpart mistake**, append a lesson:

```
.\.augment\scripts\agent-task-add-lesson.ps1 `
    -Title "..." -Context "..." -Wrong "..." -Right "..." -Applies both
```

The lesson is read by both agents at session start, so the same
mistake should not recur. If the same lesson would apply 3+ times,
promote it into this `AGENTS.md` file as a workspace-wide rule.

**Routing matrix** for what goes where:

| Work type | Channel |
|---|---|
| Anything Claude could do himself but doesn't have to | **MimicClaude** (`mimic-claude-ask.ps1`) — see R11 |
| Multi-file code edits, design decisions, judgment calls (cross-machine) | Counterpart Augment agent (`agent-task-assign.ps1`) |
| Scriptable airouter calls (summarize, classify, draft) | Clone-agent queue (`clone-agent-enqueue.ps1`) |
| Embeddings, distillation, memory writes | CModel (cold-path only, never inline) |
| One-shot exploration with no reusable output AND R11 exception applies | Just do it inline |

### MimicClaude (Not so fast AI)

MimicClaude is the specific CloudAgent on airouter slot 1 (today: the
model in `airouter.config.json .current`) that Claude asks FIRST for
every non-trivial user request. He is given this `AGENTS.md` +
`agent-operating-rules.md` in his system prompt by
`.\.augment\scripts\mimic-claude-ask.ps1`, so his behavior matches
Claude's. His spend is tagged `mimic-claude` in `.airouter-budget.jsonl`.

The complete rules for when Claude bypasses MimicClaude (5 cases) and
the loop he runs when he doesn't bypass (3 steps) live in R11 of the
rules file. R11 composes with R2 — R2 governs cross-machine delegation
to the *other architect's* agent; R11 governs same-host delegation to
MimicClaude. Both must be honored before Claude acts directly.


