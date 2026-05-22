# Laptop Sibling Agent — Bootstrap

> **Paste the message at the bottom of this file into the Augment chat
> on the laptop as your first message.** It instructs the laptop-side
> agent to read the shared project state from the Catel OneDrive mirror
> (or the workspace itself) and report back the current state before
> doing anything else.

## Why this file exists

The CHost-side Augment chat (containing the live work scroll) does
**not** sync to the laptop — that's a per-VS-Code-install thing.
What *does* sync is the project's structured state:

- `AGENTS.md` — rules, architecture, conventions
- `.augment/SESSION_LOG.md` — narrative checkpoint log, newest on top
- `.augment/memory/` — raw/distilled/index entries per architect
- `.augment/scripts/` — orchestrators (cold-path, memory-append, etc.)
- `.augment/config/` — non-secret routing config

Two ways the laptop receives these:

| Source on laptop | Path |
|---|---|
| Personal OneDrive (workspace itself) | `<laptop>\OneDrive\Documentos\GODMODE\Codebase\` |
| Catel OneDrive (Tier 3c mirror) | `<laptop>\OneDrive - Palácio dos Afetos lda\MCProcessor\` |

Either is fine for context loading. The Catel mirror is preferred for
read-only context lookup because it's isolated from accidental writes.

## Boot message — copy from here into laptop Augment chat

---

You are taking over from a sibling Augment agent that has been running
on CHost. Do NOT respond to anything else until you have completed the
following bootstrap, in order:

1. Read `AGENTS.md` in full.
2. Read the top 3 entries of `.augment/SESSION_LOG.md` (entries are
   chronological, newest on top, separated by `### YYYY-MM-DD HH:MM`
   headers).
3. Open `.augment/memory/today.index.json` and note the listed
   `.vec.jsonl` files.
4. List the contents of `.augment/memory/raw/` and tell me how many
   entries exist per architect (`zepedro`, `juan`) for today's date.

Then, in a single concise reply, tell me:

- **Project state in one paragraph** (what's the system, what's built,
  what's working today, what's blocked).
- **The next planned action** as the most recent SESSION_LOG entry
  defines it.
- **Which architect should I tag myself as?** Answer is `zepedro` if
  this laptop is being used by José Pedro Medeiros, or `juan` if by
  Juan. The env var to set in every terminal is `AUGMENT_ARCHITECT`.
- **Coordination check:** there is potentially a CHost-side agent
  actively writing to `.augment/SESSION_LOG.md`. Confirm you will NOT
  checkpoint to that file until I explicitly say to. Per-architect
  raw memory files (`.augment/memory/raw/<date>.<architect>.jsonl`)
  are safe to write without coordination since they're append-only
  and architect-scoped.
- **Token discipline:** confirm you have read the "Token discipline"
  section of `AGENTS.md` and will follow rules 1-9 (narrow reads, no
  proactive file creation, no unsolicited docs, parallel tool use).

After you reply, wait for my actual task. Do not invent next steps,
do not modify any files, and do not call any tools beyond the reads
above unless I ask.

---

End of boot message.

## Architecture reminder for humans

If two laptops or two agents end up running at the same time:

- Multiple readers: fine.
- Multiple writers to per-architect raw `.jsonl`: fine if architect
  values differ.
- Multiple writers to `SESSION_LOG.md`: **conflict.** Only one agent
  checkpoints at a time. Convention: whichever agent the user is
  actively talking to is the checkpoint owner.

If you (the human reading this) want the laptop agent to actually
take over CHost-side work, signal to me (the CHost agent) "going
quiet" so I stop writing to shared state, then ask the laptop agent
to checkpoint when its turn ends.
