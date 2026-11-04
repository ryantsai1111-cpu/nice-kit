# legacy-consulting

企業 AI 導入 / 舊系統盤點顧問案用的領域包。核心流程（規格 → 計畫 → 實作 → 交付前檢查）前後各加幾步：

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► inventory-gaps ──► spec-kit ──► characterization-tests ──► superpowers
   (訪談)             (規格)         (盤點)            (補缺)          (計畫)         (行為封存)              (實作)
```

## 什麼時候用

- 客戶有一套沒人完全懂的系統（ERP 外掛、報表、整合程式），要盤點、要接 agent、或要部分替換
- 文件不全或沒有，知識在資深員工腦袋裡
- 有資安限制：資料不出機房、紅級資料不上雲

## 什麼時候不要用

- 從零開始的新系統 → 核心層就夠，或用 web-app
- 客戶只要一份「AI 可以做什麼」的簡報 → 這不是開發案

## 加了什麼

| 元件 | 類型 | 做什麼 |
|---|---|---|
| `grill-the-client` | skill | 一次一題的結構化訪談，產出 `.grill/` 稽核軌跡 |
| REA | MCP | 沒原始碼的系統（.NET / Electron / APK / 封包）靜態分析，`hooks/install.sh` 跑它的 setup |
| 資料庫 MCP | MCP | 唯讀帳號直讀 schema，依客戶 DB 選，見 `docs/db-mcp.md` |
| Playwright MCP（核心已有） | MCP | 只有一個能登入的網頁、沒有安裝檔也沒有 DB 帳號時，點過去側錄 request 反推 API |
| `inventory-gaps` | skill | 把掃描的 unknowns 變成第二輪訪談題目 |
| `characterization-tests` | skill | 實作前把舊系統行為錄成 golden master，新系統以此驗收 |
| `templates/AGENTS.pack.md` | 規範 | 資料敏感度三級、本地/雲端分工表、禁止事項、交付物 |

## 安裝與開案

```bash
./scripts/install.sh -p legacy-consulting            # --skip-rea 可略過 REA setup
./scripts/init.sh <案名> -p legacy-consulting
```

init 會多建 `.grill/` 與 `inventory/`（都在 .gitignore），並把領域規範接在 AGENTS.md 後面。

## 文件

- [docs/workflow.md](docs/workflow.md)：每一步的輸入、輸出、做完的定義
- [docs/db-mcp.md](docs/db-mcp.md)：資料庫 MCP 選型與唯讀帳號設定
- [docs/legal.md](docs/legal.md)：反編譯授權、合約要寫什麼、資安操作規範

## 法律前提

REA 只能分析你擁有或獲授權檢視的軟體。開案前讀 `docs/legal.md`，合約裡寫明。
