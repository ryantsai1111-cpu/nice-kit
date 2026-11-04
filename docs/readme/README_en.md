# nice-kit

[繁體中文](../../README.md) · **English** · [简体中文](README_zh.md) · [日本語](README_ja.md)

A project skeleton for building with AI agents: **a core layer plus domain packs**.
**Not tied to one agent**: works with Claude Code, Codex, Cursor, Gemini CLI, Copilot, OpenCode and Hermes.
It is not a skill collection. The pitch is one sentence: **whichever agent you use and whatever you're building, the first ten minutes of a project look the same.**

```
                    ┌──────────── core (every project) ─────────────┐
                    │ spec-kit ──► superpowers ──► check.sh         │
                    │  (spec)       (build)        (pre-delivery)   │
                    │ Context7 + Playwright MCP    PROGRESS.md      │
                    │  (docs)      (browser)       (cross-session)  │
                    └─────────────────┬─────────────────────────────┘
                                      │ init.sh -p <pack>
        ┌─────────────────────────────┴──────────────────────────────┐
        │ legacy-consulting                │ web-app                  │
        │ interview → inventory → gaps →   │ spec → e2e acceptance →  │
        │ characterization tests           │ build                    │
        └──────────────────────────────────┴──────────────────────────┘
```

## Why two layers

Every skill competes with the agent for context. Install too many and things slow down and fight each other.
There are three selection criteria: **used often, needs domain knowledge, expensive to get wrong**. A tool has to hit all three.

- **Core**: hits all three regardless of what you're building. Seven items; three of them are MCP servers or scripts and take no agent context.
- **Packs**: hit all three only within one domain. Pick one with `-p` when you start a project; pick none and you get core only.

### Core

| Role | Tool | Problem it solves | Source |
|---|---|---|---|
| Spec | [spec-kit](https://github.com/github/spec-kit) | Starting work before scope is written down | GitHub official |
| Build discipline | [superpowers](https://github.com/obra/superpowers) | The agent writing code before thinking it through | Anthropic official marketplace |
| Docs lookup | [Context7 MCP](https://github.com/upstash/context7) | APIs hallucinated from memory | Upstash |
| Browser | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | "The build passed" without ever opening the page | Microsoft official |
| Pre-delivery | `scripts/check.sh` (this repo) + [gitleaks](https://github.com/gitleaks/gitleaks) | Secrets in the repo, tests not run, progress not recorded | Original + MIT |
| Memory | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | Projects run for weeks; nobody wants to re-explain everything | Every agent; Claude Code adds [claude-mem](https://github.com/thedotmack/claude-mem) |
| Rules | `templates/AGENTS.md` (this repo) | Seven agents, seven config files | One AGENTS.md; CLAUDE.md / GEMINI.md / `.cursor/rules` all point at it |

### Packs

| pack | When | What it adds |
|---|---|---|
| [legacy-consulting](../../packs/legacy-consulting/) | Enterprise AI adoption, legacy system inventory engagements | `grill-the-client` (interview), [REA](https://github.com/morluto/rea) + DB MCP (inventory), `inventory-gaps` (gap-filling), `characterization-tests` (behaviour capture), data-sensitivity and local/cloud split rules |
| [web-app](../../packs/web-app/) | Web application development | `e2e-from-spec` (spec → Playwright acceptance tests), rules for actually looking at the screen |

To write your own: [docs/packs.md](../packs.md). One `pack.conf`, one `templates/AGENTS.pack.md`, optionally a few skills and hooks.

## Install

Requires Node.js 22.19+ and at least one agent CLI. spec-kit needs [uv](https://docs.astral.sh/uv/) (the script installs it).

**Skills only (any agent):**
```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # swap in your agent; lists every pack's skills to pick from
```

**Full install:**
```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                        # core only, auto-detects installed agents
./scripts/install.sh -p legacy-consulting   # core + a pack
./scripts/install.sh -a claude-code,codex   # choose agents
./scripts/install.sh --list-packs
.\scripts\install.ps1 -Packs web-app        # Windows
./scripts/doctor.sh                         # verify
```

MCP servers register automatically on Claude Code / Codex / Gemini CLI; other agents get a config snippet to paste, see [docs/mcp.md](../mcp.md).
Agent identifiers and compatibility: [docs/agents.md](../agents.md).

## Starting a project

```bash
./scripts/init.sh <name>                          # core templates
./scripts/init.sh <name> -p legacy-consulting     # plus the pack's rules and directories
./scripts/init.sh <name> -p web-app -a codex,cursor
```

init runs `specify init` (one set of spec-kit commands per agent) and drops in AGENTS.md / CLAUDE.md / GEMINI.md / `.cursor/rules` / PROGRESS.md; with `-p` it appends the pack's domain rules to AGENTS.md and creates the pack's directories.

Then:

| Step | Core | legacy-consulting adds | web-app adds |
|---|---|---|---|
| 0 | Fill in the `<>` in AGENTS.md | | |
| 1 | | `grill-the-client` interviews → `.grill/` | |
| 2 | spec-kit: constitution → specify → clarify | | |
| 3 | | REA / DB MCP inventory → `inventory-gaps` → second interview | |
| 4 | spec-kit: plan → tasks | | |
| 5 | | `characterization-tests` records the old system's behaviour | `e2e-from-spec` writes acceptance tests (red first) |
| 6 | superpowers builds | characterization tests passing = done | e2e turning green = done |
| 7 | `check.sh` pre-delivery | | |

Slash-command syntax varies by agent (Claude `/speckit.specify`, Codex `$speckit.specify`); see docs/agents.md.
Each pack's full walkthrough is in its own README and docs.

## Layout

```
nice-kit/
├── scripts/
│   ├── lib.sh                 # shared functions (agent detection, MCP registration, pack loading)
│   ├── install.sh / .ps1      # core + optional packs
│   ├── init.sh / .ps1         # start a project, -p picks a pack
│   ├── doctor.sh              # verify the install
│   └── check.sh               # pre-delivery: secrets / tests / PROGRESS.md
├── templates/                 # core: AGENTS.md, CLAUDE.md, GEMINI.md, .cursor/rules, PROGRESS.md
├── docs/                      # agents.md, mcp.md, packs.md, readme/
└── packs/
    ├── legacy-consulting/     # pack.conf, README, skills/, templates/, hooks/, docs/
    └── web-app/               # pack.conf, README, skills/, templates/, hooks/
```

## Legal and security prerequisites

REA (in legacy-consulting) may only analyse software you **own or are authorised** to examine. Commercial ERP licences often forbid decompilation.
The contract must state that the client authorises analysis of its own systems, and all analysis runs inside the client's own infrastructure.
Details: [packs/legacy-consulting/docs/legal.md](../../packs/legacy-consulting/docs/legal.md).

## Licence

MIT. Upstream tools keep their own licences.
