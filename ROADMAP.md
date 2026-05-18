# MCProcessor Roadmap

Single source of truth for direction and sequencing. Updated only when scope changes are decided.

## Vision

Transform the imported "Internal Projects" baseline into a **domain-agnostic abstract process engine** where new business processes are added by configuration. Eventually exposed as an MCP (Model Context Protocol) server so AI agents can drive workflows.

## Tracks

Four parallel work tracks. Tasks within a track are sequential; tracks themselves can progress in parallel where dependencies allow.

```mermaid
gantt
    title MCProcessor — Phase 1 to Phase 3 (indicative)
    dateFormat  YYYY-MM-DD
    axisFormat  %b %d

    section DB (data model)
    Inventory consumers of provisioning tables   :db1, 2026-05-19, 1d
    Prove/refute 1:1 invariant in HXE            :db2, after db1, 1d
    Decide flatten vs projection                 :crit, db3, after db2, 1d
    Migration script / projection views          :db4, after db3, 3d
    Anonymize naming (table+field rename)        :db5, after db4, 3d

    section CFG (config apps)
    ValidatorDefinitions CDS entity              :cfg1, 2026-05-19, 1d
    JSON Schema + JSONLogic runner               :cfg2, after cfg1, 2d
    Extend Document Parameterization app         :cfg3, after cfg2, 3d
    Migrate hardcoded validators to data         :cfg4, after cfg3, 2d

    section ENG (abstract engine)
    Metadata: FieldDefinitions + values          :eng1, after cfg1, 2d
    Abstract Block CAP service                   :eng2, after eng1, 3d
    $select metadata-pruning middleware          :eng3, after eng2, 2d
    Abstract Block UI5 component (3x10 render)   :eng4, after eng3, 4d
    Select Option V3 selectors                   :eng5, after eng3, 3d
    Replicate one block end-to-end               :crit, eng6, after eng4 eng5, 3d

    section INF (infrastructure)
    Pick local LLM (Ollama + Continue.dev)       :inf1, 2026-05-19, 1d
    GitHub repo init + baseline push             :done, inf2, 2026-05-18, 1d
    ROADMAP + GitHub Projects board              :inf3, after inf2, 1d
    Local RAG index of the repo                  :inf4, after inf1, 1d
```

## Architectural pillars (must hold throughout)

1. **Metadata-driven, not column-wide.** Block fields live in `FieldDefinitions` + `BlockFieldValues` (EAV-style), not 300-wide tables.
2. **Validators as data.** JSON Schema (shape) + JSONLogic (cross-field). No embedded JS sandboxes.
3. **Backend-authoritative.** UI may enforce, backend must enforce. Validators run both sides.
4. **Anonymize before extending.** Phase 2 renames precede Phase 3 features; never the other way.
5. **Slow is smooth.** Validation, tests, and review gates over throughput.

## Phases

| Phase | Outcome | Tracks involved | Status |
|---|---|---|---|
| **0** | Baseline imported, repo + tooling established | INF | ✅ done |
| **1** | Database flattened (1:1 merges), validators parameterized, document-param app extended | DB · CFG | not started |
| **2** | Domain-neutral: anonymized names, Abstract Block component, 10×10×30 matrix metadata, query optimization | DB · CFG · ENG | not started |
| **3** | Field Control per-block parameterization, unified shell navigation, Select Option V3 selectors | CFG · ENG | not started |
| **4** | Local LLM (Ollama + Continue.dev) for repetitive coding; MCProcessor exposed as MCP server | INF | not started |
| **5** | Cross-platform vision: S/4HANA (ABAP) and OutSystems adapters; cross-process comparison via shared meta-model | DB · ENG | not started |

## Immediate next actions (post-baseline)

1. **DB-1** — `git grep` consumers of `RequestProvision` / `BlockProvisioning` in the imported tree
2. **CFG-1** — Draft `ValidatorDefinitions` CDS entity and discuss with reviewer before commit
3. **INF-1** — `winget install Ollama.Ollama`, pull `qwen2.5-coder:7b-instruct-q4_K_M`, wire Continue.dev to it
4. **INF-3** — Open a GitHub Projects board on this repo, seed it from this Gantt

## Open architectural questions

- EAV vs. JSON-column for `BlockFieldValues` value storage (lean toward EAV with typed value columns)
- Validator UX: dedicated app or extend existing Document Parameterization?
- Selector V3 schema spec — borrow from existing `SelectOption` table or redesign?
- MCP transport choice: stdio vs. SSE for the eventual MCP server

These are tracked as issues once the GitHub Projects board exists.
