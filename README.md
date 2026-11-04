# nice-kit

**繁體中文** · [English](docs/readme/README_en.md) · [简体中文](docs/readme/README_zh.md) · [日本語](docs/readme/README_ja.md)

一套給 AI agent 開發用的專案骨架：**核心層 + 領域包**。
**不綁定單一 agent**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes 都能用。
不是 skill 大全。賣點只有一句：**不管你用哪個 agent、做哪種專案，開案的前十分鐘長得一樣。**

```
                    ┌──────────── 核心層（任何專案）────────────┐
                    │ spec-kit ──► superpowers ──► check.sh    │
                    │  (規格)       (實作)         (交付前)     │
                    │ Context7 + Playwright MCP   PROGRESS.md  │
                    │  (查文件)    (看畫面)        (跨 session) │
                    └─────────────────┬────────────────────────┘
                                      │ init.sh -p <pack>
        ┌─────────────────────────────┴──────────────────────────────┐
        │ legacy-consulting                │ web-app                  │
        │ 訪談 → 盤點 → 補缺 → 行為封存      │ 規格 → E2E 驗收 → 實作    │
        └──────────────────────────────────┴──────────────────────────┘
```

## 為什麼分兩層

每個 skill 都在跟 agent 爭 context。裝太多會變慢、互相打架。
所以選擇標準只有三條：**高頻使用、需要領域知識、錯了很貴**。三條都中才進來。

- **核心層**：不管做什麼專案，三條都中的。七件，其中三件是 MCP server 或 script，不佔 agent context。
- **領域包（pack）**：只在某個領域三條都中的。開案時用 `-p` 選一個，不選就只有核心。

### 核心層

