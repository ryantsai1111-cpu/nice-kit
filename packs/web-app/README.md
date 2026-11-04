# web-app

Web 應用開發用的領域包。核心流程中間插一步：**先寫驗收測試，再實作**。

```
spec-kit ──► e2e-from-spec ──► superpowers ──► check.sh
 (規格)      (驗收測試，先紅)    (實作，變綠)     (交付前)
                 ▲
          Playwright MCP 先開頁面看真實的 role / label
```

## 什麼時候用

- 有畫面的東西：網站、後台、SaaS、內部工具
- 「做完了」常常跟「客戶覺得做完了」不一樣的專案

## 什麼時候不要用

- 純 API / CLI / 函式庫 → 核心層就夠（superpowers 的 TDD 已涵蓋單元測試）
- 一次性的 landing page，不會再改 → 核心層就夠

## 加了什麼

| 元件 | 類型 | 做什麼 |
|---|---|---|
| `e2e-from-spec` | skill | spec.md 的每條驗收條件 → 一個 Playwright test，實作前先紅 |
| Playwright MCP（核心已有） | MCP | 宣稱 UI 做好前實際開過頁面；寫測試前看真實的語意選擇器 |
| `templates/AGENTS.pack.md` | 規範 | 技術棧欄位（版本必填，Context7 查文件要帶版本）、看畫面規則、禁止事項 |

這個 pack 刻意很薄。前端框架、UI library、設計系統都是專案層的選擇，寫在 AGENTS.md 的「技術棧」，不進 pack。

## 安裝與開案

```bash
./scripts/install.sh -p web-app
./scripts/init.sh <案名> -p web-app
```

init 會多建 `e2e/`，並把 `test-results/`、`playwright-report/` 加進 .gitignore。
專案裡要自己 `npm i -D @playwright/test && npx playwright install`；`check.sh` 看到 `e2e/` 就會跑它。

## 流程

| 步驟 | 做什麼 | 做完的定義 |
|---|---|---|
| 1 | spec-kit constitution → specify → clarify | spec 沒有「待確認」 |
| 2 | spec-kit plan → tasks | 每個任務對應到 spec 的某條驗收條件 |
| 3 | 載入 `e2e-from-spec`，輸入 spec.md | `e2e/<feature>.spec.ts` 全紅；寫不出來的條目已回報 |
| 4 | superpowers 實作 | 對應的 e2e 變綠；UI 任務附 Playwright MCP 看過的證據 |
| 5 | `check.sh` | secret 乾淨、測試過、PROGRESS.md 有更新 |
