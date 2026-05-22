# Session Log

Rolling checkpoint log for Augment Agent work in this workspace.
Update protocol is defined in `/AGENTS.md`. Newest entry on top.

## Entries

### 2026-05-22 16:50 — Workspace migrated to `OneDrive\GODMODE\Codebase`; old `Documentos\GODMODE` kept read-only as 24-48h safety net
- **Goal:** move the active workspace out of `OneDrive\Documentos\GODMODE\Codebase`
  (deep, accented-name parent path that interacts badly with various tooling)
  into a shallower `OneDrive\GODMODE\Codebase` while ensuring the cold-path
  pipeline, all three mirror tiers, the scheduled task, and git push
  continue to work end-to-end from the new location.
- **Done:**
  - User copied entire `GODMODE` tree (26 GB / 73,512 files) from
    `OneDrive\Documentos\GODMODE` to `OneDrive\GODMODE`. Both copies
    have intact `.git`, `.augment`, `AGENTS.md`.
  - Phase A — sanitized new copy:
    - Verified git state: branch `main`, HEAD `43014b6`, remote
      `https://github.com/Jose-Pedro/MCProcessor.git`, clean.
    - Deleted all 185 `node_modules/` directories (78,521 files /
      685 MB) from new copy in 18.2 s. Reversible via `npm install`
      per sub-project. Prevents OneDrive from churning on small files
      and removes the `Prv/.../sap__cds` junction-loop risk.
  - Phase B — cutover (no source edits required; both
    `register-nightly-task.ps1` and `cold-path-distill.ps1` use
    `$PSScriptRoot` so they auto-adapt):
    - Re-registered `AugmentColdPathDistill` scheduled task to point at
      `C:\Users\zeped\OneDrive\GODMODE\Codebase\.augment\scripts\cold-path-distill.ps1`.
      Next run 2026-05-23 02:00.
    - Ran cold-path from new location end-to-end: 7 new raw lines
      distilled (Qwen), embedded (nomic), tier-3a Seagate mirror OK,
      tier-3c Catel mirror OK. Tier 3b is implicit (new location is
      already inside personal OneDrive).
    - Committed memory output + pushed from new copy:
      `82622ce chore(memory): cold-path run from new workspace location
      (post-migration)` → `origin/main`.
  - Old copy `OneDrive\Documentos\GODMODE` left untouched on disk as
    a 24-48 h safety net (per user decision). To be deleted only after
    1-2 successful nightly runs from the new location.