| 類別 | 工具 | 解決的問題 | 來源 |
|---|---|---|---|
| 規格 | [spec-kit](https://github.com/github/spec-kit) | 範圍沒寫清楚就開工 | GitHub 官方 |
| 實作紀律 | [superpowers](https://github.com/obra/superpowers) | agent 不想清楚就寫 code | Anthropic 官方 marketplace |
| 查文件 | [Context7 MCP](https://github.com/upstash/context7) | agent 憑印象寫出不存在的 API | Upstash |
| 看畫面 | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | 只看 build 過了，沒開過頁面 | 微軟官方 |
| 交付前 | `scripts/check.sh`（本 repo）+ [gitleaks](https://github.com/gitleaks/gitleaks) | secret 進 repo、測試沒跑、進度沒記 | 原創 + MIT |
| 記憶 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 案子拖幾週，每次重頭講 | 所有 agent 通用；Claude Code 另加 [claude-mem](https://github.com/thedotmack/claude-mem) |
| 規範 | `templates/AGENTS.md`（本 repo） | 七種 agent 各讀各的設定檔 | 一份 AGENTS.md，CLAUDE.md / GEMINI.md / `.cursor/rules` 都指向它 |

### 領域包

| pack | 情境 | 加了什麼 |
|---|---|---|
| [legacy-consulting](packs/legacy-consulting/) | 企業 AI 導入、舊系統盤點顧問案 | `grill-the-client`（訪談）、[REA](https://github.com/morluto/rea) + DB MCP（盤點）、`inventory-gaps`（補缺）、`characterization-tests`（行為封存）、資料敏感度與本地/雲端分工規範 |
| [web-app](packs/web-app/) | Web 應用開發 | `e2e-from-spec`（spec → Playwright 驗收測試）、看畫面規則 |

要加自己的 pack：見 [docs/packs.md](docs/packs.md)。一個 `pack.conf`、一個 `templates/AGENTS.pack.md`、需要的話幾個 skill 與 hook。

## 安裝

需要 Node.js 22.19+ 和至少一個 agent CLI。spec-kit 需要 [uv](https://docs.astral.sh/uv/)（腳本會自動裝）。

**只要 skills（任何 agent）：**

```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # 換成你的 agent；會列出所有 pack 的 skill 讓你挑
```

**完整安裝：**

```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                        # 只裝核心，自動偵測已裝的 agent
./scripts/install.sh -p legacy-consulting   # 核心 + 領域包
./scripts/install.sh -a claude-code,codex   # 指定 agent
./scripts/install.sh --list-packs           # 看有哪些 pack
.\scripts\install.ps1 -Packs web-app        # Windows
./scripts/doctor.sh                         # 檢查
```

MCP 在 Claude Code / Codex / Gemini CLI 會自動註冊，其他 agent 會印出設定片段讓你貼，見 [docs/mcp.md](docs/mcp.md)。
agent 識別碼與相容狀況見 [docs/agents.md](docs/agents.md)。

## 開案

```bash
./scripts/init.sh <案名>                          # 核心範本
./scripts/init.sh <案名> -p legacy-consulting     # 附加領域規範與目錄
./scripts/init.sh <案名> -p web-app -a codex,cursor
```

init 會跑 `specify init`（每個 agent 一份 spec-kit 指令）、放入 AGENTS.md / CLAUDE.md / GEMINI.md / `.cursor/rules` / PROGRESS.md；有 `-p` 時把 pack 的「領域規範」接在 AGENTS.md 後面、建 pack 需要的目錄。

然後：

| 步驟 | 核心流程 | legacy-consulting 加的 | web-app 加的 |
|---|---|---|---|
| 0 | 填 AGENTS.md 的 `<>` | | |
| 1 | | `grill-the-client` 訪談 → `.grill/` | |
| 2 | spec-kit：constitution → specify → clarify | | |
| 3 | | REA / DB MCP 盤點 → `inventory-gaps` → 再訪談 | |
| 4 | spec-kit：plan → tasks | | |
| 5 | | `characterization-tests` 錄舊系統行為 | `e2e-from-spec` 寫驗收測試（先紅） |
| 6 | superpowers 實作 | 以 characterization 通過為驗收 | 以 e2e 變綠為驗收 |
| 7 | `check.sh` 交付前檢查 | | |

slash command 寫法依 agent 不同（Claude `/speckit.specify`，Codex `$speckit.specify`），見 docs/agents.md。
各 pack 的完整流程見其目錄下的 README 與 docs。

## 目錄

```
nice-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── lib.sh                 # 共用函式（agent 偵測、MCP 註冊、pack 載入）
│   ├── install.sh / .ps1      # 核心 + 可選 pack 的安裝
│   ├── init.sh / .ps1         # 開新案，-p 選 pack
│   ├── doctor.sh              # 檢查安裝
│   └── check.sh               # 交付前：secret / 測試 / PROGRESS.md
├── templates/                 # 核心範本
│   ├── AGENTS.md              # 專案規範主檔（所有 agent 讀）
│   ├── CLAUDE.md / GEMINI.md  # 只有一行 @AGENTS.md
│   ├── .cursor/rules/         # Cursor 指向 AGENTS.md
│   └── PROGRESS.md            # 跨 session 記憶
├── docs/
│   ├── agents.md              # 各 agent 相容矩陣與名稱對照
│   ├── mcp.md                 # MCP 註冊方式（自動與手動）
│   ├── packs.md               # 怎麼寫一個 pack
│   └── readme/                # 其他語言的 README
└── packs/
    ├── legacy-consulting/
    │   ├── pack.conf
    │   ├── README.md
    │   ├── skills/            # grill-the-client, inventory-gaps, characterization-tests
    │   ├── templates/         # AGENTS.pack.md
    │   ├── hooks/             # install / doctor
    │   └── docs/              # workflow, db-mcp, legal
    └── web-app/
        ├── pack.conf
        ├── README.md
        ├── skills/            # e2e-from-spec
        ├── templates/         # AGENTS.pack.md
        └── hooks/             # doctor
```

## 法律與資安前提

legacy-consulting 裡的 REA 只能分析你**擁有或獲授權**檢視的軟體。商用 ERP 的授權條款可能禁止反編譯，
合約裡要寫明客戶授權分析自有系統，而且所有分析只在客戶機房內跑。
詳見 [packs/legacy-consulting/docs/legal.md](packs/legacy-consulting/docs/legal.md)。

## 授權

MIT。各上游工具保留各自授權。
