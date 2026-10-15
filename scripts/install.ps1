# enterprise-ai-kit 安裝腳本（Windows PowerShell）
$ErrorActionPreference = "Stop"

$KitDir    = Split-Path -Parent $PSScriptRoot
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

function Say($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Need($cmd) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Error "缺少 $cmd，請先安裝。"; exit 1
  }
}

Need node; Need npx; Need claude

$nodeMajor = [int](node -p 'process.versions.node.split(".")[0]')
if ($nodeMajor -lt 22) { Write-Error "Node.js 需要 22.19+ 或 24.11+，目前是 $(node -v)"; exit 1 }

Say "1/4 安裝 superpowers 與 spec-kit skills"
npx -y skills add obra/superpowers --agent claude-code
npx -y skills add github/spec-kit --agent claude-code

Say "2/4 安裝 claude-mem plugin"
try { claude plugin marketplace add thedotmack/claude-mem } catch {}
try { claude plugin install claude-mem } catch {}

Say "3/4 註冊 REA（互動式：選擇 agent 後確認變更）"
npx -y rea-agents@latest setup

Say "4/4 複製本 repo 的 skills 到 $SkillsDir"
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
Get-ChildItem (Join-Path $KitDir "skills") -Directory | ForEach-Object {
  $dest = Join-Path $SkillsDir $_.Name
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  Copy-Item $_.FullName $dest -Recurse
  Write-Host "  + $($_.Name)"
}

Write-Host @"

完成。接下來：
  1. 重啟 Claude Code
  2. 在新專案根目錄放 templates\CLAUDE.md
  3. 執行 /grill-the-client 開始第一輪訪談

資料庫 MCP 請依客戶環境另行設定，見 docs\db-mcp.md
"@
