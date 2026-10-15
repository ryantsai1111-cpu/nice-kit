#!/usr/bin/env bash
# 檢查 nice-kit 安裝狀態。不會改任何東西。
set -uo pipefail

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; FAIL=1; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
FAIL=0

echo "基礎"
if have node; then
  v="$(node -v)"; m="${v#v}"; m="${m%%.*}"
  [ "$m" -ge 22 ] && ok "node $v" || bad "node $v（需要 22.19+）"
else bad "node 未安裝"; fi
have uv      && ok "uv $(uv --version 2>/dev/null | head -1)" || bad "uv 未安裝（spec-kit 需要）"
have specify && ok "specify（spec-kit）" || bad "specify 未安裝：uv tool install specify-cli"

echo "Agent CLI（有裝的）"
found=0
for pair in claude:claude-code codex:codex cursor:cursor gemini:gemini-cli copilot:github-copilot opencode:opencode hermes:hermes-agent; do
  bin="${pair%%:*}"; id="${pair##*:}"
  have "$bin" && { ok "$id"; found=1; }
done
[ $found -eq 1 ] || warn "沒偵測到 agent CLI，skills 應在 ~/.config/agents/skills（universal）"

echo "Skills（全域）"
check_skill() {
  local name="$1"; local hit=""
  for d in ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.gemini/skills ~/.copilot/skills \
           ~/.config/opencode/skills ~/.hermes/skills ~/.config/agents/skills ~/.agents/skills; do
    [ -e "$d/$name/SKILL.md" ] && hit="$hit ${d/#$HOME/~}"
  done
  [ -n "$hit" ] && ok "$name →$hit" || bad "$name 未安裝"
}
check_skill grill-the-client
check_skill inventory-gaps
check_skill planning-with-files
# superpowers 是一組 skill，抓其中一個代表
for d in ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.gemini/skills ~/.config/agents/skills ~/.agents/skills; do
  ls "$d" 2>/dev/null | grep -qi 'brainstorm\|superpowers' && { ok "superpowers → ${d/#$HOME/~}"; sp=1; break; }
done
[ "${sp:-0}" -eq 1 ] || bad "superpowers 未安裝"

echo "REA"
if npx -y rea-agents@latest --version >/dev/null 2>&1; then
  ok "rea-agents 可執行"
  for f in ~/.claude.json ~/.codex/config.toml ~/.cursor/mcp.json ~/.gemini/settings.json; do
    [ -f "$f" ] && grep -q 'rea' "$f" 2>/dev/null && ok "已註冊於 ${f/#$HOME/~}"
  done
else
  warn "rea-agents 無法執行（或尚未 setup）：npx rea-agents setup"
fi

echo "Claude 專屬（可選）"
if have claude; then
  claude plugin list 2>/dev/null | grep -qi 'claude-mem' && ok "claude-mem" || warn "claude-mem 未裝（其他 agent 不需要）"
fi

echo
[ "$FAIL" -eq 0 ] && echo "全部通過。" || { echo "有缺項，見上方 ✗。"; exit 1; }
