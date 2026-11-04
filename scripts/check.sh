#!/usr/bin/env bash
# 交付前檢查。在專案目錄裡跑：~/nice-kit/scripts/check.sh
# 三件事：沒有 secret 進 repo、測試有過、PROGRESS.md 有跟著更新。
# 任一項失敗就 exit 1，可以放進 pre-push hook 或 CI。
set -uo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
FAIL=0

[ -d .git ] || { echo "不在 git 專案裡"; exit 1; }

echo "1. secret 掃描"
if have gitleaks; then
  if gitleaks detect --source . --no-banner --redact >/dev/null 2>&1; then ok "gitleaks：乾淨"
  else bad "gitleaks 找到疑似 secret，跑 gitleaks detect --source . --verbose 看細節"; fi
else
  warn "gitleaks 未安裝，跳過（install.sh 會裝；或 https://github.com/gitleaks/gitleaks#installing）"
fi
# 不管有沒有 gitleaks，.env 都不該被 track
if git ls-files --error-unmatch .env >/dev/null 2>&1; then bad ".env 被 git 追蹤了"; fi

echo "2. 測試"
ran=0
if   [ -f package.json ] && node -e 'process.exit(require("./package.json").scripts?.test?0:1)' 2>/dev/null; then
  ran=1; npm test --silent >/dev/null 2>&1 && ok "npm test" || bad "npm test 失敗"
elif [ -f pyproject.toml ] || [ -f pytest.ini ] || ls tests/*.py test_*.py >/dev/null 2>&1; then
  ran=1; (have pytest || have uv) || warn "找不到 pytest"
  (pytest -q >/dev/null 2>&1 || uv run pytest -q >/dev/null 2>&1) && ok "pytest" || bad "pytest 失敗"
elif [ -f go.mod ];     then ran=1; go test ./... >/dev/null 2>&1 && ok "go test" || bad "go test 失敗"
elif [ -f Cargo.toml ]; then ran=1; cargo test -q >/dev/null 2>&1 && ok "cargo test" || bad "cargo test 失敗"
fi
[ $ran -eq 1 ] || warn "沒偵測到測試指令（package.json scripts.test / pytest / go / cargo）"
# 有 e2e 目錄就也跑 playwright（web-app pack）
if [ -d e2e ] && [ -f package.json ] && ls node_modules/.bin/playwright >/dev/null 2>&1; then
  npx playwright test >/dev/null 2>&1 && ok "playwright e2e" || bad "playwright e2e 失敗"
fi

echo "3. PROGRESS.md"
if [ ! -f PROGRESS.md ]; then bad "沒有 PROGRESS.md"
elif grep -q '^<' PROGRESS.md; then bad "PROGRESS.md 還有沒填的 <> 範本"
else
  # 有程式碼變動但 PROGRESS.md 沒動：提醒
  if [ -n "$(git status --porcelain -- . ':!PROGRESS.md' 2>/dev/null)" ] && [ -z "$(git status --porcelain PROGRESS.md)" ]; then
    warn "工作目錄有改動，但 PROGRESS.md 沒更新"
  else
    ok "PROGRESS.md"
  fi
fi

echo
[ "$FAIL" -eq 0 ] && echo "可以交付。" || { echo "先修上面的 ✗。"; exit 1; }
