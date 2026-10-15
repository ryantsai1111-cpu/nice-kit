# nice-kit

**繁體中文** · [English](docs/readme/README_en.md) · [简体中文](docs/readme/README_zh.md) · [日本語](docs/readme/README_ja.md)

一套給「企業 AI 導入 / 舊系統盤點」顧問案用的專案骨架。
**不綁定單一 agent**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes 都能用。
不是另一個 skill 大全，而是**五個工具、一條流程**，開案直接跑。

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► superpowers
   (訪談)             (規格)          (盤點)           (實作)
             └──── PROGRESS.md + planning-with-files（跨 session 記憶）────┘
```

## 為什麼只有五個

每個 skill 都在跟 agent 爭 context。裝太多會變慢、互相打架。
這套選擇標準只有三條：**高頻使用、需要領域知識、錯了很貴**。三條都中才進來。

| 階段 | 工具 | 解決的問題 | 來源 |
|---|---|---|---|
| 訪談 | `grill-the-client`（本 repo） | 文件裡沒寫的事，只有資深員工知道 | 改自 [mattpocock grill-me](https://github.com/mattpocock/skills) |
| 規格 | [spec-kit](https://github.com/github/spec-kit) | 範圍沒寫清楚就開工 | GitHub 官方 |
| 盤點 | [REA](https://github.com/morluto/rea) | 沒原始碼的系統（.NET / Electron / APK / 封包） | MIT |
| 盤點 | 資料庫 MCP server | 有唯讀帳號就能直讀 schema，比反編譯快 | 依客戶 DB 選 |
| 實作 | [superpowers](https://github.com/obra/superpowers) | Claude 不想清楚就寫 code | Anthropic 官方 marketplace |
| 記憶 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 案子拖幾週，每次重頭講 | 所有 agent 通用；Claude Code 另加 [claude-mem](https://github.com/thedotmack/claude-mem) |
| 補缺 | `inventory-gaps`（本 repo） | 把 REA 的 unknowns 變成訪談題目 | 原創 |

## 安裝

需要 Node.js 22.19+ 和至少一個 agent CLI。spec-kit 需要 [uv](https://docs.astral.sh/uv/)（腳本會自動裝）。

**只要 skills（任何 agent）：**
```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # 換成你的 agent
```

**完整安裝（skills + superpowers + spec-kit + REA + 記憶）：**
```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                      # 自動偵測已裝的 agent
./scripts/install.sh -a claude-code,codex # 或指定
.\scripts\install.ps1                     # Windows
./scripts/doctor.sh                       # 檢查
```

agent 識別碼與各工具的相容狀況見 [docs/agents.md](docs/agents.md)。
資料庫 MCP server 依客戶環境不同，見 [docs/db-mcp.md](docs/db-mcp.md)。

## 開案流程

```bash
./scripts/init.sh <案名>                  # 跑 specify init、放 AGENTS.md 等範本
./scripts/init.sh <案名> -a codex,cursor  # 多 agent
```
然後依序（slash command 寫法依 agent 略有不同，見 docs/agents.md）：

| 步驟 | 怎麼觸發 | 產出 |
|---|---|---|
| 1 | 載入 `grill-the-client`（或說「訪談客戶」） | `.grill/<日期>-<主題>.md` 訪談紀錄 |
| 2 | spec-kit：constitution → specify → clarify | `specs/` 範圍與限制 |
| 3 | 「用 REA 盤點 `<路徑>`，列出所有 unknowns」 | 盤點報告 + unknowns 清單 |
| 4 | 載入 `inventory-gaps`（或說「整理 unknowns」） | 第二輪訪談題目 |
| 5 | spec-kit：plan → tasks | 任務清單 |
| 6 | superpowers 自動接手實作 | 程式碼 + 測試 |

完整說明見 [docs/workflow.md](docs/workflow.md)。

## 目錄

```
nice-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── install.sh / .ps1      # 多 agent 安裝
│   ├── init.sh / .ps1         # 開新案
│   └── doctor.sh              # 檢查安裝
├── templates/
│   ├── AGENTS.md              # 專案規範主檔（所有 agent 讀）
│   ├── CLAUDE.md / GEMINI.md  # 只有一行 @AGENTS.md
│   ├── .cursor/rules/         # Cursor 指向 AGENTS.md
│   └── PROGRESS.md            # 跨 session 記憶
├── docs/
│   ├── workflow.md            # 六步流程詳解
│   ├── agents.md              # 各 agent 相容矩陣與名稱對照
│   ├── db-mcp.md              # 資料庫 MCP 選型
│   ├── legal.md               # 授權與資安前提
│   └── readme/                # 其他語言的 README
└── skills/
    ├── grill-the-client/SKILL.md
    └── inventory-gaps/SKILL.md
```

## 法律與資安前提

REA 只能分析你**擁有或獲授權**檢視的軟體。商用 ERP 的授權條款可能禁止反編譯，
合約裡要寫明客戶授權分析自有系統，而且所有分析只在客戶機房內跑。
詳見 [docs/legal.md](docs/legal.md)。

## 授權

MIT。各上游工具保留各自授權。
