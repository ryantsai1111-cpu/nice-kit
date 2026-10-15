#!/usr/bin/env bash
# 開新案：建立專案目錄、跑 spec-kit init、放入 agent 設定檔
#
# 用法：
#   ./scripts/init.sh <案名> [-a claude-code,codex,cursor,...]
#
# -a 省略時會自動偵測。spec-kit 的 --integration 名稱與 skills CLI 不同，
# 這裡自動對照（表在 docs/agents.md）。
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"; shift || true
AGENTS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agents) AGENTS="$2"; shift 2 ;;
    *) echo "未知參數 $1"; exit 1 ;;
  esac
done
[ -n "$NAME" ] || { echo "用法：init.sh <案名> [-a agents]"; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
have specify || { echo "缺少 specify，請先跑 scripts/install.sh"; exit 1; }

if [ -z "$AGENTS" ]; then
  d=()
  have claude && d+=(claude-code); have codex && d+=(codex); have cursor && d+=(cursor)
  have gemini && d+=(gemini-cli); have copilot && d+=(github-copilot); have opencode && d+=(opencode)
  [ ${#d[@]} -gt 0 ] || d=(claude-code)
  AGENTS="$(IFS=,; echo "${d[*]}")"
fi

# skills CLI 名稱 → spec-kit --integration 名稱
to_speckit() {
  case "$1" in
    claude-code)    echo claude ;;
    codex)          echo codex ;;
    cursor)         echo cursor-agent ;;
    gemini-cli)     echo gemini ;;
    github-copilot) echo copilot ;;
    opencode)       echo opencode ;;
    windsurf)       echo windsurf ;;
    roo)            echo roo ;;
    kilo)           echo kilocode ;;
    qwen-code)      echo qwen ;;
    amp)            echo amp ;;
    codebuddy)      echo codebuddy ;;
    *)              echo "" ;;
  esac
}

IFS=',' read -ra arr <<< "$AGENTS"
first_sk="$(to_speckit "${arr[0]}")"
[ -n "$first_sk" ] || { echo "spec-kit 不支援 ${arr[0]}，請改用 -a 指定一個支援的 agent 當主要 agent"; exit 1; }

echo "==> specify init $NAME --integration $first_sk"
specify init "$NAME" --integration "$first_sk" --ignore-agent-tools
cd "$NAME"

# 其他 agent 的 spec-kit 指令（spec-kit 一次只接一個 integration，重跑 init --here 補齊）
for a in "${arr[@]:1}"; do
  sk="$(to_speckit "$a")"
  [ -n "$sk" ] || { echo "   略過 $a（spec-kit 不支援，skills 仍可用）"; continue; }
  echo "==> 補 $sk 的 spec-kit 指令"
  specify init --here --integration "$sk" --ignore-agent-tools --force >/dev/null 2>&1 || true
done

echo "==> 放入 nice-kit 範本"
cp "$KIT_DIR/templates/AGENTS.md" .
cp "$KIT_DIR/templates/CLAUDE.md" .
cp "$KIT_DIR/templates/GEMINI.md" .
cp "$KIT_DIR/templates/PROGRESS.md" .
mkdir -p .cursor/rules && cp "$KIT_DIR/templates/.cursor/rules/nice-kit.mdc" .cursor/rules/
mkdir -p .grill inventory
[ -d .git ] || git init -q
printf '.grill/\ninventory/\n.env\n' >> .gitignore

cat <<EOF

專案 $NAME 已建立。agent：$AGENTS
  1. 填 AGENTS.md 裡的 <>（只填知道的）
  2. 用你的 agent 開啟這個目錄
  3. 載入 grill-the-client skill 開始第一輪訪談
EOF
