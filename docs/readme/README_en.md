# nice-kit

[繁體中文](../../README.md) · **English** · [简体中文](README_zh.md) · [日本語](README_ja.md)

A project skeleton for "enterprise AI adoption / legacy system inventory" consulting engagements.
**Not tied to one agent**: works with Claude Code, Codex, Cursor, Gemini CLI, Copilot, OpenCode and Hermes.
It is not another skill collection. It is **five tools and one workflow** you can run on day one of an engagement.

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► superpowers
   (interview)        (spec)        (inventory)      (build)
             └──── PROGRESS.md + planning-with-files (cross-session memory) ────┘
```

## Why only five

Every skill competes with the agent for context. Install too many and things slow down and fight each other.
There are three selection criteria: **used often, needs domain knowledge, expensive to get wrong**. A tool has to hit all three.

| Stage | Tool | Problem it solves | Source |
|---|---|---|---|
| Interview | `grill-the-client` (this repo) | Things that aren't in any document and only veteran staff know | Adapted from [mattpocock grill-me](https://github.com/mattpocock/skills) |
| Spec | [spec-kit](https://github.com/github/spec-kit) | Starting work before scope is written down | GitHub official |
| Inventory | [REA](https://github.com/morluto/rea) | Systems with no source code (.NET / Electron / APK / packet captures) | MIT |
| Inventory | Database MCP server | A read-only account reads the schema directly, faster than decompiling | Pick per client DB |
| Build | [superpowers](https://github.com/obra/superpowers) | The agent writing code before thinking it through | Anthropic official marketplace |
| Memory | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | Engagements run for weeks; nobody wants to re-explain everything | Works on every agent; Claude Code adds [claude-mem](https://github.com/thedotmack/claude-mem) |
| Gap-filling | `inventory-gaps` (this repo) | Turns REA's unknowns into interview questions | Original |

## Install

Requires Node.js 22.19+ and at least one agent CLI. spec-kit needs [uv](https://docs.astral.sh/uv/) (the script installs it).

**Skills only (any agent):**
```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # swap in your agent
```

**Full install (skills + superpowers + spec-kit + REA + memory):**
```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                      # auto-detects installed agents
./scripts/install.sh -a claude-code,codex # or specify
.\scripts\install.ps1                     # Windows
./scripts/doctor.sh                       # verify
```

Agent identifiers and per-tool compatibility: [docs/agents.md](../agents.md).
Database MCP servers vary by client environment: [docs/db-mcp.md](../db-mcp.md).

## Starting an engagement

```bash
./scripts/init.sh <name>                  # runs specify init, drops in AGENTS.md etc.
./scripts/init.sh <name> -a codex,cursor  # multiple agents
```
Then, in order (slash-command syntax varies slightly by agent; see docs/agents.md):

| Step | How to trigger | Output |
|---|---|---|
| 1 | Load `grill-the-client` (or say "interview the client") | `.grill/<date>-<topic>.md` interview record |
| 2 | spec-kit: constitution → specify → clarify | `specs/` scope and constraints |
| 3 | "Use REA to inventory `<path>`, list every unknown" | Inventory report + unknowns list |
| 4 | Load `inventory-gaps` (or say "organise the unknowns") | Second-round interview questions |
| 5 | spec-kit: plan → tasks | Task list |
| 6 | superpowers takes over implementation | Code + tests |

Full walkthrough: [docs/workflow.md](../workflow.md).

## Layout

```
nice-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── install.sh / .ps1      # multi-agent install
│   ├── init.sh / .ps1         # start a new engagement
│   └── doctor.sh              # verify the install
├── templates/
│   ├── AGENTS.md              # canonical project rules (every agent reads it)
│   ├── CLAUDE.md / GEMINI.md  # one line: @AGENTS.md
│   ├── .cursor/rules/         # Cursor points at AGENTS.md
│   └── PROGRESS.md            # cross-session memory
├── docs/
│   ├── workflow.md            # the six steps in detail
│   ├── agents.md              # compatibility matrix and name mapping
│   ├── db-mcp.md              # choosing a database MCP server
│   ├── legal.md               # licensing and security prerequisites
│   └── readme/                # translations
└── skills/
    ├── grill-the-client/SKILL.md
    └── inventory-gaps/SKILL.md
```

## Legal and security prerequisites

REA may only analyse software you **own or are authorised** to examine. Commercial ERP licences often forbid decompilation.
The contract must state that the client authorises analysis of its own systems, and all analysis runs inside the client's own infrastructure.
Details: [docs/legal.md](../legal.md).

## Licence

MIT. Upstream tools keep their own licences.
