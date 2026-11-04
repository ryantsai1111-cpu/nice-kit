# nice-kit

[繁體中文](../../README.md) · [English](README_en.md) · [简体中文](README_zh.md) · **日本語**

AI エージェントで開発するためのプロジェクト骨格：**コア層＋ドメインパック**。
**特定のエージェントに依存しない**：Claude Code、Codex、Cursor、Gemini CLI、Copilot、OpenCode、Hermes で動く。
スキル集ではない。売りは一文：**どのエージェントを使っても、何を作っても、プロジェクト開始の最初の 10 分は同じになる。**

```
                    ┌──────────── コア（全プロジェクト）────────────┐
                    │ spec-kit ──► superpowers ──► check.sh       │
                    │  (仕様)       (実装)         (納品前)         │
                    │ Context7 + Playwright MCP   PROGRESS.md     │
                    │  (ドキュメント) (ブラウザ)    (セッション間)   │
                    └─────────────────┬───────────────────────────┘
                                      │ init.sh -p <pack>
        ┌─────────────────────────────┴──────────────────────────────┐
        │ legacy-consulting                │ web-app                  │
        │ ヒアリング → 棚卸し → 補完 → 挙動固定 │ 仕様 → E2E 受入 → 実装    │
        └──────────────────────────────────┴──────────────────────────┘
```

## なぜ二層か

スキルはすべてエージェントとコンテキストを奪い合う。入れすぎると遅くなり、互いに干渉する。
選定基準は三つだけ：**高頻度で使う、ドメイン知識が要る、間違えると高くつく**。三つ全部満たすものだけ入れる。

- **コア**：何を作っていても三つ全部満たすもの。七つ。うち三つは MCP サーバーかスクリプトで、エージェントのコンテキストを消費しない。
- **パック**：特定ドメインでのみ三つ全部満たすもの。プロジェクト開始時に `-p` で一つ選ぶ。選ばなければコアのみ。

### コア

| 役割 | ツール | 解決する問題 | 出典 |
|---|---|---|---|
| 仕様 | [spec-kit](https://github.com/github/spec-kit) | スコープを書く前に着手してしまう | GitHub 公式 |
| 実装規律 | [superpowers](https://github.com/obra/superpowers) | 考える前にコードを書くエージェント | Anthropic 公式 marketplace |
| ドキュメント参照 | [Context7 MCP](https://github.com/upstash/context7) | 記憶で存在しない API を書く | Upstash |
| ブラウザ | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | ビルドが通っただけで画面を開いていない | Microsoft 公式 |
| 納品前 | `scripts/check.sh`（本 repo）+ [gitleaks](https://github.com/gitleaks/gitleaks) | シークレットの混入、テスト未実行、進捗未記録 | オリジナル + MIT |
| 記憶 | `PROGRESS.md` + [planning-with-files](https://github.com/OthmanAdi/planning-with-files) | 数週間の案件で毎回説明し直す | 全エージェント共通；Claude Code は [claude-mem](https://github.com/thedotmack/claude-mem) を追加 |
| ルール | `templates/AGENTS.md`（本 repo） | 七種のエージェントがそれぞれ別の設定を読む | AGENTS.md 一つに CLAUDE.md / GEMINI.md / `.cursor/rules` が向く |

### パック

| pack | 用途 | 追加されるもの |
|---|---|---|
| [legacy-consulting](../../packs/legacy-consulting/) | 企業 AI 導入、レガシーシステム棚卸しのコンサル案件 | `grill-the-client`（ヒアリング）、[REA](https://github.com/morluto/rea) + DB MCP（棚卸し）、`inventory-gaps`（補完）、`characterization-tests`（挙動固定）、データ機密区分とローカル/クラウド分担ルール |
| [web-app](../../packs/web-app/) | Web アプリ開発 | `e2e-from-spec`（仕様 → Playwright 受入テスト）、画面を実際に見るルール |

自分のパックを作る：[docs/packs.md](../packs.md)。

## インストール

Node.js 22.19+ と最低一つのエージェント CLI が必要。spec-kit は [uv](https://docs.astral.sh/uv/) を使う（スクリプトが自動で入れる）。

```bash
npx skills add ryantsai1111-cpu/nice-kit --agent codex -g      # スキルだけ

git clone https://github.com/ryantsai1111-cpu/nice-kit && cd nice-kit
./scripts/install.sh                        # コアのみ
./scripts/install.sh -p legacy-consulting   # コア + パック
./scripts/install.sh --list-packs
.\scripts\install.ps1 -Packs web-app        # Windows
./scripts/doctor.sh
```

MCP は Claude Code / Codex / Gemini CLI で自動登録。他のエージェントには貼り付け用の設定片を表示する。[docs/mcp.md](../mcp.md) 参照。

## プロジェクト開始

```bash
./scripts/init.sh <名前>                          # コアのテンプレート
./scripts/init.sh <名前> -p legacy-consulting     # パックのルールとディレクトリを追加
./scripts/init.sh <名前> -p web-app -a codex,cursor
```

| 手順 | コア | legacy-consulting の追加 | web-app の追加 |
|---|---|---|---|
| 0 | AGENTS.md の `<>` を埋める | | |
| 1 | | `grill-the-client` ヒアリング → `.grill/` | |
| 2 | spec-kit：constitution → specify → clarify | | |
| 3 | | REA / DB MCP 棚卸し → `inventory-gaps` → 再ヒアリング | |
| 4 | spec-kit：plan → tasks | | |
| 5 | | `characterization-tests` で旧システムの挙動を記録 | `e2e-from-spec` で受入テストを書く（まず赤） |
| 6 | superpowers で実装 | characterization テスト通過が完了条件 | e2e が緑になれば完了 |
| 7 | `check.sh` 納品前チェック | | |

各パックの詳細はそれぞれの README と docs を参照。

## 法務・セキュリティ前提

legacy-consulting の REA は**所有または分析許可のある**ソフトウェアにのみ使える。詳細：[packs/legacy-consulting/docs/legal.md](../../packs/legacy-consulting/docs/legal.md)。

## ライセンス

MIT。上流ツールはそれぞれのライセンスに従う。
