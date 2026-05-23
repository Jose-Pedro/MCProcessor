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

## 2026-05-23 02:08 - OneDrive locks .git/logs/HEAD causing 'cannot update ref HEAD'
- **Context:** Restoration commit on laptop failed with: 'unable to append to .git/logs/HEAD: Invalid argument'. Root cause: OneDrive holds an open handle on .git/logs/HEAD during sync, racing git's atomic append.
- **What went wrong:** Treating the error as a real git problem and retrying blindly, or stashing.
- **Correct approach:** Apply git's own documented workaround once per clone (or set globally on every OneDrive-hosted clone): 'git config windows.appendAtomically false'. Switches reflog append from atomic-rename to append-in-place, which OneDrive tolerates. Same risk profile as default on most filesystems.
- **Applies to:** both

## 2026-05-23 02:08 - Pre-staged deletions silently swept by next commit
- **Context:** Task 91fd0352 docx build on laptop: my unrelated commit picked up 3 file deletions that were already staged in .git/index (from a prior OneDrive/git-pull desync), pushing them to origin/main and undoing CHost commits c5d452e + 24d605d (MCounterPart-Architecture.docx + build-mcounterpart-doc*.ps1).
- **What went wrong:** Ran 'git add <one path>; git commit -m ...' without pathspec on commit. Commit picked up ALL staged changes including pre-staged deletions the agent hadn't inspected. The 'git add' itself was silently rejected by .gitignore (docx not force-added).
- **Correct approach:** Before every commit on shared workspace, run 'git status --short' and inspect ALL staged lines (look for 'D ' / 'A ' / 'M ' in column 1). If anything is staged that the current task didn't intend, either 'git restore --staged <path>' those first OR use 'git commit -- <explicit pathspec>' to commit only the intended files. Also: for gitignored deliverables that previous commits force-added, use 'git add -f' explicitly or the new file silently won't enter the commit.
- **Applies to:** both

## 2026-05-22 18:25 - PowerShell param defaults: keep them to literals
- **Context:** Building agent-task-list.ps1; tool-edited file rejected a bare invocation with "Cannot convert laptop to switch" during binding
- **What went wrong:** Complex sub-expression default in param block (if/elseif/else with env var lookup as the default value)
- **Correct approach:** Keep param defaults to plain literals like empty string. Move env-var/if-else logic AFTER the param block. If file still misbehaves after str-replace edits, rewrite via PS Set-Content to clear hidden-char artifacts.
- **Applies to:** both
