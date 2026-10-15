#!/usr/bin/env bash
# nice-kit 安裝腳本（macOS / Linux）
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "缺少 $1，請先安裝。"; exit 1; }; }

need node
need npx
need claude

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "Node.js 需要 22.19+ 或 24.11+，目前是 $(node -v)"; exit 1
fi

say "1/4 安裝 superpowers 與 spec-kit"
npx -y skills add obra/superpowers --agent claude-code
if ! command -v uv >/dev/null 2>&1; then
  echo "  安裝 uv（spec-kit 需要）"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi
uv tool install specify-cli

say "2/4 安裝 claude-mem plugin"
claude plugin marketplace add thedotmack/claude-mem || true
claude plugin install claude-mem || true

say "3/4 註冊 REA（互動式：選擇 agent 後確認變更）"
npx -y rea-agents@latest setup

say "4/4 複製本 repo 的 skills 到 ${SKILLS_DIR}"
mkdir -p "${SKILLS_DIR}"
for s in "${KIT_DIR}"/skills/*/; do
  name="$(basename "$s")"
  rm -rf "${SKILLS_DIR:?}/${name}"
  cp -R "$s" "${SKILLS_DIR}/${name}"
  echo "  + ${name}"
done

cat <<'EOF'

完成。接下來：
  1. 重啟 Claude Code
  2. 新專案：specify init <案名> --integration claude，再放 templates/CLAUDE.md
  3. 執行 /grill-the-client 開始第一輪訪談

資料庫 MCP 請依客戶環境另行設定，見 docs/db-mcp.md
EOF
