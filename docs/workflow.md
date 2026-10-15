# 六步流程

每一步的輸入、輸出、以及「什麼時候算做完」。階段之間不跳。

## 0. 開案

```bash
specify init <案名> --integration claude   # 建立 .specify/ 與 /speckit.* 指令
cd <案名>
cp ~/nice-kit/templates/CLAUDE.md .
mkdir -p .grill inventory
claude
```

spec-kit 是每個專案各自 init，不是全域 skill。`--script ps` 可強制用 PowerShell 腳本。

填 CLAUDE.md 裡的 `<>`。只填知道的，不知道的留著，第 1 步會問出來。

## 1. 訪談 `/grill-the-client`

- **輸入**：一位受訪者，一個主題。
- **輸出**：`.grill/YYYY-MM-DD-<主題>.md`
- **做完的定義**：你能在 10 句內複述流程，受訪者沒有補充。
- **常見錯誤**：一次問太多；受訪者說「應該是」你記成事實；開始提解法。

通常需要 2–4 位受訪者：IT 管理者、該模組的業務負責人、一位資深操作員、必要時原廠窗口。每人一個檔。

## 2. 規格 spec-kit

```
/speckit.constitution   # 不變的原則：資料不出機房、唯讀優先、人工核准
/speckit.specify        # 這次要做什麼、不做什麼，從 .grill/ 的共識流程來
/speckit.clarify        # 把 specify 裡模糊的地方問清楚
```

- **輸出**：`specs/constitution.md`、`specs/<feature>/spec.md`
- **做完的定義**：spec 裡沒有「待確認」；每條需求都能回溯到某個 `.grill/` 檔。
- **這也是合約附件。** 客戶簽的是 spec，不是你的口頭描述。

## 3. 盤點 REA + DB MCP

有原始碼的部分：
```
用 repomix 打包 <路徑>，摘要架構與主要資料流，列出未知項。
```

沒原始碼的部分：
```
用 REA 分析 <路徑>。目標：<spec 裡的某條需求>。
每個結論附 evidence，結尾列出所有 unknowns 與 limitations。
```

資料庫：
```
用 DB MCP 列出 <schema> 的所有表、欄位、外鍵、索引。
標出：無註解欄位、無外鍵但名稱像關聯的欄位、程式碼中無引用的表。
```

- **輸出**：`inventory/report.md`（初稿，含未知項）
- **做完的定義**：每個 spec 需求都有對應的盤點章節，未知項已集中列出。
- **提醒**：REA 第一次跑大型 binary 可能要調 `REA_GHIDRA_STARTUP_TIMEOUT_MS`。

## 4. 補缺 `/inventory-gaps` → `/grill-the-client`

```
/inventory-gaps inventory/report.md
```
產出 `.grill/gaps-YYYY-MM-DD.md`，然後：
```
/grill-the-client .grill/gaps-YYYY-MM-DD.md
```

- **做完的定義**：gaps 檔裡每題都標了「已解 / 部分解 / 需要找別人」；「需要找別人」的已排進下一輪。
- 回到第 3 步更新 `inventory/report.md`。通常跑 1–2 輪就收斂。

## 5. 計畫 spec-kit

```
/speckit.plan     # 技術做法：哪些用唯讀查詢、哪些要包 tool、哪些不碰
/speckit.tasks    # 拆成任務，每個任務可獨立驗收
```

- **輸出**：`specs/<feature>/plan.md`、`tasks.md`
- **做完的定義**：每個任務都有驗收條件，且能對應到敏感度分類表。

## 6. 實作 superpowers

superpowers 裝好後會自動介入：brainstorm → 寫 plan → TDD → 子 agent 執行。
你要做的只有兩件事：
- 每個任務開始前確認它在 spec 範圍內
- 涉及寫入資料庫的任務，一律加人工核准步驟

## 貫穿全程：claude-mem

裝好後不用管。它會把每個 session 做的事壓縮存起來，下次開 Claude Code 自動帶進來。
案子拖三週回來，不用重講一遍。

## 結案交付

```
inventory/report.md            盤點報告
inventory/tool-layer-draft.md  tool 介面草稿（若在範圍內）
specs/                         合約依據
.grill/                        訪談紀錄 = 稽核軌跡
```

`.grill/` 交付前先檢查有沒有不該出現的姓名或個資。
