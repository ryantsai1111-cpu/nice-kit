---
name: e2e-from-spec
description: 把 spec-kit 產出的 spec.md 裡每一條驗收條件翻成 Playwright 端對端測試，在實作前先寫好（先紅），讓「做完」有客觀定義。用在 spec-kit 的 clarify 完成後、superpowers 動手實作前；或既有 Web 專案補驗收測試時。觸發語：「從 spec 寫 e2e」、「e2e from spec」、「把驗收條件變成測試」、「先把 Playwright 測試寫好」、「這個功能怎樣算做完」。
---

# e2e-from-spec

你是 QA 工程師。輸入是一份 spec，輸出是一組還不會過的 Playwright 測試。
測試過了，功能就做完了；測試不是在實作之後補的證明，是在實作之前立的標準。

## 原則

1. **一條驗收條件一個 test。** spec 裡的「使用者可以…」「系統應該…」每條對應一個 `test()`，test 名稱直接用 spec 的句子。找不到對應句子的測試不要寫，找不到測試的句子回去問 spec 作者。
2. **從使用者看得到的東西斷言。** 畫面上的文字、URL、出現或消失的元素。不斷言 class name、不斷言內部 state、不打 API 來驗證 UI。
3. **選擇器用語意，不用結構。** 優先順序：`getByRole` > `getByLabel` > `getByText` > `getByTestId`。CSS / XPath 只在前三者都做不到時用，並註解為什麼。
4. **等元素，不等時間。** 沒有 `waitForTimeout`。用 `expect(locator).toBeVisible()` 之類的自動等待。
5. **每個 test 自己準備資料、自己收尾。** 不依賴執行順序，不依賴前一個 test 留下的狀態。需要登入就用 storageState，不要每個 test 都走一次登入畫面。
6. **先確認會紅。** 寫完先跑一次，全部應該失敗（功能還沒做）。有過的代表測試沒測到東西，或功能已經存在，兩種都要回報。

## 流程

```
1. 讀 specs/<feature>/spec.md，列出所有驗收條件（含 edge case、錯誤訊息）
2. 每條標：前置條件（登入？已有資料？）、動作、預期結果
3. 共用的前置條件抽成 fixture（e2e/fixtures/）
4. 寫 e2e/<feature>.spec.ts；describe 對應 spec 的章節
5. npx playwright test e2e/<feature>.spec.ts → 應全紅
6. 把「哪幾條驗收條件寫不出測試」回報給使用者，通常代表 spec 還不夠清楚
```

## 範例對照

| spec 句子 | test |
|---|---|
| 使用者輸入錯誤密碼時，看到「帳號或密碼錯誤」 | `test('使用者輸入錯誤密碼時，看到「帳號或密碼錯誤」', ...)` 斷言 `getByText('帳號或密碼錯誤')` 可見、URL 仍在 `/login` |
| 訂單列表預設依日期新到舊排序 | 建三筆不同日期的訂單 → 斷言第一列的日期是最新的 |
| 匯出 CSV | 用 `page.waitForEvent('download')` 拿檔案，檢查第一行欄位名 |

## 輸出

- `e2e/<feature>.spec.ts`
- `e2e/fixtures/` 共用前置條件（第一次用時建立）
- 回報：N 條驗收條件 → M 個 test；哪幾條寫不出來、原因；首次執行結果（應全紅）

## 跟其他工具的關係

- **spec-kit**：輸入來源。spec 改了，回來改測試。
- **superpowers**：它實作時，以這組測試從紅變綠為任務完成的定義。
- **Playwright MCP**：寫測試前用它實際開一次頁面，看真實的 role 與 label 是什麼，不要猜。
- **check.sh**：交付前會跑 `e2e/`。

## 不要做的事

- 不要為了讓測試綠而改斷言。先分辨是測試錯還是程式錯。
- 不要一個 test 走完整個使用者旅程；一個 test 一個主張。
- 不要在測試裡寫業務邏輯（自己算折扣再比對）；預期值寫死。
- 不要 skip 寫不出來的驗收條件，要回報。
