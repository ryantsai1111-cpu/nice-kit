# nice-kit 安裝腳本（Windows PowerShell）
# 用法：
#   .\scripts\install.ps1                              # 只裝核心，自動偵測 agent
#   .\scripts\install.ps1 -Packs legacy-consulting     # 核心 + 領域包
#   .\scripts\install.ps1 -Agents claude-code,codex -Packs legacy-consulting,web-app
#   .\scripts\install.ps1 -SkipRea
#   .\scripts\install.ps1 -ListPacks
param(
  [string[]]$Agents = @(),
  [string[]]$Packs  = @(),
  [switch]$SkipRea,
  [switch]$ListPacks
)
$ErrorActionPreference = "Stop"
$KitDir   = Split-Path -Parent $PSScriptRoot
$PacksDir = Join-Path $KitDir "packs"
$State    = Join-Path $env:USERPROFILE ".nice-kit"

function Say($m)  { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "  v $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  ! $m" -ForegroundColor Yellow }
function Have($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# pack.conf 是 KEY="value" 格式，這裡用正則讀
function Load-Pack($name) {
  $conf = Join-Path $PacksDir "$name\pack.conf"
  if (-not (Test-Path $conf)) { throw "找不到 pack：$name" }
  $h = @{ NAME=$name; DIR=(Join-Path $PacksDir $name); DESC=""; SKILL_REPOS="" }
  Get-Content $conf | Where-Object { $_ -match '^PACK_(\w+)=(.*)$' } | ForEach-Object {
    $h[$Matches[1]] = $Matches[2].Trim('"')
  }
  return $h
}
function List-Packs { Get-ChildItem $PacksDir -Directory | Where-Object { Test-Path (Join-Path $_.FullName "pack.conf") } | ForEach-Object { $_.Name } }

if ($ListPacks) { List-Packs | ForEach-Object { $p = Load-Pack $_; "  {0,-20} {1}" -f $_, $p.DESC }; exit 0 }

if (-not (Have node)) { Write-Error "缺少 node，請先安裝 Node.js 22.19+" }
$nodeMajor = [int](node -p 'process.versions.node.split(".")[0]')
if ($nodeMajor -lt 22) { Write-Error "Node.js 需要 22.19+，目前 $(node -v)" }

if ($Agents.Count -eq 0) {
  $map = @{ claude="claude-code"; codex="codex"; cursor="cursor"; gemini="gemini-cli"; copilot="github-copilot"; opencode="opencode"; hermes="hermes-agent" }
  $Agents = $map.Keys | Where-Object { Have $_ } | ForEach-Object { $map[$_] }
  if ($Agents.Count -eq 0) { Write-Host "沒偵測到 agent，改裝到 universal"; $Agents = @("universal") }
}
$agentArgs = $Agents | ForEach-Object { "--agent", $_ }
Say "目標 agent：$($Agents -join ',')"
$packObjs = $Packs | ForEach-Object { Load-Pack $_ }   # 先驗證名稱

function Add-Skills($src) { npx -y skills add $src --skill '*' @agentArgs -g -y }

function Register-Mcp($name, $cmd, [string[]]$cmdArgs) {
  if (($Agents -contains "claude-code") -and (Have claude)) {
    if (claude mcp get $name 2>$null) { Ok "claude: $name 已存在" } else { claude mcp add -s user $name -- $cmd @cmdArgs; Ok "claude: $name" }
  }
  if (($Agents -contains "codex") -and (Have codex)) {
    if (codex mcp get $name 2>$null) { Ok "codex: $name 已存在" } else { codex mcp add $name -- $cmd @cmdArgs; Ok "codex: $name" }
  }
  if (($Agents -contains "gemini-cli") -and (Have gemini)) {
    if ((gemini mcp list 2>$null) -match $name) { Ok "gemini: $name 已存在" } else { gemini mcp add $name $cmd @cmdArgs; Ok "gemini: $name" }
  }
  $others = $Agents | Where-Object { $_ -notin @("claude-code","codex","gemini-cli") }
  if ($others) {
    Warn "$($others -join ',') 請手動加入 MCP「$name」（設定檔位置見 docs/mcp.md）："
    $argJson = ($cmdArgs | ForEach-Object { '"' + $_ + '"' }) -join ","
    Write-Host "    {`"mcpServers`":{`"$name`":{`"command`":`"$cmd`",`"args`":[$argJson]}}}"
  }
}

# ══ 核心層 ══
Say "核心 1/5 superpowers";            Add-Skills obra/superpowers
Say "核心 2/5 planning-with-files";    Add-Skills OthmanAdi/planning-with-files
Say "核心 3/5 spec-kit（specify CLI）"
if (-not (Have uv)) {
  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
  $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
}
uv tool install specify-cli
Say "核心 4/5 MCP：Context7 ＋ Playwright"
Register-Mcp context7   npx @("-y","@upstash/context7-mcp")
Register-Mcp playwright npx @("-y","@playwright/mcp@latest")
Say "核心 5/5 gitleaks"
if (Have gitleaks) { Ok "gitleaks 已安裝" }
elseif (Have winget) { winget install -e --id Gitleaks.Gitleaks --accept-source-agreements --accept-package-agreements }
else { Warn "gitleaks 未安裝；check.sh 會跳過 secret 掃描。https://github.com/gitleaks/gitleaks#installing" }

if ((Have claude) -and ($Agents -contains "claude-code")) {
  Say "（Claude Code 專屬）claude-mem"
  try { claude plugin marketplace add thedotmack/claude-mem | Out-Null } catch {}
  try { claude plugin install claude-mem | Out-Null } catch {}
}

# ══ 領域包 ══
foreach ($p in $packObjs) {
  Say "pack：$($p.NAME) — $($p.DESC)"
  $skillsDir = Join-Path $p.DIR "skills"
  if (Test-Path $skillsDir) { Add-Skills $skillsDir }
  if ($p.SKILL_REPOS) { $p.SKILL_REPOS -split "," | ForEach-Object { Add-Skills $_.Trim() } }
  $hook = Join-Path $p.DIR "hooks\install.ps1"
  if (Test-Path $hook) { & $hook -SkipRea:$SkipRea }
  elseif (Test-Path (Join-Path $p.DIR "hooks\install.sh")) { Warn "此 pack 的安裝 hook 只有 bash 版，請在 Git Bash / WSL 執行：bash scripts/install.sh -p $($p.NAME)" }
  New-Item -ItemType Directory -Force -Path $State | Out-Null
  $f = Join-Path $State "packs"
  if (-not (Test-Path $f) -or -not ((Get-Content $f) -contains $p.NAME)) { Add-Content $f $p.NAME }
}

Write-Host @"

完成。接下來：
  1. 重啟你的 agent
  2. 開新案：$KitDir\scripts\init.ps1 <案名> [-Pack <pack>] [-Agents <agent>]
  3. 檢查：bash $KitDir\scripts\doctor.sh（需 Git Bash / WSL）
"@
