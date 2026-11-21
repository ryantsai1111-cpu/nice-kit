---
name: ambition-pass
description: 在把任務交給 spec-kit 的 specify、或交給 superpowers 之前，對任務說明跑高度、深度、廣度三輪，做成更深的版本而不是更大的版本，再改寫成不大於原文的說明。瑣碎詢問跳過，結論不准自評。用在寫規格之前，以及把任務交去實作之前。觸發語：「ambition pass」、「把這個任務做深」、「做深不做大」、「加深這個任務」。
---

# ambition-pass

你在把任務交出去之前，先把任務說明做深，不做大。
方法來自 Felix Rieseberg，〈How to be more ambitious〉（https://felixrieseberg.com/how-to-be-more-ambitious-a-tutorial-for-humans-with-models/）。
三輪都跑完，才改寫。改寫後的篇幅不得超過原文。

## 什麼時候跑

- 跑 spec-kit 的 `specify` 之前，對這次要寫進 spec 的任務說明跑一輪。
- 把任務交給 superpowers 之前，對每一個任務說明各跑一輪。
- 一句話就能答的小事（改錯字、補一個名稱、問單一事實）直接跳過。回「跳過 ambition-pass」並寫原因，不要硬跑。

## 三輪

依序做。每一輪都寫下來，不要跳到改寫。

### 1. 高度（Altitude）

把目標往上抬一層，重述這件事在服務哪個決定、或哪個結果。
不要新增工作項目。只換問法，讓任務對準那個決定。

例：「盤點出貨模組有哪些表」往上是「決定哪些步驟可以改成唯讀查詢」。

### 2. 深度（Depth）

對目前的任務說明，原文執行下面這段英文。不要翻譯，不要改字：

```
I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm not asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that.
```

這一輪先收下 (1) 到 (4)。先不要採用它當場寫出的改寫；等廣度跑完，再一起收成最後一版。

### 3. 廣度（Range）

點出可以從其他領域借來的方法、工具、技術。
借的是方法，不是角色扮演。不要扮演另一個專業的人；做那個領域實際會做的事。

## 改寫

三輪收成一份新的任務說明：

- 篇幅不大於原文。
- 範圍沒有變大。原文沒有的交付物、系統、回合，不准新增。
- 問的是更深的材料、具體方法，以及你和使用者以外、什麼東西能證明結果是對的。

## 不要做的事

- 不要加範圍。做深不是做大，也不是把一個任務拆成一串新任務。
- 不要對瑣碎詢問跑這三輪。
- 不要自評。不要寫「這版已經夠深」或自己打分。改寫後的任務要點名一個你和使用者以外的驗證（查詢結果、測試、原始紀錄）。
- 盤點結論的驗證另見專案 `AGENTS.md`：只准唯讀；結果若與結論不符，退回未知項，交給 `inventory-gaps`。