- **Files touched:**
  - `.augment/SESSION_LOG.md` (this entry, written via old copy then
    sync'd to new copy + committed from new copy).
  - `.augment/memory/distilled/2026-05-22.zepedro.jsonl`,
    `.augment/memory/index/2026-05-22.zepedro.vec.jsonl`,
    `.augment/memory/today.index.json`,
    `.augment/memory/.state/distilled.json` (all in new copy, via the
    post-migration cold-path run).
  - 185 `node_modules/` directories deleted from new copy only.
  - Windows Scheduled Task `AugmentColdPathDistill` re-registered.
- **State:** complete (infra side). Manual follow-ups remain for the
  user: close this VS Code window and reopen at the new path; paste
  `LAPTOP_AGENT_BOOTSTRAP.md` boot message into the fresh Augment chat;
  decide on Phase C (old-copy deletion) after 24-48 h of green runs.
- **Next step:** user reopens VS Code at `OneDrive\GODMODE\Codebase`
  and bootstraps a fresh agent there. Then resume normal work
  (L0 — airouter budget tracker, 2nd airouter key wiring, etc.).
- **Notes:**
  - `work` VS Code tunnel auto-follows whichever folder VS Code on
    CHost was last opened at; reopen at the new path and the tunnel
    redirects automatically for Juan's incoming connections.
  - Both copies still have a 1-line `.gitignore` dirty diff predating
    the migration; not introduced here, not blocking.
  - Optional hardening: add `node_modules/` to OneDrive's per-folder
    exclusion list (Settings → Sync and backup → Manage backup) so
    future `npm install` runs inside the OneDrive tree don't re-pollute
    the cloud sync. Not done in this session.
  - Path resolution in both scripts uses `$PSScriptRoot` → migrating
    to any future location is a no-op as long as `.augment/scripts/`
    sits at the expected `<repo>/.augment/scripts/` relative path.

### 2026-05-22 15:10 — VS Code Remote Tunnel proved; Tier 3c Catel OneDrive mirror live; laptop now has full project context via Catel mirror
- **Goal:** unblock the laptop so zepedro (and Juan later) can work
  against the project state without needing RDP-into-CHost to work.
  Architecture decision: laptop runs its own VS Code + own Augment as
  a sibling agent, reading shared state from disk (not via tunnel).
- **Done:**
  - Confirmed CHost has a pre-registered VS Code tunnel named `work`
    (Microsoft Remote Tunnels), `Connected`, service installed.
    Accessible via `https://vscode.dev/tunnel/work` or VS Code
    Remote-Tunnels extension. Documented but not used as the primary
    laptop path.
  - Decision: tunnel = fallback when synchronous co-presence is
    needed; default = laptop-local sibling agent, no tunnel.
  - Added Tier 3c backup to `cold-path-distill.ps1`: mirrors
    `.augment/memory/**`, `.augment/SESSION_LOG.md`, `.augment/scripts/**`,
    `.augment/config/**`, and `AGENTS.md` to the Catel OneDrive folder
    `%USERPROFILE%\OneDrive - Palácio dos Afetos lda\MCProcessor\`.
    Path auto-resolved at runtime from HKCU OneDrive registry by
    matching `ConfiguredTenantId = 0cca651b-b45a-4199-b7b2-bd44f771253f`,
    avoiding the accented-char (`Palácio`) mojibake issue on PS 5.1.
    New flags: `-SkipCatel`, `-CatelMirrorRoot`, `-CatelTenantId`,
    `-CatelMirrorSubdir`.
  - Refactored cold-path early-exit: when no new raw entries exist,
    distill+embed phases are now skipped but mirror+git phases still
    run (so out-of-band changes to scripts/SESSION_LOG/AGENTS.md
    still propagate). Wrapped phases 1+2+state+pointer in
    `if (-not $skipDistill)`.
  - Updated AGENTS.md tier description to enumerate 3a Seagate +
    3b personal OneDrive + 3c Catel OneDrive.
  - Test run: tier-3c mirror OK -> Catel folder populated end-to-end.
    Verified all expected files present (memory tree, scripts, config,
    SESSION_LOG.md, AGENTS.md). Commit `0e21714` on `origin/main`.
  - User confirmed Catel mirror folder is now visible on laptop side
    via OneDrive sync — multi-device propagation working.
- **Files touched:**
  `.augment/scripts/cold-path-distill.ps1`,
  `AGENTS.md`,
  `.augment/SESSION_LOG.md`.
- **State:** complete for the mirror/access work. Laptop sibling agent
  can now read project context from either:
  (a) the personal-OneDrive-synced workspace root, OR
  (b) the Catel-OneDrive-synced `MCProcessor\.augment\` mirror
      (preferred for read-only context lookup; isolated from accidental
      writes in the live workspace).
- **Next step for the laptop sibling agent:** on first invocation,
  read this entry + the previous two entries + `AGENTS.md`, then state
  back the project state, the next planned action, and confirm the
  `AUGMENT_ARCHITECT` env var value to use (`zepedro` for José,
  `juan` for Juan). Do NOT checkpoint to SESSION_LOG.md concurrently
  with another active agent — coordination rule.
- **Notes:**
  - AGENTS.md is currently `.gitignore`d. Tier 3c mirror still copies
    it via robocopy/Copy-Item — laptop receives it. Decision on
    whether to track it in git is deferred.
  - RDP into CHost remains blocked (NLA on + new MSA password
    requires admin shell on CHost to disable NLA; user must walk to
    CHost or accept UAC there). Parked — tunnel + sibling-agent
    architecture removes the need.
  - Tonight's 02:00 cold-path will now exercise all three mirror
    tiers + git for the first time. Verify `.cold-path.log`
    tomorrow morning.
  - Two pending items from earlier checkpoints still open:
    L0 Airouter budget tracker, 2nd Airouter key wiring.


### 2026-05-22 14:30 — Tailscale + RDP shortcuts deployed; blocked on RDP auth, pivoting to laptop-side Augment
- **Goal:** give zepedro from-anywhere access to CHost's Augment session
  so the shared chat / context window survives location changes. Same
  mechanism unblocks Juan later (he'll RDP into the shared `zeped`
  session, tag work via `$env:AUGMENT_ARCHITECT='juan'`).
- **Done:**
  - Disabled AC standby on CHost (`powercfg /change standby-timeout-ac 0`)
    so RDP isn't blocked by the prior 3-min sleep.
  - Installed Tailscale 1.98.2 on CHost; signed in with GitHub as
    `Jose-Pedro`. CHost tailnet IP `100.83.6.49`, magic-DNS name `work`,
    FQDN `work.tail6394c1.ts.net`.
  - Installed Tailscale on laptop (`flying`, `100.74.20.77`), same
    account. Both nodes online, mutually visible.
  - Committed two pre-built RDP shortcuts under `.augment/exports/`:
    `connect-chost-lan.rdp` (192.168.4.74 for same-Wi-Fi)
    and `connect-chost-tailscale.rdp` (magic-DNS `work` for anywhere).
    Pushed as `0674ea6` + `41d7d59` on `origin/main`.
  - Identified the MSA tied to local `zeped` profile:
    `zepedro.medeiros@gmail.com` (via HKCU IdentityCRL UserNames).
    User confirmed correct password is held (redacted).
  - Created `.vsls.json` at repo root earlier in session to fix Live
    Share `RangeError` from a node_modules junction loop under
    `Prv/prv-intprojects-nodejs/`. Live Share now secondary to RDP.
- **Files touched:**
  `.augment/exports/connect-chost-lan.rdp`,
  `.augment/exports/connect-chost-tailscale.rdp`,
  `.vsls.json`,
  `.augment/SESSION_LOG.md`.
- **State:** blocked. RDP from laptop into `work` rejects all username
  variants (`zeped`, `zepedro.medeiros@gmail.com`, `-WORK\zeped`,
  `.\zeped`) despite user having the correct MSA password. CHost-side
  RDP config not yet verified (RDP-enabled? `zeped` in Remote Desktop
  Users? firewall allowing on Tailscale interface?).
- **Next step:** user is switching to a fresh Augment session on the
  laptop (own VS Code, own Augment subscription, OneDrive-synced repo).
  That agent picks up from this entry. Two parallel paths it can take:
  (a) diagnose CHost RDP from inside this CHost session via the laptop
  agent's chat — but the laptop agent has no terminal on CHost, so
  it'd need to walk the user through running commands at the CHost
  console; or (b) bypass RDP entirely and do work directly from the
  laptop-side repo (chat history won't be shared with this thread, but
  `.augment/memory/raw/*.juan.jsonl` and `*.zepedro.jsonl` keep the
  per-architect persistence working). Recommended: (b) for today, fix
  RDP later when both architects are physically at CHost.
- **Notes:**
  - C1 (sequential shared session) is the intended model: only one
    interactive session at a time. RDP-in locks the console; logging
    in at console kicks the RDP session.
  - `AUGMENT_ARCHITECT` env var is per-terminal — set it in every new
    terminal before invoking memory-append.ps1 / agent work.
  - Tonight's 02:00 cold-path will still run on CHost regardless of
    where the architects are typing from. Verify `.cold-path.log`
    tomorrow morning.
  - Password is held by user; treat as redacted in chat, tool calls,
    and this log.
  - Two deferred items still pending from prior checkpoint:
    L0 Airouter budget tracker; 2nd Airouter key wiring.


### 2026-05-22 12:05 — Phase 3b validated; Juan onboarding pending Live Share install
- **Goal:** finish validating the cold-path git auto-commit/push step
  (Phase 3b), then start Juan onboarding via VS Code Live Share so his
  raw stream feeds tonight's 02:00 cold-path alongside zepedro's.
- **Done:**
  - Validated Phase 3b end-to-end. Two bugs caught and fixed in
    `cold-path-distill.ps1`:
    1. `Push-Location (Split-Path $memRoot)` landed in `.augment/`,
       not repo root, so `git add .augment/memory ...` looked for
       `.augment/.augment/memory` and failed. Fixed by stepping up
       one more level: `Split-Path (Split-Path $memRoot)`.
    2. Git writes benign warnings to stderr (e.g. CRLF/LF
       conversion). Under script-wide `EAP=Stop` these were caught
       by the `try/catch` and aborted the commit silently. Fixed by
       wrapping the git block with `EAP=Continue` and replacing
       try/catch-driven flow with `$LASTEXITCODE` checks. Also
       restructured to drop early-`return` so `run end` always logs.
  - Verified: new commit `b931185 cold-path: distill 2026-05-22`
    on local `main` AND `origin/main` (push succeeded).
  - Total nightly run wall-clock: ~35 s (22 s distill, 3 s embed,
    6 s Seagate mirror, 3 s git).
  - Discovered three untracked dirs under `.augment/`: `config/`,
    `exports/`, `scripts/`. The `scripts/` one is the critical
    finding — our automation source (memory-append, cold-path-distill,
    register-nightly-task) lives only on CHost + Seagate mirror, not
    in git. Surfaced to user; awaiting `track scripts` confirmation.
  - Juan onboarding: user confirmed channel is **VS Code Live Share**
    (host shares a session, Juan joins as guest), NOT the previously
    documented `chost-juan` Microsoft Remote Tunnel path. AGENTS.md
    lines 127-132 are now stale; awaiting `fix agents` to rewrite.
  - Confirmed scripts already Juan-ready (no code changes): memory-
    append.ps1 already has `-Architect` param + `AUGMENT_ARCHITECT`
    env fallback; cold-path default Architects = `@('zepedro','juan')`.
  - Agreed convention with user: **option A** — Juan opens a shared
    terminal in Live Share, runs `$env:AUGMENT_ARCHITECT='juan'`
    once, then every `memory-append.ps1` call from that terminal
    tags entries to `2026-05-22.juan.jsonl`.
  - Live Share extension was MISSING from this VS Code. Installed
    `ms-vsliveshare.vsliveshare` via `code.cmd --install-extension`.
    Sign-in + first invitation still pending (requires VS Code
    restart to activate, hence this checkpoint).
- **Files touched:**
  - `.augment/scripts/cold-path-distill.ps1` (Phase 3b: two iterative
    bug fixes — pathing + EAP/exit-code handling)
  - `.augment/SESSION_LOG.md` (this entry)
  - git: new commit `b931185` on `main` + `origin/main` containing
    today's `.augment/memory/**` artifacts and the previous SESSION_LOG
    checkpoint
  - VS Code: extension `ms-vsliveshare.vsliveshare` installed (per-
    user, not in repo)
- **State:** in-progress (Phase 3b complete and live; Juan onboarding
  blocked on VS Code restart to activate Live Share extension).
- **Next step:** after VS Code restart →
  1. `Ctrl+Shift+P` → "Live Share: Sign In" (use GitHub, account is
     already `Jose-Pedro`).
  2. Click "Live Share" button in status bar (bottom-left) → "Start
     Collaboration Session" → copy invite URL to Juan.
  3. When Juan joins: Live Share panel (left sidebar) → right-click
     his name → "Make Read/Write" → `Ctrl+Shift+P` → "Live Share:
     Share Terminal" → Read/write.
  4. Juan runs in that terminal: `$env:AUGMENT_ARCHITECT='juan'`
     then his inaugural `memory-append.ps1 -Kind decision -Text ...`
     to seed `2026-05-22.juan.jsonl`.
- **Notes:**
  - Two unresolved follow-ups deliberately deferred until user gives
    explicit go-ahead: (a) `git add .augment/scripts .augment/config
    .augment/exports` so automation source is versioned; (b) AGENTS.md
    lines 127-132 rewrite (Live Share = active path, Remote Tunnel
    = optional future). Both independent of Juan; can be done
    anytime.
  - Live Share guest's shared terminal physically runs on CHost (no
    OS-level user separation between zepedro and juan in that shell).
    Architect tagging is purely a convention enforced via env var or
    `-Architect` flag — there is no auto-detection.
  - Live Share has a browser fallback (vscode.dev) so Juan does NOT
    need VS Code installed locally if he doesn't have it yet.
  - VS Code restart (not just window reload) is recommended for
    Live Share's first activation — its agent process attaches at
    full process start. After restart, the "Live Share" entry will
    appear in the status bar and as an icon in the activity bar.

### 2026-05-22 11:45 — Phase 0 closed: cold-path distill + nightly task + Tier 3a backup
- **Goal:** stand up the full write-now/index-later memory pipeline
  (raw -> distilled -> embedded -> Seagate mirror), automate it nightly,
  and validate end-to-end on real data so future sessions can read prior
  context without manual intervention.
- **Done:**
  - Verified hot path: `memory-append.ps1` produced 3 entries today in
    `.augment/memory/raw/2026-05-22.zepedro.jsonl` (decision +2 facts).
  - Verified cold path end-to-end (3 production runs, all green):
    - Phase 1 (Qwen distill): ~18-28 s per run incl. model load.
    - Phase 2 (nomic embed): ~3-4 s, dim=768.
    - Phase 3a (Seagate mirror): added new code path; tested both
      drive-present (robocopy exit=1, success) and drive-absent
      (`-BackupRoot Z:\...` -> silent skip log) branches.
    - Idempotency: re-run with no new entries exits in <1 s.
  - Registered Windows Scheduled Task `AugmentColdPathDistill`:
    daily 02:00 local, WakeToRun=True, StartWhenAvailable=True,
    LogonType=Interactive (no admin needed; CHost is always-logged-in).
    NextRunTime confirmed = 23/05/2026 02:00.
  - Resolved D11 (Tier 3a backup): Seagate at `D:` (1863 GB, 1007 GB
    free), sometimes-plugged, backup root `D:\Backups\MCProcessor\`.
    First mirror succeeded: 49 KB across raw/distilled/index/.state.
  - AGENTS.md step 5 rewritten to document the locked-in Seagate path
    and sometimes-plugged contract.
- **Files touched:**
  - `.augment/scripts/cold-path-distill.ps1` (added `-SkipBackup`,
    `-BackupRoot` params + Phase 3a robocopy block)
  - `.augment/scripts/register-nightly-task.ps1` (switched LogonType
    from S4U to Interactive — S4U needs admin)
  - `AGENTS.md` (step 5 of cold-path flow)
  - `.augment/memory/raw/2026-05-22.zepedro.jsonl` (3 entries)
  - `.augment/memory/distilled/2026-05-22.zepedro.jsonl` (3 entries)
  - `.augment/memory/index/2026-05-22.zepedro.vec.jsonl` (3 vectors)
  - `.augment/memory/.state/distilled.json`,
    `.augment/memory/today.index.json`,
    `.augment/memory/.cold-path.log`
  - `D:\Backups\MCProcessor\.augment\memory\**` (full mirror)
- **State:** complete for Phase 0. One sub-step intentionally not
  exercised: cold-path Phase 3b (git auto-commit/push) — code present
  but never run live, since every run today used `-SkipGit`.
- **Next step:** in the next session, validate Phase 3b by running
  `cold-path-distill.ps1` once without `-SkipGit` (will auto-commit
  today's memory artifacts and push to `origin/main`). Then proceed to
  Juan onboarding (chost-juan tunnel + add `juan` to default
  `-Architects` list + his raw JSONL stream).
- **Notes:**
  - Two-model coexistence on CHost (Intel Iris Xe, ~1 GB VRAM) is
    impossible — confirmed by Ollama eviction logs. Mandatory batching
    (all-writer-then-all-embed) is encoded in the script and must stay.
  - `OLLAMA_MAX_LOADED_MODELS=2` and `OLLAMA_NUM_PARALLEL=1` are set in
    User-scope env vars; Ollama must be restarted (kill + relaunch tray)
    to pick them up after any future change.
  - First real nightly run is tonight at 02:00 — tomorrow check
    `.augment/memory/.cold-path.log` for the 02:00 timestamp to confirm
    Task Scheduler actually fired.
  - Interactive LogonType means the 02:00 task only fires when user
    `zeped` is logged on. CHost is "always on, always logged in" by
    design; if that ever changes, re-register from an elevated shell
    and switch back to S4U.
  - Source/destination byte mismatch (~147 bytes) on first Seagate
    mirror is expected — `.cold-path.log` gets two more lines written
    AFTER robocopy completes; next run reconciles.

### 2026-05-12 09:10 — Installed VS Code Speech extension (dictation for chat)
- **Goal:** give the user a speech-to-text path so they can dictate into
  the Augment chat box and any other VS Code text input without keyboard.
- **Done:**
  - Discussed TTS/STT options for interacting with Augment and for
    hands-free coding. Pointed out that for full voice-driven editing
    (open file, jump to line, edit) the actual stack is
    **Talon Voice + Cursorless**, not VS Code Speech. VS Code Speech is
    dictation-only and is what the user asked to install.
  - Initial `code --install-extension ...` invocations returned exit 0
    but did nothing — root cause: on this machine `code` in PATH resolves
    to the GUI binary `C:\Users\zeped\AppData\Local\Programs\Microsoft VS
    Code\Code.exe`, which silently swallows CLI args. The real CLI shim
    is at `...\Microsoft VS Code\bin\code.cmd`.
  - Re-ran the install via the explicit shim path:
    `& "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" --install-extension ms-vscode.vscode-speech --force`
    → `Extension 'ms-vscode.vscode-speech' v0.16.0 was successfully installed.`
  - Verified via `code.cmd --list-extensions` (host VS Code is 1.115.0
    x64, commit 41dd792b5e652393e7787322889ed5fdc58bd75b).
  - Gave the user activation steps: reload window, approve the offline
    speech model download prompt, default keybinding `Ctrl+Alt+V` for
    voice in chat, and the relevant `accessibility.voice.*` settings
    (`speechLanguage`, `autoSynthesize`, `keywordActivation`).
- **Files touched:** none.
- **State:** complete (extension installed and verified). User has not yet
  confirmed they reloaded the window or tested dictation.
- **Next step:** none required. Optional follow-up only if the user asks:
  install a non-English language pack, or set up Talon + Cursorless for
  real hands-free coding (would create files outside the repo, so only on
  explicit request).
- **Notes:**
  - On Windows, always invoke the CLI shim at
    `%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd`
    for any VS Code automation — `code` from PATH is unreliable here.
  - VS Code Speech is primarily designed for Copilot Chat. It should work
    in the Augment chat input (any focusable textarea) but feature parity
    isn't guaranteed.
  - UI5 / CAP servers from the previous checkpoint are still running:
    CAP backend PID 536 on :4004, UI5 server PID 41480 on :8080.

### 2026-05-12 08:45 — Relaunched UI5 layer to load Component.js theme fix
- **Goal:** restart the local UI5 dev server cleanly so the `Component.js`
  edit from the previous checkpoint (localhost → `sap_horizon`) is loaded
  fresh, and reopen the FLP single-app entry in the browser.
- **Done:**
  - Confirmed both servers were up before the restart: CAP backend PID 536
    on `:4004`, UI5 server PID 37048 on `:8080`.
  - Killed UI5 PID 37048, removed `ui-boot.log` / `ui-boot.err.log`.
  - First attempt `npm run start-integrated` failed — that script does not
    exist. The actual UI5 scripts in `Prv/prv-intprojects-ui5/package.json`
    are `start`, `start-local`, `start-mock`, `start-noflp`,
    `start-variants-management`. None of them point at `ui5-integrated.yaml`,
    so it has to be invoked directly.
  - Relaunched with
    `npm exec -- fiori run --config ./ui5-integrated.yaml --open
     "test/flp.html#app-preview"` (background, output redirected to
    `ui-boot.log` / `ui-boot.err.log`). Server bound `:8080` after 15s as
    PID 41480, UI5 SDK 1.136.2, all three backend proxies registered
    (`/odata`, `/v2/restriction`, `/callOT` → `http://localhost:4004`).
    The `No credential found ... fiori/v2/system` warnings are normal —
    the proxy just falls through to the request's own auth.
  - Opened `http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false&
    sap-ui-language=en&t=relaunch#app-preview` in the user's browser.
- **Files touched:** none (logs only).
- **State:** waiting on user verification of the rendered FLP/theme.
- **Next step:** if theme still off, request DevTools Console / Network
  screenshots. If theme is OK, optional follow-up is to add a proper
  `start-integrated` script to `package.json` so future relaunches don't
  need the long `npm exec` invocation — only do this if the user asks.
- **Notes:**
  - User must hard-refresh (Ctrl+Shift+R) to discard the cached
    pre-fix `Component.js` from the previous run.
  - Basic-Auth creds for the CAP backend popup: `FRPRCOLMNG` /
    `Cellnex01.` (mocked manager, country FR).
  - Process inventory after relaunch:
    CAP backend PID 536 :4004, UI5 server PID 41480 :8080.

### 2026-05-12 — UI5 unstyled-render fix: localhost theme override in Component.js
- **Goal:** Resolve the "no theme installed / UI completely awkward / functionalities
  not working" report when running the UI5 app locally against the local CAP backend
  via `ui5-integrated.yaml`. User confirmed via screenshot that data was loading but
  every SAP UI5 control rendered as raw, unstyled HTML (column headers without
  background, "To select row, press SPACEBAR" ARIA hints leaking through, no FLP
  shell header, "Erro" badge in browser tab).
- **Done:**
  - Verified backend stack is healthy: cap-boot.log shows `$batch` requests for the
    seeded request `2cdcc531-...` returning 200 (Phases, Blocks, Sites, Customers,
    Documents, etc.). Stderr only shows: (a) repeated
    `[#enableNewUploadTableFeature] business switch unavailable` warnings — already
    handled by the local-dev fallback in `srv/code/blocks.js` from the previous
    session, harmless; (b) the deliberate `status_code` 400 from earlier probing.
  - Verified the UI5 proxy is correctly version-pinning to `1.136.2`:
    `GET /resources/sap-ui-version.json` via `localhost:8080` returns 1.136.2,
    matching `framework.version` in `ui5-integrated.yaml`. (Unpinned upstream
    `https://ui5.sap.com/resources/sap-ui-version.json` would return latest 1.147.2,
    but the proxy is doing the right thing — not the cause.)
  - Verified themed CSS is reachable through the proxy: HEAD on
    `/resources/sap/m/themes/sap_horizon/library.css` → 200,
    `/resources/sap/ushell/themes/sap_horizon/library.css` → 200, etc. The
    non-themed bare paths (`/resources/sap/m/library.css`) return 404, which is
    expected — the bootstrap loads themed variants only.
  - Verified the FLP sandbox HTML at `/test/flp.html` is correct: title
    `Local FLP Sandbox`, fiori2 renderer, all required libs in `data-sap-ui-libs`
    (`sap.m, sap.ui.core, sap.f, sap.suite.ui.generic.template, sap.ui.comp,
    sap.ui.generic.app, sap.ui.table, sap.ushell`), `data-sap-ui-theme="sap_horizon"`,
    and the `app-preview` intent registered to component `prvintprojectsui5`.
  - Found the actual root cause in `Prv/prv-intprojects-ui5/webapp/Component.js`
    lines 22–27: the `init()` method runs `Core.applyTheme(...)` after bootstrap
    and only uses `sap_horizon` when the host contains
    `applicationstudio.cloud.sap` or `cf.launchpad.cfapps`. On every other host
    (including `localhost`) it overrides with a custom Cellnex theme
    `cellnex_apolo_light_v1` served from `/comsapuitheming.runtime/themeroot/v1/UI5/`
    — a UI Theming Service path that exists only in the BTP runtime. Locally that
    path 404s, theme application fails, and the entire UI is left without any
    library CSS, which exactly matches the screenshot.
  - Edited `Prv/prv-intprojects-ui5/webapp/Component.js` to additively include
    `localhost` and `127.0.0.1` in the same condition that triggers `sap_horizon`.
    Production behaviour unchanged; only local-dev now uses the standard theme.
- **Files touched:**
  Prv/prv-intprojects-ui5/webapp/Component.js
- **State:** waiting on user verification (browser hard-refresh of
  `http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview`).
- **Next step:** confirm with the user that the FLP shell header, themed table,
  hidden ARIA hints, and Cellnex-blue action buttons now render correctly. If
  anything is still off, ask for DevTools Console / Network screenshots to
  isolate the next layer.
- **Notes:**
  - Backend (CAP) PID 536 on :4004, UI5 (`fiori run` with `ui5-integrated.yaml`)
    on :8080 — both still up from the prior checkpoint.
  - Manifest declares a `componentUsages` resource root
    `com.cellnex.variantstable` → `../../cmm-variantstable-ui5.comcellnexvariantstable`
    (an MTA-flattened path). The sibling project does exist at
    `Cmm/cmm-variantstable-ui5`, but the relative path won't resolve in dev. Only
    affects the variant-save dropdown on tables, not overall theming — leave alone
    unless the user reports the variants dropdown failing.
  - `refreshR3EntitiesCache` is implemented at
    `Prv/prv-intprojects-nodejs/srv/code/unboundactions.js:100`, so the
    `Component.js` post-init call is fine.

### 2026-05-11 18:30 — End-to-end Request drive succeeded: feasibilCheck → requestCompleted (status 3)
- **Goal:** From the seeded test request `2cdcc531-0fcb-4387-b7e9-796e5a241b83`,
  drive every active Block through `close` until the Request reaches
  `requestCompleted`, patching local-only gaps as they surface.
- **Done:**
  - Confirmed the action route shape is
    `POST /service/project/Blocks(<ID>)/project.close` and that the
    handler returns the next `MASTER_PHASE_ID` (or empty string when the
    closure does not advance the phase).
  - Wrote `_dev_drive.js`: lists active blocks via
    `Blocks?$filter=status_code eq 7`, calls `close` on each, loops
    until no active blocks remain (or no progress in a pass → abort).
    `path` is wrapped in `encodeURI(...)` so the parenthesised key
    segment doesn't trip `ERR_UNESCAPED_CHARACTERS`.
  - Wrote `_dev_fillchecklist.js` to satisfy mandatory checklist items
    (PICKLIST/DATEVALUE) on a target block when `close` reports
    "Please complete all mandatory checklist fields".
  - Patched `srv/code/blocks.js` `#enableNewUploadTableFeature` to
    swallow the missing `GET_ACTIVE_BUSINESS_SWITCH` DB function in HXE
    and default the feature to disabled, instead of 5xx-ing.
  - Wrote `_dev_setbttn.js`: directly sets
    `BTTN_INV_UPDATED='true'`, `BTTN_SERV_UPDATED='true'`,
    `BTTN_DOC_UPDATED='true'` on the
    `finalValidation`/`validDocument` row of `BLOCKS_PROVISIONING`,
    simulating the UI "Confirm Inventory/Services/Documents" buttons
    whose handlers (`onConfirmInventory`, `onConfirmServices`,
    `onConfirmDocuments` in `srv/code/requests.js`) call external
    services we don't have locally.
  - Drove pass-by-pass:
    pass 1 closed 9 blocks (`requestConfigur`, `globalResult`, `site`,
    `costMoveCust`, `costInfraWorks`, `acceptBuildOffe`, `dashboard`,
    `requestInformat`, `doTechDoc`) — opening `manageAdapt`,
    `feasibilCheck`, `custOfferAccept`;
    pass 2 closed 3 blocks (`kickOff`, `validDocument`,
    `universalWorks`) — opening `instCustEquip`;
    pass 3 closed `validDocument` (finalValidation) and got blocked
    on `instalService` with three handler errors
    ("Raise with Licensing/Rental Service/Document team"); after
    `_dev_setbttn.js` set the three confirm flags, pass 4 closed
    `instalService` and the action returned `requestCompleted`.
  - Direct DB verification: all 8 phases at `PHASE_STATUS=3`, the
    request itself at `REQUEST_STATUS=3` and
    `ENDED_AT=2026-05-11T18:25:51`. The handful of blocks still at
    status 2 (`permits`, `realEstate`, `dismantleWorks`,
    `energyStudy`, `manageRefunds`) are blocks whose phases were
    already closed by the time their parent advanced — i.e. they were
    never activated, which matches the real workflow's branching.
  - Side note: a 500 `invalid column name: ISACTIVEENTITY` was
    observed in the err log for a `Requests` SELECT immediately after
    the close — caused by CAP's draft-aware projection running on
    HXE's case-folded physical table `project_Requests`. It did NOT
    block the closure (the action had already committed the status
    change), and is the next-known issue to look at if drafts get
    exercised.
- **Files touched:**
  Prv/prv-intprojects-nodejs/_dev_drive.js,
  Prv/prv-intprojects-nodejs/_dev_fillchecklist.js,
  Prv/prv-intprojects-nodejs/_dev_setbttn.js,
  Prv/prv-intprojects-nodejs/srv/code/blocks.js
- **State:** complete (one-shot drive verified for the seeded request)
- **Next step:** repeatability test — `POST /Requests` to create a
  brand-new Internal Project (requestType 40) from scratch and run
  the same drive script against it; patch any gaps that surface in
  creation/initial-phase handlers (likely candidates: missing
  `siteId`, draft activation flow on HXE, the `ISACTIVEENTITY`
  column-name issue if the create path goes through drafts).
- **Notes:**
  - `close` action body must be `{}` (empty object), not empty string.
  - The drive script aborts if a pass closes zero blocks, which is
    the right signal that human intervention (extra DB seeding /
    handler patch) is needed before retrying.
  - Mocked user `FRPRCOLMNG` (FR, `TIS_WF_PRO_IntProjectsMgr` +
    `TIS_WF_PRO_Subcontractor`) was sufficient for every close in
    the chain — no role-related 403s observed.
  - `_dev_show.js` could not be re-created via `save-file` because
    OneDrive intermittently re-materialises the deleted file; piping
    the JS through `node` on stdin (`$js | node`) is the reliable
    workaround for ad-hoc DB inspection scripts on this machine.

### 2026-05-11 18:05 — All 5xx eliminated; 106/124 entity sets healthy; ready to seed value-helps and drive a Request
- **Goal:** Stabilise the local CAP server end-to-end so a Request can be
  driven from creation through to closure with no remaining handler crashes
  or external-service blockers.
- **Done:**
  - Patched `srv/code/searches.js` `onReadSearch` to skip the `groupBy`
    accumulation when the request is a `$count` (otherwise the count
    column itself was being pushed into `GROUP BY count(?)`, which
    triggered HANA `ALIAS_1.ID is invalid in the ORDER BY clause`).
    Also rebuilt the inner count query as a clean
    `SELECT count(*) as count from <table> WHERE …` instead of wrapping
    the original SELECT (which still carried `orderBy`/`limit`).
  - Added defensive `if (!oEntities) continue` / null guards to the
    after-read loops in `srv/code/blocks.js` (lines ~62 & ~338),
    `srv/code/works.js` (~80), `srv/code/requests.js` (~585) and
    `srv/code/checklists.js` (~98) so collection-level reads no longer
    crash on rows whose parent block has not been materialised in the
    HXE seed.
  - Tightened `srv/code/documentsperblock.js`:
    `#prepareRequestData` now refuses to dereference
    `aResults[0].blockId` when it is missing; `afterReadDocumentsPerBlock`
    early-returns `oRequest.reply([])` for collection reads;
    `afterReadRequestDocumentsPerBlockDefaultValid` guards both
    `oRequestHead` and `oDocProcess`.
  - Re-probed all 124 entity sets via Basic auth as `FRPRCOLMNG`:
    **200 = 106**, **400 = 12** (parameterized views — by design),
    **405 = 4** (CDS `_texts` collections — by design),
    **500 = 0**.
  - Discovered actual physical schema (singular CDS table names): the
    transactional core (`REQUEST_HEAD`, `PHASE_HEAD`, `BLOCK_HEAD`,
    `MASTER_PROCESS`, `MASTER_PHASE`, `MASTER_BLOCK`, `PHASE`,
    `WORK_TYPES`, `CHECKLIST_ITEMTYPE`, `SC_SELECT_OPTIONS_V2/V3`,
    `US_COUNTRIES`, `US_ROLES`) is already populated from cmm-sync.
    Only three lookup tables surfaced empty:
    `SAP_COMMON_CURRENCIES`, `PROJECT_TYPES`, `PROCESS_TYPES`.
  - Removed throwaway `_dev_count.js` / `_dev_findtbl.js` after use.
- **Files touched:**
  `Prv/prv-intprojects-nodejs/srv/code/searches.js`,
  `Prv/prv-intprojects-nodejs/srv/code/blocks.js`,
  `Prv/prv-intprojects-nodejs/srv/code/works.js`,
  `Prv/prv-intprojects-nodejs/srv/code/requests.js`,
  `Prv/prv-intprojects-nodejs/srv/code/checklists.js`,
  `Prv/prv-intprojects-nodejs/srv/code/documentsperblock.js`.
- **State:** in-progress (server healthy; about to seed value-helps and
  attempt the create-Request flow).
- **Next step:** Seed minimal rows into `SAP_COMMON_CURRENCIES`,
  `PROJECT_TYPES` and `PROCESS_TYPES` (English placeholders, plus any
  obvious values pulled from `MASTER_PROCESS`); then GET an existing
  FR `Requests(<id>)` to confirm the read shape; then POST a new minimal
  Request, iterate over validation errors, and walk Phases → Blocks →
  document closure until the request reaches a closed state.
- **Notes:**
  - Mocked auth: `FRPRCOLMNG` / `Cellnex01.` (Basic), country `FR`.
  - Server start incantation: `cd Prv\prv-intprojects-nodejs; npm start`
    (logs to `cap-boot.log` / `cap-boot.err.log`).
  - Probe entity-set list cached at `$env:TEMP\entitysets.txt`.
  - `hdbsql` is **not** installed on host — query HANA via the
    `@sap/hana-client` Node module against `localhost:39041 / INTPROJ /
    IntprojPwd2026 / HXE`. (Earlier sessions used the docker-exec
    hdbsql inside the `prv-intprojects-hana` container, which still
    works.)
  - The 12 remaining 400s are intentional parameterized-view shapes;
    do not "fix" them by exposing them as plain collections.

### 2026-05-11 10:13 — WSL2 installed, awaiting reboot before Docker Desktop install
- **Goal:** Execute Option B (HANA Express in Docker) for the Internal
  Projects local stack. Pre-reboot install steps only this checkpoint.
- **Done:**
  - Verified env: no Docker, no WSL, 31.7 GB total RAM (5.8–6.0 GB free at
    the time), 135 GB free on C:.
  - Walked the user through Option B prerequisites; user confirmed
    `b1 go` (have Agent fire UAC prompts) and accepted that admin install
    + reboot are unavoidable.
  - Ran `wsl --install --no-launch` from an elevated child process via
    `Start-Process -Verb RunAs -Wait`; user clicked YES on the UAC
    dialog. Exit code 0. Log at `%TEMP%\wsl-install.log`.
  - VirtualMachinePlatform Windows feature enabled; Microsoft-Windows-
    Subsystem-Linux feature enabled; WSL kernel **2.7.3** installed.
    Both feature changes are pending the reboot to take effect.
- **Files touched:** none in the repo this checkpoint. Side effects on
  the host: Windows optional features VirtualMachinePlatform and WSL
  enabled; WSL2 kernel 2.7.3 installed; default Ubuntu distro NOT
  installed (used `--no-launch` to skip the username/password prompt —
  Docker Desktop ships its own `docker-desktop` WSL distro).
- **State:** blocked on user reboot.
- **Next step (after reboot):**
  1. Verify with `wsl --status` and `wsl --list --verbose` that WSL2 is
     active.
  2. Fire UAC prompt #2: `winget install --id Docker.DockerDesktop -e
     --accept-source-agreements --accept-package-agreements` via
     `Start-Process -Verb RunAs -Wait`.
  3. User opens Docker Desktop once, accepts EULA, dismisses sign-in.
  4. Poll `docker version` until daemon is reachable.
  5. Pull `saplabs/hanaexpress` (~2.5 GB), write `passwords.json` and
     `docker-compose.yml` under `Prv/prv-intprojects-app/hana/`,
     `docker compose up -d`, wait 5–10 min for HXE startup.
  6. Add a `hana` profile to `Prv/prv-intprojects-nodejs/.cdsrc-private.json`
     pointing at `localhost:39041` (XSA tenant) or `:39013` (system DB),
     run `cds deploy --to hana --profile hana`.
  7. Build a HANA-targeted loader (mirror `Cmm/cmm-sync-database/load.js`
     but using `@sap/hana-client` and `INSERT INTO ... SELECT ?, ?, ...`).
- **Notes:**
  - User has not rebooted yet at the time of this checkpoint. They will
    reboot manually (no `Restart-Computer` from Agent — would kill the
    chat session).
  - SQLite stack from the previous checkpoint remains intact; `cmm-sync.db`
    is untouched and can still be queried.
  - HANA Cloud trial (Path B2) was offered as a no-Docker fallback; user
    chose B1.
  - Free RAM target before starting HXE container: ≥12 GB. Current is
    ~6 GB; user will need to close apps before step 5.
  - Source dump 50,000-row cap (REQUEST_HEAD, BLOCK_HEAD, PHASE_HEAD,
    BLOCKS_PROVISIONING, ~25 others) still applies — switching to real
    HANA does **not** retrieve the missing rows; that requires fixing
    `Cmm/cmm-sync/sync.js` to page the HANA OData export.
  - Identity stub tables (`US_USERS_IAS`, `US_ROLES_AGR`, `US_BUKS`,
    `US_COUNTRIES`, `US_ZAGENCY`, `US_ZCUSTOMER`, `US_ZVENDOR`) will need
    to be re-created in HANA as plain tables; production keeps them as
    synonyms into a `cnx_external` schema that won't exist locally.

### 2026-05-11 09:47 — Internal Projects local stack: SQLite blocked, switching to HANA Express
- **Goal:** Stand up `Prv/prv-intprojects-app` as a single locally runnable
  aggregator of the CAP backend (`prv-intprojects-nodejs`), UI5 frontend
  (`prv-intprojects-ui5`) and the HANA DDL (`Cmm/cmm-ddl-hana`), backed by
  the loaded production data.
- **Done:**
  - Built `Cmm/cmm-sync-database/cmm-sync.db` (SQLite, 767 MB, 143 tables,
    2,431,484 rows) from the `Cmm/cmm-sync/data/*.json` dumps using a
    streaming loader (`load.js`, `node:sqlite` + `stream-json`). Handles
    UTF-8 BOM and the single-object-vs-array dump quirk in `sync.js`.
  - Scaffolded `Prv/prv-intprojects-app/` as the orchestrator
    (`package.json`, `scripts/start-srv.cjs`, `scripts/check-db.cjs`) — no
    code duplication; spawns the existing CAP project and UI5 dev server.
  - `prv-intprojects-nodejs/.cdsrc-private.json` overrides db to SQLite
    pointing at `cmm-sync.db` and stubs `Cellnex-SAPERP-HTTP` so external
    `ZTIS_*`/`ZPM_*` services don't crash boot.
  - `prv-intprojects-nodejs/package.json` got an `overrides` section
    pinning `better-sqlite3@12` so it builds on Node 24.
  - `start-srv.cjs` ensures 7 identity-stub tables (`US_USERS_IAS`,
    `US_ROLES_AGR`, `US_BUKS`, `US_COUNTRIES`, `US_ZAGENCY`,
    `US_ZCUSTOMER`, `US_ZVENDOR`) with the exact columns from
    `db/userinfo.cds` — production keeps these in a separate
    `cnx_external` HANA schema, so they're absent from the dumps.
  - CAP server now boots cleanly against SQLite (welcome page works);
    requests against base tables succeed via raw `node:sqlite`.
  - `prv-intprojects-ui5/ui5-integrated.yaml` proxies OData calls to
    `localhost:4004` (via the cov2ap `/odata/v2/...` mount).
- **Blocker discovered:** the CAP model uses **22 HANA parameterized
  views** (`db/common.cds`, `db/document.cds`, `db/processflow.cds`,
  `srv/service.cds`). The CDS compiler refuses to emit any SQLite DDL
  while these are present (`Parameterized views can't be used with
  sqlDialect 'sqlite'`), so projection views like `project_Requests`,
  `project_CancellationReasons`, `localized_project_ProjectTypes` never
  get created and every OData GET against them returns 500/400. Of the
  22, only 4 are exposed via OData (`CUSTOMERS`, `LAST_ACTIVE_PHASES`,
  `FIRST_INPROGRESS_PHASE`, `SINGLE_REQUEST_PROCESS`); the rest are
  internal helpers.
- **Decision:** user picked **Option B** — abandon SQLite for the runtime
  and run **SAP HANA Express in Docker** locally instead, then
  `cds deploy --to hana` and re-load the dumps via `hdbsql`. Keep the
  SQLite DB around as a quick read-only inspector but don't wire CAP to
  it.
- **Files touched:** `Cmm/cmm-sync-database/load.js`,
  `Cmm/cmm-sync-database/package.json`, `Cmm/cmm-sync-database/cmm-sync.db`
  (built), `Prv/prv-intprojects-app/package.json`,
  `Prv/prv-intprojects-app/scripts/start-srv.cjs`,
  `Prv/prv-intprojects-app/scripts/check-db.cjs`,
  `Prv/prv-intprojects-nodejs/package.json`,
  `Prv/prv-intprojects-nodejs/.cdsrc-private.json`,
  `Prv/prv-intprojects-ui5/ui5-integrated.yaml`,
  `Prv/prv-intprojects-app/compile-sqlite.sql` (compile-error log).
- **State:** in-progress
- **Next step:** check for Docker on this machine, pull the
  `saplabs/hanaexpress` image, bring up a single-node HXE container,
  rewire `prv-intprojects-nodejs/.cdsrc-private.json` to point at it, run
  `cds deploy --to hana`, and rebuild a HANA-targeted loader from the
  existing JSON dumps.
- **Notes:**
  - HANA Express system requirements: ~10 GB free RAM for the container
    plus Docker overhead; first image pull ≈ 2.5 GB; first deploy can
    take 20–30 minutes.
  - Source dumps are still capped at the HANA 50,000-row export limit —
    REQUEST_HEAD, BLOCK_HEAD, PHASE_HEAD, BLOCKS_PROVISIONING and ~25
    others were truncated during sync. Document that going to real HANA
    locally **does not** fix this; for full data we'd need a fresh export
    with paging in `Cmm/cmm-sync/sync.js`.
  - Identity stub tables (`US_*`) will need to be recreated as plain HANA
    tables in the local schema since the `hdbsynonym` files point at a
    `cnx_external` schema that won't exist locally.
  - Do not delete `cmm-sync.db` — it's still the cheapest way to inspect
    the loaded data (`node -e "const{DatabaseSync}=require('node:sqlite');const db=new DatabaseSync('cmm-sync.db');console.log(db.prepare('SELECT COUNT(*) FROM REQUEST_HEAD').get())"`).

### 2026-05-10 — Duplicate project cleanup + session log bootstrap
- **Goal:** Remove duplicate project folders across module subfolders, then
  set up a persistent session log so future sessions can resume context.
- **Done:**
  - Audited every module subfolder for `-N` suffixed clone duplicates.
  - Verified each candidate pair was truly a duplicate (compared file
    counts and total source size, excluding `node_modules`, `.git`, build
    artifacts; diffed file lists for the two near-identical pairs).
  - Removed 12 duplicate folders (7 in `Cmm/`, 5 in `Prv/`), keeping the
    original un-suffixed folder in each case. Specifically deleted:
    `Cmm/cmm-adminusers-ui5-1`, `Cmm/cmm-bim-ddl-hana-1`,
    `Cmm/cmm-ddl-hana-1`, `Cmm/cmm-processflow-nodejs-1`,
    `Cmm/cmm-processflow-ui5-1`, `Cmm/cmm-processflow-ui5-2`,
    `Cmm/cmm-salesforce-document-nodejs-1`, `Prv/prv-bts-nodejs-1`,
    `Prv/prv-intprojects-nodejs-1`, `Prv/prv-intprojects-ui5-1`,
    `Prv/prv-provision-ui5-1`, `Prv/prv-service-nodejs-1`.
  - Confirmed no `-N` suffixed folders remain in any module subfolder.
  - Created `/AGENTS.md` defining the session-log protocol.
  - Created this file (`.augment/SESSION_LOG.md`) and seeded it with this
    entry.
- **Files touched:** `AGENTS.md`, `.augment/SESSION_LOG.md`; deleted 12
  folders listed above.
- **State:** complete
- **Next step:** none planned. Awaiting user direction.
- **Notes:**
  - Trigger mode chosen by user is **explicit checkpoint only** (option b):
    do **not** auto-update this log; only append when the user says
    `checkpoint`, `save progress`, `update session log`, or a clear synonym.
  - `*-v2-*` / `*-v3-*` folders (e.g. `cmm-opentext-v2-nodejs`,
    `cmm-opentext-v3-bulk-nodejs`, `Acc/*-v2-ui5`) are intentional version
    branches and were deliberately kept.
  - For the two near-identical pairs, originals had one extra local-only
    file each (`default-env.json` in `prv-bts-nodejs`,
    `GODMODE.code-workspace` inside `prv-service-nodejs/srv/provisionUX/srv/`);
    these were preserved by keeping the originals.
