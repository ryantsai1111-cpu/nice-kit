# 各 agent 支援狀況

nice-kit 以 [Agent Skills 開放格式](https://agentskills.io) 為核心，
用 [skills CLI](https://github.com/vercel-labs/skills) 安裝，所以 **skill 的部分在 70+ 個 agent 上都能用**。
差別在周邊工具（spec-kit、REA、記憶）各自支援的範圍。

## 相容矩陣

| 元件 | Claude Code | Codex | Cursor | Gemini CLI | Copilot | OpenCode | Hermes | 其他 |
|---|---|---|---|---|---|---|---|---|
| grill-the-client / inventory-gaps（skill） | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ 任何讀 `.agents/skills` 或 `SKILL.md` 的 agent |
| superpowers（skill） | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| planning-with-files（記憶，skill） | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| spec-kit（slash command） | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | windsurf, roo, kilocode, qwen, amp, codebuddy, q, auggie… |
| REA（MCP） | ✓ | ✓ | ✓ | ✓ | ✗ 手動 | ✓ | ✓ 手動 | 任何支援本機 MCP server 的 agent |
| claude-mem（自動記憶） | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | Claude 專屬，其他 agent 用 PROGRESS.md + planning-with-files |
| AGENTS.md（專案規範） | 經 CLAUDE.md `@AGENTS.md` | ✓ 原生 | 經 `.cursor/rules` | 經 GEMINI.md | ✓ 原生 | ✓ 原生 | ✓ 原生 | 多數 agent 原生讀 AGENTS.md |

「手動」表示該工具的 setup 不會自動註冊，要自己把 MCP 設定貼進 agent 的 config。

## 名稱對照

同一個 agent 在不同工具裡的識別碼不一樣。`scripts/init.sh` 會自動對照，手動時查這張表：

| Agent | skills CLI `--agent` | spec-kit `--integration` | 專案規範檔 | 全域 skills 路徑 |
|---|---|---|---|---|
| Claude Code | `claude-code` | `claude` | CLAUDE.md | `~/.claude/skills/` |
| Codex | `codex` | `codex` | AGENTS.md | `~/.codex/skills/` |
| Cursor | `cursor` | `cursor-agent` | `.cursor/rules/*.mdc` | `~/.cursor/skills/` |
| Gemini CLI | `gemini-cli` | `gemini` | GEMINI.md | `~/.gemini/skills/` |
| GitHub Copilot | `github-copilot` | `copilot` | AGENTS.md | `~/.copilot/skills/` |
| OpenCode | `opencode` | `opencode` | AGENTS.md | `~/.config/opencode/skills/` |
| Windsurf | `windsurf` | `windsurf` | AGENTS.md | `~/.codeium/windsurf/skills/` |
| Roo Code | `roo` | `roo` | AGENTS.md | `~/.roo/skills/` |
| Kilo Code | `kilo` | `kilocode` | AGENTS.md | `~/.kilocode/skills/` |
| Qwen Code | `qwen-code` | `qwen` | AGENTS.md | `~/.qwen/skills/` |
| Hermes Agent | `hermes-agent` | — | AGENTS.md | `~/.hermes/skills/` |
| 通用（多數 agent 共用） | `universal` | — | AGENTS.md | `~/.config/agents/skills/` |

完整清單：`npx skills add --help`。

## slash command 寫法

spec-kit 產生的指令在各 agent 的呼叫方式：

| Agent | 寫法 |
|---|---|
| Claude Code、Gemini CLI、Copilot、OpenCode | `/speckit.specify` |
| Codex | `$speckit.specify` 或在 prompt 裡提到 |
| Cursor | `/speckit.specify`（agent mode） |
| Hermes、其他無 slash 的 agent | 自然語言：「依照 spec-kit 的 specify 流程寫 spec」 |

nice-kit 自己的 skill 沒有 slash command 依賴。說「訪談客戶」「整理 unknowns」就會觸發；
有 slash 的 agent 也可以 `/grill-the-client`。

## 只用一個 agent 的話

```bash
./scripts/install.sh -a codex
./scripts/init.sh 案名 -a codex
```

## 同時用好幾個

```bash
./scripts/install.sh -a claude-code,codex,cursor
./scripts/init.sh 案名 -a claude-code,codex,cursor
```

skills 會裝到每個 agent 的目錄；spec-kit 會為每個 agent 各產一份指令；
AGENTS.md 一份，CLAUDE.md / GEMINI.md / `.cursor/rules` 都指向它，改一處全部生效。

## 記憶層怎麼跨 agent

claude-mem 只在 Claude Code 上有。為了讓每個 agent 都能接續，nice-kit 用兩層：

1. **PROGRESS.md**（人可讀）：每個 session 結束前更新「做了什麼、決定了什麼、下次從哪開始」。AGENTS.md 已規定每次開始先讀它。
2. **planning-with-files**（skill）：把計畫寫成 repo 裡的 markdown，任何 agent 都讀得到。

Claude Code 用戶額外得到 claude-mem 的自動壓縮，但不依賴它。
