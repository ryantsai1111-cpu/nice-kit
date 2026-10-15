# enterprise-ai-kit

一套給「企業 AI 導入 / 舊系統盤點」顧問案用的 Claude Code 專案骨架。
不是另一個 skill 大全，而是**五個工具、一條流程**，開案直接跑。

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► superpowers
   (訪談)             (規格)          (盤點)           (實作)
                └──────────── claude-mem（跨 session 記憶）────────────┘
```

## 為什麼只有五個

每個 skill 都在跟 Claude 爭 context。裝太多會變慢、互相打架。
這套選擇標準只有三條：**高頻使用、需要領域知識、錯了很貴**。三條都中才進來。

| 階段 | 工具 | 解決的問題 | 來源 |
|---|---|---|---|
| 訪談 | `grill-the-client`（本 repo） | 文件裡沒寫的事，只有資深員工知道 | 改自 [mattpocock grill-me](https://github.com/mattpocock/skills) |
| 規格 | [spec-kit](https://github.com/github/spec-kit) | 範圍沒寫清楚就開工 | GitHub 官方 |
| 盤點 | [REA](https://github.com/morluto/rea) | 沒原始碼的系統（.NET / Electron / APK / 封包） | MIT |
| 盤點 | 資料庫 MCP server | 有唯讀帳號就能直讀 schema，比反編譯快 | 依客戶 DB 選 |
| 實作 | [superpowers](https://github.com/obra/superpowers) | Claude 不想清楚就寫 code | Anthropic 官方 marketplace |
| 記憶 | [claude-mem](https://github.com/thedotmack/claude-mem) | 案子拖幾週，每次重頭講 | 社群 |
| 補缺 | `inventory-gaps`（本 repo） | 把 REA 的 unknowns 變成訪談題目 | 原創 |

## 安裝

需要 Node.js 22.19+ 與 Claude Code。

```bash
git clone https://github.com/<you>/enterprise-ai-kit
cd enterprise-ai-kit
./scripts/install.sh        # macOS / Linux
# 或
.\scripts\install.ps1       # Windows PowerShell
```

腳本會：
1. 用 `npx skills add` 裝 superpowers、spec-kit 的 skill
2. 安裝 claude-mem plugin
3. 跑 `npx rea-agents setup`（互動式，會問你要註冊哪些 agent）
4. 把本 repo 的 `skills/` 複製到 `~/.claude/skills/`

資料庫 MCP server 依客戶環境不同，見 [docs/db-mcp.md](docs/db-mcp.md)。

## 開案流程

把 `templates/CLAUDE.md` 複製到新專案根目錄，然後依序：

| 步驟 | 指令 | 產出 |
|---|---|---|
| 1 | `/grill-the-client` | `.grill/<日期>-<主題>.md` 訪談紀錄 |
| 2 | `/speckit.constitution` → `/speckit.specify` → `/speckit.clarify` | `specs/` 範圍與限制 |
| 3 | 「用 REA 盤點 `<路徑>`，列出所有 unknowns」 | 盤點報告 + unknowns 清單 |
| 4 | `/inventory-gaps` | 把 unknowns 轉成第二輪訪談題目 |
| 5 | `/speckit.plan` → `/speckit.tasks` | 任務清單 |
| 6 | superpowers 自動接手實作 | 程式碼 + 測試 |

完整說明見 [docs/workflow.md](docs/workflow.md)。

## 目錄

```
enterprise-ai-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── install.sh
│   └── install.ps1
├── templates/
│   └── CLAUDE.md              # 新專案根目錄用
├── docs/
│   ├── workflow.md            # 六步流程詳解
│   ├── db-mcp.md              # 資料庫 MCP 選型
│   └── legal.md               # 授權與資安前提
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
