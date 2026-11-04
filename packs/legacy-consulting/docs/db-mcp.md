# 資料庫 MCP 選型

原則只有三條：**唯讀帳號、只開 schema 與 SELECT、在客戶機房內跑**。

## 依資料庫選

| 客戶 DB | 建議 | 備註 |
|---|---|---|
| PostgreSQL | 官方或社群 postgres MCP server | 最成熟，直接用 |
| MSSQL | 社群 mssql MCP server，或 DBHub | 台灣中小企業 ERP 最常見 |
| MySQL / MariaDB | DBHub 或社群 mysql MCP | |
| Oracle | 社群 oracle MCP，選項較少 | 可能要自己包 |
| SQLite | REA 內建 SQLite 分析 | 不用另裝 |
| 多種混用 | [DBHub](https://github.com/bytebase/dbhub) | 一個 server 接多種 DB |

套件名稱與維護狀況變動很快，安裝前用 `npx skills search` 或 GitHub 搜最近 commit。

## 帳號設定（給客戶 IT 的要求）

```sql
-- PostgreSQL 範例
CREATE ROLE agent_ro LOGIN PASSWORD '...';
GRANT CONNECT ON DATABASE erp TO agent_ro;
GRANT USAGE ON SCHEMA public TO agent_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO agent_ro;
-- 紅色等級的表明確 REVOKE
REVOKE SELECT ON employee_salary, customer_pii FROM agent_ro;
```

MSSQL 用 `db_datareader` 角色，再對紅色等級的表 `DENY SELECT`。

## 註冊到 Claude Code

```bash
claude mcp add erp-db -- npx -y <mcp-package> --dsn "<唯讀連線字串>"
```

連線字串不要寫進 repo。用環境變數或客戶機器上的本機設定檔。

## 第一次查詢

```
列出所有表的名稱、列數估計、最後更新時間。
標出名稱含 tmp / bak / old / test 的表。
```

這一步的輸出直接餵 `/inventory-gaps`。
