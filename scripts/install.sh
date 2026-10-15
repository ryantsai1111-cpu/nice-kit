#!/usr/bin/env bash
# nice-kit 安裝腳本（macOS / Linux）
#
# 用法：
#   ./scripts/install.sh                       # 自動偵測已安裝的 agent
#   ./scripts/install.sh -a claude-code,codex  # 指定 agent（逗號分隔）
#   ./scripts/install.sh -a '*'                # 全部 agent
#   ./scripts/install.sh --skip-rea            # 不跑 REA setup
#
# agent 識別碼見 docs/agents.md（claude-code, codex, cursor, gemini-cli,
# github-copilot, opencode, windsurf, hermes-agent, universal ...）
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIT_REPO="ryantsai1111-cpu/nice-kit"
AGENTS=""
SKIP_REA=0

while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agents) AGENTS="$2"; shift 2 ;;
    --skip-rea)  SKIP_REA=1; shift ;;
    -h|--help)   sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "未知參數 $1"; exit 1 ;;
  esac
done

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

have node || { echo "缺少 node，請先安裝 Node.js 22.19+"; exit 1; }
have npx  || { echo "缺少 npx"; exit 1; }
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || { echo "Node.js 需要 22.19+ 或 24.11+，目前 $(node -v)"; exit 1; }

# ── 偵測 agent ────────────────────────────────────────────────
if [ -z "$AGENTS" ]; then
  detected=()
  have claude  && detected+=(claude-code)
  have codex   && detected+=(codex)
  have cursor  && detected+=(cursor)
  have gemini  && detected+=(gemini-cli)
  have copilot && detected+=(github-copilot)
  have opencode && detected+=(opencode)
  have hermes  && detected+=(hermes-agent)
  if [ ${#detected[@]} -eq 0 ]; then
    echo "沒偵測到任何 agent CLI，改裝到 universal（.agents/skills，多數 agent 共用）"
    detected=(universal)
  fi
  AGENTS="$(IFS=,; echo "${detected[*]}")"
fi
AGENT_FLAGS=()
IFS=',' read -ra arr <<< "$AGENTS"
for a in "${arr[@]}"; do AGENT_FLAGS+=(--agent "$a"); done
say "目標 agent：$AGENTS"

# ── 1. skills（全域安裝）────────────────────────────────────────
say "1/5 安裝 nice-kit 自己的 skills（grill-the-client、inventory-gaps）"
npx -y skills add "$KIT_REPO" --skill '*' "${AGENT_FLAGS[@]}" -g -y

say "2/5 安裝 superpowers（實作紀律）"
npx -y skills add obra/superpowers --skill '*' "${AGENT_FLAGS[@]}" -g -y

say "3/5 安裝 planning-with-files（跨 session 記憶，所有 agent 通用）"
npx -y skills add OthmanAdi/planning-with-files --skill '*' "${AGENT_FLAGS[@]}" -g -y

# ── 2. spec-kit CLI ───────────────────────────────────────────
say "4/5 安裝 spec-kit（specify CLI，每案 init 時產生各 agent 的指令）"
if ! have uv; then
  echo "  安裝 uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi
uv tool install specify-cli

# ── 3. REA ────────────────────────────────────────────────────
if [ "$SKIP_REA" -eq 0 ]; then
  say "5/5 註冊 REA（互動式，它自己會列出支援的 agent 讓你勾）"
  npx -y rea-agents@latest setup
else
  say "5/5 略過 REA"
fi

# ── Claude 專屬加值（有裝才做）────────────────────────────────
if have claude && [[ ",$AGENTS," == *",claude-code,"* ]]; then
  say "（Claude Code 專屬）安裝 claude-mem 自動記憶"
  claude plugin marketplace add thedotmack/claude-mem >/dev/null 2>&1 || true
  claude plugin install claude-mem >/dev/null 2>&1 || true
fi

cat <<EOF

完成。接下來：
  1. 重啟你的 agent
  2. 開新案：${KIT_DIR}/scripts/init.sh <案名> -a <agent>
  3. 檢查：${KIT_DIR}/scripts/doctor.sh

資料庫 MCP 請依客戶環境另行設定，見 docs/db-mcp.md
EOF
