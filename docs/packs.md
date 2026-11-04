# 怎麼寫一個 pack

pack 是「某個領域才需要的東西」。進 pack 的標準跟核心一樣：**高頻、需要領域知識、錯了很貴**，只是範圍縮到那個領域。
不確定的先不要加。一個 pack 超過五個 skill 就該懷疑自己。

## 最小結構

```
packs/<name>/
├── pack.conf                 # 必要
├── README.md                 # 必要：這個 pack 的流程、什麼時候用、什麼時候不要用
├── templates/
│   └── AGENTS.pack.md        # 建議：init 時接在核心 AGENTS.md 後面
├── skills/<skill>/SKILL.md   # 可選
├── hooks/
│   ├── install.sh / .ps1     # 可選：裝 MCP、跑 setup
│   ├── init.sh               # 可選：開案時的額外動作
│   └── doctor.sh             # 可選：檢查
└── docs/                     # 可選
```

## pack.conf

只能放 `KEY="value"` 與註解，bash 會 source 它、PowerShell 用正則讀它，所以不要寫邏輯。

```bash
PACK_DESC="一句話說明"
PACK_SKILL_REPOS="owner/repo,owner/repo2"   # 外部 skill repo，可空；本 pack 的 skills/ 一定會裝
PACK_INIT_DIRS="dir1,dir2"                  # init 時建的目錄
PACK_GITIGNORE="dir1/,*.log"                # init 時加進 .gitignore 的行
```

## AGENTS.pack.md

核心 `templates/AGENTS.md` 已經有：專案定位、核心流程、查資料順序、證據規則、記憶、不要做的事。
pack 只寫**這個領域多出來的**：

- `## 領域規範：<name>` 當第一行
- 多出來的流程步驟（表格，跟核心同格式）
- 多出來的證據來源、禁止事項、交付物
- 不要重複核心已經有的規則

## hooks

hook 被 `source`，不是執行，所以可以用 `scripts/lib.sh` 的所有函式與變數：

| 可用 | 說明 |
|---|---|
| `say` `ok` `bad` `warn` `have` | 輸出與檢查 |
| `$AGENTS` | 逗號分隔的 agent 識別碼（install hook） |
| `$SKIP_REA` 之類 | install.sh 的 flag 會 export |
| `register_mcp "$AGENTS" <name> <cmd> [args]` | 註冊 MCP，自動處理 Claude / Codex / Gemini |
| `mcp_registered <name>` | doctor 用 |
| `check_skill <name>` | doctor 用 |
| `$PACK_DIR` `$PACK_NAME` | pack 自己的路徑與名稱 |

hook 裡不要 `set -e`、不要 `exit`；失敗就 `bad` 或 `warn` 然後繼續。

## skill

跟任何 Agent Skills 格式一樣：`skills/<name>/SKILL.md`，frontmatter 有 `name` 與 `description`。
description 要寫三件事：做什麼、什麼時候用、觸發語。內文給原則不給死步驟，200 行以內。
超過的拆成 `references/`、`scripts/` 子目錄，SKILL.md 只留入口。

## 驗證

```bash
./scripts/install.sh -p <name> -a universal   # 裝到 ~/.config/agents/skills，不碰真的 agent
./scripts/doctor.sh -p <name>
./scripts/init.sh /tmp/試案 -p <name>          # 看 AGENTS.md 接得對不對
```

## 什麼不該變成 pack

- 只有你一個人、一個案子用的規則 → 直接寫在那個專案的 AGENTS.md
- 一個 skill 就能解決的 → 用 `npx skills add` 裝那個 skill，不用包
- 跟核心重疊的（另一套規格工具、另一套記憶方案）→ 不要，一個專案只能有一套
