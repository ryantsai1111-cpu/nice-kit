# MCP 註冊

核心層有兩個 MCP server，`install.sh` 會嘗試自動註冊：

| 名稱 | 指令 | 用途 |
|---|---|---|
| `context7` | `npx -y @upstash/context7-mcp` | 函式庫官方文件。agent 寫 API 前先 `resolve-library-id` 再 `get-library-docs` |
| `playwright` | `npx -y @playwright/mcp@latest` | 開真的瀏覽器看頁面、點操作、側錄 network |

套件名稱會變；這份文件以 `scripts/install.sh` 裡的指令為準。

## 自動註冊的 agent

| Agent | install.sh 做的事 | 設定檔 |
|---|---|---|
| Claude Code | `claude mcp add -s user <name> -- <cmd>` | `~/.claude.json` |
| Codex | `codex mcp add <name> -- <cmd>` | `~/.codex/config.toml` |
| Gemini CLI | `gemini mcp add <name> <cmd>` | `~/.gemini/settings.json` |

已存在的不會重複加。

## 要手動貼的 agent

install.sh 會印出這種片段：

```json
{"mcpServers":{"context7":{"command":"npx","args":["-y","@upstash/context7-mcp"]}}}
```

貼到：

| Agent | 檔案 | 格式備註 |
|---|---|---|
| Cursor | `~/.cursor/mcp.json`（全域）或 `<專案>/.cursor/mcp.json` | 同上 JSON |
| OpenCode | `~/.config/opencode/opencode.json` | key 是 `mcp`，每個 server 要 `"type":"local"`，`command` 是陣列 |
| GitHub Copilot（VS Code） | `.vscode/mcp.json` | key 是 `servers` |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` | 同 Cursor |
| Hermes | `~/.hermes/config.yaml` | 依 Hermes 版本，見其文件 |

每個 agent 的格式細節變得很快，貼之前看一眼該 agent 當下的文件。`doctor.sh` 用設定檔裡有沒有出現 server 名稱來判斷有沒有裝。

## 領域包的 MCP

- **REA**（legacy-consulting）：`npx rea-agents setup` 自己有互動式註冊，不走這裡。
- **資料庫 MCP**（legacy-consulting）：依客戶 DB 選，見 `packs/legacy-consulting/docs/db-mcp.md`。連線字串不進 repo。

## 自己加 MCP

pack 的 `hooks/install.sh` 裡可以直接用 lib.sh 的函式：

```bash
register_mcp "$AGENTS" my-server npx -y some-mcp-package --flag
```
