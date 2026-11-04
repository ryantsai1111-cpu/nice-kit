#!/usr/bin/env bash
# nice-kit 共用函式。被 install.sh / init.sh / doctor.sh / check.sh 以及各 pack 的 hook source。
# 不要直接執行。

KIT_DIR="${KIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
KIT_REPO="ryantsai1111-cpu/nice-kit"
KIT_STATE="${HOME}/.nice-kit"           # 記錄裝了哪些 pack
PACKS_DIR="${KIT_DIR}/packs"

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; FAIL=1; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ── agent 偵測 ───────────────────────────────────────────────
# 輸出逗號分隔的 skills-CLI 識別碼；沒偵測到任何 agent 時回傳 $1（預設 universal）
detect_agents() {
  local d=()
  have claude   && d+=(claude-code)
  have codex    && d+=(codex)
  have cursor   && d+=(cursor)
  have gemini   && d+=(gemini-cli)
  have copilot  && d+=(github-copilot)
  have opencode && d+=(opencode)
  have hermes   && d+=(hermes-agent)
  [ ${#d[@]} -gt 0 ] || d=("${1:-universal}")
  (IFS=,; echo "${d[*]}")
}

# 把 "a,b,c" 變成 --agent a --agent b --agent c（寫進全域陣列 AGENT_FLAGS）
build_agent_flags() {
  AGENT_FLAGS=()
  local a; IFS=',' read -ra _arr <<< "$1"
  for a in "${_arr[@]}"; do AGENT_FLAGS+=(--agent "$a"); done
}

agents_has() { [[ ",$1," == *",$2,"* ]]; }

# ── skills 安裝 ──────────────────────────────────────────────
# add_skills <source> [--skill name]   source 可為 owner/repo 或本機路徑
add_skills() {
  npx -y skills add "$1" --skill "${2:-*}" "${AGENT_FLAGS[@]}" -g -y
}

# ── MCP 註冊 ─────────────────────────────────────────────────
# register_mcp <agents> <name> <cmd> [args...]
# 會自動處理 Claude Code / Codex / Gemini CLI；其他 agent 印出 JSON 請使用者自己貼。
# 已註冊的不會重複加。
register_mcp() {
  local agents="$1" name="$2"; shift 2
  local cmd="$1"; shift
  local args=("$@")
  local printed=0

  if agents_has "$agents" claude-code && have claude; then
    if claude mcp get "$name" >/dev/null 2>&1; then ok "claude: $name 已存在"
    else claude mcp add -s user "$name" -- "$cmd" "${args[@]}" && ok "claude: $name"; fi
  fi
  if agents_has "$agents" codex && have codex; then
    if codex mcp get "$name" >/dev/null 2>&1; then ok "codex: $name 已存在"
    else codex mcp add "$name" -- "$cmd" "${args[@]}" && ok "codex: $name"; fi
  fi
  if agents_has "$agents" gemini-cli && have gemini; then
    if gemini mcp list 2>/dev/null | grep -q "^$name\b\|$name:"; then ok "gemini: $name 已存在"
    else gemini mcp add "$name" "$cmd" "${args[@]}" && ok "gemini: $name"; fi
  fi
  # 其他 agent：印一次設定片段
  local a
  IFS=',' read -ra _arr <<< "$agents"
  for a in "${_arr[@]}"; do
    case "$a" in claude-code|codex|gemini-cli) continue ;; esac
    [ $printed -eq 1 ] && continue
    printed=1
    warn "$a 請手動加入 MCP「$name」（設定檔位置見 docs/mcp.md）："
    printf '    {"mcpServers":{"%s":{"command":"%s","args":[%s]}}}\n' \
      "$name" "$cmd" "$(printf '"%s",' "${args[@]}" | sed 's/,$//')"
  done
}

# mcp_registered <name>：有任何 agent 設定檔裡出現就回 0
mcp_registered() {
  local f
  for f in ~/.claude.json ~/.codex/config.toml ~/.gemini/settings.json \
           ~/.cursor/mcp.json ~/.config/opencode/opencode.json ~/.hermes/config.yaml; do
    [ -f "$f" ] && grep -q "\"$1\"\|\[mcp_servers\.$1\]\|$1:" "$f" 2>/dev/null && return 0
  done
  return 1
}

# ── pack ─────────────────────────────────────────────────────
# load_pack <name>：source packs/<name>/pack.conf，變數前綴 PACK_
load_pack() {
  local conf="${PACKS_DIR}/$1/pack.conf"
  [ -f "$conf" ] || { echo "找不到 pack：$1（${PACKS_DIR} 裡有：$(list_packs | tr '\n' ' ')）"; return 1; }
  PACK_NAME="$1"; PACK_DIR="${PACKS_DIR}/$1"
  PACK_DESC=""; PACK_SKILL_REPOS=""; PACK_INIT_DIRS=""; PACK_GITIGNORE=""
  # shellcheck disable=SC1090
  . "$conf"
}

list_packs() {
  local d
  for d in "${PACKS_DIR}"/*/; do
    [ -f "$d/pack.conf" ] && basename "$d"
  done
}

record_pack()    { mkdir -p "$KIT_STATE"; grep -qx "$1" "$KIT_STATE/packs" 2>/dev/null || echo "$1" >> "$KIT_STATE/packs"; }
installed_packs(){ [ -f "$KIT_STATE/packs" ] && cat "$KIT_STATE/packs" || true; }

# run_pack_hook <pack> <hook> [args...]：若 packs/<pack>/hooks/<hook>.sh 存在就 source 執行
run_pack_hook() {
  local hook="${PACKS_DIR}/$1/hooks/$2.sh"; shift 2
  # shellcheck disable=SC1090
  [ -f "$hook" ] && . "$hook" "$@"
  return 0
}

# check_skill <name>：在所有已知 skills 目錄找 SKILL.md
check_skill() {
  local name="$1" hit="" d
  for d in ~/.claude/skills ~/.codex/skills ~/.cursor/skills ~/.gemini/skills ~/.copilot/skills \
           ~/.config/opencode/skills ~/.hermes/skills ~/.config/agents/skills ~/.agents/skills; do
    [ -e "$d/$name/SKILL.md" ] && hit="$hit ${d/#$HOME/\~}"
  done
  [ -n "$hit" ] && ok "$name →$hit" || bad "$name 未安裝"
}
