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

## 2026-05-25 21:55 - Excel Dashboard should derive categories from data, not hardcode them
- **Context:** Original nuno-build-roles-xlsx.ps1 hardcoded Hotel/QC/Sales COUNTIF rows. When seed grew from 32 employers / 3 profiles to 110 employers / 10 profiles, the Dashboard would have under-reported by hiding 7 new buckets entirely.
- **What went wrong:** Hardcode Cells.Item(5,2).Formula = COUNTIF(B:B, hotel) etc. for each known profile bucket.
- **Correct approach:** Define an [ordered] map of profile-code -> display-label, iterate it and emit a Dashboard row only if at least one employer has that profile. Append a second pass for any unknown profile codes encountered in the data (label them [<code>]). Dashboard then adapts to any seed without code edits. See nuno-build-roles-xlsx.ps1 lines 134-170.
- **Applies to:** both

## 2026-05-25 21:55 - Salvage truncated JSON arrays from heavy-reasoning models
- **Context:** Qwen3.6 / airouter; long structured outputs hit -MaxTokens 16384 mid-array (e.g. nuno-roles-expand burned ~6k reasoning, returned 110 employer objects truncated mid-Sonae entry, no closing ] for employers, no job_board_searches at all)
- **What went wrong:** Re-run with bigger max_tokens (no headroom - model already at ceiling), or discard the partial response and seed manually
- **Correct approach:** Locate array opener with IndexOf([, IndexOf(employers)), slice body, find LastIndexOf(},) to cut after last complete object, reconstruct as { <key>: [ <body> ] } and ConvertFrom-Json. Then merge with whatever the model didnt reach (board searches in our case) from the prior seed. See nuno-roles-merge-expand.ps1 for the canonical pattern.
- **Applies to:** both

## 2026-05-25 21:54 - Excel COM rebuilds: probe open processes first, output to sibling filename if locked
- **Context:** nuno-build-roles-xlsx.ps1 second invocation against nuno-roles.xlsx while user's Excel session (PID 14056) had it open - Remove-Item failed with IOException, whole build aborted at line 60
- **What went wrong:** Run the builder against the target filename and let Remove-Item throw. Or try to Stop-Process the user's Excel - destroys unsaved work.
- **Correct approach:** Before Remove-Item, run Get-Process EXCEL,WINWORD -ErrorAction SilentlyContinue | Select Id,MainWindowTitle. If MainWindowTitle matches the target file basename, switch -OutFile to a sibling (e.g. -expanded.xlsx) and report the rename to the user. Only Stop-Process Excel/Word PIDs whose MainWindowTitle is empty (orphan COM zombies from prior builder runs).
- **Applies to:** both

## 2026-05-25 21:54 - Compress-Archive fails on files held by Word/Excel; stage-then-zip via .NET
- **Context:** Building nuno-job-pack-2026-05-25.zip while user had nuno-roles.xlsx open in Excel and pt\\linkedin-guide-pt.docx + pt\\reclet-pt.docx open in Word
- **What went wrong:** Call Compress-Archive -Path \C:\Users\zeped\OneDrive - Palácio dos Afetos lda\GODMODE\Nuno-Job\03_deliverables\\* -DestinationPath \C:\Users\zeped\OneDrive - Palácio dos Afetos lda\GODMODE\Nuno-Job\nuno-job-pack-2026-05-25.zip directly. It (1) floods stderr with hundreds of progress-bar lines (transcript pollution), (2) opens source files with implicit exclusive access and fails with ZipArchiveHelper: The process cannot access the file ... because it is being used by another process, leaving a 0-byte zip on disk.
- **Correct approach:** Stage to \C:\Users\zeped\AppData\Local\Temp first: for each source file, open with [System.IO.File]::Open(path, Open, Read, FileShare.ReadWrite) and copy to staging (Office holds files with NO sharing, so 2-3 may still fail - log and continue, do not abort). Then [System.IO.Compression.ZipFile]::CreateFromDirectory(\C:\Users\zeped\AppData\Local\Temp\nuno-pack-21e3bdd6, \C:\Users\zeped\OneDrive - Palácio dos Afetos lda\GODMODE\Nuno-Job\nuno-job-pack-2026-05-25.zip, Optimal, \False) - silent, no progress events, no NativeCommandError noise. Delete staging at end.
- **Applies to:** both

## 2026-05-25 15:41 - airouter is flat-price; do not budget tokens like Claude
- **Context:** Routing decisions for clone-agent and remote-master-call. Default heuristic was to keep max_tokens tight to save budget.
- **What went wrong:** Treating airouter max_tokens as a cost lever (e.g. max_tokens=6144 for a multi-doc generation). Result: reasoning models like Qwen3.6 burn the entire budget on reasoning_tokens and return status=empty with text_tokens=0.
- **Correct approach:** airouter models are FLAT-PRICE. Token caps are a Claude-license / agent-seat constraint, not an airouter constraint. For reasoning models, set max_tokens >= 16384 so content survives after reasoning. Also: each airouter key supports 3 concurrent calls -- batch parallel where possible.
- **Applies to:** both

## 2026-05-23 02:44 - PowerShell 5.1 mangles UTF-8 in Invoke-RestMethod string body
- **Context:** airouter-call.ps1 sending a JSON body containing em-dashes/arrows/smart quotes (e.g. the full agent-operating-rules.md as a system prompt)
- **What went wrong:** Passing the JSON string directly to Invoke-RestMethod -Body. PS 5.1 silently encodes the string in the platform ANSI code page (CP-1252), so multi-byte UTF-8 sequences become garbage bytes. The airouter proxy fails to parse the body and returns a misleading 400 'Invalid model name passed in model=None'.
- **Correct approach:** Convert the body to UTF-8 bytes first: $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body); set Content-Type 'application/json; charset=utf-8'; pass $bodyBytes to -Body. Apply this to every wrapper that POSTs JSON via Invoke-RestMethod in PS 5.1.
- **Applies to:** both

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
