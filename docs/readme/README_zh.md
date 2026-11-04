# nice-kit

[繁體中文](../../README.md) · [English](README_en.md) · **简体中文** · [日本語](README_ja.md)

一套给 AI agent 开发用的项目骨架：**核心层 + 领域包**。
**不绑定单一 agent**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes 都能用。
不是 skill 大全。卖点只有一句：**不管你用哪个 agent、做哪种项目，开项目的前十分钟长得一样。**

```
                    ┌──────────── 核心层（任何项目）────────────┐
                    │ spec-kit ──► superpowers ──► check.sh    │
                    │  (规格)       (实现)         (交付前)     │
                    │ Context7 + Playwright MCP   PROGRESS.md  │
                    │  (查文档)    (看页面)        (跨 session) │
                    └─────────────────┬────────────────────────┘
                                      │ init.sh -p <pack>
        ┌─────────────────────────────┴──────────────────────────────┐
        │ legacy-consulting                │ web-app                  │
        │ 访谈 → 盘点 → 补缺 → 行为封存      │ 规格 → E2E 验收 → 实现    │
        └──────────────────────────────────┴──────────────────────────┘
```

## 为什么分两层

每个 skill 都在跟 agent 争 context。装太多会变慢、互相打架。
选择标准只有三条：**高频使用、需要领域知识、错了很贵**。三条都中才进来。

- **核心层**：不管做什么项目，三条都中的。七件，其中三件是 MCP server 或 script，不占 agent context。
- **领域包（pack）**：只在某个领域三条都中的。开项目时用 `-p` 选一个，不选就只有核心。

### 核心层

| 类别 | 工具 | 解决的问题 | 来源 |
|---|---|---|---|
| 规格 | [spec-kit](https://github.com/github/spec-kit) | 范围没写清楚就开工 | GitHub 官方 |
| 实现纪律 | [superpowers](https://github.com/obra/superpowers) | agent 不想清楚就写 code | Anthropic 官方 marketplace |
| 查文档 | [Context7 MCP](https://github.com/upstash/context7) | agent 凭印象写出不存在的 API | Upstash |
| 看页面 | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | 只看 build 过了，没打开过页面 | 微软官方 |
| 交付前 | `scripts/check.sh`（本 repo）+ [gitleaks](https://github.com/gitleaks/gitleaks) | secret 进 repo、测试没跑、进度没记 | 原创 + MIT |
| 记忆 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 项目拖几周，每次从头讲 | 所有 agent 通用；Claude Code 另加 [claude-mem](https://github.com/thedotmack/claude-mem) |
| 规范 | `templates/AGENTS.md`（本 repo） | 七种 agent 各读各的配置 | 一份 AGENTS.md，CLAUDE.md / GEMINI.md / `.cursor/rules` 都指向它 |

### 领域包

| pack | 场景 | 加了什么 |
|---|---|---|
| [legacy-consulting](../../packs/legacy-consulting/) | 企业 AI 导入、旧系统盘点咨询项目 | `grill-the-client`（访谈）、[REA](https://github.com/morluto/rea) + DB MCP（盘点）、`inventory-gaps`（补缺）、`characterization-tests`（行为封存）、数据敏感度与本地/云端分工规范 |
| [web-app](../../packs/web-app/) | Web 应用开发 | `e2e-from-spec`（spec → Playwright 验收测试）、看页面规则 |

要加自己的 pack：见 [docs/packs.md](../packs.md)。

## 安装

需要 Node.js 22.19+ 和至少一个 agent CLI。spec-kit 需要 [uv](https://docs.astral.sh/uv/)（脚本会自动装）。

```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # 只要 skills

git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                        # 只装核心
./scripts/install.sh -p legacy-consulting   # 核心 + 领域包
./scripts/install.sh --list-packs
.\scripts\install.ps1 -Packs web-app        # Windows
./scripts/doctor.sh
```

MCP 在 Claude Code / Codex / Gemini CLI 自动注册，其他 agent 会打印配置片段让你贴，见 [docs/mcp.md](../mcp.md)。

## 开项目

```bash
./scripts/init.sh <名称>                          # 核心模板
./scripts/init.sh <名称> -p legacy-consulting     # 附加领域规范与目录
./scripts/init.sh <名称> -p web-app -a codex,cursor
```

| 步骤 | 核心流程 | legacy-consulting 加的 | web-app 加的 |
|---|---|---|---|
| 0 | 填 AGENTS.md 的 `<>` | | |
| 1 | | `grill-the-client` 访谈 → `.grill/` | |
| 2 | spec-kit：constitution → specify → clarify | | |
| 3 | | REA / DB MCP 盘点 → `inventory-gaps` → 再访谈 | |
| 4 | spec-kit：plan → tasks | | |
| 5 | | `characterization-tests` 录旧系统行为 | `e2e-from-spec` 写验收测试（先红） |
| 6 | superpowers 实现 | 以 characterization 通过为验收 | 以 e2e 变绿为验收 |
| 7 | `check.sh` 交付前检查 | | |

各 pack 的完整流程见其目录下的 README 与 docs。

## 法律与安全前提

legacy-consulting 里的 REA 只能分析你**拥有或获授权**查看的软件。详见 [packs/legacy-consulting/docs/legal.md](../../packs/legacy-consulting/docs/legal.md)。

## 许可

MIT。各上游工具保留各自许可。
