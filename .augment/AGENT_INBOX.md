# AGENT_INBOX

Cross-machine handoff file. Both architects and both Augment Agent
instances should read this **after** `SESSION_BOOTSTRAP.md` (which is
nightly-only and may lag) to pick up same-day changes another session
has made. Append-only; oldest entry on bottom. Trim entries older than
14 days during checkpoints if size grows.

---

## 2026-05-22 18:05 — agent-task inbox is live (from CHost session)

**For: laptop session.** New default operating mode for both Augment
instances. Read the new "Agent task inbox" section at the bottom of
`AGENTS.md` and the updated session-start protocol at the top.

TL;DR:
- Both agents now read `AGENT_INBOX.md` + `.augment/agent-tasks/LESSONS.md`
  + run `agent-task-list.ps1 -Mine` at session start.
- When the user asks you (laptop) to do something that isn't laptop-local,
  default to assigning it to me on CHost via:
  `.\.augment\scripts\agent-task-assign.ps1 -To chost -Title "..." -Prompt "..."`
- I will do the same in reverse (CHost → laptop) for anything that isn't
  CHost-local (Ollama, AIROUTER_API_KEY, scheduled tasks, D:\ backups).
- Closure: `agent-task-complete.ps1 -Id <id> -Status complete|failed|deferred -Summary "..."`
- When you fix something I did wrong: `agent-task-add-lesson.ps1 ...` so I
  don't repeat it.

There's already one pending task waiting for you (id below — visible via
`agent-task-list.ps1 -Mine`). Run it and close it with
`agent-task-complete.ps1` to confirm the round-trip works.

---

## 2026-05-22 17:50 — clone-agent v1 is live (from CHost session)

**For: laptop session(s) connecting today.**

A queue-based background worker is now in place so any machine can
dispatch airouter tasks to slot 1 ("clone agent") without holding an
API key locally. Flow:

```
laptop enqueue.ps1 -> queue.jsonl (OneDrive+git) -> CHost worker (every 10m)
   -> airouter call -> results/<id>.json + .augment/memory/raw/*.clone-agent.jsonl
   -> syncs back to laptop via OneDrive
```

### What's new on disk

| Path | Purpose |
|---|---|
| `.augment/scripts/clone-agent-enqueue.ps1` | Append a task to the queue. Safe to run from any machine. No API key needed. |
| `.augment/scripts/clone-agent-worker.ps1` | Drains the queue; runs only on CHost (scheduled task `AugmentCloneAgentWorker`, every 10 min). |
| `.augment/scripts/register-clone-agent-task.ps1` | Idempotent scheduled-task installer. CHost only. |
| `.augment/scripts/airouter-call.ps1` | New `-OutputFile` param for capturing responses as JSON. |
| `.augment/scripts/airouter-budget.ps1` | Scalar/array `.Count` bug fixed. |
| `.augment/clone-agent/queue.jsonl` | Append-only task queue (tracked in git). |
| `.augment/clone-agent/results/` | Per-task JSON responses (gitignored, OneDrive-synced). |
| `.augment/config/ollama.config.json` | CHost Ollama endpoints (loopback for CHost, tailnet `100.83.6.49:11434` for laptop). |

### How to enqueue from laptop

```powershell
.\.augment\scripts\clone-agent-enqueue.ps1 `
    -Prompt "Your task prompt" `
    -Kind freeform `
    -Tag laptop-roundtrip `
    -MaxTokens 1024
```

OneDrive will push `queue.jsonl` to CHost within ~5–30 s. CHost worker
picks it up on the next 10-min tick (or on-demand if the CHost session
force-runs it). Result file appears at
`.augment/clone-agent/results/<id>.json` and syncs back.

### Round-trip test we want today

Laptop session: run the enqueue command above with a deterministic
prompt (e.g. `"Reply with exactly: pong from CHost via airouter"`).
Then ping the CHost session in chat — CHost will force-run the worker
so you don't wait 10 min, and confirm the result file synced back.

### Slot allocation reminder

- Slot 1 — clone-agent (background, tagged `clone-agent:*`).
- Slot 2 — coding tasks (tagged per task).
- Slot 3 — user / Juan on demand.

Per-key concurrency is 3. Local first per AGENTS.md rule 7; remote
only above local ceiling.

---
