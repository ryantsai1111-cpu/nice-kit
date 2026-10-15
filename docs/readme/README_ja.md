# nice-kit

[繁體中文](../../README.md) · [English](README_en.md) · [简体中文](README_zh.md) · **日本語**

「企業への AI 導入／レガシーシステム棚卸し」コンサル案件向けのプロジェクト骨格です。
**特定の agent に縛られません**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes で使えます。
skill の寄せ集めではなく、**5 つのツールと 1 本のワークフロー**。案件初日からそのまま回せます。

```
grill-the-client ──► spec-kit ──► REA + DB MCP ──► superpowers
  (インタビュー)        (仕様)         (棚卸し)          (実装)
             └──── PROGRESS.md + planning-with-files（セッション横断の記憶）────┘
```

## なぜ 5 つだけか

skill はすべて agent とコンテキストを奪い合います。入れすぎると遅くなり、互いに干渉します。
選定基準は 3 つ：**高頻度で使う、ドメイン知識が要る、間違えると高くつく**。3 つ全部満たしたものだけ入れています。

| 段階 | ツール | 解決する問題 | 出典 |
|---|---|---|---|
| インタビュー | `grill-the-client`（本 repo） | 文書に書かれておらず、ベテラン社員しか知らないこと | [mattpocock grill-me](https://github.com/mattpocock/skills) を改変 |
| 仕様 | [spec-kit](https://github.com/github/spec-kit) | 範囲を明文化せずに着手してしまう | GitHub 公式 |
| 棚卸し | [REA](https://github.com/morluto/rea) | ソースコードのないシステム（.NET / Electron / APK / パケット） | MIT |
| 棚卸し | データベース MCP server | 読み取り専用アカウントで schema を直接読む。逆コンパイルより速い | 顧客の DB に合わせて選定 |
| 実装 | [superpowers](https://github.com/obra/superpowers) | agent が考える前にコードを書いてしまう | Anthropic 公式 marketplace |
| 記憶 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 案件は数週間続く。毎回説明し直したくない | 全 agent 共通。Claude Code は [claude-mem](https://github.com/thedotmack/claude-mem) を追加 |
| 補完 | `inventory-gaps`（本 repo） | REA の unknowns をインタビュー質問に変換 | オリジナル |

## インストール

Node.js 22.19+ と、少なくとも 1 つの agent CLI が必要です。spec-kit には [uv](https://docs.astral.sh/uv/) が必要（スクリプトが自動で入れます）。

**skills だけ（任意の agent）：**
```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # 自分の agent に置き換え
```

**フルインストール（skills + superpowers + spec-kit + REA + 記憶）：**
```bash
git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                      # インストール済み agent を自動検出
./scripts/install.sh -a claude-code,codex # または指定
.\scripts\install.ps1                     # Windows
./scripts/doctor.sh                       # 確認
```

agent 識別子と各ツールの対応状況は [docs/agents.md](../agents.md)。
データベース MCP server は顧客環境ごとに異なります：[docs/db-mcp.md](../db-mcp.md)。

## 案件の開始

```bash
./scripts/init.sh <案件名>                  # specify init を実行し AGENTS.md 等を配置
./scripts/init.sh <案件名> -a codex,cursor  # 複数 agent
```
その後、順番に（slash command の書き方は agent によって少し違います。docs/agents.md 参照）：

| 手順 | 起動方法 | 成果物 |
|---|---|---|
| 1 | `grill-the-client` を読み込む（または「顧客にインタビュー」と言う） | `.grill/<日付>-<テーマ>.md` インタビュー記録 |
| 2 | spec-kit：constitution → specify → clarify | `specs/` 範囲と制約 |
| 3 | 「REA で `<パス>` を棚卸しし、unknowns を全部列挙して」 | 棚卸しレポート + unknowns 一覧 |
| 4 | `inventory-gaps` を読み込む（または「unknowns を整理」と言う） | 第 2 回インタビューの質問 |
| 5 | spec-kit：plan → tasks | タスク一覧 |
| 6 | superpowers が実装を引き継ぐ | コード + テスト |

詳細は [docs/workflow.md](../workflow.md)。

## ディレクトリ構成

```
nice-kit/
├── README.md
├── LICENSE
├── scripts/
│   ├── install.sh / .ps1      # 複数 agent 対応インストール
│   ├── init.sh / .ps1         # 新規案件の開始
│   └── doctor.sh              # インストール確認
├── templates/
│   ├── AGENTS.md              # プロジェクト規約の正本（全 agent が読む）
│   ├── CLAUDE.md / GEMINI.md  # 1 行だけ：@AGENTS.md
│   ├── .cursor/rules/         # Cursor が AGENTS.md を参照
│   └── PROGRESS.md            # セッション横断の記憶
├── docs/
│   ├── workflow.md            # 6 ステップの詳細
│   ├── agents.md              # 対応表と名称マッピング
│   ├── db-mcp.md              # データベース MCP の選定
│   ├── legal.md               # ライセンスとセキュリティの前提
│   └── readme/                # 翻訳
└── skills/
    ├── grill-the-client/SKILL.md
    └── inventory-gaps/SKILL.md
```

## 法的・セキュリティ上の前提

REA で解析できるのは、あなたが**所有しているか、検査を許可された**ソフトウェアだけです。商用 ERP のライセンスは逆コンパイルを禁じていることが多いです。
契約書に「顧客が自社システムの解析を許可する」旨を明記し、解析はすべて顧客の設備内で行ってください。
詳細：[docs/legal.md](../legal.md)。

## ライセンス

MIT。上流ツールはそれぞれのライセンスに従います。
