# LESSONS

Append-only corrective notes shared between every Augment Agent instance
in this workspace (CHost + laptop, today and future). **Both agents read
this file at session start, after `AGENT_INBOX.md`, before responding
to the user.** New lessons go on top. Never edit or delete prior entries.

Format for each lesson:

```
## YYYY-MM-DD HH:MM â€” short title
- **Context:** when/where this came up
- **What went wrong:** the failed approach (one or two lines)
- **Correct approach:** what to do instead
- **Applies to:** chost | laptop | both
```

Keep each lesson short. If the same lesson would apply 3+ times, promote
it into `AGENTS.md` (workspace-wide rule) and reference the promotion
date here.

---

## Entries

## 2026-05-22 18:25 - PowerShell param defaults: keep them to literals
- **Context:** Building agent-task-list.ps1; tool-edited file rejected a bare invocation with "Cannot convert laptop to switch" during binding
- **What went wrong:** Complex sub-expression default in param block (if/elseif/else with env var lookup as the default value)
- **Correct approach:** Keep param defaults to plain literals like empty string. Move env-var/if-else logic AFTER the param block. If file still misbehaves after str-replace edits, rewrite via PS Set-Content to clear hidden-char artifacts.
- **Applies to:** both
