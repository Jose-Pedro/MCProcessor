# MCProcessor

Domain-agnostic **Master Process Controller** — an abstract processor for business workflows, built on SAP CAP and evolving toward cross-platform support (S/4HANA, OutSystems, Git).

This repository starts from a working "Internal Projects" baseline that already implements a configurable Request → Phase → Block → Checklist engine with mandatory-gate transitions. The aim is to evolve that baseline into a metadata-driven, fully parameterized process engine where new business processes can be added by **configuration**, not code.

## Status

Early — Phase 0 (baseline import). See [`ROADMAP.md`](./ROADMAP.md) for the full plan.

## Layout

| Path | Role |
|---|---|
| `Prv/prv-intprojects-app/` | Umbrella application + approuter + HANA bootstrap helpers |
| `Prv/prv-intprojects-nodejs/` | CAP backend (CDS schema, services, business logic, event handlers) |
| `Prv/prv-intprojects-ui5/` | Fiori UI5 frontend (sap.ushell shell, Phase/Block views) |
| `.augment/SESSION_LOG.md` | Per-session work log for the AI development assistant (Augment Agent) |

These names will be renamed to `mcprocessor-*` once Phase 2 anonymization is complete.

## Local development

Prerequisites: Node 18+, SAP HANA Express (HXE) running locally, `@sap/cds-dk` globally installed.

```powershell
# CAP backend (port 4004)
cd Prv\prv-intprojects-nodejs
npm install
npm start

# UI5 frontend (port 8080, integrated proxy to :4004 + ui5.sap.com)
cd ..\prv-intprojects-ui5
npm install
npm run start-integrated
```

Open <http://localhost:8080/test/flp.html> after both servers report ready.

## Philosophy

> **Slow is smooth. Smooth is fast.**

Robust, abstract, parameterized solutions over rapid unvalidated development. Local-first tooling, cost-efficient automation, and architectural validation before implementation.

## License

Private. All rights reserved until a license is chosen.
