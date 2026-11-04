#!/usr/bin/env bash
# 開新案：建立專案目錄、跑 spec-kit init、放入 agent 設定檔，依 pack 附加領域規範
#
# 用法：
#   ./scripts/init.sh <案名> [-p pack] [-a claude-code,codex,cursor,...]
#
# -p 省略：只放核心範本（任何專案都適用）。
# -a 省略：自動偵測。spec-kit 的 --integration 名稱與 skills CLI 不同，這裡自動對照（表在 docs/agents.md）。
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

NAME="${1:-}"; shift || true
AGENTS=""; PACK=""
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agents) AGENTS="$2"; shift 2 ;;
    -p|--pack)   PACK="$2"; shift 2 ;;
    *) echo "未知參數 $1"; exit 1 ;;
  esac
done
[ -n "$NAME" ] || { echo "用法：init.sh <案名> [-p pack] [-a agents]"; exit 1; }
have specify || { echo "缺少 specify，請先跑 scripts/install.sh"; exit 1; }
[ -z "$PACK" ] || load_pack "$PACK"

[ -n "$AGENTS" ] || AGENTS="$(detect_agents claude-code)"

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

echo "==> 放入 nice-kit 核心範本"
cp "$KIT_DIR/templates/AGENTS.md" .
cp "$KIT_DIR/templates/CLAUDE.md" .
cp "$KIT_DIR/templates/GEMINI.md" .
cp "$KIT_DIR/templates/PROGRESS.md" .
mkdir -p .cursor/rules && cp "$KIT_DIR/templates/.cursor/rules/nice-kit.mdc" .cursor/rules/
[ -d .git ] || git init -q
printf '.env\n.env.*\n' >> .gitignore

if [ -n "$PACK" ]; then
  echo "==> 附加 pack：$PACK"
  # 領域規範接在 AGENTS.md 後面；其他 pack 範本直接複製
  if [ -f "$PACK_DIR/templates/AGENTS.pack.md" ]; then
    { echo; cat "$PACK_DIR/templates/AGENTS.pack.md"; } >> AGENTS.md
  fi
  if [ -d "$PACK_DIR/templates" ]; then
    find "$PACK_DIR/templates" -type f ! -name 'AGENTS.pack.md' -print0 \
      | while IFS= read -r -d '' f; do
          rel="${f#"$PACK_DIR"/templates/}"; mkdir -p "$(dirname "$rel")"; cp "$f" "$rel"
        done
  fi
  if [ -n "$PACK_INIT_DIRS" ]; then
    IFS=',' read -ra dirs <<< "$PACK_INIT_DIRS"; mkdir -p "${dirs[@]}"
  fi
  if [ -n "$PACK_GITIGNORE" ]; then
    IFS=',' read -ra ign <<< "$PACK_GITIGNORE"; printf '%s\n' "${ign[@]}" >> .gitignore
  fi
  printf 'pack: %s\n' "$PACK" > .nice-kit
  run_pack_hook "$PACK" init
else
  printf 'pack: none\n' > .nice-kit
fi

cat <<EOF

專案 $NAME 已建立。agent：$AGENTS${PACK:+，pack：$PACK}
  1. 填 AGENTS.md 裡的 <>（只填知道的）
  2. 用你的 agent 開啟這個目錄
  3. 從 spec-kit 的 constitution 開始${PACK:+；pack 的流程見 ${KIT_DIR}/packs/$PACK/README.md}
EOF
