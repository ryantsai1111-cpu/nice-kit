# <專案名稱>

<!-- 複製到新專案根目錄後，填掉 <> 的部分。其餘保留。 -->

## 專案定位

- 客戶：<公司 / 部門>
- 目標：<一句話，例如「盤點 ERP 出貨模組並評估哪些步驟可由 agent 唯讀查詢取代」>
- 階段：訪談 / 規格 / 盤點 / 實作（目前：<階段>）
- 合約範圍：見 `specs/constitution.md`；範圍外的事先問我，不要做。

## 環境

- 分析目標位於：<路徑或主機>
- 所有分析只在客戶環境內執行，**不得**把 assembly、資料庫檔、封包檔複製到外部。
- 資料庫帳號：唯讀。任何需要寫入的操作一律停下來問。
- 原始碼：<有 / 部分 / 無>。有的部分用 repomix 先讀，沒有的用 REA。

## 工作流程

| 階段 | 指令 | 產出位置 |
|---|---|---|
| 訪談 | `/grill-the-client` | `.grill/` |
| 規格 | `/speckit.constitution` `/speckit.specify` `/speckit.clarify` | `specs/` |
| 盤點 | REA MCP / DB MCP | `inventory/` |
| 補缺 | `/inventory-gaps` → `/grill-the-client` | `.grill/gaps-*.md` |
| 計畫 | `/speckit.plan` `/speckit.tasks` | `specs/` |
| 實作 | superpowers 流程（brainstorm → plan → TDD） | `src/` |

階段之間不跳。規格沒 clarify 完不盤點，盤點沒補缺不做計畫。

## 證據規則

- 每個關於客戶系統的結論都要附來源：REA 的 evidence 區塊、DB schema 查詢、或 `.grill/` 訪談紀錄的檔名。
- 沒有來源的結論寫成「推測」，不寫成事實。
- 盤點報告的每一節末尾列出「未知項」，不准省略。

## 資料敏感度

| 等級 | 定義 | 處理 |
|---|---|---|
| 紅 | 個資、薪資、客戶名單、財務明細 | 只記錄表名與欄位名，不讀內容；不進任何雲端 agent |
| 黃 | 內部流程、設定、程式邏輯 | 可在本機 agent 處理；雲端需去識別化 |
| 綠 | 公開資訊、技術文件 | 不限 |

不確定等級的一律當紅處理，列入 `/inventory-gaps` 待確認。

## 不要做的事

- 不要在訪談階段提解決方案。
- 不要對生產資料庫執行任何非 SELECT 語句。
- 不要在未確認授權前反編譯商用軟體；授權依據見 `docs/legal.md`。
- 不要把受訪者姓名寫進任何產出。

## 交付物

- `inventory/report.md`：盤點報告（架構、資料流、敏感度分類、未知項）
- `inventory/tool-layer-draft.md`：建議的 MCP tool 介面草稿（若在範圍內）
- `.grill/`：全部訪談紀錄（交付給客戶作為稽核軌跡）
