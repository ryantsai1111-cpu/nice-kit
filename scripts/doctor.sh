#!/usr/bin/env bash
# 檢查 nice-kit 安裝狀態。不會改任何東西。
# 用法：./scripts/doctor.sh [-p pack,pack]   省略 -p 時檢查核心＋曾用 install.sh 裝過的 pack
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
FAIL=0; PACKS=""
while [ $# -gt 0 ]; do
  case "$1" in -p|--packs) PACKS="$2"; shift 2 ;; *) shift ;; esac
done
[ -n "$PACKS" ] || PACKS="$(installed_packs | paste -sd, -)"

echo "基礎"
if have node; then
  v="$(node -v)"; m="${v#v}"; m="${m%%.*}"
  [ "$m" -ge 22 ] && ok "node $v" || bad "node $v（需要 22.19+）"
else bad "node 未安裝"; fi
have uv      && ok "uv $(uv --version 2>/dev/null | head -1)" || bad "uv 未安裝（spec-kit 需要）"
have specify && ok "specify（spec-kit）" || bad "specify 未安裝：uv tool install specify-cli"
have gitleaks && ok "gitleaks" || warn "gitleaks 未安裝（check.sh 會跳過 secret 掃描）"

echo "Agent CLI（有裝的）"
found=0
for pair in claude:claude-code codex:codex cursor:cursor gemini:gemini-cli copilot:github-copilot opencode:opencode hermes:hermes-agent; do
  bin="${pair%%:*}"; id="${pair##*:}"
  have "$bin" && { ok "$id"; found=1; }
done
[ $found -eq 1 ] || warn "沒偵測到 agent CLI，skills 應在 ~/.config/agents/skills（universal）"

echo "核心 skills（全域）"
check_skill planning-with-files
sp=0
for d in ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.gemini/skills ~/.config/agents/skills ~/.agents/skills; do
  ls "$d" 2>/dev/null | grep -qi 'brainstorm\|superpowers' && { ok "superpowers → ${d/#$HOME/\~}"; sp=1; break; }
done
[ $sp -eq 1 ] || bad "superpowers 未安裝"

echo "核心 MCP"
mcp_registered context7   && ok "context7 已註冊"   || bad "context7 未註冊（重跑 install.sh，或見 docs/mcp.md）"
mcp_registered playwright && ok "playwright 已註冊" || bad "playwright 未註冊（重跑 install.sh，或見 docs/mcp.md）"

if have claude; then
  echo "Claude 專屬（可選）"
  claude plugin list 2>/dev/null | grep -qi 'claude-mem' && ok "claude-mem" || warn "claude-mem 未裝（其他 agent 不需要）"
fi

if [ -n "$PACKS" ]; then
  IFS=',' read -ra arr <<< "$PACKS"
  for p in "${arr[@]}"; do
    load_pack "$p" || { FAIL=1; continue; }
    echo "pack：$p"
    run_pack_hook "$p" doctor
  done
else
  echo "pack：無（./scripts/install.sh -p <pack> 加裝）"
fi

echo
[ "$FAIL" -eq 0 ] && echo "全部通過。" || { echo "有缺項，見上方 ✗。"; exit 1; }
