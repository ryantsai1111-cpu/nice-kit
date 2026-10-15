# nice-kit

[繁體中文](../../README.md) · [English](README_en.md) · **简体中文** · [日本語](README_ja.md)

一套给「企业 AI 导入 / 旧系统盘点」咨询项目用的项目骨架。
**不绑定单一 agent**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes 都能用。
不是另一个 skill 大全，而是**五个工具、一条流程**，开项目直接跑。

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► superpowers
   (访谈)             (规格)          (盘点)           (实现)
             └──── PROGRESS.md + planning-with-files（跨 session 记忆）────┘
```

## 为什么只有五个

每个 skill 都在跟 agent 争 context。装太多会变慢、互相打架。
选择标准只有三条：**高频使用、需要领域知识、错了很贵**。三条都中才进来。

| 阶段 | 工具 | 解决的问题 | 来源 |
|---|---|---|---|
| 访谈 | `grill-the-client`（本 repo） | 文档里没写、只有资深员工知道的事 | 改自 [mattpocock grill-me](https://github.com/mattpocock/skills) |
| 规格 | [spec-kit](https://github.com/github/spec-kit) | 范围没写清楚就开工 | GitHub 官方 |
| 盘点 | [REA](https://github.com/morluto/rea) | 没源码的系统（.NET / Electron / APK / 抓包） | MIT |
| 盘点 | 数据库 MCP server | 有只读账号就能直读 schema，比反编译快 | 依客户 DB 选 |
| 实现 | [superpowers](https://github.com/obra/superpowers) | agent 没想清楚就写代码 | Anthropic 官方 marketplace |
| 记忆 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 项目拖几周，每次从头讲 | 所有 agent 通用；Claude Code 另加 [claude-mem](https://github.com/thedotmack/claude-mem) |
| 补缺 | `inventory-gaps`（本 repo） | 把 REA 的 unknowns 变成访谈问题 | 原创 |

## 安装

需要 Node.js 22.19+ 和至少一个 agent CLI。spec-kit 需要 [uv](https://docs.astral.sh/uv/)（脚本会自动装）。

**只要 skills（任何 agent）：**
```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # 换成你的 agent
```

**完整安装（skills + superpowers + spec-kit + REA + 记忆）：**
```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                      # 自动检测已装的 agent
./scripts/install.sh -a claude-code,codex # 或指定
.\scripts\install.ps1                     # Windows
./scripts/doctor.sh                       # 检查
```

agent 标识符与各工具兼容情况见 [docs/agents.md](../agents.md)。
数据库 MCP server 依客户环境不同，见 [docs/db-mcp.md](../db-mcp.md)。

## 开项目流程

```bash
./scripts/init.sh <项目名>                  # 跑 specify init、放 AGENTS.md 等模板
./scripts/init.sh <项目名> -a codex,cursor  # 多 agent
```
然后依次（slash command 写法依 agent 略有不同，见 docs/agents.md）：

| 步骤 | 怎么触发 | 产出 |
|---|---|---|
| 1 | 加载 `grill-the-client`（或说「访谈客户」） | `.grill/<日期>-<主题>.md` 访谈记录 |
| 2 | spec-kit：constitution → specify → clarify | `specs/` 范围与约束 |
| 3 | 「用 REA 盘点 `<路径>`，列出所有 unknowns」 | 盘点报告 + unknowns 清单 |
| 4 | 加载 `inventory-gaps`（或说「整理 unknowns」） | 第二轮访谈问题 |
| 5 | spec-kit：plan → tasks | 任务清单 |
| 6 | superpowers 自动接手实现 | 代码 + 测试 |

完整说明见 [docs/workflow.md](../workflow.md)。

## 目录

```
nice-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── install.sh / .ps1      # 多 agent 安装
│   ├── init.sh / .ps1         # 开新项目
│   └── doctor.sh              # 检查安装
├── templates/
│   ├── AGENTS.md              # 项目规范主文件（所有 agent 读）
│   ├── CLAUDE.md / GEMINI.md  # 只有一行 @AGENTS.md
│   ├── .cursor/rules/         # Cursor 指向 AGENTS.md
│   └── PROGRESS.md            # 跨 session 记忆
├── docs/
│   ├── workflow.md            # 六步流程详解
│   ├── agents.md              # 各 agent 兼容矩阵与名称对照
│   ├── db-mcp.md              # 数据库 MCP 选型
│   ├── legal.md               # 授权与安全前提
│   └── readme/                # 翻译
└── skills/
    ├── grill-the-client/SKILL.md
    └── inventory-gaps/SKILL.md
```

## 法律与安全前提

REA 只能分析你**拥有或获授权**检视的软件。商用 ERP 的授权条款可能禁止反编译，
合同里要写明客户授权分析自有系统，且所有分析只在客户机房内运行。
详见 [docs/legal.md](../legal.md)。

## 许可证

MIT。各上游工具保留各自许可证。
