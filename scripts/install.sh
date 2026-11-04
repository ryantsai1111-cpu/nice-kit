#!/usr/bin/env bash
# nice-kit 安裝腳本（macOS / Linux）
#
# 用法：
#   ./scripts/install.sh                          # 只裝核心，自動偵測已安裝的 agent
#   ./scripts/install.sh -p legacy-consulting     # 核心 + 一個領域包
#   ./scripts/install.sh -p legacy-consulting,web-app
#   ./scripts/install.sh -a claude-code,codex     # 指定 agent（逗號分隔）
#   ./scripts/install.sh -a '*'                   # 全部 agent
#   ./scripts/install.sh --skip-rea               # legacy-consulting 不跑 REA setup
#   ./scripts/install.sh --list-packs             # 列出可用的 pack
#
# agent 識別碼見 docs/agents.md。pack 的寫法見 docs/packs.md。
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

AGENTS=""; PACKS=""; SKIP_REA=0
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agents) AGENTS="$2"; shift 2 ;;
    -p|--packs)  PACKS="$2"; shift 2 ;;
    --skip-rea)  SKIP_REA=1; shift ;;
    --list-packs)
      for p in $(list_packs); do load_pack "$p"; printf '  %-20s %s\n' "$p" "$PACK_DESC"; done; exit 0 ;;
    -h|--help)   sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "未知參數 $1"; exit 1 ;;
  esac
done
export SKIP_REA

have node || { echo "缺少 node，請先安裝 Node.js 22.19+"; exit 1; }
have npx  || { echo "缺少 npx"; exit 1; }
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || { echo "Node.js 需要 22.19+ 或 24.11+，目前 $(node -v)"; exit 1; }

[ -n "$AGENTS" ] || AGENTS="$(detect_agents universal)"
build_agent_flags "$AGENTS"
say "目標 agent：$AGENTS"

# 先驗證 pack 名稱，不要裝到一半才發現打錯
if [ -n "$PACKS" ]; then
  IFS=',' read -ra PACK_ARR <<< "$PACKS"
  for p in "${PACK_ARR[@]}"; do load_pack "$p" >/dev/null; done
fi

# ══ 核心層 ═══════════════════════════════════════════════════
say "核心 1/5 superpowers（實作紀律）"
add_skills obra/superpowers

say "核心 2/5 planning-with-files（跨 session 記憶，所有 agent 通用）"
add_skills OthmanAdi/planning-with-files

say "核心 3/5 spec-kit（specify CLI，每案 init 時產生各 agent 的指令）"
if ! have uv; then
  echo "  安裝 uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
fi
uv tool install specify-cli

say "核心 4/5 MCP：Context7（函式庫文件）＋ Playwright（瀏覽器）"
register_mcp "$AGENTS" context7   npx -y @upstash/context7-mcp
register_mcp "$AGENTS" playwright npx -y @playwright/mcp@latest

say "核心 5/5 gitleaks（交付前掃 secret，check.sh 用）"
if have gitleaks; then ok "gitleaks 已安裝"
elif have brew; then brew install gitleaks
else warn "gitleaks 未安裝；check.sh 會跳過 secret 掃描。安裝方式：https://github.com/gitleaks/gitleaks#installing"; fi

if agents_has "$AGENTS" claude-code && have claude; then
  say "（Claude Code 專屬）claude-mem 自動記憶"
  claude plugin marketplace add thedotmack/claude-mem >/dev/null 2>&1 || true
  claude plugin install claude-mem >/dev/null 2>&1 || true
fi

# ══ 領域包 ═══════════════════════════════════════════════════
if [ -n "$PACKS" ]; then
  for p in "${PACK_ARR[@]}"; do
    load_pack "$p"
    say "pack：$p — $PACK_DESC"
    if [ -d "$PACK_DIR/skills" ] && ls "$PACK_DIR"/skills/*/SKILL.md >/dev/null 2>&1; then
      add_skills "$PACK_DIR/skills"
    fi
    if [ -n "$PACK_SKILL_REPOS" ]; then
      IFS=',' read -ra repos <<< "$PACK_SKILL_REPOS"
      for r in "${repos[@]}"; do add_skills "$r"; done
    fi
    run_pack_hook "$p" install
    record_pack "$p"
  done
fi

cat <<EOF

完成。接下來：
  1. 重啟你的 agent
  2. 開新案：${KIT_DIR}/scripts/init.sh <案名> [-p <pack>] [-a <agent>]
  3. 檢查：${KIT_DIR}/scripts/doctor.sh
EOF
[ -n "$PACKS" ] || echo "  （之後要加領域包：./scripts/install.sh -p <pack>，--list-packs 看有哪些）"
