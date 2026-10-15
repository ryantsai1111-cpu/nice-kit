# nice-kit 安裝腳本（Windows PowerShell）
# 用法：
#   .\scripts\install.ps1                        # 自動偵測 agent
#   .\scripts\install.ps1 -Agents claude-code,codex
#   .\scripts\install.ps1 -Agents '*' -SkipRea
param(
  [string[]]$Agents = @(),
  [switch]$SkipRea
)
$ErrorActionPreference = "Stop"
$KitDir  = Split-Path -Parent $PSScriptRoot
$KitRepo = "ryantsai1111-cpu/nice-kit"

function Say($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Have($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

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

Say "1/5 安裝 nice-kit skills"
npx -y skills add $KitRepo --skill '*' @agentArgs -g -y
Say "2/5 安裝 superpowers"
npx -y skills add obra/superpowers --skill '*' @agentArgs -g -y
Say "3/5 安裝 planning-with-files"
npx -y skills add OthmanAdi/planning-with-files --skill '*' @agentArgs -g -y

Say "4/5 安裝 spec-kit（specify CLI）"
if (-not (Have uv)) {
  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
  $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
}
uv tool install specify-cli

if (-not $SkipRea) { Say "5/5 註冊 REA（互動式）"; npx -y rea-agents@latest setup } else { Say "5/5 略過 REA" }

if ((Have claude) -and ($Agents -contains "claude-code")) {
  Say "（Claude Code 專屬）安裝 claude-mem"
  try { claude plugin marketplace add thedotmack/claude-mem | Out-Null } catch {}
  try { claude plugin install claude-mem | Out-Null } catch {}
}

Write-Host @"

完成。接下來：
  1. 重啟你的 agent
  2. 開新案：$KitDir\scripts\init.ps1 <案名> -Agents <agent>
  3. 檢查：bash $KitDir\scripts\doctor.sh（需 Git Bash / WSL）
"@
