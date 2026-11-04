# <專案名稱>

<!-- 給所有 agent 的主檔（Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes 等都讀 AGENTS.md）。
     CLAUDE.md / GEMINI.md 只是引用這個檔。init.sh 產生後，填掉 <> 的部分；只填知道的。
     下方「領域規範」一節由 pack 附加，沒選 pack 就沒有。 -->

## 專案定位

- 對象：<客戶 / 產品 / 自己的 side project>
- 目標：<一句話>
- 階段：規格 / 計畫 / 實作（目前：<階段>）
- 範圍：見 `.specify/memory/constitution.md` 與 `specs/`；範圍外的事先問我，不要做。

## 工作流程（核心）

| 階段 | 怎麼觸發 | 產出位置 |
|---|---|---|
| 規格 | spec-kit：constitution → specify → clarify | `specs/` |
| 計畫 | spec-kit：plan → tasks | `specs/` |
| 實作 | superpowers（brainstorm → plan → TDD） | `src/` |
| 交付前 | `nice-kit/scripts/check.sh` | 終端輸出 |

規格沒 clarify 完不做計畫，計畫沒拆成可驗收的任務不實作。
各 agent 的 slash command 寫法不同（Claude `/speckit.specify`，Codex `$speckit.specify`，無 slash 的用自然語言），見 nice-kit 的 `docs/agents.md`。

## 查資料的順序

1. 專案裡已有的程式碼與 `specs/`
2. Context7 MCP（函式庫官方文件，先 resolve-library-id 再 get-library-docs）
3. 才是你自己的記憶。版本相關的 API 一律查過再寫，不要憑印象。

## 證據規則

- 關於現況的結論要附來源：檔案路徑、測試輸出、MCP 回傳、或文件連結。
- 沒有來源的結論寫成「推測」，不寫成事實。

## 跨 session 記憶

每個 session 結束前，把「做了什麼、決定了什麼、下次從哪開始」寫進 `PROGRESS.md`。
每個 session 開始先讀 `PROGRESS.md` 與 `specs/` 最新的 spec。
（Claude Code 裝了 claude-mem 會自動做；其他 agent 靠這個檔。）

## 不要做的事

- 不要把任何金鑰、連線字串、token 寫進 repo；交付前 `check.sh` 會掃。
- 不要在沒有測試的情況下宣稱「做完了」。
- 不要在範圍外加功能，即使你覺得很小。
- <專案特有的禁止事項>
